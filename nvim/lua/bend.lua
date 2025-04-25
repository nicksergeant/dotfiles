local M = {}

local Job = require("plenary.job")
local log = require("vim.lsp.log")

local current_process = nil

local function reduce_array(arr, fn, init)
	local acc = init
	for k, v in ipairs(arr) do
		if 1 == k and not init then
			acc = v
		else
			acc = fn(acc, v)
		end
	end
	return acc
end

local jobId = 0

local function shutdownCurrentProcess()
	if current_process then
		log.info("bend", "shutting down current process")
		vim.uv.kill(-current_process.pid, uv.constants.SIGTERM)
		current_process = nil
	end
end

local function startBendProcess(rootsArray, sessionPath)
	log.info("bend", "Bend starting new client")

	local baseArgs = {
		"reactor",
		"host",
		"--session-path",
		sessionPath
	}

	local baseArgsWithWorkspaces = reduce_array(rootsArray, function(accumulator, current)
		table.insert(accumulator, current)
		return accumulator
	end, baseArgs)

	log.info("bend", "Starting NEW bend with args, " .. vim.inspect(baseArgsWithWorkspaces))

	local function jobLogger(data)
		if data ~= nil then
			local prefix = "bend process #" .. jobId .. " - "
			log.info("bend", prefix .. vim.inspect(data))
		end
	end

	local newJob = Job:new({
		command = "bend",
		args = baseArgsWithWorkspaces,
		detached = true,
		on_exit = function(j, signal)
			jobLogger("process exited")
			jobLogger(j:result())
			jobLogger(signal)
		end,
		on_stdout = function(error, data)
			jobLogger(data)
		end,
		on_stderr = function(error, data)
			jobLogger(data)
		end,
	})

	newJob:start()

	jobId = jobId + 1

	return newJob
end

function M.check_start_javascript_lsp(session_path)
	-- only setup once per instance
	if current_process then
		return
	end

	local root_dir = vim.fn.getcwd()
	if not root_dir then
		log.error("bend", "we couldnt find a root directory, ending")
		return
	end

	-- first, search up to see what you can find a static_conf file that is siblings with the .git directory
	local all_relevant_static_confs = vim.fs.find(function(name, path)
			return vim.fn.isdirectory(path .. "/.git") == 1 and name == "static_conf.json"
		end,
		{ path = root_dir, upward = true, stop = "/.git", type = "file" })

	-- if we don't have parent dirs, then search the children
	-- NOTE: we are making some assumptions about multi root workspaces. Namely, that all projects are direct
	-- children of the root directory, so something like
	-- root_dir
	--    |
	--    |-- payment-method-components
	--    |-- transactions-experience-ui
	--    |-- subscriptions-experience-ui

	if #all_relevant_static_confs == 0 then
		local handle = vim.uv.fs_scandir(root_dir)
		if handle then
			while true do
				local name, type = vim.uv.fs_scandir_next(handle)
				if not name then
					break
				end

				if type == 'directory' then
					local full_path = root_dir .. "/" .. name
					local git_path = full_path .. "/.git"
					local static_conf_path = full_path .. "/static_conf.json"
					if vim.fn.isdirectory(git_path) == 1 and vim.fn.filereadable(static_conf_path) == 1 then
						table.insert(all_relevant_static_confs, static_conf_path)
					end
				end
			end
		end
	end

	-- if we still have nothing, then don't start anything
	if #all_relevant_static_confs == 0 then
		log.info("bend", "could not find any bend repositories for path " .. root_dir)
		return
	end

	local all_directories = {}
	for _, path in ipairs(all_relevant_static_confs) do
		table.insert(all_directories, vim.fs.dirname(path))
	end

	log.info("bend", "starting a new process")

	-- create a session path and start the new session
	current_process = startBendProcess(all_directories, session_path)
end

local function setup_auto_commands()
	-- schedule this thing to run
	local session_path = "/tmp/.hubspot/vim/client-key-" ..
		os.date('%Y%m%d-%H%M%S') .. "-" .. math.random(1000000000)
	vim.fn.setenv("BEND_SESSION_PATH", session_path)

	local group = vim.api.nvim_create_augroup("bend.nvim", { clear = true })

	vim.schedule(function()
		M.check_start_javascript_lsp(session_path)
	end)

	vim.api.nvim_create_autocmd("VimLeavePre", {
		group = group,
		desc = "Shut down bend process before exiting",
		callback = function()
			vim.schedule(M.stop)
		end,
	})

	log.info("bend", "Bend plugin intialized")
end

function M.stop()
	shutdownCurrentProcess()
end

function M.setup()
	setup_auto_commands()
end

function M.reset()
	log.info(
		"bend",
		'"reset" called - running LspStop, cancelling current bend process, resetting roots, and running LspStart'
	)
	vim.cmd("LspStop")
	shutdownCurrentProcess()
	vim.cmd("LspStart")
	print('Open a new file, or re-open an existing one with ":e" for bend.nvim to start a new process')
end

function M.getTsServerPathForCurrentFile()
	function SplitFilename(strFilename)
		-- Returns the Path, Filename, and Extension as 3 values
		return string.match(strFilename, "(.-)([^\\]-([^\\%.]+))$")
	end

	local bufnr = vim.api.nvim_get_current_buf()
	local path = vim.api.nvim_buf_get_name(bufnr)

	local _, _, ft = SplitFilename(path)

	local filetypes = {
		["js"] = true,
		["ts"] = true,
		["tsx"] = true,
		["jsx"] = true,
	}

	-- Filter which files we are considering.
	if ft == nil or not filetypes[ft] then
		log.trace(
			"bend-tsserver-notification",
			"found this filetype that isnt what we're looking for: " .. (ft or "nil") .. " for buffer number: " .. bufnr
		)
		return "latest"
	end


	local directoryOfNodeModules = vim.fs.dirname(vim.fs.find({ "node_modules" }, { upward = true, path = path })[1])

	if directoryOfNodeModules == "" then
		log.trace(
			"bend-tsserver-notification",
			"node_modules not found for current file, skipping auto-sense of hs-typescript/tsserver version"
		)
		return "latest"
	end

	log.trace(
		"bend-tsserver-notification",
		"node_modules found at "
		.. directoryOfNodeModules
		.. " - will parse the package.json in that directory for the hs-typescript version"
	)

	local pathOfPackageJson = table.concat { directoryOfNodeModules, "/package.json" }

	local getVersionResult = vim.system({ "jq", "-r", '.bpm.deps."hs-typescript"', pathOfPackageJson }, { text = true })
		:wait()

	if getVersionResult.stderr ~= "" then
		log.error("bend-tsserver-notification", "there was an error reading hs-typescript version")
		log.error("bend-tsserver-notification", getVersionResult.stderr)
		return "latest"
	end

	local hsTypescriptVersion = getVersionResult.stdout
	hsTypescriptVersion = hsTypescriptVersion:gsub('"', "")
	hsTypescriptVersion = hsTypescriptVersion:gsub("\n", "")
	log.trace("bend-tsserver-notification", "found an hs-typescript version of " .. hsTypescriptVersion)

	local getHsTypescriptPathResult = vim.system(
		{ "bpx", "--path", string.format("hs-typescript@%s", hsTypescriptVersion) },
		{ text = true }
	):wait()

	if getHsTypescriptPathResult.stderr ~= "" then
		log.error(
			"bend-tsserver-notification",
			"there was an error determining the path of hs-typescript from version number: " .. hsTypescriptVersion
		)
		log.error("bend-tsserver-notification", getHsTypescriptPathResult.stderr)
		return "latest"
	end

	local hsTypescriptPath = getHsTypescriptPathResult.stdout
	hsTypescriptPath = hsTypescriptPath:gsub('"', "")
	hsTypescriptPath = hsTypescriptPath:gsub("\n", "")
	return hsTypescriptPath
end

return M
