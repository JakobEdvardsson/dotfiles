# Notes

1. Vite stuck on pending
   Add:

```sh
[Manager]
DefaultLimitNOFILE=65536
```

`/etc/systemd/system.conf` and `/etc/systemd/user.conf`

<https://support.scc.suse.com/s/kb/360054835111?language=en_US>
<https://discussion.fedoraproject.org/t/setting-default-ulimit-n-for-user-in-fedora-40/118073/3>
