{
  pkgs,
  lib,
}: let
  python = pkgs.python311.override {
    packageOverrides = final: prev: {
      "peewee-migrate" = prev.buildPythonPackage {
        pname = "peewee-migrate";
        version = "1.6.1";
        src = pkgs.fetchurl {
          url = "https://files.pythonhosted.org/packages/a1/f1/ef01c1358a34bc60925dc159c9616ee97436a2b86922cea18980772e8c70/peewee_migrate-1.6.1-py3-none-any.whl";
          sha256 = "1l28h739ina4y870vkcd7nsbs1603ca2qszkjbbwa42av15xh642";
        };
        format = "wheel";
        doCheck = false;
        buildInputs = [];
        checkInputs = [];
        nativeBuildInputs = [];
        propagatedBuildInputs = [
          final."click"
          final."peewee"
        ];
      };
      "swagger-ui-py" = prev.buildPythonPackage {
        pname = "swagger-ui-py";
        version = "23.9.23";
        src = pkgs.fetchurl {
          url = "https://files.pythonhosted.org/packages/c0/e6/be065ce1553646836a706a788bb6251b01e2dd2c7a080ff2dbdcfa7df6ca/swagger_ui_py-23.9.23-py3-none-any.whl";
          sha256 = "0xrxfz4p2zh898x9q2rlx62r642zh0y98lhql5ssgxk73ldbhvz8";
        };
        format = "wheel";
        doCheck = false;
        buildInputs = [];
        checkInputs = [];
        nativeBuildInputs = [];
        propagatedBuildInputs = [
          final."PyYaml"
          final."jinja2"
          final."packaging"
        ];
      };
    };
  };
in
  python.pkgs.buildPythonApplication rec {
    pname = "unmanic";
    format = "wheel";
    version = "0.2.6";
    src = python.pkgs.fetchPypi {
      inherit pname version format;
      sha256 = "sha256-tbjqOvBetQ3c+IZCFDdenTS8GnBEccDJJIa7QQQVTOk=";
      dist = "py3";
      python = "py3";
    };

    dependencies = with python.pkgs; [
      pkgs.psutils
      schedule
      tornado
      marshmallow
      peewee
      peewee-migrate
      psutil
      requests
      requests-toolbelt
      py-cpuinfo
      watchdog
      inquirer
      markupsafe
      pyyaml
      blessed
      certifi
      charset-normalizer
      click
      editor
      idna
      inquirer
      jinja2
      packaging
      readchar
      runs
      schedule
      six
      urllib3
      wcwidth
      xmod
      "swagger-ui-py"
    ];

    meta = with lib; {
      description = "Unmanic - Library Optimiser";
      homepage = "https://docs.unmanic.app/";
      license = licenses.gpl3Only;
      platforms = platforms.unix;
      mainProgram = "unmanic";
    };
  }
