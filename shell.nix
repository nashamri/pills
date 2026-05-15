let
  pkgs = import <nixpkgs> { };
in
pkgs.mkShell {
  buildInputs = with pkgs; [
    go
    gcc
    gtk3
    webkitgtk_4_1
    nodejs
    pkg-config
    python3
    upx
  ];

  GDK_BACKEND = "x11";

  shellHook = ''
    export PATH="$HOME/go/bin:$PATH"
  '';
}
