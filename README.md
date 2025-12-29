# FileBrowser Quantum + Samba (Family Setup)

## Goal

Provide a **secure, consistent, multi-user file system** where:

- Each family member has a private home directory
- Files can be accessed via:
  - SMB (Android, macOS, Windows)
  - FileBrowser Quantum Web UI
- Android SMB uploads work reliably
- FileBrowser can read/write/delete files
- Files remain private (no group-readable permissions)

This setup avoids:

- Running containers as root
- Weak chmod-based permissions
- Per-user containers
- Samba hacks like `force user`

---

## High-level design

- **SMB users** = real Linux users (`bob`, `alice`, etc.)
- **FileBrowser** = service account (`filebrowser`)
- **Access control** = POSIX ACLs
- **Inheritance** = enforced by Samba (`acl_xattr`)

---

## Step 1: Create users

Run the provided script:

```bash
sudo bash create-users.sh
````

Enable SMB passwords:

```bash
sudo smbpasswd -a bob
sudo smbpasswd -e bob
```

Repeat for all users.

---

## Step 2: Configure Samba

Merge the provided `smb.conf` into `/etc/samba/smb.conf`.

Important requirements:

- `vfs objects = fruit streams_xattr acl_xattr`
- `map acl inherit = yes`
- `inherit acls = yes`

Validate and restart:

```bash
testparm
sudo systemctl restart smbd
```

---

## Step 3: Create FileBrowser service user

```bash
sudo useradd -r -M -s /usr/sbin/nologin filebrowser
sudo usermod -aG family filebrowser
```

---

## Step 4: Install ACL tools

```bash
sudo apt update
sudo apt install acl
```

---

## Step 5: Enable ACL inheritance (ONE-TIME)

This is the **critical step**.

```bash
sudo setfacl -R -d -m u:filebrowser:rwX,m:rwX /DATA/srv/users
```

What this does:

- Affects **future files only**
- Ensures FileBrowser can access Android/SMB uploads
- Does NOT change existing files
- Does NOT weaken file privacy

---

## Step 6: Deploy FileBrowser Quantum

1. Place `config.yaml` at `/DATA/AppData/filebrowser-quantum/config/config.yaml`

2. Import `FileBrowserQuantum-CasaOS.yaml` into CasaOS. It contains docker-compose in casa-os style.

3. Start the container

4. Login as admin on FileBrowser WebUI.

5. Create users and assign sources:

   - My Home
   - Media
   - Family Docs

---

## Final verification

From Android (via SMB):

- Upload a new file

From FileBrowser Web UI:

- Download it
- Delete it

## Done

All users should get full access to their own home directories in both ways, SMB and WebUI.
