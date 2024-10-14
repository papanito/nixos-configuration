{ config, pkgs, ... }:

{
   environment.systemPackages = with pkgs; [
      notify-desktop
   ];
   systemd.services = {
      "systemd-googlechat-notifier@" = {
         enable = true;
         description = "Send notifications to google chat endpoint";
         wantedBy = [ "default.target" ];
         after = [ "network.target" ];
         serviceConfig = {
            Type = "oneshot";
            User = "root";
         };
         scriptArgs = "-s %i -u '${config.sops.placeholder.GOOGLE_CHAT_KEY}'";
         script = ''
            #!/usr/bin/env bash
            # Send notifications to a chat channel about systemd service status
            SERVICE=restic-backups-b2
            URL=

            # Function: Print a help message.
            usage() {
               echo "Usage: $0 -s SERVICENAME -u URL -f" 1>&2
            }

            # Function: Exit with error.
            exit_abnormal() {
               usage
               exit 1
            }
            if [ "$#" -lt "4" ]; then
               exit_abnormal
            fi

            while getopts "u:s:f" option; do
               case $option in
                  s )
                     SERVICE=$OPTARG
                     echo $SERVICE
                     ;;
                  u )
                     URL=$OPTARG
                     ;;
                  f )
                     FULLSTATUS=true
                     ;;
                  \? )
                     exit_abnormal
                  ;;
                  *)
                     exit_abnormal
                  ;;
               esac
            done

            if [ -v FULLSTATUS ]; then
               svc_status=$(systemctl status --full $SERVICE)
            else
               svc_status=$(systemctl status $SERVICE | grep Active)
            fi
            svc_status=$(sed "s:'::g" <<< "$svc_status")
            hostname=`/run/current-system/sw/bin/hostname`

            if [[ $URL =~ "https://chat.googleapis.com/v1/spaces" ]]; then
               /run/current-system/sw/bin/curl --data "{'text':'*$SERVICE@$hostname*\n\`\`\`$svc_status\`\`\`'}" --header 'Content-Type: application/json; charset=UTF-8' --request POST $URL
            fi
         '';
      };
      "systemd-desktop-notifier@" = {
         enable = true;
         description = "Send notifications to desktop";
         wantedBy = [ "default.target" ];
         after = [ "network.target" ];
         serviceConfig = {
            Type = "oneshot";
            User = "root";
         };
         scriptArgs = "-s %i";
         script = ''
            #!/usr/bin/env bash
            # Send notifications to desktop using notify-send (libnotify)
            SERVICE=
            USERID=1000

            # Function: Print a help message.
            usage() {
            echo "Usage: $0 -s servicename -u username -f" 1>&2
            }

            # Function: Exit with error.
            exit_abnormal() {
            usage
            exit 1
            }

            if [ "$#" -lt "2" ]; then
               exit_abnormal
            fi

            while getopts ":s:u:f" option; do
               case $option in
                  s )
                     SERVICE=$OPTARG
                     ;;
                  f )
                     FULLSTATUS=true
                     ;;
                  u )
                     USERID=$(/run/current-system/sw/bin/id -u $OPTARG)
                     ;;
                  \? )
                     exit_abnormal
                  ;;
                  *)
                     exit_abnormal
                  ;;
               esac
            done
            if [ -v FULLSTATUS ]; then
               svc_status=$(systemctl status --full $SERVICE)
            else
               svc_status=$(systemctl status $SERVICE | grep Active)
            fi
            svc_status=$(sed "s:'::g" <<< "$svc_status")
            hostname=`/run/current-system/sw/bin/hostname`

            DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$USERID/bus /run/current-system/sw/bin/notify-desktop --app-name=$SERVICE $SERVICE@$hostname "svc_$status"
         '';
      };
   };
}