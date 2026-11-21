# Windows Max Net Speed Optimizer (One-Command PowerShell)

Tune Windows 10/11 network stack, active Wi-Fi or Ethernet adapters, and local SMB transfers with a single PowerShell command — with automatic adapter detection and clean rollback.

## One-Command Install (Run PowerShell as Administrator)

```powershell
irm https://raw.githubusercontent.com/darshanrathod27/windows-max-net-speed-optimizer/main/install.ps1 | iex
```

## How It Works

- **Auto-Detects Active Adapters**: Finds connected (`Up`) physical network interfaces automatically without hardcoding interface names like Wi-Fi or Ethernet.
- **Removes Windows Bottlenecks**: Sets `NetworkThrottlingIndex` to `0xffffffff`, sets QoS `NonBestEffortLimit` to `0`, and disables Delivery Optimization P2P bandwidth sharing.
- **TCP & Local LAN Tuning**: Configures TCP auto-tuning (`normal`), RSS/RSC, disables ECN/heuristics bottlenecks, disables adapter power-saving sleep, and optimizes SMB client/server settings.

## Rollback

```powershell
irm https://raw.githubusercontent.com/darshanrathod27/windows-max-net-speed-optimizer/main/rollback.ps1 | iex
```

## Common User Issues & Fixes

- **Speed still capped by ISP or router**: Software tuning removes OS and adapter throttling, but cannot exceed your ISP plan ceiling or router/link throughput.
- **Brief network drop during run**: Power-management updates on an active adapter can cause a 1–3 second reconnect.
- **Registry policies need refresh**: Restart Windows after running to ensure all policy keys apply cleanly.

## License

MIT — see [LICENSE](LICENSE).
