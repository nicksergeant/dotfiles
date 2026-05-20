{ pkgs, ... }:

{
  home = {
    username = "nsergeant";
    homeDirectory = "/Users/nsergeant";
    stateVersion = "25.11";

    packages = [
      pkgs.fzf
      pkgs.nixos-rebuild-ng
      pkgs.pnpm
      (pkgs.callPackage ./pkgs/ungoogled-chromium { })
    ];
  };

  programs.home-manager.enable = true;
}
