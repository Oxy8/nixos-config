
# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];
    
  # -------------------------------------------------------------------
  # NIX

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable the "nix *" commands (expected to substitute the current "nix-*" commands) and flakes.
  nix.settings.experimental-features = ["nix-command" "flakes"];
  
  # Enable direnv
  programs.direnv.enable = true;

  # Enable nix-ld for running unpatched dynamic libraries.
  programs.nix-ld.enable = true;

  # -------------------------------------------------------------------
  # BOOTLOADER
  
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";

  # -------------------------------------------------------------------
  
  networking.hostName = "V15";

  # -------------------------------------------------------------------
  
  networking.firewall.enable = false;

  # -------------------------------------------------------------------
  # LOCALE

  time.timeZone = "America/Sao_Paulo";

  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_BR.UTF-8";
    LC_IDENTIFICATION = "pt_BR.UTF-8";
    LC_MEASUREMENT = "pt_BR.UTF-8";
    LC_MONETARY = "pt_BR.UTF-8";
    LC_NAME = "pt_BR.UTF-8";
    LC_NUMERIC = "pt_BR.UTF-8";
    LC_PAPER = "pt_BR.UTF-8";
    LC_TELEPHONE = "pt_BR.UTF-8";
    LC_TIME = "pt_BR.UTF-8";
  };

  # ------------------------------------------------------------------
  # HARDWARE ACCELERATION

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
    ];
  };
  
  # ------------------------------------------------------------------
  # SWAP + SUSPEND
  
  # /etc/nixos/V15 $ find kernel | cpio -H newc --create > acpi_override
  # acpi_override has a modified version of dsdt.aml which allows for S3 sleep
  boot.initrd.prepend = [ "${/etc/nixos/V15/acpi_override}" ];

  # sets S3 sleep as default
  boot.kernelParams = [ "mem_sleep_default=deep" ];
  
  # Swap file creation
  boot.initrd.systemd.enable = true;  
  swapDevices = [ {
      device = "/var/swapfile";
      size = 8*1024; # 8GB
    } ];

  # Temporary fix for computer not suspending properly when closing the lid.
  boot.kernelPackages = pkgs.linuxPackages_6_6;

  # ------------------------------------------------------------------
  # DESKTOP ENVIRONMENT

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "estevan";

  # Enables Gnome DE
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  environment.gnome.excludePackages = (with pkgs; [
    gnome-tour
  ]);
  
  services.gnome.games.enable = false;
  
  # Enable rygel
  #services.gnome.rygel.enable = true;

  # Workaround for https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # -------------------------------------------------------------------
  # KEYBOARD

  # Configure keymap in X11 (XWayland compatibility) (don't know if needed, but it ain't hurting no one)
  services.xserver.xkb = {
    layout = "br";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "br-abnt2";

  # Add fonts
  fonts.packages = with pkgs; [
    fira-code
    fira-code-symbols
    ibm-plex
  ];

  
  # -------------------------------------------------------------------
  # BASH

  # Sets PS1 appearance normally and when within a nix develop environment.
  programs.bash.promptInit =
    ''PS1="\[\e]0;\u@\h: \w\a\]\[$(tput bold)\]\[$(tput setaf 39)\]\u\[$(tput setaf 45)\]@\[$(tput setaf 51)\]\h \[$(tput setaf 195)\]\w \[$(tput sgr0)\]$ "'';
  nix.extraOptions = 
    ''bash-prompt-prefix = \[$(tput setaf 27)\](nix develop) \[$(tput sgr0)\]'';  

  # Sets additional bash aliases
  programs.bash.shellAliases = {
    ll = "ls -l";
    mv = "mv -i";
    gted = "gnome-text-editor";
  };

  # Make bash auto-completion case-insensitive
  environment.etc.inputrc.source = ./inputrc;
  
  # -------------------------------------------------------------------
  # PRINTING

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable Avahi and mDNS NSS
  services.avahi = {
  	enable = true;
  	nssmdns4 = true;
  	openFirewall = true;
  };
  
  # Leave it enabled for increasing the chances of being able to use a foreign printer, but it serves
  # no purpose to the brother printer at home, which requires drivers to be installed.

  # -------------------------------------------------------------------
  # SOUND

  # Enable sound with pipewire.
  #hardware.alsa.enable = true;
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # -------------------------------------------------------------------  

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.estevan = {
    isNormalUser = true;
    description = "Estevan Küster";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      firefox
      google-chrome
      onlyoffice-bin
      # wineWowPackages.stable
      # mono # .NET replacement for wine
      fragments # Torrent
      ghex
      dconf-editor
      discord
      spotify
      prismlauncher
      inputs.nix-software-center.packages.${system}.nix-software-center
      thunderbird
      foliate
      openvpn
      nnn
      pass
    ];
  };
  
  # Firmware Update Daemon
  services.fwupd.enable = true;

  # -------------------------------------------------------------------
  # VM

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    lshw
    # linuxKernel.packages.linux_6_1.vmware
    # vmware-workstation
  ];


  #=-=-=-=-=
  # Docker
  #  virtualisation.docker.enable = true;
  #  virtualisation.docker.daemon.settings = {
  #    data-root = "/home/estevan/Ambientes/.DOCKER";
  #  };
 
 
  #=-=-=-=-=
  # VMware
  # virtualisation.vmware.host.enable = true;	


  #=-=-=-=-=
  # VirtualBox
  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "estevan" ];


  # -------------------------------------------------------------------
  # GIT

  programs.git = {
    enable = true;
    config = {
      user = {
      	email = "34687508+Oxy8@users.noreply.github.com";
      	name = "Oxy8";
      	signingkey = "/home/estevan/.ssh/id_ed25519.pub";
      };
      
      core = {
      	editor = "micro";
      };
      
      init = {
        defaultBranch = "main";
      };

      gpg = {
      	format = "ssh";
      };

      commit = {
      	gpgsign = "true";
      };
    };
  };

  # -------------------------------------------------------------------
  # SSH

  # Enable the OpenSSH daemon.
  services.openssh = {
  	enable = true;
  	hostKeys = [
	  {
	    bits = 4096;
	    path = "/etc/ssh/ssh_host_rsa_key";
	    type = "rsa";
	  }
	  {
	    path = "/etc/ssh/ssh_host_ed25519_key";
	    type = "ed25519";
	  }
	];
  };

  # Specify the prefered algorithms the client wants to use when authenticating using a host key.
  # Needed to connect to portal.inf.ufrgs.br via ssh.
  programs.ssh.hostKeyAlgorithms = ["ssh-rsa" "ssh-ed25519"];

  programs.ssh.extraConfig =
  "
  Host *.inf.ufrgs.br
  User ekuster
  ";
  
  
  # -------------------------------------------------------------------
  

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
