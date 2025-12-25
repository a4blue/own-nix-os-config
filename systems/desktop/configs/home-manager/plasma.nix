{pkgs, ...}: {
  home.file.".local/share/color-schemes/EverforestHard.colors".source = ./EverforestHard.colors;
  programs.plasma = {
    enable = true;

    fonts = {
      fixedWidth = {
        family = "FiraCode Nerd Font Mono";
        pointSize = 10;
      };
      general = {
        family = "NotoSans Nerd Font";
        pointSize = 10;
      };
      menu = {
        family = "NotoSans Nerd Font";
        pointSize = 10;
      };
      small = {
        family = "NotoSans Nerd Font";
        pointSize = 8;
      };
      toolbar = {
        family = "NotoSans Nerd Font";
        pointSize = 10;
      };
      windowTitle = {
        family = "NotoSans Nerd Font";
        pointSize = 10;
      };
    };

    input.keyboard.numlockOnStartup = "on";

    krunner = {
      activateWhenTypingOnDesktop = true;
      historyBehavior = "enableSuggestions";
    };

    kscreenlocker = {
      appearance = {
        alwaysShowClock = true;
        showMediaControls = true;
      };
      autoLock = false;
      lockOnResume = true;
      timeout = 0;
    };

    kwin = {
      edgeBarrier = 0;
      cornerBarrier = false;
      borderlessMaximizedWindows = false;
      effects = {
        dimAdminMode.enable = true;
        shakeCursor.enable = true;
      };
    };

    #overrideConfig = true;

    panels = [
      {
        location = "bottom";
        screen = "all";
        floating = true;
        widgets = [
          {
            kickoff = {
              sortAlphabetically = true;
              icon = "nix-snowflake-white";
              sidebarPosition = "left";
            };
          }
          {
            iconTasks = {
              iconsOnly = true;
              appearance = {
                showTooltips = true;
                highlightWindows = true;
                indicateAudioStreams = true;
                fill = true;
              };
              launchers = [
                "applications:org.kde.plasma.settings.open.desktop"
                "applications:org.kde.dolphin.desktop"
                "applications:Alacritty.desktop"
                "applications:steam.desktop"
                "applications:${(builtins.elemAt pkgs.signal-desktop.out.desktopItems 0).name}"
                "applications:proton-pass.desktop"
                "applications:firefox.desktop"
              ];
            };
          }
          {
            systemTray = {
            };
          }
          {
            systemMonitor = {
              displayStyle = "org.kde.ksysguard.horizontalbars";
              showTitle = false;
              settings = {
                Appearance = {updateRateLimit = 1000;};
                "org.kde.ksysguard.facegrid/General" = {faceId = "org.kde.ksysguard.horizontalbars";};
                "FaceGrid/Appearance" = {
                  chartFace = "org.kde.ksysguard.horizontalbars";
                  showTitle = false;
                  updateRateLimit = 1000;
                };
              };
              sensors = [
                {
                  name = "cpu/all/usage";
                  color = "230,126,128";
                  label = "CPU";
                }
                {
                  name = "memory/physical/usedPercent";
                  color = "214,153,182";
                  label = "MEM";
                }
                {
                  name = "gpu/all/usage";
                  color = "230,152,117";
                  label = "GPU";
                }
                {
                  name = "gpu/all/usedVram";
                  color = "219,188,127";
                  label = "GPU MEM";
                }
              ];
            };
          }
          {
            digitalClock = {
            };
          }
        ];
      }
    ];

    powerdevil = {
      AC = {
        autoSuspend.action = "nothing";
        dimDisplay.enable = false;
        powerButtonAction = "showLogoutScreen";
        powerProfile = "performance";
        turnOffDisplay.idleTimeout = 600000;
        turnOffDisplay.idleTimeoutWhenLocked = 120;
      };
      battery = {
        autoSuspend.action = "nothing";
        dimDisplay.enable = false;
        powerButtonAction = "showLogoutScreen";
        powerProfile = "performance";
        turnOffDisplay.idleTimeout = 600000;
        turnOffDisplay.idleTimeoutWhenLocked = 120;
      };
      lowBattery = {
        autoSuspend.action = "nothing";
        dimDisplay.enable = false;
        powerButtonAction = "showLogoutScreen";
        powerProfile = "performance";
        turnOffDisplay.idleTimeout = 600000;
        turnOffDisplay.idleTimeoutWhenLocked = 120;
      };
    };

    workspace = {
      enableMiddleClickPaste = true;
      colorScheme = "EverforestHard";
      lookAndFeel = "org.kde.breezedark.desktop";
      cursor = {
        theme = "Breeze";
        size = 24;
      };
      theme = "breeze-dark";
      iconTheme = "Breeze Dark";
      #wallpaper = "${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/Patak/contents/images/1080x1920.png";
    };

    #
    # Some low-level settings:
    #
    configFile = {
      #baloofilerc.General = {
      #  "dbVersion" = 2;
      #  "exclude filters" = "*~,*.part,*.o,*.la,*.lo,*.loT,*.moc,moc_*.cpp,qrc_*.cpp,ui_*.h,cmake_install.cmake,CMakeCache.txt,CTestTestfile.cmake,libtool,config.status,confdefs.h,autom4te,conftest,confstat,Makefile.am,*.gcode,.ninja_deps,.ninja_log,build.ninja,*.csproj,*.m4,*.rej,*.gmo,*.pc,*.omf,*.aux,*.tmp,*.po,*.vm*,*.nvram,*.rcore,*.swp,*.swap,lzo,litmain.sh,*.orig,.histfile.*,.xsession-errors*,*.map,*.so,*.a,*.db,*.qrc,*.ini,*.init,*.img,*.vdi,*.vbox*,vbox.log,*.qcow2,*.vmdk,*.vhd,*.vhdx,*.sql,*.sql.gz,*.ytdl,*.tfstate*,*.class,*.pyc,*.pyo,*.elc,*.qmlc,*.jsc,*.fastq,*.fq,*.gb,*.fasta,*.fna,*.gbff,*.faa,po,CVS,.svn,.git,_darcs,.bzr,.hg,CMakeFiles,CMakeTmp,CMakeTmpQmake,.moc,.obj,.pch,.uic,.npm,.yarn,.yarn-cache,__pycache__,node_modules,node_packages,nbproject,.terraform,.venv,venv,core-dumps,lost+found";
      #  "exclude filters version" = 9;
      #};
      #baloofilerc."Basic Settings"."Indexing-Enabled" = true;
      kwinrc."Xwayland"."Scale" = 1.45;
    };
  };
}
