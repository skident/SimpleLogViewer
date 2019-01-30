#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickView>

#include "LogParser.h"
#include "LogQmlAdapter.h"
#include "MainController.h"

/*
 *  TODO list:
 * 1. Search                                                    - DONE preliminary!
 * 2. Field details (open popup with full content)
 * 3. Pin row (to easier comparison of lines)
 * 4. Support any type of log with adding regex for parsing it
 * 5. Save to file processed log                                - DONE: preliminary
 * 6. Serialize/Deserialize project to/from file
 * 7. Drag&Drop new log file into a window                      - DONE: preliminary
*/

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    MainController mainController;
    engine.rootContext()->setContextProperty("MainController", &mainController);
    engine.rootContext()->setContextProperty("LogQmlAdapter", &mainController.m_adapter);


    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
