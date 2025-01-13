{ config, lib, ... }:
{
  programs.nixvim = {
    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };

    keymaps = [
      {
        mode = [ "n" ];
        key = "<leader>e";
        action = "<cmd>Neotree toggle<cr>";
        options = {
          desc = "Open/Close Neotree";
        };
      }

      # Gitsigns
      {
        mode = [ "n" ];
        key = "]h";
        action.__raw = ''function()
          if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
          else
            package.loaded.gitsigns.nav_hunk("next")
          end
        end'';
        options.desc = "Next Hunk";
      }
      {
        mode = [ "n" ];
        key = "[h";
        action.__raw = ''function()
          if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
          else
            package.loaded.gitsigns.nav_hunk("prev")
          end
        end'';
        options.desc = "Prev Hunk";
      }
      {
        mode = [ "n" ];
        key = "]H";
        action.__raw = "function() package.loaded.gitsigns.nav_hunk('last') end";
        options.desc = "Last Hunk";
      }
      {
        mode = [ "n" ];
        key = "[H";
        action.__raw = "function() package.loaded.gitsigns.nav_hunk('first') end";
        options.desc = "First Hunk";
      }
      {
        mode = [ "n" "v" ];
        key = "<leader>ghs";
        action = ":Gitsigns stage_hunk<cr>";
        options.desc = "Stage Hunk";
      }
      {
        mode = [ "n" "v" ];
        key = "<leader>ghr";
        action = ":Gitsigns reset_hunk<cr>";
        options.desc = "Reset Hunk";
      }
      {
        mode = [ "n" ];
        key = "<leader>ghS";
        action.__raw = "package.loaded.gitsigns.stage_buffer";
        options.desc = "Stage Buffer";
      }
      {
        mode = [ "n" ];
        key = "<leader>ghu";
        action.__raw = "package.loaded.gitsigns.undo_stage_hunk";
        options.desc = "Undo Stage Hunk";
      }
      {
        mode = [ "n" ];
        key = "<leader>ghR";
        action.__raw = "package.loaded.gitsigns.reset_buffer";
        options.desc = "Reset Buffer";
      }
      {
        mode = [ "n" ];
        key = "<leader>ghp";
        action.__raw = "package.loaded.gitsigns.preview_hunk_inline";
        options.desc = "Preview Hunk Inline";
      }
      {
        mode = [ "n" ];
        key = "<leader>ghb";
        action.__raw = "function() package.loaded.gitsigns.blame_line({ full = true }) end";
        options.desc = "Blame Line";
      }
      {
        mode = [ "n" ];
        key = "<leader>ghB";
        action.__raw = "function() package.loaded.gitsigns.blame() end";
        options.desc = "Blame Buffer";
      }
      {
        mode = [ "n" ];
        key = "<leader>ghd";
        action.__raw = "package.loaded.gitsigns.diffthis";
        options.desc = "Diff This";
      }
      {
        mode = [ "n" ];
        key = "<leader>ghD";
        action.__raw = "function() package.loaded.gitsigns.diffthis('~') end";
        options.desc = "Diff This ~";
      }
      {
        mode = [ "o" "x" ];
        key = "ih";
        action = ":<C-U>Gitsigns select_hunk<cr>";
        options.desc = "GitSigns Select Hunk";
      }

      # Bufferline
      {
        mode = [ "n" ];
        key = "<leader>bp";
        action = "<cmd>BufferLineTogglePin<cr>";
        options.desc = "Toggle Pin";
      }
      {
        mode = [ "n" ];
        key = "<leader>bP";
        action = "<cmd>BufferLineGroupClose ungrouped<cr>";
        options.desc = "Delete Non-Pinned Buffers";
      }
      {
        mode = [ "n" ];
        key = "<leader>br";
        action = "<cmd>BufferLineCloseRight<cr>";
        options.desc = "Delete Buffers to the Right";
      }
      {
        mode = [ "n" ];
        key = "<leader>bl";
        action = "<cmd>BufferLineCloseLeft<cr>";
        options.desc = "Delete Buffers to the Left";
      }
      {
        mode = [ "n" ];
        key = "<S-h>";
        action = "<cmd>BufferLineCyclePrev<cr>";
        options.desc = "Prev Buffer";
      }
      {
        mode = [ "n" ];
        key = "<S-l>";
        action = "<cmd>BufferLineCycleNext<cr>";
        options.desc = "Next Buffer";
      }
    ];
  };
}
