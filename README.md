# Kora qb-inventory Image Compatibility

This is an image-path compatibility resource for Kora Inventory. It is **not** the qb-inventory script or an inventory implementation.

It lets legacy NUI code load item artwork from:

```text
nui://qb-inventory/html/images/<image>
```

When started with Kora Inventory, the one-time sync copies image files from `kora_inventory/images/` into this resource's `html/images/` folder. The generated images are ignored by Git and are not committed here.

## Install

1. Place this repository in your resources directory as `qb-inventory` (for example, under `[compat]`). Do not run the real qb-inventory resource at the same time.
2. Ensure this resource and `kora_inventory` are started. The sync waits for Kora Inventory, copies the current images, refreshes the resource packfile, and restarts this resource once if files were copied.
3. Keep this resource running so clients can load the NUI image URLs.

If the server restricts resource command execution, allow this resource to run `refresh` and `restart` in `server.cfg`:

```cfg
add_ace resource.qb-inventory command.refresh allow
add_ace resource.qb-inventory command.restart allow
```

The sync runs once per resource start. Restart `qb-inventory` after adding or changing files in `kora_inventory/images/`.