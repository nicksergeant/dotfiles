{ stdenv, lib, fetchurl, undmg }:

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

  nativeBuildInputs = [ undmg ];
  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/Applications"
    # `ditto` (Apple's bundle-aware copy tool) preserves symlinks, xattrs, and
    # resource forks inside .app bundles — `cp -R` was breaking the codesign
    # signature by following Contents/CodeResources (a symlink to
    # _CodeSignature/CodeResources) and copying it as a regular file, leaving
    # `codesign --verify` reporting "code has no resources but signature
    # indicates they must be present" on a fresh-machine launch.
    /usr/bin/ditto "Chromium.app" "$out/Applications/Chromium.app"
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
