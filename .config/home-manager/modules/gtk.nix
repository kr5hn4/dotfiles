{
  config,
  pkgs,
  ...
}:

let
  # Define the shared settings once for both gtk3 and gtk4
  sharedGtkConfig = {
    gtk-enable-event-sounds = 1;
    gtk-enable-input-feedback-sounds = 0;
    gtk-xft-antialias = 1;
    gtk-xft-hinting = 1;
    gtk-xft-hintstyle = "hintfull";
    gtk-xft-rgba = "rgb";
    gtk-application-prefer-dark-theme = 1;
  };
in

{
  gtk = {
    enable = true;

    theme = {
      name = "Gruvbox-B-MB-Dark";
      package = pkgs.gruvbox-gtk-theme;
    };

    iconTheme = {
      name = "Gruvbox-Plus-Dark";
      package = pkgs.gruvbox-plus-icons;
    };

    font = {
      name = "Roboto";
      size = 12;
      package = pkgs.roboto;
    };

    cursorTheme = {
      name = "Vanilla-DMZ";
      package = pkgs.vanilla-dmz;
      size = 28;
    };

    gtk3.extraConfig = sharedGtkConfig // {
      # Legacy settings only valid in GTK3
      gtk-toolbar-style = "GTK_TOOLBAR_BOTH";
      gtk-toolbar-icon-size = "GTK_ICON_SIZE_LARGE_TOOLBAR";
      gtk-button-images = 1;
      gtk-menu-images = 1;
    };

    gtk4.extraConfig = sharedGtkConfig;

  };

  # Global pointer configuration to match GTK cursor sizes
  home.pointerCursor = {
    gtk.enable = true;
    name = "Vanilla-DMZ";
    package = pkgs.vanilla-dmz;
    size = 28;
  };

  # Forces system-wide dark mode for modern applications (like Chrome, Edge, and Libadwaita).
  # Many modern apps query this specific GSettings path via XDG Desktop Portals to determine user theme preferences.
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };
}
