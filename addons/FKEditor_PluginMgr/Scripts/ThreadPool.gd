# Created by Freeknight
# Date: 2021/12/11
# Desc：线程池
# @category: 工具类
#--------------------------------------------------------------------------------------------------
class_name ThreadPool
extends Reference
### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------
signal all_thread_finished()
#--- enums ----------------------------------------------------------------------------------------
#--- constants ------------------------------------------------------------------------------------
#--- public variables - order: export > normal var > onready --------------------------------------
var logger
#--- private variables - order: export > normal var > onready -------------------------------------
var _threads = []
var _finished_threads = []
var _mutex = Mutex.new()
var _tasks = []
### -----------------------------------------------------------------------------------------------

### Built in Engine Methods -----------------------------------------------------------------------
func _init(p_logger):
	logger = p_logger
	_threads.resize(OS.get_processor_count())
### -----------------------------------------------------------------------------------------------

### Public Methods --------------------------------------------------------------------------------
func enqueue_task(instance, method, userdata=null, priority=1):
	enqueue({"instance": instance, "method": method, "userdata": userdata, "priority": priority})
# ------------------------------------------------------------------------------
func enqueue(task):
	var can_execute = _execute_task(task)
	if not can_execute:
		_tasks.append(task)
# ------------------------------------------------------------------------------
func process(delta):
	_flush_tasks()
	_flush_threads()
# ------------------------------------------------------------------------------
func is_all_thread_finished():
	for i in _threads.size():
		if _threads[i]:
			return false
	return true
# ------------------------------------------------------------------------------
func is_all_task_finished():
	for i in _tasks.size():
		if _tasks[i]:
			return false
	return true
### -----------------------------------------------------------------------------------------------

### Private Methods -------------------------------------------------------------------------------
func _execute_task(task):
	var thread = _get_thread()
	var can_execute = thread
	if can_execute:
		task.thread = weakref(thread)
		thread.start(self, "_execute", task, task.priority)
		logger.debug("Execute task %s.%s() " % [task.instance, task.method])
	return can_execute
# ------------------------------------------------------------------------------
func _execute(args):
	args.instance.call(args.method, args.userdata)
	_mutex.lock()
	var thread = args.thread.get_ref()
	_threads[_threads.find(thread)] = null
	_finished_threads.append(thread)
	var all_finished = is_all_thread_finished()
	_mutex.unlock()

	logger.debug("Execution finished %s.%s() " % [args.instance, args.method])
	if all_finished:
		logger.debug("All thread finished")
		emit_signal("all_thread_finished")
# ------------------------------------------------------------------------------
func _flush_tasks():
	if not _tasks:
		return

	var executed = true
	while executed:
		var task = _tasks.pop_front()
		if task != null:
			executed = _execute_task(task)
			if not executed:
				_tasks.push_front(task)
		else:
			executed = false
# ------------------------------------------------------------------------------
func _flush_threads():
	for i in _finished_threads.size():
		var thread = _finished_threads.pop_front()
		thread.wait_to_finish()
# ------------------------------------------------------------------------------
func _get_thread():
	var thread
	for i in OS.get_processor_count():
		var t = _threads[i]
		if t:
			if not t.is_active():
				thread = t
				break
		else:
			thread = Thread.new()
			_threads[i] = thread
			break
	return thread
### -----------------------------------------------------------------------------------------------
