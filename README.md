# DA Connect Queue (Advanced Standalone)

![DA Scripts](https://via.placeholder.com/800x200?text=DA+Scripts+-+Connect+Queue)

A professional, advanced standalone connection queue system for FiveM. This script manages player connections with high-end features like Discord role integration, dynamic slots, and admin controls.

Made with ❤️ by **DA Scripts**.

## 🚀 Advanced Features

- **Standalone:** No dependencies on ESX, QBCore, or any other framework.
- **Discord Integration:**
  - **Role-based Priority:** Automatically assign priority levels based on Discord roles.
  - **Webhook Logs:** Real-time logging of queue entries and connections to Discord.
- **Dynamic Slot Management:** Start with a default number of slots and adjust them dynamically.
- **Reserved Slots:** Keep specific slots free for priority players (Staff/VIP) even when the server is "full" for regular players.
- **Priority System:** Multiple levels of priority via identifiers or Discord roles.
- **Estimated Wait Time (ETA):** Calculates and displays the estimated time until connection.
- **Admin Commands:** Manage the queue, whitelist, and slots in-real-time.
- **Grace Period:** Instant reconnection for players who recently crashed.

## 🛠️ Installation

1. Download or clone this repository.
2. Extract the `da-connectqueue` folder into your FiveM `resources` directory.
3. Open your `server.cfg` and add:

```cfg
ensure da-connectqueue
```

4. Configure the settings in `config.lua`.
5. (Optional) For Discord features, provide your Bot Token and Guild ID.

## ⚙️ Configuration

The `config.lua` file is now more powerful:

- `Config.DynamicSlots`: Define `default` and `max` slots.
- `Config.ReservedSlots`: Number of slots reserved for priority players.
- `Config.Discord`: Webhook URL, Bot Token, and Role mappings.
- `Config.WhitelistEnabled`: Toggle whitelist mode.
- `Config.Priority`: Manual priority based on licenses.
- `Config.GracePeriod`: Time allowed for quick reconnection.

## ⌨️ Admin Commands

Use these commands to manage the queue (requires `command.creload`, `command.cwhitelist`, etc. ace permissions):

- `/c-reload`: Reloads `config.lua` without restarting the resource.
- `/c-info`: Displays current queue status and slot usage.
- `/c-whitelist [add/remove] [license]`: Manage the whitelist.
- `/c-slots [number]`: Change the dynamic slot limit on the fly.

## 📜 License

This project is licensed under the MIT License - feel free to use it, just keep the credits to **DA Scripts**.

---

**DA Scripts** - Providing high-quality scripts for the FiveM community.
