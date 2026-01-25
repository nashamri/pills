let
  # Pin nixpkgs to a specific commit
  pkgs = import (fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/078d69f03934859a181e81ba987c2bb033eebfc5.tar.gz";
    sha256 = "sha256:0swjr1q8d1zrnmy7mlv6jywxbqifwf9sv9bpjns0lmc0icn3y87p";
  }) { };
in
pkgs.mkShell {
  buildInputs = with pkgs; [
    go
    gcc
    gtk3
    webkitgtk_4_1
    nodejs
    pkg-config
    upx
  ];

  GDK_BACKEND = "x11";

  shellHook = ''
    export PATH="$HOME/go/bin:$PATH"
  '';
}
