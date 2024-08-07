# Private Cardano node cluster

**Blog post (as of 2024-08-07: need to be updated to reflect all changes)**
Reference: https://webuxlab.com/en/devops/cardano-private-cluster


**If you need to expose the socket**
```bash
sudo socat TCP-LISTEN:1234,fork,reuseaddr UNIX-CONNECT:./cluster/main.sock
```

Follow this repo to get a working **nami wallet extension**: https://github.com/studiowebux/nami.git

---
