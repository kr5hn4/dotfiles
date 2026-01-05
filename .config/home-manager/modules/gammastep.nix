{...}: {
  services.gammastep = {
    enable = true;

    temperature = {
      day = 6500;
      night = 3800;
    };

    # Fixed schedule (no sunrise/sunset math)
    dawnTime = "07:00";
    duskTime = "20:00";

    # Required even when using fixed times
    latitude = 0.0;
    longitude = 0.0;
  };
}
