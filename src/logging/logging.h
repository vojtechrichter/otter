#ifndef OTTER_LOGGING_H
#define OTTER_LOGGING_H

#include "stdio.h"
#include "time.h"
#include "stdarg.h"

#include "../types.h"

typedef enum {
    LogDebug,
    LogInfo,
    LogWarning,
    LogError,
} LogLevel;

void log_msg(LogLevel level, const char *fmt, ...) __attribute__((format(printf, 2, 3)));

#define LOG_AT(level, ...) \
    do { \
        log_msg((level), __VA_ARGS__); \
    } while (0)

#define LOG_INFO(...) LOG_AT(LogInfo, __VA_ARGS__)

#if OTTER_DEBUG
    #define LOG_DEBUG(...) LOG_AT(LogInfo, __VA_ARGS__)
#else
    #define LOG_DEBUG(...) ((void)0)
#endif

#endif // OTTER_LOGGING_H
