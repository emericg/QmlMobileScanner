/*!
 * Copyright (c) 2017 Ekkehard Gentz (ekke)
 * Copyright (c) 2026 Emeric Grange
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#import "MobileSharing_ios.h"

#import <UIKit/UIKit.h>
#import <QuickLook/QuickLook.h>
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>

#import <QGuiApplication>
#import <QDesktopServices>
#import <QFileInfo>
#import <QUrl>

/* ************************************************************************** */

// Resolve the view controller to present from.
// Prefers the foreground-active window scene's key window, and falls back to
// any window scene if none is active yet. Returns nil if there is none.
static UIViewController *topViewController()
{
    UIWindow *fallbackWindow = nil;

    for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
        if (![scene isKindOfClass:[UIWindowScene class]]) continue;
        UIWindowScene *windowScene = (UIWindowScene *)scene;

        UIWindow *keyWindow = nil;
        for (UIWindow *w in windowScene.windows) {
            if (w.isKeyWindow) { keyWindow = w; break; }
        }
        if (keyWindow == nil) keyWindow = windowScene.windows.firstObject;
        if (keyWindow == nil) continue;

        if (scene.activationState == UISceneActivationStateForegroundActive) {
            return keyWindow.rootViewController; // best match
        }
        if (fallbackWindow == nil) fallbackWindow = keyWindow;
    }

    return fallbackWindow.rootViewController;
}

/* ************************************************************************** */

// Delegate for the "save file to..." export picker
@interface DocExportDelegate : NSObject <UIDocumentPickerDelegate>
@property (nonatomic) int requestId;
@property (nonatomic) IosShareUtils *mIosShareUtils;
@property (nonatomic, retain) NSURL *stagingDir; // temp dir to remove afterwards, or nil
@end

@implementation DocExportDelegate

- (void)cleanup {
    if (self.stagingDir) {
        [[NSFileManager defaultManager] removeItemAtURL:self.stagingDir error:nil];
        self.stagingDir = nil;
    }
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
#pragma unused (controller, urls)
    if (self.mIosShareUtils) self.mIosShareUtils->handleSaveResult(self.requestId, true, false);
    [self cleanup];
    [self release];
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
#pragma unused (controller)
    if (self.mIosShareUtils) self.mIosShareUtils->handleSaveResult(self.requestId, false, true);
    [self cleanup];
    [self release];
}

- (void)dealloc {
    [_stagingDir release];
    [super dealloc];
}

@end

/* ************************************************************************** */

// Delegate for the "open file" import picker
@interface DocImportDelegate : NSObject <UIDocumentPickerDelegate>
@property (nonatomic) IosShareUtils *mIosShareUtils;
@end

@implementation DocImportDelegate

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
#pragma unused (controller)
    NSURL *picked = urls.firstObject;
    if (self.mIosShareUtils && picked) {
        self.mIosShareUtils->handleImportedFile(QString::fromNSString(picked.path));
    }
    [self release];
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
#pragma unused (controller)
    [self release];
}

@end

/* ************************************************************************** */

// Data source + delegate for the in-app file viewer (QLPreviewController). Same MRC
// self-ownership as the picker delegates: alive from creation until the preview is
// dismissed, then it releases itself. NSURL already conforms to <QLPreviewItem>.
@interface QLPreviewHelper : NSObject <QLPreviewControllerDataSource, QLPreviewControllerDelegate>
@property (nonatomic) int requestId;
@property (nonatomic) IosShareUtils *mIosShareUtils;
@property (nonatomic, retain) NSURL *fileUrl;
@end

@implementation QLPreviewHelper

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
#pragma unused (controller)
    return self.fileUrl ? 1 : 0;
}

- (id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index {
#pragma unused (controller, index)
    return self.fileUrl;
}

- (void)previewControllerDidDismiss:(QLPreviewController *)controller {
#pragma unused (controller)
    if (self.mIosShareUtils) self.mIosShareUtils->handlePreviewDismissed(self.requestId);
    [self release];
}

- (void)dealloc {
    [_fileUrl release];
    [super dealloc];
}

@end

/* ************************************************************************** */

IosShareUtils::IosShareUtils(QObject *parent) : PlatformShareUtils(parent)
{
    // the iOS "receive a file" entry point // analogous to the Android QShareActivity.processIntent() > setFileReceived() path
    // important note: hijack QDesktopServices::openUrl("file://") though you can't really do that on iOS anyway...
    QDesktopServices::setUrlHandler("file", this, "handleFileUrlReceived");
}

/* ************************************************************************** */

bool IosShareUtils::checkMimeTypeView(const QString &mimeType) {
#pragma unused (mimeType)
    // MimeType not used yet
    return true;
}

/* ************************************************************************** */

void IosShareUtils::sendText(const QString &text, const QString &subject, const QUrl &url) {

    NSMutableArray *sharingItems = [NSMutableArray new];

    if (!text.isEmpty()) {
        [sharingItems addObject:text.toNSString()];
    }
    if (url.isValid()) {
        [sharingItems addObject:url.toNSURL()];
    }

    UIViewController *qtUIViewController = topViewController();

    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
    if (qtUIViewController == nil) {
        Q_EMIT shareError(0, "Cannot share: no root view controller");
        [activityController release];
        return;
    }

    // Report the outcome once the sheet closes
    activityController.completionWithItemsHandler = ^(UIActivityType activityType, BOOL completed,
                                                      NSArray *returnedItems, NSError *activityError) {
#pragma unused (activityType, returnedItems)
        if (activityError) {
            Q_EMIT shareError(0, QString::fromNSString(activityError.localizedDescription));
        } else if (completed) {
            Q_EMIT shareFinished(0);
        } else {
            // dismissed without sharing -> stay silent
        }
    };

    // iPad: anchor the popover (harmless on iPhone, where it presents as a sheet).
    activityController.popoverPresentationController.sourceView = qtUIViewController.view;
    activityController.popoverPresentationController.sourceRect = CGRectMake(qtUIViewController.view.bounds.size.width / 2.0,
                                                                            qtUIViewController.view.bounds.size.height / 2.0, 0, 0);

    [qtUIViewController presentViewController:activityController animated:YES completion:nil];
    [activityController release];
}

void IosShareUtils::sendFile(const QString &filePath, const QString &title, const QString &mimeType, int requestId, bool move) {
#pragma unused (title, mimeType, move)
    // 'move' is a no-op on iOS: any file in the app sandbox is shareable as-is (no FileProvider
    // equivalent). Throwaway-file cleanup is left to the app (e.g. delete after shareFinished).
    // We present the system share sheet (UIActivityViewController), which offers AirDrop,
    // "Save to Files", "Copy to <app>", etc. - a superset of the old Quick Look preview.

    NSURL *fileUrl = [NSURL fileURLWithPath:filePath.toNSString()];

    UIViewController *qtUIViewController = topViewController();
    UIActivityViewController *activityController =
        [[UIActivityViewController alloc] initWithActivityItems:@[fileUrl] applicationActivities:nil];
    if (qtUIViewController == nil) {
        Q_EMIT shareError(requestId, "Cannot share: no root view controller");
        [activityController release];
        return;
    }

    // Report the outcome once the sheet closes.
    activityController.completionWithItemsHandler = ^(UIActivityType activityType, BOOL completed,
                                                      NSArray *returnedItems, NSError *activityError) {
#pragma unused (activityType, returnedItems)
        if (activityError) {
            Q_EMIT shareError(requestId, QString::fromNSString(activityError.localizedDescription));
        } else if (completed) {
            Q_EMIT shareFinished(requestId);
        }
        // dismissed without sharing -> stay silent
    };

    // iPad: anchor the popover (harmless on iPhone, where it presents as a sheet).
    activityController.popoverPresentationController.sourceView = qtUIViewController.view;
    activityController.popoverPresentationController.sourceRect = CGRectMake(qtUIViewController.view.bounds.size.width / 2.0,
                                                                            qtUIViewController.view.bounds.size.height / 2.0, 0, 0);

    [qtUIViewController presentViewController:activityController animated:YES completion:nil];
    [activityController release];
}

void IosShareUtils::viewFile(const QString &filePath, const QString &title, const QString &mimeType, int requestId) {
#pragma unused (title, mimeType)
    // In-app file preview via QuickLook.
    // Unsupported types still present (QLPreviewController shows a placeholder with its own share button), so no fallback is needed here.

    NSString *path = filePath.toNSString();
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        Q_EMIT shareError(requestId, QString("Cannot view file: %1").arg(filePath));
        return;
    }

    UIViewController *root = topViewController();
    if (root == nil) {
        Q_EMIT shareError(requestId, "Cannot view file: no root view controller");
        return;
    }

    QLPreviewController *preview = [[QLPreviewController alloc] init];

    QLPreviewHelper *helper = [[QLPreviewHelper alloc] init];
    helper.requestId = requestId;
    helper.mIosShareUtils = this;
    helper.fileUrl = [NSURL fileURLWithPath:path]; // retained by the property
    preview.dataSource = helper; // weak; helper keeps itself alive until dismiss
    preview.delegate = helper; // weak

    [root presentViewController:preview animated:YES completion:nil];
    [preview release];
}

void IosShareUtils::saveFile(const QString &filePath, const QString &suggestedName, const QString &mimeType, int requestId) {
#pragma unused (mimeType)

    NSString *srcPath = filePath.toNSString();
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:srcPath]) {
        Q_EMIT shareError(requestId, QString("Cannot save file: %1").arg(filePath));
        return;
    }

    // The iOS export picker keeps the source file's own name.
    // If a different name is requested, stage a copy under that name in a temp dir and export that instead.
    NSURL *exportUrl = [NSURL fileURLWithPath:srcPath];
    NSURL *stagingDir = nil;
    if (!suggestedName.isEmpty() && suggestedName != QFileInfo(filePath).fileName()) {
        NSString *dirPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[@"MobileSharingExport-" stringByAppendingString:[[NSUUID UUID] UUIDString]]];
        if ([fm createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil]) {
            NSString *stagedPath = [dirPath stringByAppendingPathComponent:suggestedName.toNSString()];
            if ([fm copyItemAtPath:srcPath toPath:stagedPath error:nil]) {
                exportUrl = [NSURL fileURLWithPath:stagedPath];
                stagingDir = [NSURL fileURLWithPath:dirPath];
            }
        }
    }

    // asCopy:YES leaves our (session-wiped) source in place; iOS exports a duplicate.
    UIDocumentPickerViewController *picker = [[UIDocumentPickerViewController alloc] initForExportingURLs:@[exportUrl] asCopy:YES];

    DocExportDelegate *delegate = [[DocExportDelegate alloc] init];
    delegate.requestId = requestId;
    delegate.mIosShareUtils = this;
    delegate.stagingDir = stagingDir; // retained by the property
    picker.delegate = delegate; // assign; the delegate keeps itself alive until its callback

    UIViewController *root = topViewController();
    if (root != nil) {
        [root presentViewController:picker animated:YES completion:nil];
    } else {
        Q_EMIT shareError(requestId, "Cannot save file: no root view controller");
        [delegate cleanup];
        [delegate release];
    }
    [picker release];
}

void IosShareUtils::openFile() {
    // asCopy:YES makes iOS copy the picked file into our own container and hand back a readable URL,
    // sidestepping the security-scoped File Provider URL that Qt's FileDialog returns (which QFile cannot read).
    UIDocumentPickerViewController *picker = [[UIDocumentPickerViewController alloc] initForOpeningContentTypes:@[UTTypeItem] asCopy:YES];

    DocImportDelegate *delegate = [[DocImportDelegate alloc] init];
    delegate.mIosShareUtils = this;
    picker.delegate = delegate; // assign; the delegate keeps itself alive until its callback

    UIViewController *root = topViewController();
    if (root != nil) {
        [root presentViewController:picker animated:YES completion:nil];
    } else {
        Q_EMIT shareError(0, "Cannot open file: no root view controller");
        [delegate release];
    }
    [picker release];
}

void IosShareUtils::handleImportedFile(const QString &filePath) {
    // The copy lives in our sandbox temp; emit it like any incoming file.
    // MobileSharing::onFileReceived() then relocates it into the cache's MobileSharing/incoming/ dir.
    QFileInfo fi(filePath);
    if (fi.exists() && fi.isFile()) {
        Q_EMIT fileReceived(filePath);
    } else {
        Q_EMIT shareError(0, QString("Open: imported file is not readable: %1").arg(filePath));
    }
}

void IosShareUtils::handleSaveResult(int requestId, bool success, bool canceled) {
    if (success) {
        Q_EMIT fileSaved(requestId);
    } else if (canceled) {
        Q_EMIT shareFinished(requestId);
    } else {
        Q_EMIT shareError(requestId, "Save: could not export the file");
    }
}

void IosShareUtils::handlePreviewDismissed(int requestId) {
    Q_EMIT shareFinished(requestId);
}

void IosShareUtils::handleFileUrlReceived(const QUrl &url)
{
    if (url.isEmpty()) {
        qWarning() << "handleFileUrlReceived: we got an empty URL";
        Q_EMIT shareError(0, "Empty URL received");
        return;
    }

    // Resolve to a real local path with toLocalFile() to handles the file:// scheme and percent-decoding
    const QString localPath = url.isLocalFile() ? url.toLocalFile() : url.toString();
    qDebug() << "IosShareUtils handleFileUrlReceived:" << url.toString() << "->" << localPath;

    if (QFileInfo::exists(localPath)) {
        // iOS delivers the files directly into the app's Inbox
        Q_EMIT fileReceived(localPath);
    } else {
        qWarning() << "handleFileUrlReceived: file does not exist:" << localPath;
        Q_EMIT shareError(0, QString("File does not exist: %1").arg(localPath));
    }
}

/* ************************************************************************** */
