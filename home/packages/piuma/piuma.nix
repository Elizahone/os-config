{
lib,
stdenvNoCC,
fetchurl,

autoPatchelfHook,
pam,
wayland,
libxkbcommon,
# vulkan-loader,
libglvnd,
stdenv,
}:

let
  pname = "piuma";
  version = "0.2.7";
in
  stdenvNoCC.mkDerivation {
    inherit pname version;

    src = fetchurl {
      url = "https://github.com/logicheneurali/piuma/releases/download/v${version}/${pname}-${version}-linux-x86_64.tar.gz";
      hash = "sha256-mYbEUBj3I90/Lj4LpVFvrj7to6nPW4oTf4SQlKKOQMU=";
    };

    sourceRoot = ".";

    dontBuild = true;

    nativeBuildInputs = [
      autoPatchelfHook
    ];

    buildInputs = [
      pam
      stdenv.cc.cc.lib
    ];

    runtimeDependencies = [
      wayland
      libxkbcommon
#       vulkan-loader
      libglvnd
    ];

    installPhase = ''
      runHook preInstall

      install -Dm755 piuma $out/bin/piuma
      install -Dm755 piuma-setup $out/bin/piuma-setup
      runHook postInstall
    '';

    meta = {
      description = "Piuma";
    };
  }

