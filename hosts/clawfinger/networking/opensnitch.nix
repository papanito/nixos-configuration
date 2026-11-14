{
  config,
  lib,
  pkgs,
  ...
}:
# Permanent OpenSnitch rules. `permanent` here means: declared here, not clicked in
# the GUI. The NixOS module symlinks each of these into the daemon's Rules.Path on
# service start, so they are rebuilt, not edited by hand.
#
# Two OpenSnitch v1.8.0 details drive the whole layout:
#
#  1. Rules are evaluated in LEXICOGRAPHIC ORDER OF THEIR NAME (daemon/rule/
#     loader.go: sortRules + FindFirstMatch). There is no numeric priority.
#     A matching deny/reject short-circuits the scan; otherwise the last matching
#     allow wins. Because `deny-*` sorts after `allow-*`, a GUI-created deny would
#     beat any allow declared here — so every rule below carries
#     `precedence = true`, which stops the scan at its own match. Declaring a rule
#     therefore makes it authoritative, which is the point of calling it permanent.
#  2. `simple` compares with exact EqualFold, so a Nix store hash can only ever be
#     matched with `regexp`. Every process rule here uses regexp for that reason.
let
  # A single-condition rule on process.path (the common case).
  rule =
    {
      name,
      type,
      data,
      operand ? "process.path",
      action ? "allow",
    }:
    {
      inherit
        name
        action
        ;
      enabled = true;
      # Only `always` is durable: `once` is never registered in the running rule
      # set, and any other value is parsed as a Go duration and expires.
      duration = "always";
      precedence = true;
      operator = {
        inherit
          type
          operand
          data
          ;
        sensitive = false;
        list = [ ];
      };
    };

  # AND of several conditions, e.g. "this binary, to this host only".
  listRule =
    {
      name,
      conditions,
      action ? "allow",
    }:
    {
      inherit
        name
        action
        ;
      enabled = true;
      duration = "always";
      precedence = true;
      operator = {
        type = "list";
        operand = "list";
        data = "";
        sensitive = false;
        list = map (c: {
          inherit (c) type operand data;
          sensitive = false;
          list = [ ];
        }) conditions;
      };
    };

  allRules = [
    (rule { name = "000-allow-localhost"; type = "network"; operand = "dest.network"; data = "127.0.0.0/8"; })
    (rule { name = "allow-always-antigravity"; type = "regexp"; data = "/nix/store/.*/lib/antigravity/antigravity"; })
    (rule { name = "allow-always-app-evolution-calendar-factory-wrapp"; type = "regexp"; data = "/nix/store/.*/.evolution-calendar-factory-wrapped"; })
    (listRule {
      name = "allow-always-bin-atuin-to-api.atuin.sh";
      conditions = [
        { type = "regexp"; operand = "process.path"; data = "/nix/store/.*/atuin"; }
        { type = "simple"; operand = "dest.host"; data = "api.atuin.sh"; }
      ];
    })
    (rule { name = "allow-always-bin-avahi-daemon"; type = "regexp"; data = "/nix/store/.*/avahi-daemon"; })
    (rule { name = "allow-always-bin-bun"; type = "regexp"; data = "/nix/store/.*/bin/bun"; })
    (rule { name = "allow-always-bin-bws"; type = "regexp"; data = "/nix/store/.*/bws"; })
    (rule { name = "allow-always-bin-calicoctl"; type = "regexp"; data = "/nix/store/.*/bin/calicoctl"; })
    (rule { name = "allow-always-bin-cargo-wrapped"; type = "regexp"; data = "/nix/store/.*/bin/.cargo-wrapped"; })
    (rule { name = "allow-always-bin-cheat"; type = "regexp"; data = "/nix/store/.*/bin/cheat"; })
    (rule { name = "allow-always-bin-chronyd"; type = "regexp"; data = "/nix/store/.*/bin/chronyd"; })
    (rule { name = "allow-always-bin-cups-browsed"; type = "regexp"; data = "/nix/store/.*/bin/cups-browsed"; })
    (rule { name = "allow-always-bin-curl"; type = "regexp"; data = "/nix/store/.*/curl"; })
    (rule { name = "allow-always-bin-dev-geopjr-tuba-wrapped"; type = "regexp"; data = "/nix/store/.*tuba.*/bin/.dev.geopjr.tuba-wrapped"; })
    (rule { name = "allow-always-bin-dig"; type = "regexp"; data = "/nix/store/.*/bin/dig"; })
    (rule { name = "allow-always-bin-dleyna-renderer-service"; type = "regexp"; data = "/nix/store/.*/dleyna-renderer-service"; })
    (rule { name = "allow-always-bin-dnscrypt-proxy"; type = "regexp"; data = "/nix/store/.*/dnscrypt-proxy"; })
    (rule { name = "allow-always-bin-dnsmasq"; type = "regexp"; data = "/nix/store/.*/bin/dnsmasq"; })
    (rule { name = "allow-always-bin-evolution-addressbook-factory-w"; type = "regexp"; data = "/nix/store/.*/.evolution-addressbook-factory-wrapped"; })
    (rule { name = "allow-always-bin-evolution-source-registry-wrapped"; type = "regexp"; data = "/nix/store/.*/.evolution-source-registry-wrapped"; })
    (rule { name = "allow-always-bin-firefox"; type = "regexp"; data = "/nix/store/.*/firefox"; })
    (rule { name = "allow-always-bin-fwupdmgr-wrapped"; type = "regexp"; data = "/nix/store/.*/bin/.fwupdmgr-wrapped"; })
    (rule { name = "allow-always-bin-geoclue-wrapped"; type = "regexp"; data = "/nix/store/.*/.geoclue-wrapped"; })
    (rule { name = "allow-always-bin-git-remote-http"; type = "regexp"; data = "/nix/store/.*/git-remote-http"; })
    (rule { name = "allow-always-bin-gjs-console"; type = "regexp"; data = "/nix/store/.*/gjs-console"; })
    (rule { name = "allow-always-bin-glab-wrapped"; type = "regexp"; data = "/nix/store/.*/.glab-wrapped"; })
    (rule { name = "allow-always-bin-gnome-calculator-wrapped"; type = "regexp"; data = "/nix/store/.*/bin/.gnome-calculator-wrapped"; })
    (rule { name = "allow-always-bin-gnome-control-center-wrapped"; type = "regexp"; data = "/nix/store/.*/bin/.gnome-control-center-wrapped"; })
    (rule { name = "allow-always-bin-gnome-shell-wrapped"; type = "regexp"; data = "/nix/store/.*/.gnome-shell-wrapped"; })
    (rule { name = "allow-always-bin-go"; type = "regexp"; data = "/nix/store/.*/share/go/bin/go"; })
    (rule { name = "allow-always-bin-gsd-datetime-wrapped"; type = "regexp"; data = "/nix/store/.*/.gsd-datetime-wrapped"; })
    (rule { name = "allow-always-bin-handy-wrapped"; type = "regexp"; data = "/nix/store/.*/bin/.handy-wrapped"; })
    (rule { name = "allow-always-bin-helm"; type = "regexp"; data = "/nix/store/.*/bin/helm"; })
    (rule { name = "allow-always-bin-insync"; type = "regexp"; data = "/nix/store/.*/insync"; })
    (rule { name = "allow-always-bin-k3s"; type = "regexp"; data = "/home/papanito/.rancher/k3s/.*/bin/k3s"; })
    (rule { name = "allow-always-bin-k3s-wrapped"; type = "regexp"; data = "/nix/store/.*/bin/.k3s-wrapped"; })
    (rule { name = "allow-always-bin-k9s"; type = "regexp"; data = "/nix/store/.*/bin/k9s"; })
    (rule { name = "allow-always-bin-keyguard"; type = "regexp"; data = "/nix/store/.*/bin/Keyguard"; })
    (rule { name = "allow-always-bin-mpv"; type = "regexp"; data = "/nix/store/.*/mpv"; })
    (rule { name = "allow-always-bin-nc"; type = "regexp"; data = "/nix/store/.*/bin/nc"; })
    (rule { name = "allow-always-bin-networkmanager"; type = "regexp"; data = "/nix/store/.*/bin/networkmanager"; })
    (rule { name = "allow-always-bin-nextcloud-wrapped"; type = "regexp"; data = "/nix/store/.*/.nextcloud-wrapped"; })
    (rule { name = "allow-always-bin-nix"; type = "regexp"; data = "/nix/store/.*/nix"; })
    (rule { name = "allow-always-bin-node"; type = "regexp"; data = "/nix/store/.*/node"; })
    (rule { name = "allow-always-bin-nsncd"; type = "regexp"; data = "/nix/store/.*/nsncd"; })
    (rule { name = "allow-always-bin-ollama"; type = "regexp"; data = "/nix/store/.*/bin/ollama"; })
    (rule { name = "allow-always-bin-opencode"; type = "regexp"; data = "/nix/store/.*/bin/\\.opencode-wrapped"; })
    (rule { name = "allow-always-bin-opencode2"; type = "regexp"; data = "/nix/store/.*/bin/\\.opencode2-wrapped"; })
    (rule { name = "allow-always-bin-packer"; type = "regexp"; data = "/nix/store/.*/bin/packer"; })
    (rule { name = "allow-always-bin-passt-avx2"; type = "regexp"; data = "/nix/store/.*/bin/passt.avx2"; })
    (rule { name = "allow-always-bin-podman-wrapped"; type = "regexp"; data = "/nix/store/.*/bin/.podman-wrapped"; })
    (rule { name = "allow-always-bin-python3-13"; type = "regexp"; data = "/nix/store/.*/python3.13"; })
    (rule { name = "allow-always-bin-qemu"; type = "regexp"; data = "/nix/store/.*/bin/.qemu-system-x86_64-wrapped"; })
    (rule { name = "allow-always-bin-rclone-wrapped"; type = "regexp"; data = "/nix/store/.*/bin/.rclone-wrapped"; })
    (rule { name = "allow-always-bin-restic-wrapped"; type = "regexp"; data = "/nix/store/.*/.restic-wrapped"; })
    (rule { name = "allow-always-bin-solo2"; type = "regexp"; data = "/nix/store/.*/bin/solo2"; })
    (rule { name = "allow-always-bin-speech-dispatcher"; type = "regexp"; data = "/nix/store/.*/speech-dispatcher"; })
    (rule { name = "allow-always-bin-speech-dispatcher-modules-sd-festiv"; type = "regexp"; data = "/nix/store/.*/sd_festival"; })
    (rule { name = "allow-always-bin-ssh-dev"; type = "regexp"; data = "/nix/store/.*/ssh"; })
    (listRule {
      name = "allow-always-bin-ssh-home-network";
      conditions = [
        { type = "regexp"; operand = "process.path"; data = "/nix/store/.*/ssh"; }
        { type = "network"; operand = "dest.network"; data = "10.0.0.0/8"; }
      ];
    })
    (rule { name = "allow-always-bin-terraform"; type = "regexp"; data = "/nix/store/.*/terraform"; })
    (rule { name = "allow-always-bin-tor"; type = "regexp"; data = "/nix/store/.*/bin/tor"; })
    (rule { name = "allow-always-bin-traceroute"; type = "regexp"; data = "/nix/store/.*/bin/traceroute"; })
    (rule { name = "allow-always-bin-trivy"; type = "regexp"; data = "/nix/store/.*/bin/trivy"; })
    (rule { name = "allow-always-bin-zellij"; type = "regexp"; data = "/nix/store/.*/zellij"; })
    (rule { name = "allow-always-domain-discord"; type = "simple"; operand = "dest.host"; data = "gateway.discord.gg"; })
    (rule { name = "allow-always-domain-gmail.com"; type = "regexp"; operand = "dest.host"; data = ".*\\.gmail.com"; })
    (rule { name = "allow-always-domain-wyssmann.com"; type = "regexp"; operand = "dest.host"; data = ".*\\.wyssmann.com"; })
    (rule { name = "allow-always-goa-daemon-wrapped"; type = "regexp"; data = "/nix/store/.*/.goa-daemon-wrapped"; })
    (rule { name = "allow-always-ibexec-chromium-chromium"; type = "regexp"; data = "/nix/store/.*/libexec/chromium/chromium"; })
    (rule { name = "allow-always-lib-bloodhound-bloodhound"; type = "regexp"; data = "/nix/store/.*/BloodHound"; })
    (listRule {
      name = "allow-always-lib-cups-backend-socket";
      conditions = [
        { type = "regexp"; operand = "process.path"; data = "/nix/store/.*/lib/cups/backend/socket"; }
        { type = "network"; operand = "source.network"; data = "10.0.0.0/24"; }
      ];
    })
    (rule { name = "allow-always-lib-openjdk-bin-java"; type = "regexp"; data = "/nix/store/.*/lib/openjdk/bin/java"; })
    (rule { name = "allow-always-lib-orca-orca-ide"; type = "regexp"; data = "/nix/store/.*/lib/Orca/orca-ide"; })
    (rule { name = "allow-always-libexec-omp"; type = "regexp"; data = "/nix/store/.*/libexec/omp"; })
    (rule { name = "allow-always-qemu-packer-plugin-qemu"; type = "regexp"; data = "/home/papanito/.config/packer/plugins/github.com/hashicorp/qemu/packer-plugin-qemu_v.*_linux_amd64"; })
    (rule { name = "allow-always-share-go-bin-go"; type = "regexp"; data = "/nix/store/.*/share/go/bin/go"; })
    (rule { name = "allow-always-systemd-timesyncd"; type = "regexp"; data = "/nix/store/.*/systemd-timesyncd"; })
    (rule { name = "allow-always-terraform-providers-registry-terraform-io-gitlabhq-gitlab"; type = "regexp"; data = "/home/papanito/workspaces/wyssmann.com/.*/.terraform/providers/registry.terraform.io/gitlabhq/gitlab/\\d+\\.\\d+\\.\\d+/linux_amd64/terraform-provider-gitlab_v\\d+\\.\\d+\\.\\d+"; })
    (rule { name = "allow-always-terraform-providers-registry-terraform-io-integrations-github"; type = "regexp"; data = "/home/papanito/workspaces/wyssmann.com/.*/.terraform/providers/registry.terraform.io/integrations/github/\\d+\\.\\d+\\.\\d+/linux_amd64/terraform-provider-github_v\\d+\\.\\d+\\.\\d+"; })
    (rule { name = "allow-always-vim-mason-packages"; type = "regexp"; data = "/home/papanito/.local/share/nvim/mason/packages/.*"; })
    (rule { name = "allow-always-webkitnetworkprocess"; type = "regexp"; data = "/nix/store/.*/webkitnetworkprocess"; })
    (rule { name = "allow-alwayshome-papanito-local-share-cargo-bin-gitpane"; type = "simple"; data = "/home/papanito/.local/share/cargo/bin/gitpane"; })
    (rule { name = "allow-alwaysn-aardvark-dns"; type = "regexp"; data = "/nix/store/.*/bin/aardvark-dns"; })
    (rule { name = "always-allow-bin-evince-wrapped"; type = "regexp"; data = "/nix/store/.*/bin/.evince-wrapped"; })
    (rule { name = "always-allow-bin-prefetch-npm-deps-wrapped"; type = "regexp"; data = "/nix/store/.*/bin/.prefetch-npm-deps-wrapped"; })
    (rule { name = "always-allow-libexec-electron-electron"; type = "regexp"; data = "/nix/store/.*/libexec/electron/electron"; })

  ];
in
{
  services.opensnitch.rules = lib.listToAttrs (
    map (r: lib.nameValuePair r.name r) allRules
  );
}
