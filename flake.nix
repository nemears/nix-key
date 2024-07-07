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
                packages.sharkey = pkgs.stdenv.mkDerivation (finalAttrs: rec {
                    pname = "sharkey";
                    version = "2024.5.1";
                    src = pkgs.fetchFromGitLab {
                        domain = "activitypub.software";
                        owner = "TransFem-org";
                        repo = "Sharkey";
                        rev = version;
			fetchSubmodules = true;
                        hash = "sha256-7x7zT88mncxc5jy+6E4uO+7ZNSBCOrIpxY9IxGV0UxM=";
                    };
                    pnpmDeps = pkgs.pnpm_9.fetchDeps{
                        inherit (finalAttrs) pname version src buildInputs;
                        hash = "";
			postInstall = ''
			    cd packages/frontend
			    pnpm install --frozen-lockfile --force
			'';
		    };
                    nativeBuildInputs = with pkgs; [ pnpm_9.configHook ];
                    buildInputs = with pkgs; [ pnpm_9 nodejs_20 python3 ];
                    buildPhase = 
                        ''
			    ls -la node_modules/.pnpm/v-code-diff@1.11.0_vue@3.4.26_typescript@5.4.5_/node_modules/v-code-diff/dist 
			    cp .config/example.yml .config/default.yml
			    NODE_ENV=production pnpm run --stream build
			'';
                    installPhase = 
                        ''
                            cp -r . $out
                        '';
                });
                packages.default = self.packages."${system}".sharkey;
            }        
        );
}
