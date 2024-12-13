# Dell XPS 9500 macOS with OpenCore

![hackintosh](./screenshot.png)

# Details

| OpenCore Version | 1.0.3 |
| --- | --- |
| macOS Version | 14.7 (Sonoma) |
| SMBios | MacBookAir9,1 |

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
| Fingerprint Sensor | Shenzen Goodix | ❌ Not Working |
| S4 SLeep | Hibernate/Wake | ✅ Working |
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

# S4 Sleep
Despite Dell's attempts to sabotage S3 sleep, I've managed to get S4 sleep
(hibernatemode 25) on macOS, uusing a combination of IFR edits
and ACPI table changes. The first step is to change the following
variables from the UEFI interface using modGRUBshell:

```bash
setup_var PchSetup 0x16 0x00 # Disable RTC Memory Lock
setup_var CpuSetup 0x3E 0x00 # Disable CFG Lock
setup_var CpuSetup 0xDA 0x00 # Disable Overclocking Lock
setup_var SaSetup  0xF5 0x02 # DVMT Pre-allocated = 64MB
setup_var SaSetup  0xF6 0x03 # Total DVMT = MAX
```

In macOS (Monterey, Ventura, Sonoma, Sequoia) open a terminal and set the following:

```bash
sudo pmset -a hibernatemode 25
sudo pmset -a standby 1
sudo pmset -a powernap 1
sudo pmset -a sleep 1
sudo pmset -a standbydelaylow 1
sudo pmset -a standbydelayhigh 1
sudo pmset -a womp 0
sudo pmset -a proximitywake 0
```

# finalise_config.sh
This bash script can be run to setup the Platform info like serial, model etc in an automated matter.
It will update the config.plist in EFI/OC/ and makes a copy ( will be overwritten next run).

The config.plist has a construct with min and maxkernel to support Sonoma and the script detects the OS version to modify certain parameters and sets OpenCore to boot graphically.

The script relies on the current config.plist and may not work as expected on other versions of the file or on other OS versions.

# Known Issues

None as far as I know.

# Experimental settings for faster performance and better power saving

The following UEFI IFR settings have worked very well on my i9 and given me even better performance AND power savings. However YMMV and you may soft-brick your machine (and might need to RTC
reset your laptop). Use with caution!

```bash
setup_var Setup 0x14  	  0x00      # Disable ACPI Debug
setup_var Setup 0x38  	  0x01      # Enable Sensor Standby
setup_var Setup 0x44  	  0x01      # Enable MSI
setup_var Setup 0x428 	  0x02      # USB Port 1 RTD3 Support: Super Speed
setup_var Setup 0x429 	  0x02      # USB Port 2 RTD3 Support: Super Speed
setup_var SaSetup 0x130   0x00      # Disable ECC DRAM Support (if no ECC RAM)
setup_var SaSetup 0x123   0x03      # DMI ASPM: L0sL1

setup_var Setup 0x4CD     0x01      # Enable Tbt Dynamic AC/DC L1
setup_var Setup 0x4B5     0x03      # Enable ASPM: L0sL1
setup_var Setup 0x4CB     0x03      # TBT Enable ASPM: L1.1 & L1.2

setup_var PchSetup 0x586  0x00      # Disable Intel WoV DSP Firmware

setup_var PchSetup 0x04   0x03      # Deep Sx Power policy: S4-S5/Battery
setup_var PchSetup 0x10   0x01      # Allow CLKRUN# logic to stop the PCI clocks

setup_var CpuSetup 0x24D  0x01      # Enable Dual Tau Boost
setup_var CpuSetup 0x1B7  0x01      # Enable OverClocking Feature
setup_var CpuSetup 0x2AC  0x01 	    # Enable Intel Speed Optimizer (ISO)
setup_var CpuSetup 0x46   0x08      # Package C State Limit: C10
setup_var CpuSetup 0x3B   0x00      # Disable Package C-State Demotion
setup_var CpuSetup 0x3C   0x01      # Enable Package C-State Un-Demotion
```

# Donate

If you like and use this project, feel free to contribute anything you can below:

Paypal: https://paypal.me/jkbuha

Bitcoin: bc1qjuy6hy5shqqdnyzzcjlc2h4ua47gpugphuxdae
