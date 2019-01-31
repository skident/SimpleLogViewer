#pragma once

#include <QObject>
#include <QString>
#include <QVariant>
#include <QVariantList>
#include <QDebug>

#include <set>

#include "LogParser.h"

struct LogInfoAdapter
{
    Q_GADGET

    Q_PROPERTY(QString timestamp READ timestamp)
    Q_PROPERTY(QString thread_info READ thread_info)
    Q_PROPERTY(QString severity READ severity)
    Q_PROPERTY(QString message READ message)

public:
    LogInfoAdapter()
    {
    }

    LogInfoAdapter(LogInfo info)
    {
        m_data = std::move(info);
    }

    QString timestamp() const
    {
        return QString::fromStdString(m_data.timestamp);
    }

    QString thread_info() const
    {
        return QString::fromStdString(m_data.thread_info);
    }

    QString severity() const
    {
        return QString::fromStdString(m_data.severity);
    }

    QString message() const
    {
        return QString::fromStdString(m_data.message);
    }

private:
    LogInfo m_data;
};

Q_DECLARE_METATYPE(LogInfoAdapter)


/////////////////////

/////////////////////

class LogQmlAdapter : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QVariantList info READ info NOTIFY changed)
    Q_PROPERTY(QVariantList pinnedInfo READ pinnedInfo NOTIFY changed)
    Q_PROPERTY(QStringList filters READ filters NOTIFY changed)

    Q_PROPERTY(QList<int> foundIds READ foundIds NOTIFY searchResultsChanged)

public:
    QVariantList info() const
    {
        return m_info;
    }

    QVariantList pinnedInfo() const
    {
        return m_pinnedInfo;
    }

    void init(const std::list<LogInfo>& info)
    {
        resetSession();
        m_origInfo = info;
        show();
    }

    std::list<LogInfo> filteredLogs() const
    {
        return FilterProcessor::filter(m_filters, m_origInfo);
    }

    void show(const std::list<LogInfo>& info)
    {
        m_info.clear();

        auto logs = FilterProcessor::filter(m_filters, info);

        for (const auto& elem : logs)
        {
            LogInfoAdapter adapter(elem);
            m_info.append(QVariant::fromValue(adapter));
        }

        emit changed();
    }

    void show()
    {
        show(m_origInfo);
    }

    QStringList filters() const
    {
        QStringList userFilters;

        for (const auto& filter : m_filters)
        {
            userFilters.append(QString::fromStdString(filter.to_string()));
        }

        return userFilters;
    }

    Q_INVOKABLE void removeFilter(const QString& filterStr)
    {
        Filter filter(filterStr.toStdString());
        auto it = m_filters.find(filter);
        if (it != m_filters.end())
        {
            m_filters.erase(it);
            show();
        }
    }

    Q_INVOKABLE void clearFilters()
    {
        m_filters.clear();
        show();
    }

    Q_INVOKABLE void applyFilter(const QString& field, const QString& comparison, const QString& value)
    {
        Filter filter = {field.toStdString(), comparison.toStdString(), value.toStdString()};
        m_filters.insert(filter);

        show();
    }

    Q_INVOKABLE int findAllElements(const QString& searchRequest)
    {
        auto logs = FilterProcessor::filter(m_filters, m_origInfo);
        int idx = 0;
        int firstIdx = -1;

        const std::string request = searchRequest.toStdString();
        for (const auto& elem : logs)
        {
            if (elem.contains(request))
            {
                if (firstIdx == -1)
                {
                    firstIdx = idx;
                }
                m_foundIds.append(idx);
            }
            idx++;
        }
        emit searchResultsChanged();
        return firstIdx;
    }

    QList<int> foundIds() const
    {
        return m_foundIds;
    }


    Q_INVOKABLE void resetSearch()
    {
        m_foundIds.clear();
        emit searchResultsChanged();
    }

private:
    void resetSession()
    {
        clearFilters();
        resetSearch();
    }

signals:
    void changed();
    void searchResultsChanged();

private:
    std::set<Filter> m_filters;

    std::list<LogInfo> m_origInfo;

    QVariantList m_info;
    QVariantList m_pinnedInfo;

    QList<int> m_foundIds;

    //    QVariantMap m_threads;
};


