## Cloudflare Zero Trust changes we made

### 1) Enabled Cloudflare Zero Trust

Activated **Cloudflare Zero Trust** for the account to control access at the identity layer instead of exposing services directly.

Purpose:

* No public IP exposure
* No open ports
* Identity-first access

---

### 2) Created a Cloudflare Tunnel

Set up a **Cloudflare Tunnel** on the server.

What this does:

* Creates an outbound-only connection to Cloudflare
* Eliminates port forwarding
* Works behind NAT, CGNAT, or dynamic IPs

Result:

* FileBrowser is reachable without exposing the server

---

### 3) Mapped public hostname to local service

Configured a public hostname like:

```
files.myfamily.site  →  http://localhost:8181
```

Purpose:

* Clean URL
* TLS handled by Cloudflare
* No certificates on the server

---

### 4) Added Zero Trust Access Application

Created a **Self-Hosted Application** in Zero Trust.

Bound to:

```
https://files.myfamily.site
```

This is where access control actually lives.

---

### 5) Restricted access using identity rules

Defined **Access Policies** such as:

* Allow:

  * Specific email addresses from family

Result:

* Even though the URL is public, access is not

---

### 6) Enabled public access

Create a policy for BypassAuth. Info [here](https://filebrowserquantum.com/en/docs/getting-started/reverse-proxy/)

---

### 7) Create a new ZT Application called 'Public Shares'

* New app should have path `files.myfamily.site/public`
* Associate `BypassAuth` policy with it
