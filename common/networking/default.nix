{
  config,
  pkgs,
  name,
  ...
}:
{
  imports = [
    ./dns.nix
    ./firewall.nix
    ./sshd.nix
  ];
  networking.hostName = name;

  networking.networkmanager.settings = {
    # This tells NetworkManager to use the ethtool settings
    # defined by the system/udev instead of its own defaults.
    connection = {
      "ethtool.feature-tso" = false;
      "ethtool.feature-gso" = false;
      "ethtool.feature-gro" = false;
    };
  };

  # Optimize TCP Buffers for Gigabit
  boot.kernel.sysctl = {
    # The current 'rmem_max' is low (212KB). Increasing this allows for larger
    # TCP windows, which is necessary for high-speed transfers.
    "net.core.rmem_max" = 16777216;
    "net.core.wmem_max" = 16777216;
    "net.ipv4.tcp_rmem" = "4096 87380 16777216";
    "net.ipv4.tcp_wmem" = "4096 65536 16777216";
    # Use BBR congestion control
    # By default, Linux uses "Cubic" congestion control, which is aggressive. It tries to find the maximum speed of the line by filling the "pipe" until it overflows. This "overflow" is what causes lag for everyone else.
    # Switching to BBR (Bottleneck Bandwidth and RTT) makes your NixOS box "listen" for congestion instead of just pushing until things break.
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.ipv4.tcp_mtu_probing" = 2; # 1 = enable when black hole detected, 2 = always on
    # Prevent "stuck" connections from hogging the router's NAT table
    "net.ipv4.tcp_fin_timeout" = 20;
    "net.ipv4.tcp_keepalive_time" = 600;
  };
}
