#pragma once

#include <string>
#include <fstream>
#include <list>

#include <set>
#include <iostream>

#include <regex>

struct StringHelper
{
    static std::string upper_string(const std::string& str)
    {
        std::string upper;
        transform(str.begin(), str.end(), std::back_inserter(upper), toupper);
        return upper;
    }

    static std::string::size_type find_str_ci(const std::string& str, const std::string& substr)
    {
        return upper_string(str).find(upper_string(substr) );
    }

    static bool contains(const std::string& str, const std::string& substr)
    {
        return find_str_ci(str, substr) != std::string::npos;
    }
};

///////////

struct Filter
{
    std::string field;
    std::string operation;
    std::string value;


    Filter(const std::string& field,
           const std::string& operation,
           const std::string& value)
        : field(field)
        , operation(operation)
        , value(value)
    {
    }

    Filter(const std::string& description)
    {
        const std::set<std::string> operations = {
            "==",
            "!=",
        };

        for (const auto& op : operations)
        {
            auto pos = description.find(op);
            if (pos != std::string::npos)
            {
                field = description.substr(0, pos);
                operation = op;
                value = description.substr(pos + op.size());
            }
        }
    }

    std::string to_string() const
    {
        return field+operation+value;
    }

    bool operator==(const Filter& rhs) const
    {
        return field == rhs.field &&
                operation == rhs.operation &&
                value == rhs.value;
    }

    bool operator<(const Filter& rhs) const
    {
        return this->to_string() < rhs.to_string();
    }

    bool empty() const
    {
        return field.empty() || operation.empty() || value.empty();
    }
};


struct LogInfo
{
    std::string timestamp;
    std::string thread_info;
    std::string severity;
    std::string message;

    std::string to_string(const std::string& separator = " ") const
    {
        return timestamp + separator + thread_info + separator + severity + separator + message;
    }

    bool contains(const std::string& chunk) const
    {
        bool contains = false;
        contains |= StringHelper::contains(timestamp, chunk);
        contains |= StringHelper::contains(thread_info, chunk);
        contains |= StringHelper::contains(severity, chunk);
        contains |= StringHelper::contains(message, chunk);

        return contains;
    }

    bool empty() const
    {
        return timestamp.empty() &&
                thread_info.empty() &&
                severity.empty() &&
                message.empty();
    }

    friend std::ostream& operator<< (std::ostream& os, const LogInfo& rhs);
};

inline std::ostream& operator<< (std::ostream& os, const LogInfo& rhs)
{
    os << rhs.timestamp << " " << rhs.thread_info << " " << rhs.severity << " " << rhs.message;
    return os;
}

struct FilterProcessor
{
private:
    static bool passed(const Filter& filter, const LogInfo& logInfo)
    {
        if (filter.empty())
        {
            return true;
        }

        std::string value;
        if (filter.field == "thread")
        {
            value = logInfo.thread_info;
        }
        else if (filter.field == "severity")
        {
            value = logInfo.severity;
        }
        else if (filter.field == "msg")
        {
            value = logInfo.message;
        }

        if (value.empty())
        {
            return false;
        }


        auto pos = StringHelper::find_str_ci(value, filter.value);
        if (pos != std::string::npos)
        {
            return filter.operation == "==";
        }
        return filter.operation == "!=";
    }

public:
    static std::list<LogInfo> filter(const std::set<Filter> &filters, const std::list<LogInfo>& logs)
    {
        std::list<LogInfo> filteredLogs;

        for (const auto& logLine : logs)
        {
            bool passedAllFilters = true;
            for (const Filter& filter : filters)
            {
                if (!passed(filter, logLine))
                {
                    passedAllFilters = false;
                    break;
                }
            }

            if (passedAllFilters)
            {
                filteredLogs.push_back(logLine);
            }
        }

        return  filteredLogs;
    }
};

/////////////

class LogParser
{
public:
    std::list<LogInfo> infoList;


public:
    LogParser();

    void open(const std::string& filename)
    {
        std::ifstream file(filename);
        if (!file.is_open())
        {
            std::cerr << "File wasn't opened" << filename << std::endl;
            return;
        }

        std::string line;
        infoList.clear();
        while (std::getline(file, line))
        {
            LogInfo info = parseLine(line);
            if (info.empty())
            {
                continue;
            }
            infoList.emplace_back(std::move(info));
        }
    }

    static void parse(const std::list<std::string>& lines, std::list<LogInfo>& outInfoList)
    {
        outInfoList.clear();

        for (const auto& line : lines)
        {
            LogInfo info = parseLine(line);
            if (info.empty())
            {
                continue;
            }
            outInfoList.emplace_back(std::move(info));
        }
    }

    static LogInfo parseLine(const std::string& subject)
    {
        LogInfo result;
        try {
            const std::string threadIdChunk = "Thread ID=";
            std::regex re("(\\d{4}\\.\\d{2}\\.\\d{2} \\d{2}:\\d{2}:\\d{2}\\.\\d{3}) (\\(.*\\)) (\\[DEBUG\\]|\\[ERROR\\]|\\[WARNING\\]|\\[INFO\\]) (.*)");
            std::smatch match;
            if (std::regex_search(subject, match, re) && match.size() >= 4)
            {
                result.timestamp = match.str(1);

                std::string tmp = match.str(2);
                auto pos = tmp.find(threadIdChunk)+threadIdChunk.size();
                tmp = tmp.substr(pos);
                tmp = tmp.substr(0, tmp.size()-1);

                result.thread_info = tmp; // match.str(2).substr(1, match.str(2).size()-2);

                result.severity = match.str(3).substr(1, match.str(3).size()-2);

                result.message = match.str(4);
            }
        } catch (std::regex_error& e) {
            // Syntax error in the regular expression
        }

        //        std::cout << result << std::endl;

        return result;
        //        std::cout << result << std::endl;
    }
};

