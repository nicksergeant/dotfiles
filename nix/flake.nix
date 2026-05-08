{
  description = "Workstation packages (macOS) — pinned binaries, hash-verified, supply-chain-conservative.";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

  outputs = { self, nixpkgs }:
    let
      systems = [ "aarch64-darwin" "x86_64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          ungoogled-chromium = pkgs.callPackage ./pkgs/ungoogled-chromium { };
        }
      );
    };
}
