local M = {}
local fs = require("fzf-dotnet.fs")
local utils = require("fzf-dotnet.utils")

local function get_namespace_for_file(file_path)
  local elements = {}
  local csproj_path
  local curr_path = file_path
  local max_level = 5
  for i = 1, max_level do
    curr_path = fs.get_directory_path(curr_path)

    for _, file in ipairs(fs.get_files(curr_path)) do
      if fs.get_ext(file:lower()) == "csproj" then
        csproj_path = file
        break
      end
    end

    if csproj_path then
      break
    end

    -- insert dir name as element of namespace
    table.insert(elements, 1, fs.get_file_name(curr_path))

    -- do not go above root and pwd
    if curr_path == "/" or curr_path == vim.fn.getcwd() then
      break
    end
  end
  if csproj_path then
    local root_namespace = utils.get_root_namespace(csproj_path)
    table.insert(elements, 1, root_namespace)
  end
  local namespace = ""
  for _, element in ipairs(elements) do
    namespace = namespace .. "." .. element
  end
  namespace = string.gsub(namespace, "^.", "")
  return namespace
end

local function get_new_class_locations(path)
  local function get_subdirs_recursive(dir_path, base)
    local res = {}
    local dirs = fs.get_dirs(dir_path)
    for _, dir in ipairs(dirs) do
      local dir_name = fs.get_file_name(dir)
      if dir_name ~= "obj" and dir_name ~= "bin" and dir_name ~= ".git" then
        local entry = fs.join_paths(base, dir_name)
        table.insert(res, entry)
        local subdirs = get_subdirs_recursive(dir, entry)
        for _, subdir in ipairs(subdirs) do
          table.insert(res, subdir)
        end
      end
    end
    return res
  end
  local locations = get_subdirs_recursive(path, "./")
  table.insert(locations, 1, "./")
  return locations
end

function M.new_class()
  local cwd = vim.fn.getcwd()
  local locations = get_new_class_locations(cwd)

  require("fzf-lua").fzf_exec(locations, {
    winopts = {
      title = "Select folder",
    },
    actions = {
      ["default"] = function(selected, opts)
        local location = selected[1]
        local class_name = vim.fn.input("Enter name: ")
        local file_name = class_name .. ".cs"

        local file_path = fs.join_paths(cwd, location, file_name)

        local buf = vim.api.nvim_create_buf(true, false)
        vim.api.nvim_buf_set_name(buf, file_path)
        vim.api.nvim_buf_set_option(buf, "filetype", "cs")
        vim.api.nvim_set_current_buf(buf)

        local namespace = get_namespace_for_file(file_path)
        if not namespace then
          return
        end

        local lines = {
          "namespace " .. namespace .. ";",
          "",
          "public class " .. class_name,
          "{",
          "}",
        }
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
        -- vim.cmd("write")
      end,
    },
  })
end

function M.new_api_controller()
  local cwd = vim.fn.getcwd()
  local locations = get_new_class_locations(cwd)

  require("fzf-lua").fzf_exec(locations, {
    winopts = {
      title = "Select folder",
    },
    actions = {
      ["default"] = function(selected)
        local location = selected[1]
        local class_name = vim.fn.input("Enter name: ")
        local file_name = class_name .. ".cs"

        local file_path = fs.join_paths(cwd, location, file_name)

        local buf = vim.api.nvim_create_buf(true, false)
        vim.api.nvim_buf_set_name(buf, file_path)
        vim.api.nvim_buf_set_option(buf, "filetype", "cs")
        vim.api.nvim_set_current_buf(buf)

        local namespace = get_namespace_for_file(file_path)
        if not namespace then
          return
        end

        local lines = {
          "using Microsoft.AspNetCore.Http;",
          "using Microsoft.AspNetCore.Mvc;",
          "",
          "namespace " .. namespace .. ";",
          "",
          '[Route("api/[controller]")]',
          "[ApiController]",
          "public class " .. class_name .. " : ControllerBase",
          "{",
          "}",
        }
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
        -- vim.cmd("write")
      end,
    },
  })
end

return M
