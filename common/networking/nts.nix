{ config, ... }:
{
  services.chrony = {
    enable = true;
    enableNTS = true;
    servers = [
      "time.cloudflare.com iburst nts"
      "ntppool1.time.nl iburst nts"
      "nts.netnod.se iburst nts"
      "ptbtime1.ptb.de iburst nts"
      "time.dfm.dk iburst nts"
      "time.cifelli.xyz iburst nts"
     ];
  };
}

