{ config, pkgs, name, ... }:
{
  security = {
     protectKernelImage = true;
     lockKernelModules = false; # this breaks iptables, wireguard, and virtd

     # force-enable the Page Table Isolation (PTI) Linux kernel feature
     forcePageTableIsolation = true;

     # User namespaces are required for sandboxing.
     # this means you cannot set `"user.max_user_namespaces" = 0;` in sysctl
     allowUserNamespaces = true;

     # Disable unprivileged user namespaces, unless containers are enabled
     unprivilegedUsernsClone = config.virtualisation.containers.enable;
     allowSimultaneousMultithreading = true;
  };

   boot = {
    kernel.sysctl = {
      "fs.suid_dumpable" = 0;
      # prevent pointer leaks
      "kernel.kptr_restrict" = 2;
      # restrict kernel log to CAP_SYSLOG capability
      "kernel.dmesg_restrict" = 1;
      # Note: certian container runtimes or browser sandboxes might rely on the following
      # restrict eBPF to the CAP_BPF capability
      "kernel.unprivileged_bpf_disabled" = 1;
      # should be enabled along with bpf above
      # "net.core.bpf_jit_harden" = 2;
      # restrict loading TTY line disciplines to the CAP_SYS_MODULE
      "dev.tty.ldisk_autoload" = 0;
      # prevent exploit of use-after-free flaws
      "vm.unprivileged_userfaultfd" = 0;
      # kexec is used to boot another kernel during runtime and can be abused
      "kernel.kexec_load_disabled" = 1;
      # Kernel self-protection
      # SysRq exposes a lot of potentially dangerous debugging functionality to unprivileged users
      # 4 makes it so a user can only use the secure attention key. A value of 0 would disable completely
      "kernel.sysrq" = 4;
      # disable unprivileged user namespaces, Note: Docker, NH, and other apps may need this
      # This should be set to 0 if you don't rely on flatpak, NH, Docker, etc.
      # restrict all usage of performance events to the CAP_PERFMON capability
      "kernel.perf_event_paranoid" = 3;
    };

    kernelParams = [
      # make it harder to influence slab cache layout
      "slab_nomerge"
      # enables zeroing of memory during allocation and free time
      # helps mitigate use-after-free vulnerabilaties
      "init_on_alloc=1"
      "init_on_free=1"
      # randomizes page allocator freelist, improving security by
      # making page allocations less predictable
      "page_alloc.shuffle=1"
      # enables Kernel Page Table Isolation, which mitigates Meltdown and
      # prevents some KASLR bypasses
      "pti=on"
      # randomizes the kernel stack offset on each syscall
      # making attacks that rely on a deterministic stack layout difficult
      "randomize_kstack_offset=on"
      # disables vsyscalls, they've been replaced with vDSO
      "vsyscall=none"
      # disables debugfs, which exposes sensitive info about the kernel
      "debugfs=off"
      # certain exploits cause an "oops", this makes the kernel panic if an "oops" occurs
      "oops=panic"
      # only alows kernel modules that have been signed with a valid key to be loaded
      # making it harder to load malicious kernel modules
      # can make VirtualBox or Nvidia drivers unusable
      "module.sig_enforce=1"
      # prevents user space code excalation
      "lockdown=confidentiality"
      # "rd.udev.log_level=3"
      # "udev.log_priority=3"
    ];

    blacklistedKernelModules = [
      # Obscure networking protocols
      "dccp"   # Datagram Congestion Control Protocol
      "sctp"  # Stream Control Transmission Protocol
      "rds"  # Reliable Datagram Sockets
      "tipc"  # Transparent Inter-Process Communication
      "n-hdlc" # High-level Data Link Control
      "ax25"  # Amateur X.25
      "netrom"  # NetRom
      "x25"     # X.25
      "rose"
      "decnet"
      "econet"
      "af_802154"  # IEEE 802.15.4
      "ipx"  # Internetwork Packet Exchange
      "appletalk"
      "psnap"  # SubnetworkAccess Protocol
      "p8023"  # Novell raw IEE 802.3
      "p8022"  # IEE 802.3
      "can"   # Controller Area Network
      "atm"
      # Various rare filesystems
      "cramfs"
      "freevxfs"
      "jffs2"
      "hfs"
      "hfsplus"
      "udf"

      # "squashfs"  # compressed read-only file system used for Live CDs
      # "cifs"  # cmb (Common Internet File System)
      # "nfs"  # Network File System
      # "nfsv3"
      # "nfsv4"
      # "ksmbd"  # SMB3 Kernel Server
      # "gfs2"  # Global File System 2
      # vivid driver is only useful for testing purposes and has been the
      # cause of privilege escalation vulnerabilities
      # "vivid"
    ];
  };
}

