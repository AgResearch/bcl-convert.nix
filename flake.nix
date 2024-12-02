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

          # extend as required
          default_version = "v4_2_7";

          available_versions = {
            "v4_2_7" = {
              version = "4.2.7-2";
              hash = "sha256-6lCNdj3CfTDRo09qONjaMepneX17SXHowQZ3vEhTlWU=";
            };

            "v4_2_4" = {
              version = "4.2.4-2";
              hash = "sha256-/p8DQ+/AV5TVCPAk1d3JOXZItw0PGkMMTgPVKW5hoVw=";
            };
          };

          bcl-convert = ver:
            with pkgs;
            with available_versions.${ver};
            stdenv.mkDerivation rec {
              pname = "bcl-convert";
              arch = builtins.head (lib.strings.splitString "-" system);

              inherit version;
              inherit hash;

              src = fetchurl {
                url = "https://s3.amazonaws.com/webdata.illumina.com/downloads/software/bcl-convert/bcl-convert-${version}.el7.${arch}.rpm";
                inherit hash;
              };

              buildInputs = [
                stdenv.cc.cc.lib
                xz
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
          devShells = {
            default = mkShell {
              buildInputs = [ (bcl-convert default_version) ];
            };
          } // builtins.mapAttrs
            (ver: _:
              mkShell {
                buildInputs = [ (bcl-convert ver) ];
              }
            )
            available_versions;

          packages = {
            default = bcl-convert default_version;
          } // builtins.mapAttrs (ver: _: bcl-convert ver) available_versions;
        }
      );
}
