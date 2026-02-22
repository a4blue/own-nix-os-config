{
  config,
  pkgs,
  ...
}: let
  acmeDnsScript = pkgs.writeScript "acme.sh" ''
    #! ${pkgs.stdenv.shell}

    mode=$1
    name=$2
    data=$3
    # Lego passes the name with a dot at the end
    baseDomain="home.a4blue.me."
    sanitizedName=''${name%.$baseDomain}

    secret=$(cat ${config.sops.secrets.spaceshipApiSecretACME.path})
    key=$(cat ${config.sops.secrets.spaceshipApiKeyACME.path})

    echo "Called acme Script with Params:\n"
    echo "Mode: ''${mode}\n"
    echo "Name: ''${name}\n"
    echo "Data: ''${data}\n"
    echo "SanitizedName: ''${sanitizedName}"

    if [ $mode == "present" ]; then
      ${pkgs.curlFull}/bin/curl -v -X PUT https://spaceship.dev/api/v1/dns/records/a4blue.me \
        -H "X-API-Key: ''${key}"
        -H "X-API-Secret: ''${secret}"
        -H "Accept: application/json"
        -H "Content-Type: application/json"
        -d "{"force":true,"items":[{"type":"TXT","value":"''${data}","name":"''${sanitizedName}.home","ttl":60}"
    fi

    if [ $mode == "cleanup" ]; then
      ${pkgs.curlFull}/bin/curl -v -X DELETE https://spaceship.dev/api/v1/dns/records/a4blue.me \
        -H "X-API-Key: ''${key}"
        -H "X-API-Secret: ''${secret}"
        -H "Accept: application/json"
        -H "Content-Type: application/json"
        -d "{"force":true,"items":[{"type":"TXT","value":"''${data}","name":"''${sanitizedName}.home","ttl":60}"
    fi
  '';
  acmeEnvironmentFile = pkgs.writeText "ACMEDynDnsEnvFile" ''
    EXEC_PATH=${acmeDnsScript}
  '';
in {
  sops.secrets.spaceshipApiSecretACME = {
    owner = "acme";
    group = "nginx";
    key = "spaceshipApiSecret";
  };
  sops.secrets.spaceshipApiKeyACME = {
    owner = "acme";
    group = "nginx";
    key = "spaceshipApiKey";
  };

  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "a4blue@hotmail.de";
      dnsResolver = "1.1.1.1:53";
    };
    certs = {
      "home.a4blue.me" = {
        domain = "*.home.a4blue.me";
        group = "nginx";
        dnsProvider = "exec";
        environmentFile = acmeEnvironmentFile;
      };
    };
  };
}
