#!/usr/bin/env bash
# Send notifications to a chat channel about systemd service status
SERVICE=restic-backups-b2.service
URL="${GOOGLE_CHAT_KEY}"

# Function: Print a help message.
usage() {
  echo "Usage: $0 -s SERVICENAME -u URL -f -j" 1>&2
}

# Function: Exit with error.
exit_abnormal() {
  usage
  exit 1
}

while getopts "u:s:fj" option; do
  case $option in
  s)
    SERVICE=$OPTARG
    echo $SERVICE
    ;;
  u)
    URL=$OPTARG
    echo "URL: $URL"
    ;;
  j)
    JOURNAL=true
    ;;
  f)
    FULLSTATUS=true
    ;;
  \?)
    exit_abnormal
    ;;
  *)
    exit_abnormal
    ;;
  esac
done

echo "# getting status of $SERVICE"
if [ -v JOURNAL ]; then
  if [ -v FULLSTATUS ]; then
    svc_status=$(journalctl -I -u $SERVICE)
  else
    svc_status=$(journalctl -I -u $SERVICE | grep systemd)
  fi
elif [ -v FULLSTATUS ]; then
  svc_status=$(systemctl status --full $SERVICE)
else
  svc_status=$(systemctl status $SERVICE | grep Active)
fi
svc_status=$(sed "s:'::g" <<<"$svc_status")
hostname=$(/run/current-system/sw/bin/hostname)

if [[ $URL =~ "https://chat.googleapis.com/v1/spaces" ]]; then
  /run/current-system/sw/bin/curl --data "{'text':'*$SERVICE@$hostname*\n\`\`\`$svc_status\`\`\`'}" --header 'Content-Type: application/json; charset=UTF-8' --request POST $URL
fi
