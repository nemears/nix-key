{
    description = "a nix flake for deploying sharkey";
    inputs = {
        flake-utils.url = "github:numtide/flake-utils";
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    outputs = { self, nixpkgs, flake-utils, ... } : 
        flake-utils.lib.eachDefaultSystem(
            system: 
            let
                pkgs = import nixpkgs {
                    inherit system;
                };
            in
            {
                packages.sharkey = pkgs.stdenv.mkDerivation rec {
                    pname = "sharkey";
                    version = "2024.5.1";
                    src = pkgs.fetchFromGitLab {
                        domain = "activitypub.software";
                        owner = "TransFem-org";
                        repo = "Sharkey";
                        rev = version;
                        hash = "sha256-3eBMaJ4GCRVgcalCKPyUeJCNNeQrqZ2cFw0wSp/JEok=";
                    };
                    pnpmDeps = pkgs.pnpm.fetchDeps{
                        inherit pname version src;
                        hash = "sha256-8cRTY76ATnvrhWe+Hz1iUWnvnN7Zimr7wBEsgpC1Knc=";
                    };
                    nativeBuildInputs = with pkgs; [ pnpm.configHook ];
                    buildInputs = with pkgs; [ pnpm nodejs_22 typescript python3 ];
                    buildPhase = 
                        ''
                            pnpm run build --max-old-space-size=4096
                        '';
                    installPhase = 
                        ''
                            cp -r . $out
                        '';
                };
                packages.default = self.packages."${system}".sharkey;
            }        
        );
}
