{
  config,
  pkgs,
  lib,
  ...
}: let
  servicePort = 9999;
  serviceDomain = "stash.home.a4blue.me";
in {
  sops.secrets = {
    stash_password = {
      owner = "stash";
      group = "stash";
    };
    stash_jwt_secret_key = {
      owner = "stash";
      group = "stash";
    };
    session_store_key = {
      owner = "stash";
      group = "stash";
    };
  };
  services.stash = {
    enable = true;
    dataDir = "/var/lib/stash-new";
    username = "a4blue";
    passwordFile = "${config.sops.secrets.stash_password.path}";
    jwtSecretKeyFile = "${config.sops.secrets.stash_jwt_secret_key.path}";
    sessionStoreKeyFile = "${config.sops.secrets.session_store_key.path}";
    mutablePlugins = true;
    mutableScrapers = true;
    openFirewall = false;
    settings = {
      stash = [
        {
          path = "/LargeMedia/smb/Porn-New";
          excludeimage = true;
        }
      ];
      port = servicePort;
      host = "127.0.0.1";
      notifications_enabled = false;
      scrapers_path = "${config.services.stash.dataDir}/scrapers";
      plugins_path = "${config.services.stash.dataDir}/plugins";
      generated = "${config.services.stash.dataDir}/generated";
      database = "${config.services.stash.dataDir}/go.sqlite";
      cache = "${config.services.stash.dataDir}/cache";
      blobs_path = "${config.services.stash.dataDir}/blobs";
    };
    #settings.sequential_scanning = true;
  };
  users.users.stash.extraGroups = ["smbUser" "LargeMediaUsers"];
  systemd.services.stash = {
    after = ["LargeMedia.mount" "bcachefs-large-media-mount.service"];
    serviceConfig = {
      RestartSec = 5;
      BindReadOnlyPaths = lib.mkForce [];
      BindPaths = lib.mkIf (config.services.stash.settings != {}) (map (stash: "${stash.path}") config.services.stash.settings.stash);
    };
    path = lib.mkForce (with pkgs; [
      ffmpeg-full
      (let
        stashapi = pkgs.python313.pkgs.buildPythonPackage rec {
          pname = "stashapi";

          version = "0.1.3";

          src = pkgs.fetchPypi {
            inherit pname version;

            hash = "sha256-VS7e8HgsPkkt+Nk6H4cQQppkvVuyu473KfX3gEtuG1c=";
          };

          doCheck = false;

          pyproject = true;

          build-system = with python313Packages; [
            hatchling
            hatch-vcs
            wheel
          ];
          dependencies = with python313Packages; [
            requests
          ];
        };
        stashapp-tools = pkgs.python313.pkgs.buildPythonPackage rec {
          pname = "stashapp-tools";

          version = "0.2.59";

          src = pkgs.fetchPypi {
            inherit pname version;

            hash = "sha256-Y52YueWHp8C2FsnJ01YMBkz4O2z4d7RBeCswWGr8SjY=";
          };

          doCheck = false;

          pyproject = true;

          build-system = with python313Packages; [
            wheel
            setuptools
          ];
          dependencies = with python313Packages; [
            requests
          ];
        };
      in
        python313.withPackages
        (
          ps:
            with ps; [
              # Renamer Plugin Dep
              #stashapi # seems to be included in stashapp-tools
              # LocalVisage Plugin Dep
              stashapp-tools
              absl-py
              aiofiles
              annotated-types
              anyio
              astunparse
              beautifulsoup4
              blinker
              certifi
              charset-normalizer
              click
              contourpy
              cycler
              deepface
              fastapi
              ffmpy
              filelock
              fire
              flask
              flask-cors
              flatbuffers
              fonttools
              fsspec
              gast
              gdown
              google-pasta
              gradio
              gradio-client
              groovy
              grpcio
              gunicorn
              h11
              h5py
              httpcore
              httpx
              huggingface-hub
              idna
              itsdangerous
              jinja2
              joblib
              keras
              kiwisolver
              libclang
              lz4
              markdown
              markdown-it-py
              markupsafe
              matplotlib
              mdurl
              ml-dtypes
              mpmath
              mtcnn
              namex
              networkx
              numpy
              opencv-python
              opt-einsum
              optree
              orjson
              packaging
              pandas
              pillow
              protobuf
              psutil
              py-cpuinfo
              pycryptodomex
              pydantic
              pydantic-core
              pydub
              pygments
              pyparsing
              pysocks
              python-dateutil
              python-multipart
              pytz
              pyyaml
              pyzipper
              requests
              retinaface
              rich
              ruff
              safehttpx
              scipy
              seaborn
              semantic-version
              setuptools
              shellingham
              six
              sniffio
              soupsieve
              starlette
              sympy
              tensorboard
              tensorboard-data-server
              tensorflow
              termcolor
              tf-keras
              tomlkit
              torch
              torchvision
              tqdm
              typer
              typing-extensions
              typing-inspection
              tzdata
              ultralytics
              ultralytics-thop
              urllib3
              uvicorn
              websockets
              werkzeug
              wheel
              wrapt
              # StarIdentifier Plugin Deps
              face-recognition
              numpy
              requests
            ]
        ))
      ruby
      coreutils-full
      findutils
    ]);
  };

  environment.persistence."${config.modules.impermanenceExtra.defaultPath}" = {
    directories = [
      {
        directory = "${config.services.stash.dataDir}";
        mode = "0740";
        user = "stash";
        group = "stash";
      }
    ];
  };

  services.nginx.virtualHosts."${serviceDomain}" = {
    forceSSL = true;
    useACMEHost = "home.a4blue.me";
    locations."/" = {
      recommendedProxySettings = true;
      proxyPass = "http://127.0.0.1:${builtins.toString servicePort}/";
      extraConfig = ''
        client_max_body_size 512M;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header X-Forwarded-Protocol $scheme;
      '';
    };
  };
}
