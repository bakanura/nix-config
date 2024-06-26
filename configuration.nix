{ config, pkgs, ... }:

let
  # Fetch unstable channel
  unstableTarball =
    builtins.fetchTarball
      "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz";

  # Fetch hardware framework
  hardwareFramework =
    builtins.fetchTarball {
      url = "https://github.com/NixOS/nixos-hardware/archive/master.tar.gz";
      sha256 = "sha256:0w6d2nk498i0hqiimfxhxj7i9zhija9sybnhbyknwl7pkc4b7lkp";
    };

  # Fetch stable NixOS version
  nixpkgsTarball =
    builtins.fetchTarball
      "https://releases.nixos.org/nixos/24.05/nixos-24.05.tar.xz";

in
{
  # Import hardware configuration
  imports =
    [ # include the results of the hardware scan.
      (import "${hardwareFramework}/framework/13-inch/7040-amd")
      ./hardware-configuration.nix
    ];

  # Override packages in nixpkgs
  nixpkgs.config.packageOverrides = pkgs: {
    unstable = import unstableTarball {
      config = {
        allowUnfree = true;  # Example of using config settings
      };
    };
  };

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.hostName = "nixos"; # Define your hostname.
  networking.networkmanager.enable = true;
  networking.firewall.enable = false;
  networking.nameservers = [ "1.1.1.1" "8.8.8.8" ]; # Google's public DNS

  # Timezone and internationalization
  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # Auto CPU frequency management
  services.auto-cpufreq = {
    enable = true;
    settings = {
      battery = {
        governor = "powersave";
        turbo = "never";
      };
      charger = {
        governor = "performance";
        turbo = "auto";
      };
    };
  };

  # X11 and DisplayLink drivers
  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "displaylink" "modesetting" ];

  # Firmware updates with fwupd
  services.fwupd = {
    enable = true;
    extraRemotes = [ "lvfs-testing" ];
  };

  # GNOME Desktop Environment
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Keyboard and console keymap
  services.xserver.layout = "de";
  services.xserver.xkbVariant = "";
  console.keyMap = "de";

  # Printing with CUPS
  services.printing.enable = true;

  # Sound with Pipewire
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  nixpkgs.config.pulseaudio = true;
  hardware.pulseaudio.extraConfig = "load-module module-combine-sink";
  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
  };

  # Bluetooth settings
  hardware.bluetooth.settings = {
    General = {
      Experimental = true;
    };
  };

  # Shell aliases
  programs.bash.shellAliases = { mixer = "pulsemixer"; };

  # Libinput for touchpad support
  services.xserver.libinput.enable = true;

  # Thermal management
  services.thermald.enable = true;

  # OBS CAM setup
 # boot.extraModulePackages = with config.boot.kernelPackages; [
  #  pkgs.v4l2loopback
  #];
  #boot.extraModprobeConfig = ''
  #  options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1
  #  options v4l2loopback video_nr=2 card_label="Droidcam" width=640,1920 max_width=1920 height=480,1080 max_height=1080
  #'';

  # Polkit and RPC
  security.polkit.enable = true;
  services.rpcbind.enable = true;

  # NFS setup
  boot.initrd = {
    supportedFilesystems = [ "nfs" ];
    kernelModules = [ "nfs" ];
  };

#  fileSystems."/mnt/truenas/nfs" = {
 #   device = "192.168.1.117:/mnt/nextcloud-datapool";
  #  fsType = "nfs";
   # options = [ "x-systemd.automount" "noauto" ];
  #};

  # Fingerprint authentication
  services.fprintd.enable = true;
  security.pam.services.swaylock = {
    fprintAuth = true;
  };

  # Logitech wireless
  hardware.logitech.wireless = {
    enable = true;
    enableGraphical = true;
  };

  # User account
  users.users.bakanura = {
    isNormalUser = true;
    description = "bakanura";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      firefox
      libnfs
      nfs-utils
      notesnook
      joplin-desktop
      android-tools
      unstable.droidcam
      lutris
      unstable.wine
      discord
      unstable.steam
      thunderbird
      unstable.vscode
      unstable.terraform
      pulseaudioFull
      unstable.pulsemixer
      unstable.easyeffects
      unstable.ldacbt
      unstable.fprintd
      fwupd
      obs-studio
      unstable.v4l-utils
      unstable.buttercup-desktop
      unstable.keepass
      git
      unstable.rpi-imager
      angryipscanner
      drawio
      libreoffice
      ventoy-full
      usbutils
      krita
      nextcloud-client
      ungoogled-chromium
      opentabletdriver
      aws-sso-cli
      oversteer
      betterdiscordctl
      linuxKernel.packages.linux_zen.v4l2loopback

    ];
  };

  # Mullvad VPN
  services.mullvad-vpn.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Steam and gaming setup
  hardware.steam-hardware.enable = true;
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  # Automatic login
  services.xserver.displayManager.autoLogin = {
    enable = true;
    user = "bakanura";
  };

  # System packages
  environment.systemPackages = with pkgs; [
    pkgs.nfs-utils
    pkgs.firefox
    (pkgs.wrapFirefox (pkgs.firefox-unwrapped.override { pipewireSupport = true; }) {})
    pkgs.android-tools
    pkgs.droidcam
    pkgs.steam
    pkgs.v4l-utils
    pkgs.angryipscanner
    pkgs.ldacbt
    pkgs.fprintd
    pkgs.fwupd
    pkgs.obs-studio
    pkgs.buttercup-desktop
    pkgs.joplin-desktop
    pkgs.git
    pkgs.libnfs
    pkgs.rpi-imager
    pkgs.ventoy-full
    pkgs.krita
    (pkgs.wrapOBS {
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-backgroundremoval
        obs-pipewire-audio-capture
      ];
    })
    (vscode-with-extensions.override {
      vscodeExtensions = with vscode-extensions; [
        bbenoist.nix
        ms-python.python
        ms-azuretools.vscode-docker
        ms-vscode-remote.remote-ssh
      ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          name = "remote-ssh-edit";
          publisher = "ms-vscode-remote";
          version = "0.47.2";
          sha256 = "1hp6gjh4xp2m1xlm1jsdzxw9d8frkiidhph6nvl24d0h8z34w49g";
        }
      ];
    })
    pkgs.go
    pkgs.terraform
    pkgs.pulseaudioFull
    pkgs.notesnook
    pkgs.drawio
    pkgs.libreoffice
    pkgs.usbutils
    pkgs.mullvad-vpn
    pkgs.mullvad
    pkgs.nextcloud-client
    pkgs.ungoogled-chromium
    pkgs.opentabletdriver
    pkgs.oversteer
    pkgs.aws-sso-cli
    (pkgs.discord.override {
      withOpenASAR = true;
      withVencord = true;
    })
    pkgs.betterdiscordctl
    pkgs.linuxKernel.packages.linux_zen.v4l2loopback

  ];

  # State version
  system.stateVersion = "23.11";
}
