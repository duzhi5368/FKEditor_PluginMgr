# Created by Freeknight
# Date: 2021/12/11
# Desc：日志工具
# @category: 工具类
#--------------------------------------------------------------------------------------------------
class_name Logger
extends Reference
### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------
#--- enums ----------------------------------------------------------------------------------------
enum LogLevel {
	ALL, DEBUG, INFO, WARN, ERROR, NONE
}
#--- constants ------------------------------------------------------------------------------------
const DEFAULT_LOG_FORMAT_DETAIL = "[{time}] [{level}] {msg}"
const DEFAULT_LOG_FORMAT_NORMAL = "{msg}"
#--- public variables - order: export > normal var > onready --------------------------------------
var log_level = LogLevel.INFO
var log_format = DEFAULT_LOG_FORMAT_NORMAL
var log_time_format = "{year}/{month}/{day} {hour}:{minute}:{second}"
#--- private variables - order: export > normal var > onready -------------------------------------
### -----------------------------------------------------------------------------------------------

### Built in Engine Methods -----------------------------------------------------------------------
### -----------------------------------------------------------------------------------------------

### Public Methods --------------------------------------------------------------------------------
func debug(msg, raw=false):
	_log(LogLevel.DEBUG, msg, raw)
# ------------------------------------------------------------------------------
func info(msg, raw=false):
	_log(LogLevel.INFO, msg, raw)
# ------------------------------------------------------------------------------
func warn(msg, raw=false):
	_log(LogLevel.WARN, msg, raw)
# ------------------------------------------------------------------------------
func error(msg, raw=false):
	_log(LogLevel.ERROR, msg, raw)
# ------------------------------------------------------------------------------
func format_log(level, msg):
	return log_format.format({
		"time": log_time_format.format(get_formatted_datatime()),
		"level": LogLevel.keys()[level],
		"msg": msg
	})
# ------------------------------------------------------------------------------
func get_formatted_datatime():
	var datetime = OS.get_datetime()
	datetime.year = "%04d" % datetime.year
	datetime.month = "%02d" % datetime.month
	datetime.day = "%02d" % datetime.day
	datetime.hour = "%02d" % datetime.hour
	datetime.minute = "%02d" % datetime.minute
	datetime.second = "%02d" % datetime.second
	return datetime
### -----------------------------------------------------------------------------------------------

### Private Methods -------------------------------------------------------------------------------
func _log(level, msg, raw=false):
	if log_level <= level:
		if raw:
			printraw(format_log(level, msg))
		else:
			print(format_log(level, msg))
### -----------------------------------------------------------------------------------------------
