{ config, pkgs, name, ... }:
{
  imports = [
    ./dns.nix
    ./firewall.nix
    ./nts.nix
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
    "net.ipv4.tcp_mtu_probing" = 2; # 1 = enable when black hole detected, 2 = always on
    # Prevent "stuck" connections from hogging the router's NAT table
    "net.ipv4.tcp_fin_timeout" = 20;
    "net.ipv4.tcp_keepalive_time" = 600;

    # protect against SYN flood attacks (denial of service attack)
    "net.ipv4.tcp_syncookies" = 1;
    # protection against TIME-WAIT assassination
    "net.ipv4.tcp_rfc1337" = 1;
    # enable source validation of packets received (prevents IP spoofing)
    "net.ipv4.conf.default.rp_filter" = 1;
    "net.ipv4.conf.all.rp_filter" = 1;

    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv4.conf.default.accept_redirects" = 0;
    "net.ipv4.conf.all.secure_redirects" = 0;
    "net.ipv4.conf.default.secure_redirects" = 0;
    # Protect against IP spoofing
    "net.ipv6.conf.all.accept_redirects" = 0;
    "net.ipv6.conf.default.accept_redirects" = 0;
    "net.ipv4.conf.all.send_redirects" = 0;
    "net.ipv4.conf.default.send_redirects" = 0;

    # prevent man-in-the-middle attacks
    "net.ipv4.icmp_echo_ignore_all" = 1;

    # ignore ICMP request, helps avoid Smurf attacks
    "net.ipv4.conf.all.forwarding" = 0;
    "net.ipv4.conf.default.accept_source_route" = 0;
    "net.ipv4.conf.all.accept_source_route" = 0;
    "net.ipv6.conf.all.accept_source_route" = 0;
    "net.ipv6.conf.default.accept_source_route" = 0;
    # Reverse path filtering causes the kernel to do source validation of
    "net.ipv6.conf.all.forwarding" = 0;
    "net.ipv6.conf.all.accept_ra" = 0;
    "net.ipv6.conf.default.accept_ra" = 0;

    ## TCP hardening
    # Prevent bogus ICMP errors from filling up logs.
    "net.ipv4.icmp_ignore_bogus_error_responses" = 1;

    # Userspace
    # restrict usage of ptrace
    "kernel.yama.ptrace_scope" = 2;

    # ASLR memory protection (64-bit systems)
    "vm.mmap_rnd_bits" = 32;
    "vm.mmap_rnd_compat_bits" = 16;

    # only permit symlinks to be followed when outside of a world-writable sticky directory
    "fs.protected_symlinks" = 1;
    "fs.protected_hardlinks" = 1;
    # Prevent creating files in potentially attacker-controlled environments
    "fs.protected_fifos" = 2;
    "fs.protected_regular" = 2;

    # Randomize memory
    "kernel.randomize_va_space" = 2;
    # Exec Shield (Stack protection)
    "kernel.exec-shield" = 1;

    ## TCP optimization
    # TCP Fast Open is a TCP extension that reduces network latency by packing
    # data in the sender’s initial TCP SYN. Setting 3 = enable TCP Fast Open for
    # both incoming and outgoing connections:
    "net.ipv4.tcp_fastopen" = 3;
    "net.ipv4.tcp_congestion_control" = "bbr";
    # Use BBR congestion control
    # By default, Linux uses "Cubic" congestion control, which is aggressive. It tries to find the maximum speed of the line by filling the "pipe" until it overflows. This "overflow" is what causes lag for everyone else.
    # Switching to BBR (Bottleneck Bandwidth and RTT) makes your NixOS box "listen" for congestion instead of just pushing until things break.
    #"net.core.default_qdisc" = "fq";
    "net.core.default_qdisc" = "cake";
  };
}
