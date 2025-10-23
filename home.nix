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
  in {
    tmux = {
      enable = true;
    };

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
        abbreviations = aliases;
      };
      setOptions = [
        "APPEND_HISTORY"
        "INC_APPEND_HISTORY"
        "NO_SHARE_HISTORY"
        "HIST_IGNORE_DUPS"
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
          function zvm_after_init() { zvm_bindkey viins '^Y' autosuggest-accept }
        '';
      in
        lib.mkMerge [zshConfigEarlyInit zshConfig];
    };

    fish = {
      enable = true;
      preferAbbrs = true;
      shellAbbrs = aliases;
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

    eza = {
      enable = true;
      enableZshIntegration = false;
      enableFishIntegration = false;
    };

    bat = {
      enable = true;
      config = {
        theme = "Catppuccin Latte";
      };
    };

    ripgrep = {
      enable = true;
    };

    fzf = {
      enable = true;
      defaultOptions = [
        "--style=full:sharp"
        "--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
      ];
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
        border = "#1E66F5"; # Override with a blue border
        label = "#4C4F69";
      };
    };

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
      };
    };
  };

  home.stateVersion = "24.11";
}
