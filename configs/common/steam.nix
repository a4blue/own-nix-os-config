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

    # Rebind driver to xpadneo
    ACTION=="bind", SUBSYSTEM=="hid", DRIVER!="xpadneo", KERNEL=="0005:045E:*", KERNEL=="*:02FD.*|*:02E0.*|*:0B05.*|*:0B13.*|*:0B20.*|*:0B22.*", ATTR{driver/unbind}="%k", ATTR{[drivers/hid:xpadneo]bind}="%k"

    # Tag xpadneo devices for access in the user session
    # MODE="0664" allows user read/write access for proper Steam Input detection
    # LIBINPUT_IGNORE_DEVICE prevents desktop environments from using controller as mouse
    ACTION!="remove", DRIVERS=="xpadneo", SUBSYSTEM=="input", ENV{ID_INPUT_JOYSTICK}=="1", TAG+="uaccess", MODE="0664", ENV{LIBINPUT_IGNORE_DEVICE}="1"

    # Allow hidraw access for Steam Input to properly detect controller models and features
    # This is needed with PID spoofing disabled (default) for Elite paddle detection
    ACTION!="remove", DRIVERS=="xpadneo", SUBSYSTEM=="hidraw", TAG+="uaccess", MODE="0660"
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

  users.users.a4blue.extraGroups = ["gamemode"];
}
