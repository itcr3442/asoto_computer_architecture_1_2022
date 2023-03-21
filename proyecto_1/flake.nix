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
            { biber, mkShell, texlive }:
            mkShell {
              nativeBuildInputs = [
                biber
                gnumake
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
