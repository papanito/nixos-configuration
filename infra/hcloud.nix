{
  # Set the provider (assumes you have the HCLOUD_TOKEN env var set)
  terraform.required_providers.hcloud.source = "hetznercloud/hcloud";
  terraform = {
    cloud = {
      organization = "papanito";

      workspaces = {
        name = "homelab-infra";
      };
    };
  };
  resource.hcloud_firewall.standard = {
    name = "homelab-fw";
    rule = [
      { direction = "in"; protocol = "tcp"; port = "22"; source_ips = ["0.0.0.0/0"]; }
      { direction = "in"; protocol = "tcp"; port = "443"; source_ips = ["0.0.0.0/0"]; }
    ];
  };

  resource.hcloud_network.private_vlan = {
    name = "homelab-private";
    ip_range = "10.0.0.0/16";
  };
}
