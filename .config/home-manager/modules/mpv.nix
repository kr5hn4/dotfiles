{...}: {
  programs.mpv = {
    enable = true;

    config = {
      # ---- Core playback ----
      # vo = "gpu";
      # hwdec = "auto-safe";
      ao = "pipewire";

      # ---- UX ----
      save-position-on-quit = true;
      keep-open = true;
      force-seekable = true;

      # ---- Wayland ----
      # gpu-context = "wayland";
    };

    # Optional but recommended keybindings
    bindings = {
      "[" = "add speed -0.1";
      "]" = "add speed 0.1";
      "\\" = "set speed 1.0";
      "s" = "screenshot";
      "l" = "ab-loop";
    };
  };
}
