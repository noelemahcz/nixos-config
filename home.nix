{
  config,
  pkgs,
  lib,
  userName,
  userEmail,
  ...
}: {
  home.username = userName;
  home.homeDirectory = "/home/${userName}";

  home.packages = with pkgs; [
    # System & Shell
    file
    asciinema_3

    # Nix
    cachix
    nixd
    alejandra

    # Other languages
    nodejs
    koka
    prettier
    python314
    lua-language-server

    # Markup languages
    marksman
    yamlfmt

    # Misc
    google-cloud-sdk
  ];

  programs = let
    eza_ = {
      options = {
        enable = true;
        enableZshIntegration = false;
        enableFishIntegration = false;
      };
      aliases = let
        # --icons=auto
        ezaDirsFirst = "eza --color=auto --classify=auto --group-directories-first";
        ezaDirsLast = "eza --color=auto --classify=auto --group-directories-last";
      in {
        ls = "${ezaDirsFirst}";
        ll = "${ezaDirsFirst} --long";
        la = "${ezaDirsFirst} --long --all";
        lt = "${ezaDirsLast} --tree";
      };
    };

    fzf_ = let
      searcher = "fd --type file --follow --hidden --no-ignore";
      style = "--style=full:sharp";
      reverse = "--reverse";
      preview = "--preview 'bat --color=always --style=numbers --line-range=:500 {}'";
      bindVim = "--bind 'enter:become(vim {})'";
    in {
      options = {
        enable = true;
        defaultCommand = searcher;
        changeDirWidgetOptions = [style reverse];
        fileWidgetOptions = [style reverse];
        historyWidgetOptions = [style reverse];
        # https://github.com/catppuccin/fzf
        colors = {
          fg = "#4C4F69";
          bg = "#EFF1F5";
          hl = "#D20F39";
          "fg+" = "#4C4F69";
          "bg+" = "#CCD0DA";
          "hl+" = "#D20F39";
          selected-bg = "#BCC0CC";
          spinner = "#DC8A78";
          header = "#D20F39";
          info = "#8839EF";
          pointer = "#DC8A78";
          marker = "#7287FD";
          prompt = "#8839EF";
          # border = "#9CA0B0";
          border = "#1E66F5"; # Override with a blue border
          label = "#4C4F69";
        };
      };
      aliases = {
        ff = "fzf ${style} ${reverse} ${preview} ${bindVim}";
        ffh = "${searcher} --search-path $HOME | fzf ${style} ${reverse} ${preview} ${bindVim}";
      };
    };

    shellAliases =
      builtins.foldl' lib.attrsets.unionOfDisjoint {}
      (lib.map (set: set.aliases) [eza_ fzf_]);
  in {
    tmux.enable = true;

    zsh = {
      enable = true;
      autosuggestion = {
        enable = true;
      };
      syntaxHighlighting = {
        enable = true;
      };
      zsh-abbr = {
        enable = true;
        globalAbbreviations = shellAliases;
      };
      setOptions = [
        "APPEND_HISTORY"
        "INC_APPEND_HISTORY"
        "NO_SHARE_HISTORY"
        "HIST_IGNORE_DUPS"
        # The control-s and control-q keys now do flow control by default,
        # unless you have turned this off with `stty -ixon' or redefined the
        # keys which control it with `stty start' or `stty stop'.  (This is
        # done by the system, not zsh; the shell simply respects these
        # settings.)  In other words, \C-s stops all output to the terminal,
        # while \C-q resumes it.
        # There is an option NO_FLOW_CONTROL to stop zsh from allowing flow
        # control and hence restoring the use of the keys: put `setopt
        # noflowcontrol' in your .zshrc file.
        "NO_FLOW_CONTROL"
      ];
      initContent = let
        # Common order values:
        # - 500 (mkBefore: Early initialization (replaces initExtraFirst
        # - 550: Before completion initialization (replaces initExtraBeforeCompInit
        # - 1000 (default: General configuration (replaces initExtra
        # - 1500 (mkAfter: Last to run configuration
        zshConfigEarlyInit = lib.mkOrder 500 "";
        zshConfig = lib.mkOrder 1000 ''
          source ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh

          # DO NOT use zvm_after_lazy_keybindings for insert mode bindings.
          # That hook is only for 'normal' (vicmd) and 'visual' modes.
          function zvm_after_init() {
            zvm_bindkey viins '^Y' autosuggest-accept
            zvm_bindkey viins '^R' fzf-history-widget
          }
        '';
      in
        lib.mkMerge [zshConfigEarlyInit zshConfig];
    };

    fish = {
      enable = true;
      preferAbbrs = true;
      shellAbbrs = shellAliases;
    };

    oh-my-posh = {
      enable = true;
      useTheme = "catppuccin_latte";
    };

    direnv = {
      enable = true;
      nix-direnv = {
        enable = true;
      };
    };

    eza = eza_.options;

    bat = {
      enable = true;
      config = {
        theme = "Catppuccin Latte";
      };
    };

    fd.enable = true;

    ripgrep.enable = true;

    fzf = fzf_.options;

    yazi = {
      enable = true;
      settings = {
        mgr = {
          show_hidden = true;
          sort_by = "natural";
          sort_dir_first = true;
        };
      };
    };

    neovim = {
      enable = true;
      defaultEditor = true;
      vimAlias = true;
      viAlias = true;
    };

    git = {
      enable = true;
      settings = {
        user = {
          name = userName;
          email = userEmail;
        };
        init = {
          defaultBranch = "main";
        };
        gpg.ssh.allowedSignersFile = toString (pkgs.writeText "allowed-signers" ''
          noelemahcz@outlook.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPdyIFdhPysCFyB5D8ca6xTLFS1EppepGwY4QRHv7eVg noelemahcz@outlook.com
        '');
      };
      signing = {
        signByDefault = true;
        format = "ssh";
        key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPdyIFdhPysCFyB5D8ca6xTLFS1EppepGwY4QRHv7eVg noelemahcz@outlook.com";
      };
    };
  };

  home.stateVersion = "24.11";
}
