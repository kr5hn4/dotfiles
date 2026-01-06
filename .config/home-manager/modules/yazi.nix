{...}: {
  programs.yazi = {
    enable = true;

    settings = {
      mgr = {
        ratio = [2 2 4];
        sort_by = "mtime";
        sort_reverse = true;
        show_hidden = false;
        show_symlink = true;
      };

      opener = {
        play = [
          {
            run = ''mpv "$@"'';
            orphan = true;
            for = "unix";
          }
        ];

        edit = [
          {
            run = ''$EDITOR "$@"'';
            block = true;
            for = "unix";
          }
        ];

        open = [
          {
            run = ''xdg-open "$@"'';
            desc = "Open";
          }
        ];
      };

      plugin = {
        prepend_previewers = [
          {
            mime = "video/mp4";
            run = "mpv";
          }
        ];
      };
    };
  };
}
