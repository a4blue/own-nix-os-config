{
  lib,
  config,
  ...
}:
lib.mkIf config.services.gpg-agent.enable {
  services.ssh-agent.enable = false;
  services.gpg-agent = {
    enableSshSupport = true;
    extraConfig = ''
      default-cache-ttl = 3600
      default-cache-ttl-ssh = 3600
    '';
  };
  home =
    if config.modules.impermanenceExtra.enabled
    then {
      persistence."${config.modules.impermanenceExtra.defaultPath}" = {
        directories = [
          ".gnupg"
        ];
      };
    }
    else {};
}
