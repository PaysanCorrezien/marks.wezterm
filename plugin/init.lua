local wezterm = require("wezterm")

---@class Config
local M = {}

-- Plugin configuration
M.config = {
	debug = false,
	namespace = "plugins.marks",
}

-- Helper function for logging
local function log(message, force)
	if M.config.debug or force then
		wezterm.log_info(string.format("[%s] %s", M.config.namespace, message))
	end
end

-- Initialize the plugin state
local function init_plugin_state()
	if not wezterm.GLOBAL then
		wezterm.GLOBAL = {}
	end

	wezterm.GLOBAL.plugins = wezterm.GLOBAL.plugins or {}

	if not wezterm.GLOBAL.plugins[M.config.namespace] then
		wezterm.GLOBAL.plugins[M.config.namespace] = {
			initialized = true,
			current_mark = nil,
		}
	end

	return wezterm.GLOBAL.plugins[M.config.namespace]
end

-- Enable/disable debug logging
function M.set_debug(enabled)
	M.config.debug = enabled
	log(string.format("Debug logging %s", enabled and "enabled" or "disabled"), true)
end

--- Saves mark data to plugin state
--- @param data table: The workspace data to be saved
--- @return boolean: true if saving was successful
local function save_to_memory(data)
	if not data then
		log("No workspace data to save")
		return false
	end

	local plugin_state = init_plugin_state()
	plugin_state.current_mark = data
	log(string.format("Saved mark data to memory: %s", wezterm.json_encode(data)))
	return true
end

--- Writes the current workspace, tab, and pane information to memory
--- @param window window: The active window object
function M.WriteMarkToMemory(window)
	local active_tab = window:active_tab()
	local active_workspace_name = window:active_workspace()
	local active_pane = active_tab:active_pane()

	local mark_data = {
		workspace_name = active_workspace_name,
		tab_id = tostring(active_tab:tab_id()),
		pane_id = tostring(active_pane:pane_id()),
	}

	if save_to_memory(mark_data) then
		window:toast_notification("WezTerm Marks", "Workspace Mark saved", nil, 2000)
		log(string.format("Mark saved successfully: %s", wezterm.json_encode(mark_data)))
	else
		wezterm.log_error(string.format("[%s] Failed to save mark data to memory", M.config.namespace))
	end
end

--- Accesses and activates the workspace and pane from memory
--- @param window window: The active window object
function M.AccessMarkFromMemory(window)
	local plugin_state = init_plugin_state()
	local mark_data = plugin_state.current_mark

	if not mark_data then
		wezterm.log_error(string.format("[%s] No mark data found in memory", M.config.namespace))
		return
	end

	log(string.format("Retrieved mark data from memory: %s", wezterm.json_encode(mark_data)))

	if mark_data.workspace_name then
		log(string.format("Switching to workspace: %s", mark_data.workspace_name))
		window:perform_action(
			wezterm.action.SwitchToWorkspace({ name = mark_data.workspace_name }),
			window:active_pane()
		)
	end

	wezterm.sleep_ms(100)

	local panes = wezterm.mux.get_all_panes()
	local target_pane

	for _, pane in ipairs(panes) do
		local pane_id = tostring(pane:pane_id())
		if pane_id == mark_data.pane_id then
			target_pane = pane
			break
		end
	end

	if target_pane then
		log(string.format("Found and activating pane: %s", mark_data.pane_id))
		target_pane:activate()
	else
		wezterm.log_error(
			string.format("[%s] Could not find target pane with ID: %s", M.config.namespace, mark_data.pane_id)
		)
	end
end

-- Initialize plugin state when module is loaded
init_plugin_state()

return M
