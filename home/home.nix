{ config, pkgs, pkgs-unstable, ... } :

{
    home.sessionPath = [ "$HOME/.local/bin" ];
    xdg = {
        enable = true;
        configFile.nvim.source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/dot-config/nvim";
        configFile.herdr.source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/dot-config/herdr";
        configFile.foot.source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/dot-config/foot";
    };


  home.packages = with pkgs; [
    fastfetch
    wl-clipboard
    tree-sitter
    ripgrep
    unzip
    mihomo
    foot
    hyprlauncher
    htop
    uv

    pkgs-unstable.claude-code
  ];

  imports = [
    ./zsh
    # ./hyprland
  ];
  home.stateVersion = "26.05";
}
