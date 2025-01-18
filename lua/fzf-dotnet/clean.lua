local fs = require("fzf-dotnet.fs")
local utils = require("fzf-dotnet.utils")

local M = {}

function M.clean_project_or_solution()
  local targets = utils.get_projects(vim.fn.getcwd())
  require("fzf-lua").fzf_exec(targets, {
    winopts = {
      title = "Select project or solution",
    },
    actions = {
      ["default"] = function(selected, opts)
        vim.cmd("! dotnet clean " .. selected[1])
      end,
    },
  })
end

function M.clean_solution()
  local solution = utils.get_solution(vim.fn.getcwd())
  if solution then
    vim.cmd("! dotnet clean " .. solution)
  end
end

return M
