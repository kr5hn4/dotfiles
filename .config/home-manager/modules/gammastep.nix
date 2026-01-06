{lib, ...}: {
  services.gammastep = {
    enable = true;
    provider = "manual";
    temperature = {
      day = 6500; # Normal during day
      night = 3800; # Red/warm at night
    };
    dawnTime = "07:00-07:30"; # Start going back to normal at 7am (30 min fade)
    duskTime = "20:00-20:30"; # Start going red at 8pm (30 min fade)
    latitude = 0.0;
    longitude = 0.0;
  };
  systemd.user.services.gammastep = {
    Unit = {
      After = lib.mkForce [];
      PartOf = lib.mkForce [];
    };
    Install.WantedBy = lib.mkForce ["default.target"];
  };
}
