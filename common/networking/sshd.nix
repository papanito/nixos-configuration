{ config, pkgs, ... }:

{
  # Enable the OpenSSH server.
  services.sshd.enable = true;
  services.openssh = {
    settings = {
      PasswordAuthentication = false;
      PermitEmptyPasswords = false;
      PermitTunnel = false;
      UseDns = false;
      KbdInteractiveAuthentication = false;
      X11Forwarding = config.services.xserver.enable;
      MaxAuthTries = 3;
      MaxSessions = 2;
      ClientAliveInterval = 300;
      ClientAliveCountMax = 0;
      AllowUsers = ["admin" "nixos"];
      TCPKeepAlive = false;
      AllowTcpForwarding = false;
      AllowAgentForwarding = false;
      LogLevel = "VERBOSE";
      PermitRootLogin = "no";
      KexAlgorithms = [
        # Post-Quantum: https://www.openssh.org/pq.html
        "mlkem768x25519-sha256"
        "sntrup761x25519-sha512"
        "curve25519-sha256@libssh.org"
        "ecdh-sha2-nistp521"
        "ecdh-sha2-nistp384"
        "ecdh-sha2-nistp256"
        "diffie-hellman-group-exchange-sha256"
      ];
      Ciphers = [
        "aes256-gcm@openssh.com"
        "aes128-gcm@openssh.com"
        # stream cipher alternative to aes256, proven to be resilient
        # Very fast on basically anything
        "chacha20-poly1305@openssh.com"
        # industry standard, fast if you have AES-NI hardware
        "aes256-ctr"
        "aes192-ctr"
        "aes128-ctr"
      ];
      Macs = [
        # Combines the SHA-512 hash func with a secret key to create a MAC
        "hmac-sha2-512-etm@openssh.com"
        "hmac-sha2-256-etm@openssh.com"
        "umac-128-etm@openssh.com"
        "hmac-sha2-512"
        "hmac-sha2-256"
        "umac-128@openssh.com"
      ];
    };
  };
}
