{
  config,
  pkgs,
  ...
}: {
  systemd.user.services.kanata = {
    Unit = {
      Description = "Kanata keyboard remapper";
      Documentation = "https://github.com/jtroo/kanata";
    };

    Service = {
      Type = "simple";
      ExecStart = "${pkgs.kanata}/bin/kanata -c ${config.home.homeDirectory}/.config/kanata/config.kbd";
      Restart = "on-failure";
      RestartSec = 3;
    };

    Install = {
      WantedBy = ["default.target"];
    };
  };
}
