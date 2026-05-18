#include "logging.h"

Internal
const char *get_log_level_name(LogLevel log_level)
{
    switch (log_level) {
        case LogDebug: {
            return "DEBUG";
        } break;

        case LogInfo: {
            return "INFO";
        } break;

        default: {
            return "UNKNOWN";
        } break;
    }
}

void log_msg(LogLevel level, const char *fmt, ...)
{
    struct timespec ts;
    clock_gettime(CLOCK_REALTIME, &ts);
    struct tm tm;
    localtime_r(&ts.tv_sec, &tm);
    char formatted_time_string[32];
    strftime(formatted_time_string, sizeof(formatted_time_string), "%Y-%m-%d %H:%M:%S", &tm);

    fprintf(stdout, "[%s][%s]: ", get_log_level_name(level), formatted_time_string);

    va_list args;
    va_start(args, fmt);
    vfprintf(stdout, fmt, args);
    va_end(args);

    fputc('\n', stdout);
    fflush(stdout);

    funlockfile(stdout);
}

