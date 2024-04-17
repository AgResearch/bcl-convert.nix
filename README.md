# bcl-convert.nix

This is a Nix Flake for Illumina BCL Convert, which provides both an installable package and a dev shell.

## Usage

As a devshell:

```
$ nix develop github:AgResearch/bcl-convert.nix
$ bcl-convert --version
bcl-convert Version 00.000.000.4.2.7

$ nix develop github:AgResearch/bcl-convert.nix#v4_2_4
$ bcl-convert --version
bcl-convert Version 00.000.000.4.2.4
Copyright (c) 2014-2018 Illumina, Inc.
```

From another flake, e.g. Home Manager:

```
{
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;

    bcl-convert = {
      url = github:AgResearch/bcl-convert.nix/main;
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { nixpkgs, bcl-convert, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      flakePkgs = {
        bcl-convert = bcl-convert.packages.${system};
      };

...

  packages = [
    flakePkgs.bcl-convert.v4_2_4
  ];
```
