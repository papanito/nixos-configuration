{
  config,
  pkgs,
  name,
  ...
}:
{
  systemd.user.services.tuios-daemon = {
    Unit = {
      Description = "TUIOS Background Daemon";
      After = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = "${pkgs.tuios}/bin/tuios daemon";
      Restart = "always";
      RestartSec = 3;
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
