{pkgs, ...}: {
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

    keyd

    # screenshots and screen recording
    grim
    slurp
    wf-recorder
    swappy

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

  # Enables zoxide integration in your shell, providing the `z` command for fast directory jumping
  programs.zoxide.enable = true;
}
