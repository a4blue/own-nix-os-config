{
  lib,
  config,
  ...
}:
lib.mkIf config.security.tpm2.enable {
  security = {
    tpm2 = {
      pkcs11.enable = true;
      tctiEnvironment.enable = true;
    };
  };

  users.users.a4blue.extraGroups = ["tss"];
}
