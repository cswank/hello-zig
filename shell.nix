with import (fetchTarball {
  url = "https://github.com/NixOS/nixpkgs/archive/refs/tags/25.05.tar.gz";
  sha256 = "1915r28xc4znrh2vf4rrjnxldw2imysz819gzhk9qlrkqanmfsxd";
}) {};

let
  zig = stdenv.mkDerivation rec {

    name = "zig";

    src = fetchFromGitHub {
      owner = "ziglang";
      repo = "zig";
      rev = "0.14.1";
      hash = "sha256-DhVJIY/z12PJZdb5j4dnCRb7k1CmeQVOnayYRP8azDI=";
    };

    nativeBuildInputs = [
      cmake
      llvmPackages_19.llvm.dev
    ];

    buildInputs = [
      coreutils
      libxml2
      zlib
    ] ++ (with llvmPackages_19; [
      libclang
      lld
      llvm
      libcxx
    ]);

    preBuild = ''
      export HOME=$TMPDIR;
    '';

    cmakeFlags = [
      # file RPATH_CHANGE could not write new RPATH
      "-DCMAKE_SKIP_BUILD_RPATH=ON"

      # ensure determinism in the compiler build
      "-DZIG_TARGET_MCPU=baseline"
    ];

    doCheck = true;
    installCheckPhase = ''
      $out/bin/zig test --cache-dir "$TMPDIR" -I $src/test $src/test/behavior.zig
    '';

  };
in
mkShell {
  nativeBuildInputs = [
    zig
  ];
}
