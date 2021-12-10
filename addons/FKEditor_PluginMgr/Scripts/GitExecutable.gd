# Created by Freeknight
# Date: 2021/12/11
# Desc：Git执行类
# @category: 工具类
#--------------------------------------------------------------------------------------------------
class_name GitExecutable
extends Reference
### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------
#--- enums ----------------------------------------------------------------------------------------
#--- constants ------------------------------------------------------------------------------------
#--- public variables - order: export > normal var > onready --------------------------------------
var cwd = ""
var logger
#--- private variables - order: export > normal var > onready -------------------------------------
### -----------------------------------------------------------------------------------------------

### Built in Engine Methods -----------------------------------------------------------------------
func _init(p_cwd, p_logger):
	cwd = p_cwd
	logger = p_logger
### -----------------------------------------------------------------------------------------------

### Public Methods --------------------------------------------------------------------------------
func init():
	logger.debug("Initializing git at %s..." % cwd)
	var output = []
	var exit = _execute("git init", true, output)
	logger.debug("Successfully init" if exit == OK else "Failed to init")
	return {"exit": exit, "output": output}
# ------------------------------------------------------------------------------
func clone(src, dest, args={}):
	logger.debug("Cloning from %s to %s..." % [src, dest])
	var output = []
	var branch = args.get("branch", "")
	var tag = args.get("tag", "")
	var commit = args.get("commit", "")
	var command = "git clone --depth=1 --progress '%s' '%s'" % [src, dest]
	if branch or tag:
		command = "git clone --depth=1 --single-branch --branch %s '%s' '%s'" % [branch if branch else tag, src, dest]
	elif commit:
		return clone_commit(src, dest, commit)
	var exit = _execute(command, true, output)
	logger.debug("Successfully cloned from %s" % src if exit == OK else "Failed to clone from %s" % src)
	return {"exit": exit, "output": output}
# ------------------------------------------------------------------------------
func clone_commit(src, dest, commit):
	var output = []
	if commit.length() < 40:
		logger.error("Expected full length 40 digits commit-hash to clone specific commit, given {%s}" % commit)
		return {"exit": FAILED, "output": output}

	logger.debug("Cloning from %s to %s @ %s..." % [src, dest, commit])
	var result = init()
	if result.exit == OK:
		result = remote_add("origin", src)
		if result.exit == OK:
			result = fetch("%s %s" % ["origin", commit])
			if result.exit == OK:
				result = reset("--hard", "FETCH_HEAD")
	return result
# ------------------------------------------------------------------------------
func fetch(rm="--all"):
	logger.debug("Fetching %s..." % rm.replace("--", ""))
	var output = []
	var exit = _execute("git fetch %s" % rm, true, output)
	logger.debug("Successfully fetched" if exit == OK else "Failed to fetch")
	return {"exit": exit, "output": output}
# ------------------------------------------------------------------------------
func pull():
	logger.debug("Pulling...")
	var output = []
	var exit = _execute("git pull --rebase", true, output)
	logger.debug("Successfully pulled" if exit == OK else "Failed to pull")
	return {"exit": exit, "output": output}
# ------------------------------------------------------------------------------
func remote_add(name, src):
	logger.debug("Adding remote %s@%s..." % [name, src])
	var output = []
	var exit = _execute("git remote add %s '%s'" % [name, src], true, output)
	logger.debug("Successfully added remote" if exit == OK else "Failed to add remote")
	return {"exit": exit, "output": output}
# ------------------------------------------------------------------------------
func reset(mode, to):
	logger.debug("Resetting %s %s..." % [mode, to])
	var output = []
	var exit = _execute("git reset %s %s" % [mode, to], true, output)
	logger.debug("Successfully reset" if exit == OK else "Failed to reset")
	return {"exit": exit, "output": output}
# ------------------------------------------------------------------------------
func get_commit_comparison(branch_a, branch_b):
	var output = []
	var exit = _execute("git rev-list --count --left-right %s...%s" % [branch_a, branch_b], true, output)
	var raw_ahead_behind = output[0].split("\t")
	var ahead_behind = []
	for msg in raw_ahead_behind:
		ahead_behind.append(int(msg))
	return ahead_behind if exit == OK else []
# ------------------------------------------------------------------------------
func get_current_branch():
	var output = []
	var exit = _execute("git rev-parse --abbrev-ref HEAD", true, output)
	return output[0] if exit == OK else ""
# ------------------------------------------------------------------------------
func get_current_tag():
	var output = []
	var exit = _execute("git describe --tags --exact-match", true, output)
	return output[0] if exit == OK else ""
# ------------------------------------------------------------------------------
func get_current_commit():
	var output = []
	var exit = _execute("git rev-parse --short HEAD", true, output)
	return output[0] if exit == OK else ""
# ------------------------------------------------------------------------------
func is_detached_head():
	var output = []
	var exit = _execute("git rev-parse --short HEAD", true, output)
	return (!!output[0]) if exit == OK else true
# ------------------------------------------------------------------------------
func is_up_to_date(args={}):
	if fetch().exit == OK:
		var branch = args.get("branch", "")
		var tag = args.get("tag", "")
		var commit = args.get("commit", "")

		if branch:
			if branch == get_current_branch():
				return FAILED if is_detached_head() else OK
		elif tag:
			if tag == get_current_tag():
				return OK
		elif commit:
			if commit == get_current_commit():
				return OK

		var ahead_behind = get_commit_comparison("HEAD", "origin")
		var is_commit_behind = !!ahead_behind[1] if ahead_behind.size() == 2 else false
		return FAILED if is_commit_behind else OK
	return FAILED
### -----------------------------------------------------------------------------------------------

### Private Methods -------------------------------------------------------------------------------
func _execute(command, blocking=true, output=[], read_stderr=false):
	var cmd = "cd '%s' && %s" % [cwd, command]
	# NOTE: OS.execute() seems to ignore read_stderr
	var exit = FAILED
	match OS.get_name():
		"Windows":
			cmd = cmd.replace("\'", "\"") # cmd doesn't accept single-quotes
			cmd = cmd if read_stderr else "%s 2> nul" % cmd
			logger.debug("Execute \"%s\"" % cmd)
			exit = OS.execute("cmd", ["/C", cmd], blocking, output, read_stderr)
		"X11", "OSX", "Server":
			cmd if read_stderr else "%s 2>/dev/null" % cmd
			logger.debug("Execute \"%s\"" % cmd)
			exit = OS.execute("bash", ["-c", cmd], blocking, output, read_stderr)
		var unhandled_os:
			logger.error("Unexpected OS: %s" % unhandled_os)
	logger.debug("Execution ended(code:%d): %s" % [exit, output])
	return exit
### -----------------------------------------------------------------------------------------------
