{
  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      devShells.${system} = with pkgs; {
        default = mkShell {
          nativeBuildInputs = [
            binutils
            gcc
            gdb
            gnumake
            (python39.withPackages (py: [ py.autopep8 ]))
            qemu
          ];
        };
      };

      formatter.${system} = pkgs.nixpkgs-fmt;
    };
}
