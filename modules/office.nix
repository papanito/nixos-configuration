{ config, pkgs, lib, ... }:

let
   cfg = config.office;
in
{
  options.office = {
    enable 
      = lib.mkEnableOption "enable office module";
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      libreoffice-fresh # Comprehensive, professional-quality productivity suite, a variant of openoffice
      onlyoffice-bin
      pdftk # Command-line tool for working with PDFs
      pdfchain # A graphical user interface for the PDF Toolkit (PDFtk)
      pdfarranger # Merge or split pdf documents and rotate, crop and rearrange their pages using an interactive and intuitive graphical interface
    ];
  };
}
