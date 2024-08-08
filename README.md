# Dell XPS 9500 macOS with OpenCore

![hackintosh](./screenshot.png)

# Details

| OpenCore Version | 1.0.1 |
| --- | --- |
| macOS Version | 13.6.9 (Ventura) |
| SMBios | MacBookPro16,4 |

# Hardware Specifications

| Hardware | Specification | Status |
| --- | --- | --- |
| CPU | Intel Core i9-10885H | ✅ Working |
| RAM | DDR4 32GB | ✅ Working |
| Audio | Realtek ALC3281 | ✅ Working |
| WiFi | Killer 1675 (AX201) | ✅ Working |
| Bluetooth | AX201 Wi-Fi 5 | ✅ Working |
| SSD | Crucial P3 2TB | ✅ Working |
| Keyboard | - | ✅ Working |
| Trackpad | I2C Connection | ✅ Working |
| Webcam | Microdia RGB IR HD camera | ✅ Working |
| MicroSD Card | RTS5260 Card Reader | ✅ Working |
| Fingerprint Sensor | Shenzen Goodix | 🔶 Partially working |
| S4 | Hibernate/Wake | ✅ Working |
| GPU | Intel HD630 Graphics | ✅ Working |
| eGPU | AMD Sapphire Radeon RX6950XT | ✅ Working |
| Display | 1920 x 1200 FHD LCD | ✅ Working |

# Overview

This is the first working configuration for the Dell XPS 9500 with working S4 hibernate/resume. S3 seems to be elusive (for now) but S4 works seamlessly and honestly it's a much more practical option as the machine shuts down and then resumes seamlessly on power on.

# BIOS Settings

| Setting | Option |
| --- | --- |
| SATA Operation | AHCI |
| Fast Boot | Thorough |
| Secure Boot | Disabled |
| TMP 2.0 Security | Disabled |
| Intel SGX | Disabled |
| VT for Direct I/O | Disabled |
| Fingerprint Reader | Disabled |

# S4 ACPI
Despite Dell's attempts to sabotage S3 sleep, I've managed to get S4 sleep 
(hibernatemode 25) on macOS, uusing a combination of IFR edits 
and ACPI table changes. The first step is to change the following 
variables from the UEFI interface using modGRUBshell:

```bash
setup_var PchSetup 0x16 00 (RTC Memory Lock ->Disabled)
setup_var CpuSetup 0x3E 00 (CFG Lock ->Disabled)
setup_var CpuSetup 0xDA 00 (Overclocking Lock ->Disabled)
setup_var SaSetup 0xF5 02 (DVMT Pre-allocated ->64MB)
setup_var SaSetup 0xF6 03 (Total DVMT ->MAX)
```

In macOS (Monterey, Ventura, Sonoma) open a terminal and set the following:

```bash
sudo pmset -a hibernatemode 25
sudo pmset -a standby 1
sudo pmset -a powernap 1
sudo pmset -a sleep 1
sudo pmset -a standbydelaylow 1
sudo pmset -a standbydelayhigh 1
```

# finalise_config.sh
This bash script can be run to setup the Platform info like serial, model etc in an automated matter.
It will update the config.plist in EFI/OC/ and makes a copy ( will be overwritten next run).

The config.plist has a construct with min and maxkernel to support Sonoma and the script detects the OS version to modify certain parameters and sets OpenCore to boot graphically.

The script relies on the current config.plist and may not work as expected on other versions of the file or on other OS versions.

# Known Issues

- None as far as I know...

