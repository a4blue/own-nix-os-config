{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./tailscale.nix
  ];
  environment.persistence."/persistent" = {
    directories = [
      {
        directory = "/var/lib/tailscale-nginx-certs/";
        mode = "0777";
        user = "nginx";
        group = "nginx";
      }
    ];
  };

  systemd.services = {
    "tailscale-certs" = {
      description = "Generates and copies tailscale certs";
      after = ["tailscaled.service"];
      before = [
        "nginx.service"
      ];
      conflicts = ["shutdown.target"];
      unitConfig.DefaultDependencies = false;
      serviceConfig = {
        Type = "oneshot";
        Restart = "on-failure";
        RestartMode = "direct";
        RemainAfterExit = true;
      };
      # TODO
      # making it extensible would probably be great
      script = ''
        # Give tailscale some time to init
        sleep 10
        # TODO
        # checking if cert is valid before getting a new one would be great
        ${pkgs.tailscale}/bin/tailscale cert homelab.armadillo-snake.ts.net
        cp /var/lib/tailscale/certs/homelab.armadillo-snake.ts.net.crt /var/lib/tailscale-nginx-certs/
        cp /var/lib/tailscale/certs/homelab.armadillo-snake.ts.net.key /var/lib/tailscale-nginx-certs/
        chown nginx:nginx /var/lib/tailscale-nginx-certs/homelab.armadillo-snake.ts.net.crt /var/lib/tailscale-nginx-certs/homelab.armadillo-snake.ts.net.key
        chmod 640 /var/lib/tailscale-nginx-certs/homelab.armadillo-snake.ts.net.crt /var/lib/tailscale-nginx-certs/homelab.armadillo-snake.ts.net.key
      '';
    };
  };
}
