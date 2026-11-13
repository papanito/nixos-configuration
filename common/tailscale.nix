{ ... }:
{
  # Tailscale runs on every host (workstation, servers, RPi) as a client node.
  # `useRoutingFeatures = "client"` relaxes the firewall's reverse-path check
  # for tunnel traffic without turning any host into a router.
  #
  # No `authKeyFile` is wired: the fleet has no reusable auth key in sops, and
  # an empty/expired key would make `tailscaled-autoconnect` fail on every
  # boot. Joining the tailnet is a one-time manual step per host:
  #
  #   clawfinger: run0 tailscale up
  #   servers:    sudo tailscale up
  #
  # To later automate the join, add the key to sops and set
  # `services.tailscale.authKeyFile = config.sops.secrets.tailscale_auth_key.path`.
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
    openFirewall = true;
  };
}
