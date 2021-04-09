{ pkgs ? import <nixpkgs> {} }:

with pkgs;

stdenv.mkDerivation {
  name = "gbkanren-env";
  buildInputs = [
    gambit
    gerbil
  ];
}
