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
    cp -R "Chromium.app" "$out/Applications/Chromium.app"
    runHook postInstall
  '';

  meta = {
    description = "Chromium without Google integration (community macOS binary, wrapped for Nix)";
    homepage = "https://ungoogled-software.github.io/";
    platforms = [ "aarch64-darwin" "x86_64-darwin" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
