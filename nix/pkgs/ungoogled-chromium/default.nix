{ stdenv, lib, fetchurl }:

let
  source = builtins.fromJSON (builtins.readFile ./source.json);
  arch = if stdenv.hostPlatform.isAarch64 then "arm64" else "x86_64";
  archSrc = source.${arch};
in
stdenv.mkDerivation {
  pname = "ungoogled-chromium";
  version = source.version;

  src = fetchurl {
    url = archSrc.url;
    hash = archSrc.hash;
  };

  # The .dmg ships an already-signed-and-notarized .app from upstream
  # ("Developer ID Application: Qian Qian (B9A88FL5XJ)", notarization stapled).
  # We need to preserve that signature end-to-end:
  #
  #   1. `undmg` silently strips macOS extended attributes during extraction
  #      (specifically `com.apple.FinderInfo`, which codesign uses for the
  #      resource-presence check). Use `hdiutil attach` + `ditto` instead —
  #      the same path brew cask uses, which preserves xattrs / resource
  #      forks / symlinks.
  #
  #   2. `dontFixup = true` skips the whole fixup phase. Otherwise nixpkgs
  #      Darwin stdenv runs strip / patch-rpath / signingHook / etc. against
  #      the .app's Mach-O binaries — those modifications invalidate the
  #      original codesign hash, which then triggers the signingHook to
  #      replace the upstream Developer ID signature with an ad-hoc one
  #      (`Sealed Resources=none, Format=adhoc`). Skipping fixup keeps the
  #      upstream signature intact.
  dontUnpack = true;
  dontFixup = true;

  installPhase = ''
    runHook preInstall

    mkdir -p mnt
    /usr/bin/hdiutil attach -nobrowse -readonly -mountpoint mnt "$src"
    trap '/usr/bin/hdiutil detach mnt 2>/dev/null || true' EXIT

    mkdir -p "$out/Applications"
    /usr/bin/ditto "mnt/Chromium.app" "$out/Applications/Chromium.app"

    /usr/bin/hdiutil detach mnt
    trap - EXIT

    runHook postInstall
  '';

  meta = {
    description = "Chromium without Google integration (community macOS binary, wrapped for Nix)";
    homepage = "https://ungoogled-software.github.io/";
    license = lib.licenses.bsd3;
    platforms = [ "aarch64-darwin" "x86_64-darwin" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
