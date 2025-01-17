{ config, lib, ... }:
{
    programs.nixvim.plugins = {
      mini = {
        enable = true;
        modules = {
          icons = {
            style = "glyph";
          };
          surround = {
            mappings = {
              add = "gsa";
              delete = "gsd";
              find = "gsf";
              find_left = "gsF";
              highlight = "gsh";
              replace = "gsr";
              update_n_lines = "gsn";
            };
          };
          pairs = {};
        };
        mockDevIcons = true;
      };

      gitsigns.enable = true;

      noice.enable = true;

      notify.enable = true;
      
      neo-tree = {
        enable = true;
        sources = [
          "filesystem"
          "buffers"
          "git_status"
          "document_symbols"
        ];
      };

      better-escape.enable = true;

      bufferline = {
        enable = true;
        settings.options = {
          offsets = [
            {
              filetype = "neo-tree";
              text = "Neo-tree";
              highlight = "Directory";
              text_alight = "left";
            }
          ];
        };
      };

      lualine = {
        enable = true;
      };

      toggleterm = {
        enable = true;
        settings = {
          open_mapping = "[[<C-\\>]]";
        };
      };
    };
}