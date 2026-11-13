{ config, ... }:
{
  # Tailscale runs on every host (workstation, servers, RPi) as a client node and
  # joins the tailnet automatically from the sops-managed auth key.
  # `useRoutingFeatures = "client"` relaxes the firewall's reverse-path check
  # for tunnel traffic without turning any host into a router.
  #
  # The key lives in `secrets/secrets.yaml` (encrypted to every host and both
  # admins); rotate it there with `sops secrets/secrets.yaml`. A reusable,
  # non-ephemeral, pre-approved key is required so all five hosts can join and
  # survive reboots.
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
    openFirewall = true;
    authKeyFile = config.sops.secrets.tailscale_auth_key.path;
  };
}
