{ pkgs, ... }: {
  # Allow installation of proprietary/non-open-source packages (e.g. Google-Chrome, Obsidian, Discord)
  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    git
    lazygit

    fzf
    eza
    ripgrep
    bat

    htop
    btop

    zip
    unzip

    mako
    weechat

    neovim

    # mason tools

    # Treesitter
    tree-sitter
    gcc

    # Formatter
    nixfmt

    # LSP servers
    lua-language-server
    stylua

    # mason tools end

    fuzzel
    matugen

    fastfetch

    kanata
    awww

    # screenshots and screen recording
    grim
    slurp
    wf-recorder
    swappy

    # misc
    cmatrix
    cava
    figlet

    # fast version manager for node
    fnm

    # go toolchain
    go

    # lua toolchain
    lua

    # rust toolchain
    rustup

    # zig toolchain
    zig

    obsidian
  ];

  # Enables zoxide integration in your shell, providing the `z` command for fast directory jumping
  programs.zoxide.enable = true;
}
