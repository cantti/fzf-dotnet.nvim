local utils = require("fzf-dotnet.utils")

local M = {}

local function readAll(file)
  local f = assert(io.open(file, "rb"))
  local content = f:read("*all")
  f:close()
  return content
end

local function write_to_file(path, content)
  local file = io.open(path, "w") -- Open the file in write mode
  if not file then
    return false, "Error: Could not open file for writing."
  end

  file:write(content) -- Write the content to the file
  file:close() -- Close the file
  return true, "File written successfully."
end

function M.fix_namespace()
  local locations = utils.get_dir_options(".")

  require("fzf-lua").fzf_exec(locations, {
    winopts = {
      title = "Select folder",
    },
    actions = {
      ["default"] = function(selected, opts)
        local chosen_dir = selected[1]
        local files = utils.get_file_options(chosen_dir, { "cs" })
        vim.print(files)

        local updated_files = {}

        for _, file_path in ipairs(files) do
          local new_namespace = utils.get_namespace_for_file(file_path)
          local content = readAll(file_path)
          local new_content = string.gsub(content, "(namespace) .-([;%s])", "%1 " .. new_namespace .. "%2")
          write_to_file(file_path, new_content)
          if content ~= new_content then
            table.insert(updated_files, file_path)
          end
        end
        -- update buffers
        vim.cmd("bufdo checktime")

        vim.print("Updated files count: " .. vim.tbl_count(updated_files))
      end,
    },
  })
end

return M
