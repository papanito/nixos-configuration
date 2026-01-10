{ config, pkgs, ... }:
{
   sops = {
      secrets.GOOGLE_CHAT_KEY = {
        sopsFile = ./secrets.yaml;
      };
   
      templates."googlechat.env".content = ''
        GOOGLE_CHAT_KEY=${config.sops.placeholder.GOOGLE_CHAT_KEY}
      '';
   };

   systemd.services = {
      "systemd-googlechat-notifier@" = {
         enable = true;
         description = "Send notifications to google chat endpoint";
         after = [ "network.target" ];
         serviceConfig = {
            Type = "oneshot";
            User = "root";
            EnvironmentFile = config.sops.templates."googlechat.env".path;
         };
         scriptArgs = "-s %i -j";
         script = builtins.readFile ../../scripts/google_notify.sh;
      };
   };
}
