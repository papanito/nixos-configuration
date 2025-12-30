{ lib, config, pkgs, ... }:
{
  # see ../servers/users.nix
  # Disable the default RPi user
  users.users.nixos = {
    extraGroups = lib.mkForce [ ];
    isNormalUser = lib.mkForce false;
    # This ensures the user is effectively disabled in /etc/passwd
  };
  
  # Ensure your admin is the only one with wheel access
  users.mutableUsers = false; # Prevents 'passwd' from working, forces declarative state

  users.users.root = {
    # Locking the account password
    hashedPassword = "!"; 
    
    # Ensure no SSH keys are snuck in from the RPi base profiles
    openssh.authorizedKeys.keys = lib.mkForce [ ];
  };
}
