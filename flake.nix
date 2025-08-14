{
  description = "Ephemeral Netdata-on-Docker environment for internship task";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          docker
          docker-compose
          bashInteractive
        ];

        shellHook = ''
          echo "=== Netdata Ephemeral Environment ==="
          echo "1. Starting Docker daemon in user namespace..."
          if ! pgrep dockerd > /dev/null; then
            dockerd-rootless-setuptool.sh install
            export PATH=/home/$USER/bin:$PATH
            export DOCKER_HOST=unix:///run/user/$(id -u)/docker.sock
            dockerd-rootless.sh > /tmp/dockerd.log 2>&1 &
            sleep 3
          fi
          echo "Docker ready. Run:"
          echo "  docker run -d --name=netdata -p 19999:19999 \\"
          echo "    --cap-add=SYS_PTRACE --security-opt apparmor=unconfined \\"
          echo "    netdata/netdata"
          echo
          echo "Then open: http://localhost:19999"
        '';
      };
    };
}
