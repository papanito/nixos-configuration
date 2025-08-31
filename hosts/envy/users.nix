{ pkgs, ... }: {
  users = {
    groups ={
      admin = {};
    };
    users = {
      admin = {
        openssh.authorizedKeys.keys = [
         "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOrOn3Kj/+ztMtQAaq4pVvXgTsIs1ZOqQDbsA+nJMuRM admin@envy from clawfinger"
         "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFTCwPNpVjW6R9vqpKgNSWgGS5hZMZcHwexAMl7E/OI2 admin@envy from clawfinger"
        ];
        group = "admin";
        isNormalUser = true;
        extraGroups = [ "networkmanager" "wheel" ];
        packages = with pkgs; [];
      };
    };
  };
}
