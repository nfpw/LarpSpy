# Larp Spy

A remote inspection and debugging tool for Roblox. It logs the remote calls a game makes and shows the code needed to reproduce each call, so developers can study and debug their own game's network traffic.

> **For educational and development use only.** Use it on games you own or have explicit permission to test. Do not use it to gain an unfair advantage in games or to violate the Roblox Terms of Use.

## Features

**Remote logging**
- Logs `RemoteEvent:FireServer`, `RemoteFunction:InvokeServer` and `UnreliableRemoteEvent:FireServer`.
- Optional: `BindableEvent:Fire`, `BindableFunction:Invoke` and incoming `OnClientEvent`.

**Actors**
- Scripts inside Actors run in separate Lua VMs. With **Spy on actors** enabled, calls from actors are logged too, including actors created later.

**Per-call tools**
- Click a call to see its generated code, the remote's path, the calling script and the actor.
- **Ignore** hides a remote from the log.
- Right-click a log entry for more options, such as ignoring every remote with the same name.

**Extra loggers** (optional)
- `table.*` and `buffer.*` calls, capped per frame.
- `LogService` output.
- Debug info, buffer decoding and packet-module support (such as ByteNet).

**Interface**
- Settings are saved to `LarpSpy/settings.json`.
- Configurable log limit, merging of repeated calls, ignored names, code style, theme and toggle key (default `RightControl`).

## Usage

1. Run the script in your test environment.
2. Press `RightControl` to show or hide the window.
3. Enable the call types you want to inspect and play your game. Calls appear as they happen.
4. Click a call to inspect it or copy its code.

Re-running the script removes the previous window and restores its hooks first.

## Requirements

The environment must provide function hooking, metamethod hooking and file access (`hookfunction`, `hookmetamethod`, `getnamecallmethod`, `writefile`, `readfile`). Actor support needs `getactors` and `run_on_actor`. Missing functions are handled with fallbacks where possible.

## Disclaimer

This project is provided for learning and debugging. You are responsible for how you use it.
