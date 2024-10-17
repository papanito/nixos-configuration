{ stdenv, fetchFromGitLab, kernel }:

stdenv.mkDerivation rec {
  name = "tuxedo-drivers-${version}-${kernel.version}";
  version = "4.9.0";

  src = fetchFromGitLab {
    owner = "tuxedocomputers";
    repo = "development/packages/tuxedo-drivers";
    rev = "v${version}";
    sha256 = "sha256-hZ4fY6TQj4YIOzFH+iZq90VPr87KIzke4N2PiJGYeEE=";
  };

  makeFlags = [ "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build" ];

  /*
  Modules included in this repo:
    ite_8291/ite_8291
    ite_8291_lb/ite_8291_lb
    ite_8297/ite_8297
    ite_829x/ite_829x
    tuxedo_compatibility_check/tuxedo_compatibility_check
    tuxedo_io/tuxedo_io
    tuxedo_nb05/tuxedo_nb05_ec
    tuxedo_nb05/tuxedo_nb05_power_profiles
    tuxedo_nb05/tuxedo_nb05_sensors
    tuxedo_nb05/tuxedo_nb05_keyboard
    tuxedo_nb04/tuxedo_nb04_keyboard
    tuxedo_nb04/tuxedo_nb04_wmi_ab
    tuxedo_nb04/tuxedo_nb04_wmi_bs
    tuxedo_nb04/tuxedo_nb04_sensors
    tuxedo_nb04/tuxedo_nb04_power_profiles
    tuxedo_nb04/tuxedo_nb04_kbd_backlight
    tuxedo_keyboard
    clevo_acpi
    clevo_wmi
    uniwill_wmi

  To use these, add them to the for module .. list like so:
    for module in clevo_acpi.ko clevo_wmi.ko tuxedo_keyboard.ko "tuxedo_io/tuxedo_io.ko" uniwill_wmi.ko; do
  */
  installPhase = ''
    runHook preInstall

    mkdir -p "$out/lib/modules/${kernel.modDirVersion}"

    for module in tuxedo_keyboard.ko "tuxedo_io/tuxedo_io.ko"; do
        mv src/$module $out/lib/modules/${kernel.modDirVersion}
    done

    runHook postInstall
  '';
}
