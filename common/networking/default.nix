{ config, pkgs, name, ... }:
{
  imports = [
    ./dns.nix
    ./firewall.nix
    ./sshd.nix
  ];
  networking.hostName = name;

  boot.kernel.sysctl = {
  # Use BBR congestion control
    # By default, Linux uses "Cubic" congestion control, which is aggressive. It tries to find the maximum speed of the line by filling the "pipe" until it overflows. This "overflow" is what causes lag for everyone else.
  # Switching to BBR (Bottleneck Bandwidth and RTT) makes your NixOS box "listen" for congestion instead of just pushing until things break.
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.ipv4.tcp_mtu_probing" = 1; # 1 = enable when black hole detected, 2 = always on
    # Prevent "stuck" connections from hogging the router's NAT table
    "net.ipv4.tcp_fin_timeout" = 20;
    "net.ipv4.tcp_keepalive_time" = 600;
  };
}
