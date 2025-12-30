{...}: {
  programs.zsh = {
    enable = true;

    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      append = true;
      path = "$HOME/.zhistory";
      size = 10000;
      save = 10000;
    };

    shellAliases = {
      # Git
      gs = "git status";
      ga = "git add";
      gp = "git push";
      gpo = "git push origin";
      gplo = "git pull origin";
      gb = "git branch";
      gc = "git commit";
      gd = "git diff";
      gco = "git checkout";
      gl = "git log";
      gr = "git remote";
      grs = "git remote show";

      # Tools
      tx = "tmuxinator";

      # Overrides
      grep = "grep --color=auto";

      # Home Manager
      hms = "home-manager switch";

      # Eza replacements
      ls = "eza --icons -lh";
      tree = "eza --tree --long --icons";

      # zoxide
      cd = "z";
    };

    initExtra = ''
      [[ -o interactive ]] || return

      # Vi mode
      bindkey -v

      # History search
      bindkey '^R' history-incremental-search-backward

      # Accept autosuggestions
      bindkey '^y' autosuggest-accept

      # Key timeout (zsh option)
      KEYTIMEOUT=1

      # Cursor shape for vi mode
      cursor_mode() {
        cursor_block='\e[2 q'
        cursor_beam='\e[6 q'

        function zle-keymap-select {
          if [[ $KEYMAP == vicmd ]] || [[ $1 == block ]]; then
            echo -ne $cursor_block
          else
            echo -ne $cursor_beam
          fi
        }

        zle-line-init() {
          echo -ne $cursor_beam
        }

        zle -N zle-keymap-select
        zle -N zle-line-init
      }

      cursor_mode

      # Prompt
      PROMPT=$'%F{white}%~ %B%F{blue}>%f%b '
    '';
  };
}
