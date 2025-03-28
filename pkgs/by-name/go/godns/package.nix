{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nodejs,
  npmHooks,
  fetchNpmDeps,
  nix-update-script,
}:

buildGoModule rec {
  pname = "godns";
  version = "3.2.2";

  src = fetchFromGitHub {
    owner = "TimothyYe";
    repo = "godns";
    tag = "v${version}";
    hash = "sha256-2VBgc+cp1IF3GprSt0oc5WOAepmV8dGhKjwodZ2JS6k=";
  };

  vendorHash = "sha256-cR+hlIGRPffP21lqDZmqBF4unS6ZyEvEvRlTrswg+js=";
  npmDeps = fetchNpmDeps {
    src = "${src}/web";
    hash = "sha256-lchAfi97a97TPs22ML3sMrlSZdvWMMC+wBrGbvke5rg=";
  };

  npmRoot = "web";
  nativeBuildInputs = [
    nodejs
    npmHooks.npmConfigHook
  ];

  overrideModAttrs = oldAttrs: {
    # Do not add `npmConfigHook` to `goModules`
    nativeBuildInputs = lib.remove npmHooks.npmConfigHook oldAttrs.nativeBuildInputs;
    # Do not run `preBuild` when building `goModules`
    preBuild = null;
  };

  # Some tests require internet access, broken in sandbox
  doCheck = false;

  preBuild = ''
    npm --prefix="$npmRoot" run build
    go generate ./...
  '';

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${version}"
  ];

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Dynamic DNS client tool supports AliDNS, Cloudflare, Google Domains, DNSPod, HE.net & DuckDNS & DreamHost, etc";
    homepage = "https://github.com/TimothyYe/godns";
    changelog = "https://github.com/TimothyYe/godns/releases/tag/v${version}";
    license = licenses.asl20;
    maintainers = with maintainers; [ yinfeng ];
    mainProgram = "godns";
  };
}
