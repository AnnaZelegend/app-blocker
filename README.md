# AppBlocker

A personal iOS app for blocking distracting apps (Instagram, etc.) with a
"vault" style unlock flow: block an app from AppBlocker, and the next time
you try to open it you get a lock screen instead. To use it again, you have
to go back into AppBlocker and unlock it — and unlocking requires sitting
through a short pause first, so it's a decision rather than a reflex tap.

There's also an optional daily schedule (e.g. auto-block Instagram every
day 9am-5pm) that layers on top of whatever you've blocked manually.

## How it works

iOS does not let third-party apps hide, delete, or disable other apps —
that's an OS-level restriction Apple doesn't expose to developers. What it
*does* expose is Apple's **Screen Time API**, which is the mechanism this
app is built on:

- **FamilyControls** — lets the user pick which apps/categories to manage,
  and requests the "Screen Time" authorization prompt.
- **ManagedSettings** — lets the app apply a "shield" to chosen apps. A
  shielded app can't be opened; instead the system shows a full-screen lock
  card over it.
- **ManagedSettingsUI** — lets you customize that lock card (title,
  subtitle, button) and handle the button tap via a **Shield Action
  Extension**.

So the flow is:

1. Open AppBlocker, grant Screen Time access once.
2. On the **Block Now** tab, tap **Add Apps**, pick Instagram (or anything
   else) from the system's privacy-preserving app picker.
3. AppBlocker applies a shield. Instagram now shows a lock screen instead
   of opening.
4. To use Instagram again, open AppBlocker and tap **Unlock** next to it,
   then wait out the 10-second pause. The shield is removed and Instagram
   opens normally until you re-block it.

Separately, the **Schedule** tab lets you pick apps and a daily time
window (e.g. 9am-5pm) to auto-block on a recurring basis, driven by a
`DeviceActivityMonitor` extension that applies/clears its own shield when
the interval starts/ends — independent of whatever you've blocked manually,
so the two never conflict.

This is enforced by iOS itself (not just the app UI), so it can't be
bypassed by force-quitting AppBlocker or restarting the phone.

## Project layout

```
project.yml                          XcodeGen project definition
Shared/AppGroup.swift                Shared App Group identifier
Shared/ScheduleKeys.swift            UserDefaults keys shared with the DeviceActivity extension
AppBlocker/                          Main app target (SwiftUI)
  AppBlockerApp.swift
  RootView.swift                     Authorization gate
  Models/BlockedAppsStore.swift      Manual block/unlock selection + shield state
  Models/ScheduleStore.swift         Daily block-window selection + DeviceActivity scheduling
  Views/ContentTabView.swift         Block Now / Schedule tabs
  Views/HomeView.swift               Blocked-apps list, add/unlock UI
  Views/ScheduleView.swift           Daily block-window configuration
  Views/UnlockConfirmationView.swift Forced pause before an unlock takes effect
  AppBlocker.entitlements
  Info.plist
ShieldConfigurationExtension/        Customizes the lock screen shown
  ShieldConfigurationExtension.swift over a blocked app
ShieldActionExtension/               Handles the lock screen's button tap
  ShieldActionExtension.swift
DeviceActivityMonitorExtension/      Applies/clears the scheduled shield when
  DeviceActivityMonitorExtension.swift the daily block window starts/ends
```

## Building it

This needs a Mac with Xcode 15+ and a physical iPhone (Screen Time APIs
don't work in the Simulator). Steps:

1. Install [XcodeGen](https://github.com/yonaskolb/XcodeGen): `brew install xcodegen`
2. In `project.yml` and `Shared/AppGroup.swift`, replace
   `com.yourcompany.appblocker` with your own bundle ID prefix, and
   register a matching **App Group** (`group.<your-bundle-id>`) in your
   Apple Developer account.
3. Run `xcodegen generate` in the repo root — this produces `AppBlocker.xcodeproj`.
4. Open the project in Xcode, set your Development Team on all four
   targets (AppBlocker, ShieldConfigurationExtension, ShieldActionExtension,
   DeviceActivityMonitorExtension).
5. In **Signing & Capabilities**, add the **Family Controls** capability
   and the matching **App Group** to all four targets (the entitlements
   files already declare them; Xcode needs a signed-in team to provision
   them).
6. Build and run on your device, then accept the Screen Time prompt.

### A note on the Family Controls entitlement

For your own personal use (building from Xcode and installing straight to
your own iPhone), this works with a free or paid Apple Developer account —
no extra approval needed. You only need Apple's separate approval process
if you intend to **distribute** the app via TestFlight or the App Store.

## Limitations

- Blocked apps aren't hidden/deleted — they're shielded. The icon stays on
  your home screen, but tapping it shows the lock screen.
- This can't work on the Simulator or for apps installed via non-standard
  means — only on a real device.
- The unlock pause (10s) is a fixed constant in `UnlockConfirmationView.swift`
  rather than a user-facing setting — change it there if you want it longer,
  shorter, or gone.
- Not implemented here (natural follow-ups if you want them later): a
  passcode/Face ID gate on the unlock button itself, or per-app custom
  schedules (currently one shared window covers all scheduled apps).
