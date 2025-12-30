{ lib, config, pkgs, ...}:
{
  # allow nix-copy to live system
  nix.settings.trusted-users = [ "admin" ];
  services.getty.autologinUser = lib.mkForce null;

  users.users.admin = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
    ];
    initialHashedPassword = "$6$/f0v6HdHFSMjukeZ$0/QeGATuWXvhYcU60XPo6Vsqfb1hwIajKGsp90ZthLH8ionsXMFTBXyRXDA119.Ej0ldc35gT9ua0pePtwILI1";
    hashedPasswordFile = config.sops.secrets.default_password.path;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOrOn3Kj/+ztMtQAaq4pVvXgTsIs1ZOqQDbsA+nJMuRM admin@envy from clawfinger"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFTCwPNpVjW6R9vqpKgNSWgGS5hZMZcHwexAMl7E/OI2 admin@envy from clawfinger"
    ];
  };

  #users.users.root = {
  #  initialHashedPassword = "$6$/f0v6HdHFSMjukeZ$0/QeGATuWXvhYcU60XPo6Vsqfb1hwIajKGsp90ZthLH8ionsXMFTBXyRXDA119.Ej0ldc35gT9ua0pePtwILI1";
  #  hashedPasswordFile = config.sops.secrets.default_password.path;
  #};

  security.polkit.enable = true;

  # Allow passwordless sudo from admin user
  security = {
    pam = {
      rssh.enable     =  true;
      services = {
          sudo.rssh   =  true;
      };
    };
    sudo = {
      execWheelOnly  =  true;
      wheelNeedsPassword = false;
    };
  };
  
  #users.users.root.openssh.authorizedKeys.keys = [
  #  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOrOn3Kj/+ztMtQAaq4pVvXgTsIs1ZOqQDbsA+nJMuRM admin@envy from clawfinger"
  #  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFTCwPNpVjW6R9vqpKgNSWgGS5hZMZcHwexAMl7E/OI2 admin@envy from clawfinger"
  #];
}
