{
  outputs = { self, nixpkgs }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
  in {
    devShells."${system}" = with pkgs; {
      default = mkShell {
        buildInputs = [
          ncurses
          openssl
          SDL2
        ];

        nativeBuildInputs = [
          binutils
          gcc
          gdb
          gnumake
          gtkwave
          pkg-config
          (python39.withPackages (py: [ py.numpy py.pillow py.matplotlib ]))
          (quartus-prime-lite.override { supportedDevices = [ "Cyclone V" ]; })
          verilator
        ];

        shellHook = ''
          export MAKEFLAGS="AR=gcc-ar"
          export CXXFLAGS="-O3 -flto $(pkg-config --cflags sdl2 ncursesw)"
          export LDFLAGS="-O3 -flto $(pkg-config --libs sdl2 ncursesw)"

          # <https://discourse.nixos.org/t/fonts-in-nix-installed-packages-on-a-non-nixos-system/5871/7>
          export LOCALE_ARCHIVE="${glibcLocales}/lib/locale/locale-archive"
          export FONTCONFIG_FILE="${fontconfig.out}/etc/fonts/fonts.conf"
        '';
      };
    };
  };
}
