local source = debug.getinfo(1, "S").source
local config_dir = source:sub(1, 1) == "@" and source:sub(2):match("(.*/)") or "./"

package.path = config_dir .. "?.lua;" .. package.path

require("desu.core")
require("desu.lifecycle")
require("desu.bindings")
require("desu.rules")
