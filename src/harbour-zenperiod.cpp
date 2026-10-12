/* Application entry point. Exposes CycleStore to QML as "store". */

#include <sailfishapp.h>
#include <QGuiApplication>
#include <QQuickView>
#include <QQmlContext>
#include <QScopedPointer>

#include "cyclestore.h"

int main(int argc, char *argv[])
{
    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));
    QScopedPointer<QQuickView> view(SailfishApp::createView());

    CycleStore store;
    if (!store.init())
        qWarning("CycleStore init failed, running without persistence");
    view->rootContext()->setContextProperty("store", &store);

    view->setSource(SailfishApp::pathTo("qml/harbour-zenperiod.qml"));
    view->showFullScreen();
    return app->exec();
}
