{ config, pkgs, lib, ... }:

let
   cfg = config.security;
in
{
  options.security = {
    enable 
      = lib.mkEnableOption "enable security related software";
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      ### Security ###
      chkrootkit # Locally checks for signs of a rootkit
      clamav # Antivirus engine designed for detecting Trojans, viruses, malware and other malicious threats
      lynis # Security auditing tool for Linux, macOS, and UNIX-based systems
      vt-cli # VirusTotal Command Line Interface
      vuls #Agent-less vulnerability scanner
    ];
  };
}