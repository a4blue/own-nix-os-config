{
  pkgs,
  config,
  inputs,
  lib,
  ...
}:
lib.mkIf config.programs.steam.enable {
  environment.systemPackages = with pkgs; [
    steamtinkerlaunch
  ];

  services.udev.extraRules = ''
    # https://wiki.archlinux.org/title/Gamepad#Gamepad_is_not_recognized_by_all_programs
    #ACTION=="add", KERNEL=="js[0-9]*", SUBSYSTEM=="input", KERNELS=="*045E:0B22*", ATTRS{bInterfaceSubClass}=="00", ATTRS{bInterfaceProtocol}=="00", ATTRS{bInterfaceNumber}=="02", RUN+="${pkgs.coreutils}/bin/rm /dev/input/js%n"
    #ACTION=="add", KERNEL=="event*", SUBSYSTEM=="input", KERNELS=="*045E:0B22*", ATTRS{bInterfaceSubClass}=="00", ATTRS{bInterfaceProtocol}=="00", ATTRS{bInterfaceNumber}=="02", RUN+="${pkgs.coreutils}/bin/rm /dev/input/event%n"
    # https://github.com/atar-axis/xpadneo/pull/559
    # Rebind driver to xpadneo
    ACTION=="bind", SUBSYSTEM=="hid", DRIVER!="xpadneo", KERNEL=="0005:045E:*", KERNEL=="*:02FD.*|*:02E0.*|*:0B05.*|*:0B13.*|*:0B20.*|*:0B22.*", ATTR{driver/unbind}="%k", ATTR{[drivers/hid:xpadneo]bind}="%k"

    # Tag xpadneo devices for access in the user session
    ACTION!="remove", DRIVERS=="xpadneo", SUBSYSTEM=="input", TAG+="uaccess"
    #FIXME(issue-291) Work around Steamlink not properly detecting the mappings
    #FIXME(issue-457) Word around QMK overriding our hidraw rules
    ACTION!="remove", DRIVERS=="xpadneo", SUBSYSTEM=="hidraw", MODE:="0000", TAG-="uaccess"
  '';

  programs = {
    steam = {
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      gamescopeSession.enable = true;
      protontricks.enable = true;
      extraCompatPackages = with pkgs; [proton-ge-bin steamtinkerlaunch];
      extest.enable = true;
    };
    gamemode.enable = true;
    nix-ld = {
      enable = true;
    };
    java.enable = true;
  };
  boot.kernelModules = ["ntsync"];
}
