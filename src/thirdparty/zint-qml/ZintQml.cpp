/*
 * Copyright 2023 Emeric Grange
 */

#include "ZintQml.h"
#include "ZintImageProvider.h"

////////////////////////////////////////////////////////////////////////////////

void ZintQml::registerQMLTypes()
{
    qmlRegisterType<ZintQml>("ZintQml", 1, 0, "ZintQml");
}

void ZintQml::registerQMLImageProvider(QQmlEngine &engine)
{
    engine.addImageProvider("ZintQml", new ZintImageProvider());
}

////////////////////////////////////////////////////////////////////////////////
