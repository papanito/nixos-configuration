{ pkgs, ... }:
let
  virsh = "${pkgs.libvirt}/bin/virsh";
  # Suspend all running VMs; ignore failures (no VMs running is fine).
  suspendAllVms = ''
    for vm in $(${virsh} list --name --state-running 2>/dev/null); do
      ${virsh} suspend "$vm" 2>/dev/null || true
    done
  '';
  # Resume all paused VMs.
  resumeAllVms = ''
    for vm in $(${virsh} list --name --state-paused 2>/dev/null); do
      ${virsh} resume "$vm" 2>/dev/null || true
    done
  '';
in
{
  users.users.papanito = {
    extraGroups = [ "libvirtd" ];
  };

  # Grant read/write/execute permissions to the libvirtd group on /var/lib/libvirt/images
  systemd.tmpfiles.rules = [
    "Z /var/lib/libvirt 0775 root libvirtd - -"
  ];
  environment.systemPackages = with pkgs; [
    tigervnc
    turbovnc
  ];

  # --- Fix: gracefully suspend/resume QEMU/KVM VMs around host suspend ---
  # When the host suspends with running VMs, QEMU processes can hang or become
  # zombies, and the i915 display pipeline may fail to reinitialize on resume
  # (black screen). These systemd sleep hooks use virsh to suspend all running
  # VMs before the host sleeps and resume them after wake.
  systemd.services.libvirt-suspend-vms = {
    description = "Suspend all running libvirt VMs before host sleep";
    wantedBy = [ "systemd-suspend.service" "systemd-hibernate.service" "systemd-hybrid-sleep.service" "systemd-suspend-then-hibernate.service" ];
    before = [ "systemd-suspend.service" "systemd-hibernate.service" "systemd-hybrid-sleep.service" "systemd-suspend-then-hibernate.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = suspendAllVms;
    };
  };

  systemd.services.libvirt-resume-vms = {
    description = "Resume all paused libvirt VMs after host wake";
    after = [ "systemd-suspend.service" "systemd-hibernate.service" "systemd-hybrid-sleep.service" "systemd-suspend-then-hibernate.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = resumeAllVms;
    };
  };
}