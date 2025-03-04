local M = {}
local fs = require("cshelper.fs")
local utils = require("cshelper.utils")

local function get_ident()
  return vim.fn["repeat"](" ", vim.opt.shiftwidth:get())
end

local function write(lines)
  local fpath = fs.current_file_path()
  local replacements = {
    namespace = utils.get_namespace_for_file(fpath),
    classname = fs.get_file_name_without_ext(fpath),
    i = get_ident(),
  }
  lines = vim.tbl_map(function(line)
    for key, val in pairs(replacements) do
      line = string.gsub(line, "%%" .. key .. "%%", val)
    end
    return line
  end, lines)
  vim.api.nvim_put(lines, "c", true, true)
end

function M.class(opts)
  opts = vim.tbl_deep_extend("keep", opts, {
    blockns = false,
  })
  if opts.blockns then
    write({
      "namespace %namespace%",
      "{",
      "%i%public class %classname%",
      "%i%{",
      "%i%}",
      "}",
    })
  else
    write({
      "namespace %namespace%;",
      "",
      "public class %classname%",
      "{",
      "}",
    })
  end
end

function M.api_controller(opts)
  opts = vim.tbl_deep_extend("keep", opts, {
    blockns = false,
  })
  if opts.blockns then
    write({
      "using Microsoft.AspNetCore.Mvc;",
      "",
      "namespace %namespace%",
      "{",
      '%i%[Route("api/[controller]")]',
      "%i%[ApiController]",
      "%i%public class %classname% : ControllerBase",
      "%i%{",
      "%i%}",
      "}",
    })
  else
    write({
      "using Microsoft.AspNetCore.Mvc;",
      "",
      "namespace %namespace%;",
      "",
      '[Route("api/[controller]")]',
      "[ApiController]",
      "public class %classname% : ControllerBase",
      "{",
      "}",
    })
  end
end

return M
