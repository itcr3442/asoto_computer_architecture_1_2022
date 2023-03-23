{
  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    with pkgs.lib; {
      formatter.${system} = pkgs.nixpkgs-fmt;

      devShells.${system} =
        let
          default =
            { biber, gdb, gnumake, mkShell, python3, texlive }:
            mkShell {
              nativeBuildInputs = [
                biber
                gdb
                gnumake
                (python3.withPackages (py: [ py.pillow ]))
                (texlive.combine {
                  inherit (texlive)
                    scheme-medium
                    biblatex
                    biblatex-ieee
                    cleveref
                    csquotes
                    enumitem
                    ieeetran;
                })
              ];
            };
        in
        {
          default = pkgs.callPackage default { };
        };
    };
}
