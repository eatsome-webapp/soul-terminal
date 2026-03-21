---
plan: "08-03"
title: "Pigeon API extensions for session control"
status: completed
completed_at: "2026-03-21"
commits:
  - b7fa8a10: "feat(08-03-01): extend Pigeon definition with session control methods"
  - 4c60a046: "feat(08-03-02): regenerate Pigeon code with new session control methods"
  - 04735dea: "feat(08-03-03): implement closeSession, switchSession, renameSession in TerminalBridgeImpl"
  - b685b416: "feat(08-03-04): fire onSessionListChanged from termuxSessionListNotifyUpdated"
requirements_addressed: [SESS-06]
---

# Summary: Plan 08-03

## Wat is gedaan

**08-03-01** — Pigeon definitie uitgebreid:
- `closeSession(int id)`, `switchSession(int id)`, `renameSession(int id, String name)` toegevoegd aan `TerminalBridgeApi` (HostApi)
- `onSessionListChanged(List<SessionInfo> sessions)` toegevoegd aan `SoulBridgeApi` (FlutterApi)

**08-03-02** — Gegenereerde code handmatig bijgewerkt (cmd-proxy token niet beschikbaar):
- `flutter_module/lib/generated/terminal_bridge.g.dart`: 3 nieuwe async methoden + `onSessionListChanged` handler in `SoulBridgeApi.setUp()`
- `app/src/main/java/com/termux/bridge/TerminalBridgeApi.java`: 3 nieuwe interface methoden + setUp-blokken + `onSessionListChanged` in `SoulBridgeApi`

**08-03-03** — `TerminalBridgeImpl.java` volledig herschreven:
- `mActivity` field + `setActivity(TermuxActivity)` setter
- `closeSession()`: guard op bounds en last-session, `finishIfRunning()` op main thread (CP-4)
- `switchSession()`: delegeert naar `mActivity.getTermuxTerminalSessionClient().switchToSession(index)` op main thread
- `renameSession()`: schrijft `mSessionName`, roept `termuxSessionListNotifyUpdated()` aan op main thread
- `getCurrentTerminalSession()` gefixed: gebruikt `mActivity.getTerminalView().getCurrentSession()` als primaire bron
- `TermuxActivity.setupPigeonBridges()` uitgebreid: maakt echte `TerminalBridgeImpl` aan, registreert HostApi, slaat `SoulBridgeApi` op als `mSoulBridgeApi`

**08-03-04** — `termuxSessionListNotifyUpdated()` uitgebreid:
- Bouwt `List<SessionInfo>` van alle actieve sessies
- Vuurt `mSoulBridgeApi.onSessionListChanged(sessions, reply -> {})` af

## Beslissingen

- Pigeon code handmatig gegenereerd (exact patroon van bestaande v22.7.0 output gevolgd) omdat cmd-proxy token niet beschikbaar was. CI build verifieert correctheid.
- `setupPigeonBridges()` was een placeholder — nu omgezet naar echte registratie met field-opslag voor `mSoulBridgeApi`
- `setActivity()` setter (niet constructor parameter) om bestaande `TermuxService`-only constructie niet te breken

## Verificatie

- Alle 4 acceptance criteria sets geslaagd via grep checks
- 4 atomische commits, elk per taak
- CI build pending (GitHub Actions)
