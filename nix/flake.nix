# ============================================================================
# First-time setup (bootstrap on a fresh machine, or first ever run)
# ----------------------------------------------------------------------------
# home-manager isn't installed yet, so build the activation script directly
# from this flake's pinned home-manager input and run it:
#
#   cd ~/Sources/dotfiles
#   git add nix/                   # flakes only see git-tracked files
#   cd nix
#   nix flake lock                 # creates flake.lock if missing
#   nix build .#homeConfigurations.nsergeant.activationPackage
#   ./result/activate
#
# After this, home-manager itself is in ~/.nix-profile/bin (because
# programs.home-manager.enable is set in home.nix), so future runs use the
# CLI directly (see "Steady-state" below).
#
# If `nix profile list` shows packages installed via the older
# `nix profile add` flow, remove them first so they don't conflict with the
# home-manager-managed profile:
#
#   nix profile list               # find the entry's Name
#   nix profile remove <name>
#
# ============================================================================
# Steady-state (any change to home.nix, or after bumping an input)
# ----------------------------------------------------------------------------
#
#   home-manager switch --flake ~/Sources/dotfiles/nix#nsergeant
#
# ============================================================================
# Bumping inputs (deliberate; never auto-update to HEAD)
# ----------------------------------------------------------------------------
# nixpkgs — channel-gated by hydra CI + branch protection; safe to advance to
# channel HEAD:
#
#   nix flake update nixpkgs
#
# home-manager — no equivalent gating, so apply a 10-day bake window (mirrors
# devex/nix.md and ungoogled-chromium's bin/update script). To bump:
#
#   gh api 'repos/nix-community/home-manager/commits?sha=release-25.11&per_page=30' \
#     --jq '.[] | "\(.commit.committer.date)  \(.sha[0:12])  \(.commit.message | split("\n")[0])"'
#
# Pick the newest line whose date is ≥10 days before today. Replace the SHA
# on the home-manager input below; then `nix flake lock`.
#
# After any bump, run the steady-state command above.
# ============================================================================
{
  description = "Nick Sergeant's Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    # Currently pinned: 0d02ec1d  (committed 2026-04-05). See "Bumping inputs"
    # at the top of this file for the bump procedure + 10-day rule.
    home-manager = {
      url = "github:nix-community/home-manager/0d02ec1d0a05f88ef9e74b516842900c41f0f2fe";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      ...
    }:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};
      homeConfig = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./home.nix ];
      };
    in
    {
      packages.${system}.ungoogled-chromium = pkgs.callPackage ./pkgs/ungoogled-chromium { };

      homeConfigurations."nsergeant" = homeConfig;

      # Re-export the activation derivation under `checks` so `nix flake
      # check` actually walks the home-manager module tree. Without this
      # the .githooks/pre-commit gate misses bugs in home.nix (typos,
      # missing options, etc.) — `homeConfigurations` isn't a well-known
      # flake output and `nix flake check` only force-evaluates the
      # documented schema (packages / devShells / checks / etc.).
      checks.${system}.home-config = homeConfig.activationPackage;

      # Dev shell with formatter / linter / spell-check tools used by the
      # repo's pre-commit hook (.githooks/pre-commit). All pinned via
      # flake.lock → nixpkgs.
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          nixfmt-rfc-style
          statix
          deadnix
          shellcheck
          typos
        ];
      };
    };
}
