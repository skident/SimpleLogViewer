#pragma once

#include <QObject>
#include "LogParser.h"
#include "LogQmlAdapter.h"

#include <QUrl>

class MainController : public QObject
{
    Q_OBJECT

public:
    MainController(const std::string& path = "")
    {
        if (!path.empty())
            openFile(path);
    }

    Q_INVOKABLE void openFile(const QUrl& path)
    {
        openFile(path.toLocalFile().toStdString());
    }

    Q_INVOKABLE void saveToFile(const QUrl& path)
    {
        saveToFile(path.toLocalFile().toStdString());
    }

    Q_INVOKABLE void closeCurrent()
    {
        m_adapter.init({});
    }

private:
    bool openFile(const std::string& path)
    {
        if (path.empty())
        {
            return false;
        }
        m_parser.open(path);
        m_adapter.init(m_parser.infoList);

        return true;
    }

    bool saveToFile(const std::string& path)
    {
        std::ofstream file(path);
        if (!file.is_open())
        {
            return false;
        }

        auto logs = m_adapter.filteredLogs();
        for (const auto& elem : logs)
        {
            file << elem.to_string() << std::endl;
        }
        return true;
    }

public:
    LogParser m_parser;
    LogQmlAdapter m_adapter;
};
