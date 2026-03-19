# Features Research: SOUL Terminal

## Table Stakes
Features die gebruikers verwachten van een Android terminal emulator. Zonder deze vertrekken ze.

### Shell & Terminal Basics
| Feature | Complexity | Notes |
|---------|-----------|-------|
| Bash/Zsh shell | **Inherited** | Termux heeft dit al |
| Package manager (pkg/apt) | **Inherited** | Termux heeft dit, maar custom bootstrap nodig voor com.soul.terminal |
| Multiple sessions/tabs | **Inherited** | Termux heeft dit |
| Persistent sessions (survive app switch) | **Inherited** | Termux heeft dit |
| Copy/paste support | **Inherited** | Termux heeft dit |
| Extra keys row (Ctrl, Alt, Tab, etc.) | **Inherited** | Termux heeft dit |
| Configurable font size & typeface | **Inherited** | Termux heeft dit |
| True color (24-bit) support | **Inherited** | Termux heeft dit |
| Unicode/emoji rendering | **Inherited** | Termux heeft dit |
| SSH client (openssh) | **Inherited** | Via packages |
| Foreground service notification | **Inherited** | Termux heeft dit, essentieel op Android 12+ |

### Android Integration
| Feature | Complexity | Notes |
|---------|-----------|-------|
| Storage access (internal + external) | **Inherited** | termux-setup-storage |
| URL detection & opening | **Inherited** | Termux heeft dit |
| Share text from/to terminal | **Inherited** | Recent toegevoegd aan Termux |
| Notification bij background processen | **Inherited** | Via foreground service |

**Totaal inherited van Termux: ~15 features gratis.** Dit is het grote voordeel van forken i.p.v. from scratch.

---

## Differentiators
Features die SOUL Terminal onderscheiden van Termux en andere Android terminals.

### Tier 1 — Core differentiators (must ship)
| Feature | Complexity | Dependencies | Notes |
|---------|-----------|--------------|-------|
| **SOUL AI overlay (FlutterFragment)** | **Hoog** | Flutter module, Pigeon bridge | De killer feature: AI assistent geintegreerd in de terminal. Schuif omhoog voor SOUL, schuif omlaag voor terminal. |
| **Pigeon bridge (Flutter <-> Kotlin)** | **Hoog** | Flutter module | Type-safe communicatie: terminal output naar AI, AI commands naar terminal. Vervangt cmd-proxy. |
| **Custom branding** | **Laag** | — | SOUL Terminal naam, icoon, kleurschema. Rebranding is al begonnen. |
| **Custom bootstrap pipeline** | **Hoog** | termux-packages fork | Alle packages herbouwen met com.soul.terminal prefix. Vereist eigen apt repo. |

### Tier 2 — Modern terminal features (competitive edge)
| Feature | Complexity | Dependencies | Notes |
|---------|-----------|--------------|-------|
| **Kitty keyboard protocol** | **Medium** | terminal-emulator wijzigingen | Moderne apps (Neovim, Helix) verwachten dit. Termux mist het. Ghostty, WezTerm, Alacritty hebben het. |
| **Command palette** | **Medium** | Flutter overlay of native UI | WezTerm-style: fuzzy search door commands, sessies, history. Perfecte Flutter UI use case. |
| **OSC9 desktop notifications** | **Laag** | Android NotificationManager | Terminal apps kunnen native Android notificaties triggeren. Laagdrempelig, hoge waarde. |
| **Inline image support (Kitty graphics protocol)** | **Hoog** | terminal-view wijzigingen | Sixel of Kitty graphics. Maakt image preview in ranger/yazi mogelijk. Complexe rendering. |
| **Split panes** | **Medium-Hoog** | terminal-view layout changes | Ghostty en WezTerm hebben dit built-in. Termux vereist tmux. Native splits = betere UX. |
| **Session restore** | **Medium** | Persistentie laag | Ghostty kan tabs, splits, working directories herstellen na restart. |

### Tier 3 — AI-powered features (long-term moat)
| Feature | Complexity | Dependencies | Notes |
|---------|-----------|--------------|-------|
| **AI command suggestions** | **Medium** | SOUL brain, Pigeon bridge | Terminal output analyseren, volgende commando suggereren. |
| **AI error explanation** | **Medium** | SOUL brain, Pigeon bridge | Foutmeldingen automatisch uitleggen met context. |
| **Smart command history** | **Medium** | SOUL brain, lokale DB | Semantisch zoeken in command history, niet alleen substring match. |
| **Context-aware autocomplete** | **Hoog** | SOUL brain, Pigeon bridge | AI snapt wat je aan het doen bent en suggereert contextual. |
| **Terminal-to-SOUL handoff** | **Medium** | Pigeon bridge | "SOUL, deploy dit" — naadloze overgang van terminal naar AI orchestration. |

---

## Anti-Features
Dingen die we bewust NIET bouwen, en waarom.

| Anti-Feature | Reden |
|-------------|-------|
| **Eigen terminal emulator library** | Termux's terminal-emulator is bewezen, stabiel, en upstream te mergen. Herbouwen = jaren werk, geen toegevoegde waarde. |
| **iOS versie** | Android-only terminal fork. iOS heeft geen terminal emulator ecosystem. |
| **Plugin apps (Termux:Float, Termux:API, etc.)** | SOUL Terminal is self-contained. Plugin functionaliteit komt via Flutter module, niet via aparte APKs. |
| **GUI file manager** | Terminal gebruikers willen ranger/lf/yazi, niet een grafische file browser. Flutter UI is voor AI, niet voor file management. |
| **Built-in code editor (IDE-achtig)** | Neovim/Helix in terminal is beter dan wat wij kunnen bouwen. Focus op terminal excellence + AI, niet IDE features. |
| **Multi-device sync** | v1 is local-first. Sync voegt complexiteit toe zonder core waarde. |
| **Web terminal (browser-based)** | Native Android app. Geen web UI nodig. |
| **Root-only features** | Target device heeft geen root. Alles moet rootless werken. |
| **AccessibilityService integratie** | Verboden door Play Store sinds januari 2026. |
| **Persona selector / multiple chatbot modes** | SOUL is een entiteit. Geen aparte chatbot modi in de UI. |
| **Termux:Widget / home screen shortcuts** | Niet nodig in v1. Focus op core terminal + AI. |

---

## Feature Dependencies

```
Custom Bootstrap Pipeline
  └── Eigen apt repository
       └── termux-packages fork met com.soul.terminal prefix

Flutter Module Embedding
  ├── FlutterFragment integratie in terminal Activity
  ├── Pigeon Bridge (type-safe Flutter <-> Kotlin)
  │    ├── Terminal output streaming naar Flutter
  │    ├── Command execution vanuit Flutter
  │    └── Vervangt cmd-proxy
  └── SOUL AI Brain (Flutter side)
       ├── Claude API integratie
       ├── AI command suggestions
       ├── AI error explanation
       └── Context-aware autocomplete

Modern Terminal Features (onafhankelijk van Flutter)
  ├── Kitty keyboard protocol (terminal-emulator wijziging)
  ├── OSC9 notifications (terminal-emulator + Android)
  ├── Inline images (terminal-view + terminal-emulator)
  ├── Split panes (terminal-view layout)
  ├── Command palette (kan native of Flutter zijn)
  └── Session restore (persistentie laag)

Rebranding (geen dependencies, al begonnen)
  ├── Package name (com.soul.terminal)
  ├── App naam & icoon
  └── UI theming
```

**Kritiek pad:** Rebranding -> Bootstrap -> Flutter Module -> Pigeon Bridge -> AI Features

---

## Complexity Assessment

### Laag (dagen)
- Custom branding (naam, icoon, kleuren) — grotendeels klaar
- OSC9 desktop notifications
- Session tab management UI verbeteringen

### Medium (1-2 weken per feature)
- Kitty keyboard protocol — goed gedocumenteerd, maar terminal-emulator core raken
- Command palette — Flutter UI of native, fuzzy search
- OSC52 clipboard support
- Session restore
- AI command suggestions (als Pigeon bridge er is)
- AI error explanation (als Pigeon bridge er is)

### Hoog (weken-maanden)
- **Custom bootstrap pipeline** — alle packages herbouwen, eigen repo opzetten, CI/CD. Grootste blocker.
- **Flutter module embedding** — FlutterFragment lifecycle, rendering, back button handling, engine caching
- **Pigeon bridge** — interface design, bidirectioneel, streaming terminal output, error handling
- **Inline image support** — Kitty graphics of Sixel in terminal-view, complex rendering
- **Split panes** — terminal-view layout engine, focus management, resize handling
- **Context-aware autocomplete** — AI moet terminal state snappen, latency-sensitief

### Inherited (gratis van Termux)
- Shell, packages, tabs, clipboard, storage, SSH, foreground service, extra keys, colors, fonts
- Dit bespaart maanden werk en is de strategische reden om te forken

---

## Bronnen
- [Terminal Compatibility Matrix](https://tmuxai.dev/terminal-compatibility/)
- [State of Terminal Emulators 2025](https://www.jeffquast.com/post/state-of-terminal-emulation-2025/)
- [Modern Terminal Emulators 2026: Ghostty, WezTerm, Alacritty](https://calmops.com/tools/modern-terminal-emulators-2026-ghostty-wezterm-alacritty/)
- [Kitty Keyboard Protocol](https://sw.kovidgoyal.net/kitty/keyboard-protocol/)
- [Flutter Add-to-App: FlutterFragment](https://docs.flutter.dev/add-to-app/android/add-flutter-fragment)
- [Pigeon Package](https://pub.dev/packages/pigeon)
- [Flutter Platform Channels](https://docs.flutter.dev/platform-integration/platform-channels)
- [Termux GitHub](https://github.com/termux/termux-app)
- [Choosing a Terminal on macOS 2025](https://medium.com/@dynamicy/choosing-a-terminal-on-macos-2025-iterm2-vs-ghostty-vs-wezterm-vs-kitty-vs-alacritty-d6a5e42fd8b3)
