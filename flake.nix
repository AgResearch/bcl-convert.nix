{
  description = "Flake for Illumina bcl-convert that converts the Binary Base Call (BCL) files produced by Illumina sequencing systems to FASTQ files";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs {
            inherit system;
          };

          bcl-convert =
            with pkgs;
            stdenv.mkDerivation rec {
            pname = "bcl-convert";
            version = "4.2.7-2";
            hash = "sha256-6lCNdj3CfTDRo09qONjaMepneX17SXHowQZ3vEhTlWU=";
            arch = builtins.head (lib.strings.splitString "-" system);

            src = fetchurl {
              url = "https://s3.amazonaws.com/webdata.illumina.com/downloads/software/bcl-convert/bcl-convert-${version}.el7.${arch}.rpm";
              inherit hash;
            };

            buildInputs = [
              stdenv.cc.cc.lib
              lzma
              udev
              zlib
            ];

            nativeBuildInputs = [
              autoPatchelfHook
            ];

            unpackPhase = ''
              ${rpmextract}/bin/rpmextract $src
            '';

            installPhase = ''
              runHook preInstall
              mkdir -p $out/bin
              cp usr/bin/bcl-convert $out/bin
              runHook postInstall
            '';
          };

        in
          with pkgs;
          {
            devShells.default = mkShell {
              buildInputs = [ bcl-convert ];
            };

            packages.default = bcl-convert;
          });
}
