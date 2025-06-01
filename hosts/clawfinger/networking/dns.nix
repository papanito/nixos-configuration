{ config, pkgs, ... }:

{
  # networking.firewall = {
  #   allowedTCPPorts = [
  #     443
  #   ];
  #   allowedUDPPorts = [
  #     53
  #   ];
  # };

  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "aedu@wyssmann.com";
    };
  };

  services.nginx = {
    enable = true;
    virtualHosts = let
      SSL = {
        enableACME = true;
        forceSSL = true;
      }; in {
        "webcheck.local" = (SSL // {
          locations."/".proxyPass = "http://127.0.0.1:8888/";

        });
      };
  };
}
