{
  lib,
  rustPlatform,
  fetchCrate,
  cmake,
  installShellFiles,
  pkg-config,
  ronn,
  stdenv,
  curl,
  libgit2,
  libssh2,
  openssl,
  zlib,
  darwin,
}:

rustPlatform.buildRustPackage rec {
  pname = "cargo-update";
  version = "16.2.0";

  src = fetchCrate {
    inherit pname version;
    hash = "sha256-dO8A4XAFms31hWVpZelMnDmn0sPpCh4S4byEVRYjOTI=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-DxY03sqr/upJbNm8EkoIN96SOhZr1jm/6dgtKwyDFEU=";

  nativeBuildInputs =
    [
      cmake
      installShellFiles
      pkg-config
      ronn
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      curl
    ];

  buildInputs =
    [
      libgit2
      libssh2
      openssl
      zlib
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      curl
      darwin.apple_sdk.frameworks.Security
    ];

  postBuild = ''
    # Man pages contain non-ASCII, so explicitly set encoding to UTF-8.
    HOME=$TMPDIR \
    RUBYOPT="-E utf-8:utf-8" \
      ronn -r --organization="cargo-update developers" man/*.md
  '';

  postInstall = ''
    installManPage man/*.1
  '';

  env = {
    LIBGIT2_NO_VENDOR = 1;
  };

  meta = with lib; {
    description = "Cargo subcommand for checking and applying updates to installed executables";
    homepage = "https://github.com/nabijaczleweli/cargo-update";
    changelog = "https://github.com/nabijaczleweli/cargo-update/releases/tag/v${version}";
    license = licenses.mit;
    maintainers = with maintainers; [
      gerschtli
      Br1ght0ne
      johntitor
      matthiasbeyer
    ];
  };
}
