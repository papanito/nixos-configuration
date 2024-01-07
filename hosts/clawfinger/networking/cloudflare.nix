{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    cloudflared
    cloudflare-warp
  ];

    # systemd.packages = with pkgs; [
    #   cloudflare-warp
    # ];
  imports = [
    ./cloudflare-warp.nix
  ];
  services.cloudflare-warp = {
    enable = false;
    certificate = ./Cloudflare_CA.pem; # download here https://developers.cloudflare.com/cloudflare-one/connections/connect-devices/warp/install-cloudflare-cert/
  };
}

