{ pkgs, ... }: {
  services.gnome.gnome-keyring.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    #defaultCacheTtl = : # Sets the default time in seconds a cached passphrase is valid.
    #maxCacheTtl:        # Sets the maximum time in seconds a cached passphrase can be valid, even if accessed recently. Useful for security policies.
    #pinentryFlavor:     # Specifies the graphical or terminal program used to prompt for passphrases. Choose one that fits your environment (e.g., qt, gtk2, curses). If not set and you have a graphical environment, you might encounter issues if a suitable pinentry is not automatically picked up.
  };
}