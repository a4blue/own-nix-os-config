{
  config,
  pkgs,
  ...
}: {
  boot.kernelPatches = [
    {
      # @see https://bugzilla.kernel.org/show_bug.cgi?id=219968
      name = "avoid-reset-after-failed-handshake";
      patch = ./kernel-patch/avoid-reset-after-failed-handshake.patch;
    }
  ];
}
