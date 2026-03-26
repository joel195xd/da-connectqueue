# DA Connect Queue (Standalone)

![DA Scripts](https://via.placeholder.com/800x200?text=DA+Scripts+-+Connect+Queue)

A professional, standalone connection queue system for FiveM. This script manages player connections, ensuring that the server doesn't exceed its slot limit while providing a fair queuing system based on priority levels and whitelist status.

Made with ❤️ by **DA Scripts**.

## 🚀 Features

- **Standalone:** No dependencies on ESX, QBCore, or any other framework.
- **Priority System:** Assign higher priority levels to specific players (Admins, VIPs, etc.) to skip ahead in the queue.
- **Whitelist System:** Optional whitelist mode based on player identifiers (License, Steam, Discord, etc.).
- **Grace Period:** Allows players who recently disconnected or crashed to skip the queue if they reconnect within a certain timeframe.
- **Highly Configurable:** Easy-to-use `config.lua` for all settings and messages.
- **Optimized:** Efficient deferral handling with regular updates to waiting players.

## 🛠️ Installation

1. Download or clone this repository.
2. Extract the `da-connectqueue` folder into your FiveM `resources` directory.
3. Open your `server.cfg` and add:
   ```cfg
   ensure da-connectqueue
   ```
4. (Optional) Configure the settings in `config.lua`.

## ⚙️ Configuration

The `config.lua` file allows you to customize almost every aspect of the queue:

- `Config.Slots`: Set your server's max slots (e.g., 64).
- `Config.WhitelistEnabled`: Set to `true` to enable whitelist-only mode.
- `Config.Whitelist`: Add player licenses to the whitelist.
- `Config.Priority`: Assign priority levels (higher numbers rank higher in the queue).
- `Config.GracePeriod`: Number of seconds a player has to reconnect without queuing.
- `Config.Messages`: Customize all in-game messages and queue status text.

### Example Priority Config
```lua
Config.Priority = {
    ["license:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"] = 10, -- Super Admin
    ["license:yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy"] = 5,  -- VIP Player
}
```

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details (or feel free to use it as you wish, just keep the credits!).

---

**DA Scripts** - Providing high-quality scripts for the FiveM community.
