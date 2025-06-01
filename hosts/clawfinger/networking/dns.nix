{ config, pkgs, ... }:

{
services.coredns.enable = true;
services.coredns.config =
  ''
    local {
      template IN A  {
          answer "{{ .Name }} 0 IN A 127.0.0.1"
      }
    }
  '';
}
