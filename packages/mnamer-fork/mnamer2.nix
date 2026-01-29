{
  pkgs,
  fetchFromGitHub,
  ...
}:
pkgs.python3Packages.buildPythonApplication rec {
  pname = "mnamer2";
  version = "2.6.0";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "asfixia";
    repo = "mnamer";
    rev = "6c8331f115dd2331c03441446cee861d4a81e0a5";
    sha256 = "sha256-qpZFg325nbjjpVfwtkl5u5JN4JAmJvkOHaHVnY3MkGM=";
  };

  build-system = with pkgs.python3Packages; [
    setuptools
    setuptools-scm
  ];

  dependencies = with pkgs.python3Packages; [
    appdirs
    babelfish
    guessit
    requests
    requests-cache
    setuptools-scm
    teletype
    typing-extensions
    langdetect
    levenshtein
  ];

  pythonRelaxDeps = true;

  patches = [
    # https://github.com/jkwill87/mnamer/pull/291
    ./cached_session_error.patch
  ];

  nativeCheckInputs = [pkgs.python3Packages.pytestCheckHook];

  # disable test that fail (networking, etc)
  disabledTests = [
    "network"
    "e2e"
    "test_utils.py"
  ];
  disabledTestPaths = [
    "tests/network"
    "tests/e2e"
  ];

  meta = {
    homepage = "https://github.com/jkwill87/mnamer";
    description = "Intelligent and highly configurable media organization utility";
    mainProgram = "mnamer2";
    #license = lib.licenses.mit;
    #maintainers = with lib.maintainers; [urlordjames];
  };
}
