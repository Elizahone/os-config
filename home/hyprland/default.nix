{ config, pkgs, ... }:

{

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = false;

    settings = {
        mod = {
          _var = "SUPER";
        };

    };
  };

  services.hyprpaper.enable = true;
  services.hyprlauncher.enable = true;
  home.packages = with pkgs; [
  ];

}
