status = error

appender.console.type = Console
appender.console.name = console
appender.console.layout.type = PatternLayout
appender.console.layout.pattern = [%d{ISO8601}][%-5p][%-25c{1.}] %marker%m%n

appender.syslog.type = syslog
appender.syslog.name = syslog
appender.syslog.syslogHost = localhost:514
appender.syslog.facility: local0
appender.syslog.layout.type = PatternLayout
appender.syslog.layout.pattern = [%d{ISO8601}][%-5p][%-25c{1.}] %marker%m%n

rootLogger.level = info
rootLogger.appenderRef.console.ref = syslog