# App Proxifier (Network Namespace + tun2socks)

## Dependencies

- `tun2socks`
- `nsenter`

---

## How does it work?

`app-proxifier.sh` creates a new network namespace and starts `tun2socks` inside it.

It then:

- Connects this namespace to the host using a veth pair  
- Routes `tun2socks` traffic to your SOCKS5 proxy running in the host namespace  

---

## Setup

You can either:

- Manually configure `app-proxifier.sh`  
**or**
- Use environment variables

### Environment Variables

```bash
# Your username
USER="USER"

# Path to tun2socks
TUN2SOCKS="/opt/tun2socks/tun2socks"

# Your SOCKS5 proxy port
SOCKS_PORT="1080"
```

> ⚠️ **MAKE SURE YOUR SOCKS PROXY LISTENS ON `0.0.0.0` OR INCLUDES THE VETH PAIR ADDRESS**

---

## Running an App Through the Proxy

### Lazy way:

```bash
sudo -E nsenter --net=/run/netns/proxy -- sudo -Eu USERNAME EXECUTABLE
```

I’ve added a simple bash script for running Discord.  
You can use that as an example for your own app and optionally save it in your `$PATH` for easier access.

---

## Notes

- Using nested `sudo` is not good practice. You can implement your own method — just make sure:
  - The correct environment variables are passed  
  - Privileges are properly dropped/elevated where needed  

- This method **does not work with `.desktop` files**. Terminal only.

- Rootless namespaces might be better suited for this purpose.  
  Maybe I’ll look into them in the future.
