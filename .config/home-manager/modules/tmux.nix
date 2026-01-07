{pkgs, ...}: {
  programs.tmux = {
    enable = true;

    # Core options
    prefix = "C-a";
    mouse = true;
    baseIndex = 1;

    # Plugins (NO TPM)
    # plugins = with pkgs.tmuxPlugins; [];

    extraConfig = ''
      # Reload config
      unbind r
      bind r source-file ~/.config/tmux/tmux.conf \; display "tmux config reloaded"

      # Status bar
      set -g status-position top

      # Pane navigation (Ctrl + h/j/k/l)
      bind-key -n C-h select-pane -L
      bind-key -n C-j select-pane -D
      bind-key -n C-k select-pane -U
      bind-key -n C-l select-pane -R

      set -sg escape-time 50

      # New window
      bind-key -n M-n new-window

      # Window navigation (Alt + h/l)
      bind -n M-h previous-window
      bind -n M-l next-window

      # Switch between last two windows
      bind-key M-Tab last-window

      # Alt + number to select window
      bind -n M-1 select-window -t 1
      bind -n M-2 select-window -t 2
      bind -n M-3 select-window -t 3
      bind -n M-4 select-window -t 4
      bind -n M-5 select-window -t 5
      bind -n M-6 select-window -t 6
      bind -n M-7 select-window -t 7
      bind -n M-8 select-window -t 8
      bind -n M-9 select-window -t 9

      # Clear history + redraw
      bind-key -n C-\; clear-history \; send-keys C-l


      # Load plugins (always keep at bottom)
      run-shell ${pkgs.tmuxPlugins.vim-tmux-navigator}/share/tmux-plugins/vim-tmux-navigator/vim-tmux-navigator.tmux
      run-shell ${pkgs.tmuxPlugins.gruvbox}/share/tmux-plugins/gruvbox/gruvbox-tpm.tmux

      # Gruvbox theme
      set -g @tmux-gruvbox 'dark'
    '';
  };
}
