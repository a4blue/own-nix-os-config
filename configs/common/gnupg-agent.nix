{
  lib,
  config,
  ...
}:
lib.mkIf config.programs.gnupg.agent.enable {
  programs.ssh.startAgent = false;
  programs.gnupg.agent = {
    enableSSHSupport = true;
    settings = {
      default-cache-ttl = 3600;
      default-cache-ttl-ssh = 3600;
    };
  };
  environment =
    if config.modules.impermanenceExtra.enabled
    then {
      persistence."${config.modules.impermanenceExtra.defaultPath}" = {
        directories = [
        ];
      };
    }
    else {};
}
