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

    token=$(cat ${config.sops.secrets.dynv6TokenACME.path})

    echo "Called acme Script with Params:\n"
    echo "Mode: ''${mode}\n"
    echo "Name: ''${name}\n"
    echo "Data: ''${data}\n"
    echo "SanitizedName: ''${sanitizedName}"

    if [ $mode == "present" ]; then
      ${pkgs.curlFull}/bin/curl -v -X POST https://dynv6.com/api/v2/zones/5211604/records \
      -H "Authorization: Bearer ''${token}" \
      -H "Accept: application/json" \
      -H "Content-Type: application/json" \
      -d "{\"name\":\"''${sanitizedName}\",\"data\":\"''${data}\",\"type\":\"TXT\"}"
    fi

    if [ $mode == "cleanup" ]; then
      ID="$(${pkgs.curlFull}/bin/curl -s -X GET https://dynv6.com/api/v2/zones/5211604/records \
      -H "Authorization: Bearer ''${token}" \
      -H "Accept: application/json" | ${pkgs.jq}/bin/jq --args "map(select(.type == \"TXT\" and .data == \"''${data}\" and .name == \"''${sanitizedName}\")).[0].id"
      )"
      echo "Deleting entry with ID ''${ID}"
      ${pkgs.curlFull}/bin/curl -v -X DELETE https://dynv6.com/api/v2/zones/5211604/records/''${ID} \
      -H "Authorization: Bearer ''${token}"
    fi
  '';
  acmeEnvironmentFile = pkgs.writeText "ACMEDynDnsEnvFile" ''
    EXEC_PATH=${acmeDnsScript}
  '';
in {
  sops.secrets.dynv6TokenACME = {
    owner = "acme";
    group = "nginx";
    key = "dynv6Token";
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
