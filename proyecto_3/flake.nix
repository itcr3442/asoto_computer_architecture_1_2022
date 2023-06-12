{
  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
        overlays = [ self.overlays.default ];
      };
    in
    {
      devShells.${system} = with pkgs; {
        default = mkShell {
          nativeBuildInputs = [
            binutils
            gcc
            gdb
            gnumake
            (python3.withPackages (py: [ py.autopep8 py.iced-x86 ]))
            qemu
          ];
        };
      };

      formatter.${system} = pkgs.nixpkgs-fmt;

      overlays.default = self: prev: {
        python3 = prev.python3.override {
          packageOverrides = nextPy: prevPy: {
            iced-x86 = nextPy.callPackage ./iced-x86 { };
          };
        };
      };
    };
}
