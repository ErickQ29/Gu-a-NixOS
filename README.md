

# 🐧 NixOS 25.05 Minimal Installation Guide (VMware + No Desktop + SSH)

This guide walks you through installing **NixOS 25.05** (`25.05.804391.b2485d569675`) in a **VMware virtual machine** with **no desktop environment**, enabling **SSH access**, and applying a custom system configuration. Perfect for servers, headless development, or learning NixOS fundamentals.

> ✅ Based on real installation logs  
> 🖥️ Virtualization: VMware  
> 🌐 Network: Bridged or NAT (ensure host can reach VM)  
> 🔒 Security: Strong password + SSH enabled

---

## 📸 Installation Screenshots Overview

This guide references **15 key screenshots** from the installation process. Placeholder image paths are included below—you can replace them with actual screenshots from your setup.

---

## 🚀 Step-by-Step Installation

### Step 1: Boot the Installer  
Select the **NixOS installer without desktop** (e.g., “NixOS Installer (Linux LTS)”).  
> ⏱️ Auto-boots in 3 seconds.

![Step 1](images/step-1.png)

---

### Step 2: Welcome Screen  
Click **Next** to begin the guided setup.

![Step 2](images/step-2.png)

---

### Step 3: Set Location  
- **Region**: `America`  
- **Zone**: `Panama`  
- System language: `British English (United Kingdom)`  
- Numbers/dates locale: `español (Panama)`

![Step 3](images/step-3.png)

---

### Step 4: Configure Keyboard  
- **Model**: `Generic 104-key PC`  
- **Layout**: `English (UK) – Default`

![Step 4](images/step-4.png)

---

### Step 5: Create User Account  
- **Full name**: `Erick`  
- **Username**: `erick`  
- Set a **password ≥6 characters**  
- ✅ **Use the same password for the administrator (root) account**

![Step 5](images/step-5.png)

---

### Step 6: Choose Desktop Environment  
👉 **Select: “No desktop”**  
> This installs a minimal, headless system—ideal for remote management.

![Step 6](images/step-6.png)

---

### Step 7: Enable Unfree Software  
✅ **Check “Allow unfree software”**  
> Required for certain hardware (e.g., NVIDIA, some Wi-Fi chips). You agree to potential EULAs.

![Step 7](images/step-7.png)

---

### Step 8: Select Storage Device  
- Device: `VMware Virtual S - 100.00 GiB (/dev/sda)`  
- ✅ **Erase disk**  
- Filesystem: `ext4`  
- Bootloader: **Master Boot Record (MBR) on /dev/sda**

![Step 8](images/step-8.png)

---

### Step 9: Review Installation Summary  
Confirm:
- Timezone: `America/Panama`
- No desktop
- Disk will be erased and formatted as ext4
- MBR bootloader

![Step 9](images/step-9.png)

---

### Step 10: Begin Installation  
Click **Install** and wait.  
> ⏳ Duration depends on internet speed.

![Step 10](images/step-10.png)

---

### Step 11: First Boot – Login Prompt  
After reboot, you’ll see a TTY login screen:  
```
Welcome to NixOS 25.05.804391.b2485d569675 (x86_64)
nixos login:
```

Log in with your username (`erick`) and password.

![Step 11](images/step-11.png)

---

### Step 12: Enable SSH via `configuration.nix`  
Edit the system config:

```bash
sudo nano /etc/nixos/configuration.nix
```

Add or ensure this line is present:

```nix
services.openssh.enable = true;
```

> 💡 You can paste your full custom Nix config here.

Save the file:
- `Ctrl+X` → `Y` → `Enter`

![Step 12](images/step-12.png)

---

### Step 13: Apply Configuration  
Rebuild the system:

```bash
sudo nixos-rebuild switch
```

> ⏳ This may take **5–30 minutes** depending on your internet speed.  
> 🚫 **Avoid public Wi-Fi**—this downloads and builds packages securely.

![Step 13](images/step-13.png)

---

### Step 14: Reboot the System  
```bash
sudo reboot now
```

You’ll be prompted for your password during boot if disk encryption were enabled (it isn’t in this setup).

![Step 14](images/step-14.png)

---

### Step 15: Connect via SSH from Windows  
On your **Windows host**, open PowerShell and:

1. **Find your VM’s IP** (inside the VM):
   ```bash
   ip a
   ```
   Look for an address like `192.168.15.143`.

2. **SSH from Windows**:
   ```powershell
   ssh erick@192.168.15.143
   ```

3. Accept the host key fingerprint when prompted:
   ```
   Are you sure you want to continue connecting (yes/no)? yes
   ```

4. Enter your password.

✅ You’re now remotely managing your NixOS VM!

![Step 15](images/step-15.png)

---

## 🛠️ Post-Install Tips

- **Check IP anytime**: `ip a` or `hostname -I`
- **Edit config again**: `sudo nano /etc/nixos/configuration.nix`
- **Reapply changes**: `sudo nixos-rebuild switch`
- **View manual**: `nixos-help`

---

## 📁 Project Structure (Optional)

If you’re storing your config in a repo:

```
nixos-vm-setup/
├── README.md
├── configuration.nix      # Your main system config
└── images/
    ├── step-1.png
    ├── step-2.png
    └── ... (up to step-15.png)
```

---

## 📝 Notes

- This setup is **minimal by design**—no GUI, no bloat.
- SSH is your primary access method after setup.
- Always use a **private, secure network** during `nixos-rebuild`.

---

> 🛠️ **Prepared by**: Erick  
> 📅 Date: October 2025  
> 💡 Tip: Commit your `configuration.nix` to version control!

---

