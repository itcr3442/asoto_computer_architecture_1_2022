{ buildPythonPackage, cargo, lib, fetchPypi, setuptools-rust, rustc, rustPlatform }:
let
  pname = "iced-x86";
  version = "1.19.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-YljWeJNOk7eF1iPymarxNLj3rLnXJGC/Qsajb9YWXnE=";
  };
in
buildPythonPackage {
  inherit pname src version;

  nativeBuildInputs = [
    cargo
    rustc
    rustPlatform.cargoSetupHook
    setuptools-rust
  ];

  # Esta gente no le puso Cargo.lock
  cargoDeps = rustPlatform.importCargoLock {
    lockFile = ./Cargo.lock;
  };

  patches = [
    ./0001-add-Cargo.lock.patch
  ];
}
