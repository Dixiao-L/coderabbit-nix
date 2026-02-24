{ lib
, stdenv
, fetchurl
, unzip
, autoPatchelfHook
}:

let
  version = "0.3.6";

  # Platform-specific source URLs and hashes
  sources = {
    "x86_64-linux" = {
      url = "https://cli.coderabbit.ai/releases/${version}/coderabbit-linux-x64.zip";
      sha256 = "106k9ghp0xhijnfqpv44kall8pn967qlgi1z7xdad3f1lmbg1kjz";
    };
    "aarch64-linux" = {
      url = "https://cli.coderabbit.ai/releases/${version}/coderabbit-linux-arm64.zip";
      sha256 = lib.fakeHash;  # Update when needed
    };
    "x86_64-darwin" = {
      url = "https://cli.coderabbit.ai/releases/${version}/coderabbit-darwin-x64.zip";
      sha256 = lib.fakeHash;  # Update when needed
    };
    "aarch64-darwin" = {
      url = "https://cli.coderabbit.ai/releases/${version}/coderabbit-darwin-arm64.zip";
      sha256 = lib.fakeHash;  # Update when needed
    };
  };

  platformSource = sources.${stdenv.hostPlatform.system} or (throw "Unsupported platform: ${stdenv.hostPlatform.system}");

in
stdenv.mkDerivation {
  pname = "coderabbit";
  inherit version;

  src = fetchurl {
    inherit (platformSource) url sha256;
  };

  nativeBuildInputs = [ unzip ];

  # Handle zip extraction
  unpackPhase = ''
    runHook preUnpack
    unzip $src
    runHook postUnpack
  '';

  dontConfigure = true;
  dontBuild = true;

  # Critical: Do not strip or patch ELF - this corrupts the embedded Bun runtime
  dontStrip = true;
  dontPatchELF = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    install -m 755 coderabbit $out/bin/coderabbit
    ln -s $out/bin/coderabbit $out/bin/cr

    runHook postInstall
  '';

  meta = with lib; {
    description = "CodeRabbit CLI - AI-powered code review tool";
    homepage = "https://coderabbit.ai";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
    mainProgram = "coderabbit";
    maintainers = [ ];
  };
}
