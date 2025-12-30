{...}: {
  imports = [
    ./modules/packages.nix
    ./modules/zsh.nix
  ];

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "ctrl-p";
  home.homeDirectory = "/home/ctrl-p";

  home.stateVersion = "25.05"; # Please read the comment before changing.
  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.

  # It is sometimes useful to fine-tune packages, for example, by applying
  # overrides. You can do that directly here, just don't forget the
  # parentheses. Maybe you want to install Nerd Fonts with a limited number of
  # fonts?
  # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

  # You can also create simple shell scripts directly inside your
  # configuration. For example, this adds a command 'my-hello' to your
  # environment:
  # (pkgs.writeShellScriptBin "my-hello" ''
  #   echo "Hello, ${config.home.username}!"
  # '')

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/ctrl-p/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";

    QT_QPA_PLATFORM = "wayland";
    JAVA_HOME = "/usr/lib/jvm/java-17-openjdk";

    ANDROID_HOME = "$HOME/Android/Sdk";
    ANDROID_NDK_HOME = "$HOME/Android/Sdk/ndk/27.1.12297006";
    NDK_HOME = "$HOME/Android/Sdk/ndk/27.1.12297006";
  };

  home.sessionPath = [
    # Android
    "$ANDROID_NDK_HOME"
    "$ANDROID_HOME/emulator"
    "$ANDROID_HOME/platform-tools"
    "$ANDROID_HOME/cmdline-tools/latest/bin"
    "/opt/android-studio/bin"
    "$HOME/.local/bin"

    # Go
    "$HOME/go/bin"

    # Linuxbrew
    "/home/linuxbrew/.linuxbrew/bin"
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
