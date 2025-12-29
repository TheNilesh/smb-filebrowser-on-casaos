# From Google Drive to 'My Drive': Self-Hosting Your Cloud Storage with CasaOS

## Part 1: The Dream of a Boring, Reliable Cloud

Welcome back to my self-hosting journey! If you're anything like me, you love the **convenience** of services like Google Drive, but you hate the feeling of your data being locked away in someone else's vault. The goal of this part of the series was simple, yet deceptively hard:

> **Create a personal cloud storage that is as easy to use as Google Drive, but as simple and reliable as a file browser.**

I wanted the best of both worlds for my family:

| Google Drive Convenience | Self-Hosted Control |
| :--- | :--- |
| Easy upload from phone | **Under my control** |
| Simple browser download | **Built on plain files** |
| Works automatically | **Boringly reliable** |
| No thinking about permissions | **No vendor lock-in** |

The moment you try to combine "easy" and "under my control," you run into a few technical hurdles. But trust me, the solution is elegant, and it all starts with a simple philosophy: **Boring is best.**

---

## The Foundation: The Power of Plain Files

When you use a complex cloud service, your files are often stored in a proprietary database. If that service goes down, your data is trapped.

My solution starts with the most reliable technology on the planet: **the Linux filesystem**.

At its core, my self-hosted cloud is just a set of directories on my CasaOS server. Each family member gets their own dedicated folder:

```
/DATA/srv/users/<username>
```

Why this simplicity? Because Linux has already solved the hard problems: storage, permissions, users, and backups. By respecting the filesystem as the ultimate source of truth, we ensure that if any application breaks, the files themselves are still perfectly safe and accessible.

---

## The Two Access Doors

To make this simple filesystem feel like a modern cloud, we need two ways to access it: a fast, local way for writing, and a convenient web way for browsing.

### Door 1: The Primary Write Path (SMB)

To get files onto the server from phones, tablets, and computers, we use **SMB (Server Message Block)**.

If you've ever connected to a shared folder on a Windows or Mac network, you've used SMB. It's old, it's boring, and that's a huge compliment!

*   **It works everywhere:** Android, macOS Finder, Windows Explorer, Linux file managers.
*   **No new apps:** Users just connect to a network drive, and it feels like a local folder.
*   **It's the primary writer:** When a file is uploaded via SMB, the system knows exactly which user uploaded it, and the file is created with that user as the owner.

### Door 2: The Google Drive View (FileBrowser)

SMB is great for uploading, but sometimes you want a quick link, a remote download, or a simple browser view—just like Google Drive.

This is where the fantastic CasaOS app **FileBrowser Quantum** comes in.

FileBrowser is not a cloud platform. It's not a database. It's just a **stateless web interface over your real files**. It does one thing perfectly: it shows you your directories and lets you manage files through a browser. Crucially, it respects the filesystem instead of trying to replace it.

---

## The Permission Puzzle: Why It Gets Complicated

Now for the tricky part. We have two systems touching the same files:

1.  **Real Users:** Writing files via SMB, each owning their own data.
2.  **FileBrowser:** A single web app, running inside a Docker container on CasaOS, that needs to *read* everyone's files to display them on the web.

Here’s the core problem that traditional Linux permissions can't solve:

> A Docker container runs as a single, dedicated **service user** (let's call it `filebrowser`). This user is not *you*, and it's not your *family members*.

If your file is set to be private (which it should be!), only the owner can read it. How can the single `filebrowser` service user read *everyone's* private files without becoming a super-user or making the files public?

Traditional permissions only allow for **Owner**, **Group**, and **Others**. We can't make the `filebrowser` user the owner, and we definitely don't want to give access to "Others" (which means *anyone*).

---

## The Elegant Solution: The VIP Pass (ACLs)

The answer lies in a feature that has been part of Linux for decades but is rarely needed in simple setups: **ACLs (Access Control Lists)**.

Think of ACLs as a **VIP Pass** or a **Special Key** you attach to a file.

They don't change the file's ownership or its main permissions. They just add an extra rule that says:

> "Even though this file is private, I'm granting a special, read-only pass to the `filebrowser` service user."

With ACLs, we achieve the perfect balance:

*   Your files remain private (`600` permissions).
*   You remain the owner.
*   The **FileBrowser** service gets a quiet, specific key to access the files it needs to display on the web.

This is the key to security and convenience: no file becomes accidentally public, and no user can see another user's data.

---

## The Final Tweak: Taming Samba

At first, even with ACLs set up, I ran into a frustrating issue: **"Permission Denied"** errors when trying to view files uploaded from an Android phone via SMB.

The culprit? **Samba** (the software handling the SMB connection) was being *too* helpful.

By default, when a file is uploaded, Samba tries to "recalculate" the permissions based on the client's settings. This process was silently overriding or disabling the ACL "VIP Pass" we had just set up.

The fix is a simple, explicit instruction to Samba:

> "Do not reinterpret permissions. The Linux ACLs are the authority here."

This is done with a few simple configuration lines (like `acl_xattr` and `inherit acls`). Once this is set, Samba stops being clever, and the entire system works flawlessly.

### The Final Mental Model

The whole system now operates with perfect clarity:

1.  **You** own your files.
2.  **SMB** writes files as you (the real user).
3.  **FileBrowser** runs as a separate service user.
4.  **ACLs** quietly grant FileBrowser the special access it needs.
5.  **Samba** is told to trust the Linux system and not interfere.

This is the beauty of a **filesystem-first** approach.

---

## Why Not Nextcloud or Other Solutions?

This is the question I get most often. Why go through this setup when you could just install Nextcloud?

The answer is the philosophy: **Nextcloud replaces the filesystem.**

Nextcloud, like many other solutions, adds its own database, its own permission layers, and its own sync logic. If you remove Nextcloud, your files are often left in a complex, proprietary structure that's hard to manage.

In my setup, if FileBrowser disappears tomorrow:

*   **SMB still works.**
*   **The files are still just plain files.**
*   **Nothing is locked in.**

This commitment to simplicity and the filesystem is what makes this setup so robust and future-proof.

---

## What's Next in the Journey?

This setup is now boringly reliable, which is exactly what I wanted. But a cloud isn't complete without a solid backup strategy.

In the next post, we'll dive into:

### 2️⃣ Backups: The Filesystem-First Advantage

We'll look at how tools like `restic` can easily back up these plain directories, and how the ACLs we just set up are preserved perfectly, all without needing any special adapters or complex database dumps.

Stay tuned, and happy self-hosting!
