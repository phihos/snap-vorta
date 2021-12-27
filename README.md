# Vorta as Snap

## Building

Install snapcraft and simply run `snapcraft` inside the repo root. Then you can install it by running

```bash
sudo snap install vorta*_multi.snap --dangerous
```

## Permissions

There are some permissions you can grant to enable specific features.

```bash
sudo snap connect <plug>
```

| Plug                    | Description                                                                                                                       |
|-------------------------|-----------------------------------------------------------------------------------------------------------------------------------|
| `vorta:home`            | Allow Vorta to access the user's home. Necessary for backing up personal files.                                                   |
| `vorta:network-manager` | Allow Vorta to check the network status. Necessary for backing up when connected to specific networks.                            |
| `vorta:system-backup`   | Allow Vorta to read the full system. Necessary for backing up files outside the current user's home. Makes `vorta:home` obsolete. |

Connecting at least `vorta:home` or `vorta:system-backup` is recommended to ensure some backup functionality.