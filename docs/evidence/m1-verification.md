# M1 verification — 2026-10-16, Africa/Nairobi

Toolchain: Jac 0.37.25, Node 20.20.2, Playwright 1.64.1 / Chromium 156.

## Successful acceptance checks

- `jac install`: installed Python/npm dependencies (network-authorized retry).
- `jac fmt . --check`: all 11 source files formatted.
- `jac check .`: 11 passed; zero errors, warnings remain (see below).
- `jac run --show`: web-app, serve, main.jac, DOM; equivalent `jac run main.jac --dev`.
- `jac run --dev`: ready on localhost:8000, API on localhost:8001.
- `curl -X POST http://localhost:8000/function/shell_status -H 'Content-Type: application/json' -d '{}'`:
  `{"ok":true,"type":"response","data":{"result":"Connected to the Jac kitchen","reports":[]},"error":null}`.
- `jac build --as client`: successful Vite production bundle under .jac/client/dist.
- `node tests/shell-smoke.mjs`: PASS. Home, Explore, Pantry, Cook Along and 404;
  actual server request recorded, title, skip-link focus, keyboard region selection,
  reset region, navigation and deep-link reload. 390px/320px routes have no horizontal
  document overflow. An aborted status request in a fresh context shows the offline
  state; unblocking it and pressing Reconnect restores connected state. No page errors.
- Screenshot mode runs the same suite and captures four desktop/mobile PNGs outside
  the app at /tmp/cooksy-m1-screenshots; copy into docs/screenshots with server stopped.

## Failures investigated

Sandbox package downloads failed and compiler cache was read-only. Required commands
were rerun with authorization. Initial callback arrow annotation failed parsing;
installed props guide corrected it to Callable[[MouseEvent], None].
Pure status initially relocated into JS; explicit server placement corrected it.
Compiled ConnectionStatus now calls __jacCallFunction, and browser tests assert a
real status response; the offline test would fail with a client-only constant.

jac browse initially found no browser; Chromium was downloaded, then Jac browse
captured a desktop screenshot and console. The first accessibility snapshot was
taken too early, before React finished rendering. Persistent Playwright assertions
provide the repeatable acceptance check instead of relying on that empty snapshot.

Concurrent checks/builds, dependency installation or edits while HMR was running
caused transient module-export/server-refresh errors, a navigation abort and a
screenshot timeout. No data was deleted. Run tooling with server stopped, restart,
then run browser checks without edits or parallel compilation. Further diagnosis
showed screenshots written inside the app also trigger Jac HMR. The suite now writes
to /tmp outside the app, and captures are copied into docs only after server shutdown.

## Warning and verification limits

Installed compiler emits W1037 for the intentional router children boundary,
W1050/W1051/W2001 for some intrinsic JSX/runtime types, W2003 for generated state
aliases, and W3005 for optional empty parentheses. These warnings were inspected;
build and browser behavior pass. They are not silently disabled. React Router logs
v7 migration notices; this shell uses the scaffold's v6 dependency. No claim of
warning-free compilation or completed screen-reader/contrast audit is made.

Runtime's local admin portal/default credentials and optional emailer/scheduler
messages are framework defaults. No public deployment or model integration tested.

## Visual evidence

- [Home desktop](../screenshots/m1-home-desktop.png)
- [Home mobile](../screenshots/m1-home-mobile.png)
- [Explore desktop](../screenshots/m1-explore-desktop.png)
- [Explore mobile](../screenshots/m1-explore-mobile.png)

The Home serving artwork is CSS illustration, not SDXL output. No external images,
fonts, provider keys, model weights or user content are required to render the shell.
