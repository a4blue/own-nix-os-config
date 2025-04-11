{
  config,
  pkgs,
  ...
}: {
  boot.kernelPatches = [
    {
      name = "avoid-reset-after-failed-handshake";
      patch = ./kernel-patch/avoid-reset-after-failed-handshake.patch;
    }
  ];
}
