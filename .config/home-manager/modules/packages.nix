{pkgs, ...}: {
  home.packages = with pkgs; [
    zsh
    zsh-autosuggestions
    zsh-syntax-highlighting

    tmux

    git
    lazygit

    fzf
    eza
    yazi
    ripgrep
    zoxide
    bat

    htop
    btop

    zip
    unzip

    mpv

    mako
    weechat

    keyd

    # screenshots and screen recording
    grim
    slurp
    wf-recorder

    # misc
    cmatrix
    cava

    # go toolchain
    go

    # lua toolchain
    lua

    # rust toolchain
    rustup

    # zig toolchain
    zig
  ];
}
