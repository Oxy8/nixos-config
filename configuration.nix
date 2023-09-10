
# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # -------------------------------------------------------------------

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable broadcom drivers
  boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
  boot.kernelModules = [ "wl" ]; # set of kernel modules loaded in second stage of boot process
  boot.initrd.kernelModules = [ "kvm-intel" "wl" ]; # list of modules always loaded by the initrd, don't know if really necessary
  # It may be possible to disable initramfs entirely, check LinuxFromScratch post about it.

  # -------------------------------------------------------------------

  # Enable the "nix *" commands (expected to substitute the current "nix-*" commands) and flakes.
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # -------------------------------------------------------------------

  networking.hostName = "nixos"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  # Disables firewall
  networking.firewall.enable = false;

  # -------------------------------------------------------------------

  # Set your time zone.
  time.timeZone = "America/Sao_Paulo";

  # Select internationalisation properties.
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
  # Hardware acceleration
  
  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };
  
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      #intel-media-driver # Intel Broadwell and Skylake 
      vaapiIntel         
      #vaapiVdpau # Other GPUs
      #libvdpau-va-gl # Other GPUs
    ];
  };
  
  # ------------------------------------------------------------------

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable rygel
  #services.gnome.rygel.enable = true;

  # Enable automatic login for the user.
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "estevan";

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  environment.gnome.excludePackages = (with pkgs; [
    gnome-tour
  ]) ++ (with pkgs.gnome; [
    tali # poker game
    iagno # go game
    hitori # sudoku game
    atomix # puzzle game
  ]);

  # Workaround for https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # -------------------------------------------------------------------

  # Configure keymap in X11
  services.xserver = {
    layout = "br";
    xkbVariant = "";
  };

  # Configure console keymap
  console.keyMap = "br-abnt2";

  # Add fonts
  fonts.fonts = with pkgs; [
    fira-code
    fira-code-symbols
    ibm-plex
  ];

  
  # -------------------------------------------------------------------

  # Sets PS1 appearance normally and when within a nix develop environment.
  programs.bash.promptInit =
    ''PS1="\[\e]0;\u@\h: \w\a\]\[$(tput bold)\]\[$(tput setaf 39)\]\u\[$(tput setaf 45)\]@\[$(tput setaf 51)\]\h \[$(tput setaf 195)\]\w \[$(tput sgr0)\]$ "'';
  nix.extraOptions = 
    ''bash-prompt-prefix = \[$(tput setaf 27)\](nix develop) \[$(tput sgr0)\]'';  
  
  # -------------------------------------------------------------------
  # Set additional bash aliases

  programs.bash.shellAliases = {
    ll = "ls -l";
    mv = "mv -i";
  };

  # -------------------------------------------------------------------
  # Make bash auto-completion case-insensitive

  environment.etc.inputrc.source = ./inputrc;
  
  # -------------------------------------------------------------------

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable Avahi and mDNS NSS
  services.avahi = {
  	enable = true;
  	nssmdns = true;
  	openFirewall = true;
  };
  
  # Leave it enabled for increasing the chances of being able to use a foreign printer, but it serves
  # no purpose to the brother printer at home, which requires drivers to be installed.
  # It may be possible to make the printer at home work without installing drivers,
  # but my efforts so far have been in vain.

  # -------------------------------------------------------------------

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;

    # Use the example session manager instead of wirepumbler.
    # As of 17-03-2023: 
    # * wireplumber is causing an OOM state due to a bad memory leak.
    # * wireplumber also seems to be responsible for media being paused when changing volume using XF86Audio[Raise|Lower]Volume keys
    media-session.enable = true;
    wireplumber.enable = false;
  };

  # -------------------------------------------------------------------

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.estevan = {
    isNormalUser = true;
    description = "Estevan Küster";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      firefox
      ncdu
      bc
      onlyoffice-bin
      gitg
      wineWowPackages.stable
      mono # .NET replacement for wine
      fragments # Torrent
      gnome.ghex
      gnome.gnome-boxes
      gnome.dconf-editor
      discord
      prismlauncher
    ];
  };

  # -------------------------------------------------------------------
  # Needed for Gnome-Boxes
	virtualisation.libvirtd.enable = true;
  # -------------------------------------------------------------------

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    micro
    lshw
  ];

  # -------------------------------------------------------------------

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

  # Since august 2022, github supports SSH commit verification, so GPG is not needed anymore
  # https://github.blog/changelog/2022-08-23-ssh-commit-verification-now-supported/
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # -------------------------------------------------------------------

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Specify the prefered algorithms the client wants to use when authenticating using a host key.
  # Needed to connect to portal.inf.ufrgs.br via ssh.
  programs.ssh.hostKeyAlgorithms = ["ssh-rsa" "ssh-ed25519"];  

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

}
