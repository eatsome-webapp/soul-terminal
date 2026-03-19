# Phase 3: Flutter Integration — Research

**Researched:** 2026-03-19

## Summary

Flutter add-to-app vereist een AGP upgrade van 4.2.2 naar 8.x en een Gradle wrapper upgrade van 7.2 naar 8.x. De grootste risicofactor is de migratie van `TermuxActivity extends Activity` naar `FragmentActivity` — de activiteit heeft een complexe view hierarchy (custom root view, DrawerLayout, keyboard insets) die met FragmentActivity anders kan reageren. Pigeon biedt een type-safe in-process bridge die cmd-proxy volledig kan vervangen met significante complexiteitsreductie.

---

## 1. AGP/Gradle Upgrade Path

### Huidige staat
- **AGP**: 4.2.2 (in `build.gradle` root: `classpath 'com.android.tools.build:gradle:4.2.2'`)
- **Gradle wrapper**: 7.2 (in `gradle/wrapper/gradle-wrapper.properties`)
- **compileSdkVersion**: 34 (in `gradle.properties`) — al correct
- **targetSdkVersion**: 34 — al correct
- **Java**: 1.8 source/target compatibility
- **Kotlin**: niet aanwezig

### Upgrade matrix (AGP ↔ Gradle ↔ Java)

| AGP | Min Gradle | Max Gradle | Min Java |
|-----|-----------|-----------|----------|
| 7.0 | 7.0 | 7.4 | 11 |
| 7.4 | 7.5 | 7.6 | 11 |
| 8.0 | 8.0 | 8.3 | 17 |
| 8.1 | 8.0 | 8.3 | 17 |
| 8.3 | 8.4 | 8.6 | 17 |
| 8.7 | 8.9 | — | 17 |

Flutter 3.41.x vereist minimaal AGP 7.0 en werkt optimaal met AGP 8.x. De aanbevolen combinatie is **AGP 8.3.x + Gradle 8.5 + Java 17** — dit is de combinatie die Flutter 3.41.4 standaard genereert bij `flutter create`.

### Noodzakelijke wijzigingen

**`build.gradle` (root):**
```groovy
buildscript {
    dependencies {
        classpath 'com.android.tools.build:gradle:8.3.2'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.22"
    }
}
```

**`gradle/wrapper/gradle-wrapper.properties`:**
```
distributionUrl=https\://services.gradle.org/distributions/gradle-8.5-all.zip
```

**`app/build.gradle` — compileOptions:**
```groovy
compileOptions {
    coreLibraryDesugaringEnabled true
    sourceCompatibility JavaVersion.VERSION_17
    targetCompatibility JavaVersion.VERSION_17
}
```

**`app/build.gradle` — NDK build syntax:**
AGP 8.x depreceert `lintOptions {}` blok — moet `lint {}` worden. Ook `packagingOptions {}` wordt `packaging {}`. De `applicationVariants.all` closure werkt nog steeds.

**Kotlin plugin in `app/build.gradle` plugins:**
Flutter embedding vereist Kotlin support in de app module, maar de app zelf blijft Java. Kotlin plugin toevoegen:
```groovy
plugins {
    id "com.android.application"
    id "org.jetbrains.kotlin.android"
}
```
Dit is ook nodig voor de Flutter module die Kotlin gebruikt voor `GeneratedPluginRegistrant`.

**`settings.gradle` — plugin management (AGP 8.x best practice):**
AGP 8.x werkt nog steeds met de legacy `buildscript {}` syntax in `build.gradle`. Plugin Management block in settings.gradle is optioneel maar aanbevolen. Gezien de complexiteit van de bestaande setup: behoud legacy buildscript syntax, geen migratie naar plugin management blocks nodig.

### NDK compatibiliteit
De bestaande `ndkVersion = "22.1.7171670"` werkt met AGP 8.x. NDK 22 heeft geen conflicten met de AGP 8.x upgrade.

### desugar_jdk_libs
Huidige versie 2.1.3 is compatible met Java 17 source compatibility en AGP 8.x.

---

## 2. Flutter Add-to-App Integration

### Module structuur
Flutter add-to-app werkt via een Flutter module die als Gradle project geïncludeerd wordt. Twee aanpakken:

**Optie A: Source inclusion via settings.gradle (aanbevolen)**
```groovy
// settings.gradle
include ':app', ':termux-shared', ':terminal-emulator', ':terminal-view'

// Flutter module toevoegen:
setBinding(new Binding([gradle: this]))
evaluate(new File(settingsDir, 'flutter_module/.android/include_flutter.groovy'))
```
Dit includeert `:flutter` en `:flutter_module` als Gradle subprojecten. De Flutter SDK genereert het `.android/` directory met de benodigde Gradle configuratie.

**Optie B: AAR pre-build**
`flutter build aar` bouwt een `.aar` die je als Maven local dependency includeert. Minder koppeling, maar vereist dat Flutter gebouwd wordt vóór Gradle.

**Keuze: Optie A** past bij het besluit in 03-CONTEXT.md (source inclusion via settings.gradle). Het vereenvoudigt de CI/CD twee-stage build.

### Flutter module aanmaken
In proot-distro Ubuntu:
```bash
cd /path/to/soul-terminal
flutter create --template=module flutter_module
```
Dit genereert:
```
flutter_module/
  lib/main.dart          # Entry point
  pubspec.yaml
  .android/              # Gradle wrapper (gegenereerd, niet committen)
  .ios/                  # iOS wrapper (niet relevant)
```
`.android/` en `.ios/` komen in `.gitignore` — ze worden bij iedere `flutter pub get` opnieuw gegenereerd.

### FlutterFragment integratie
Na de AGP upgrade en module include, in `TermuxActivity`:

```java
// Fragment tagconstante
private static final String FLUTTER_FRAGMENT_TAG = "flutter_fragment";

// In onCreate(), na setContentView():
FlutterEngine engine = FlutterEngineCache.getInstance()
    .get(MyApplication.FLUTTER_ENGINE_ID);

FlutterFragment flutterFragment = FlutterFragment
    .withCachedEngine(MyApplication.FLUTTER_ENGINE_ID)
    .build();

getSupportFragmentManager()
    .beginTransaction()
    .add(R.id.flutter_container, flutterFragment, FLUTTER_FRAGMENT_TAG)
    .commit();
```

Let op: `getSupportFragmentManager()` vereist `FragmentActivity` als superclass.

### Toggle mechanisme (visibility swap)
Layout beslissing uit 03-CONTEXT.md: FrameLayout container naast de bestaande DrawerLayout, toggle via VISIBLE/GONE. In `activity_termux.xml` wordt de huidige `RelativeLayout` (id: `activity_termux_root_relative_layout`) uitgebreid met een sibling FrameLayout voor de Flutter container:

```xml
<FrameLayout
    android:id="@+id/flutter_container"
    android:layout_width="match_parent"
    android:layout_height="0dp"
    android:layout_weight="1"
    android:visibility="gone" />
```

In TermuxActivity:
```java
private boolean mIsFlutterVisible = false;

public void toggleFlutterView() {
    mIsFlutterVisible = !mIsFlutterVisible;
    findViewById(R.id.flutter_container).setVisibility(
        mIsFlutterVisible ? View.VISIBLE : View.GONE);
    findViewById(R.id.activity_termux_root_relative_layout).setVisibility(
        mIsFlutterVisible ? View.GONE : View.VISIBLE);
}
```

---

## 3. Pigeon Bridge Architecture

### Wat is Pigeon
Pigeon is een Dart code-generator die type-safe platform channels genereert. Gedefinieerd in een Dart schema-file, genereert Pigeon:
- Dart-side: abstracte klassen + `MessageCodec` implementaties
- Java/Kotlin host-side: interfaces die je implementeert in de native code

Geen reflection, geen string-based method lookup, compile-time type checking aan beide kanten.

### Schema definitie (in `flutter_module/pigeons/`)

**`terminal_bridge.dart`** (Flutter → Host):
```dart
import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/generated/terminal_bridge.g.dart',
  javaOut: '../app/src/main/java/com/termux/bridge/TerminalBridgeApi.java',
  javaOptions: JavaOptions(package: 'com.termux.bridge'),
))
@HostApi()
abstract class TerminalBridgeApi {
  void executeCommand(String command);
  String getTerminalOutput(int lines);
  void createSession();
  List<SessionInfo> listSessions();
}

@FlutterApi()
abstract class SoulBridgeApi {
  void onTerminalOutput(String output);
  void onSessionChanged(SessionInfo info);
}

class SessionInfo {
  SessionInfo({required this.id, required this.name, required this.isRunning});
  final int id;
  final String name;
  final bool isRunning;
}
```

**`system_bridge.dart`** (Flutter → Host):
```dart
@HostApi()
abstract class SystemBridgeApi {
  DeviceInfo getDeviceInfo();
  PackageInfo getPackageInfo();
}
```

### Code generatie
```bash
dart run pigeon \
  --input pigeons/terminal_bridge.dart
```

Of via `pubspec.yaml` script. Genereert Java-bestanden in `app/src/main/java/com/termux/bridge/`.

### Host-side implementatie (Java)
Pigeon genereert een interface `TerminalBridgeApi` met methoden die je implementeert:

```java
public class TerminalBridgeImpl implements TerminalBridgeApi {
    private final TermuxService mTermuxService;

    @Override
    public void executeCommand(@NonNull String command) {
        TerminalSession session = mTermuxService.getCurrentSession();
        if (session != null) {
            session.write(command + "\n");
        }
    }

    @Override
    public String getTerminalOutput(int lines) {
        TerminalSession session = mTermuxService.getCurrentSession();
        if (session == null) return "";
        // TerminalBuffer.getTranscriptText() of getSelectedText()
        return session.getEmulator().getScreen().getTranscriptText();
    }
    // ...
}
```

Registratie in TermuxActivity (na service bind):
```java
TerminalBridgeApi.setUp(flutterEngine.getDartExecutor().getBinaryMessenger(),
    new TerminalBridgeImpl(mTermuxService));
```

### SoulBridge (Host → Flutter) — debounced streaming
De `SoulBridgeApi` is een `@FlutterApi()` — host initieert calls naar Flutter. Instance ophalen en aanroepen:

```java
SoulBridgeApi soulBridge = new SoulBridgeApi(
    flutterEngine.getDartExecutor().getBinaryMessenger());

// In TermuxTerminalSessionClient.onTextChanged() (terminal output callback):
mDebounceHandler.removeCallbacksAndMessages(null);
mDebounceHandler.postDelayed(() -> {
    String output = getLastNLines(10);
    soulBridge.onTerminalOutput(output, reply -> {});
}, 100); // 100ms debounce = max 10/sec
```

De debounce-handler is een `android.os.Handler(Looper.getMainLooper())`.

### Pigeon versie
pigeon `^22.x` genereert Java code (niet alleen Kotlin). Controleer dat `javaOut` is opgegeven in PigeonOptions, anders genereert het alleen Kotlin.

---

## 4. FlutterEngine Pre-warming

### Doel
FlutterEngine opstarten kost ~300-500ms op moderne hardware. Pre-warming in `Application.onCreate()` zorgt dat de toggle instant voelt.

### Implementatie in TermuxApplication

```java
public class TermuxApplication extends Application {
    public static final String FLUTTER_ENGINE_ID = "soul_flutter_engine";

    @Override
    public void onCreate() {
        super.onCreate();

        // Bestaande initialisatie...
        TermuxCrashUtils.setCrashHandler(this);
        setLogLevel();

        // FlutterEngine pre-warming
        FlutterEngine flutterEngine = new FlutterEngine(this);
        flutterEngine.getDartExecutor().executeDartEntrypoint(
            DartExecutor.DartEntrypoint.createDefault()
        );
        FlutterEngineCache.getInstance().put(FLUTTER_ENGINE_ID, flutterEngine);
    }
}
```

### FlutterEngineGroup (alternatief)
`FlutterEngineGroup` is efficiënter bij meerdere engines (shared Dart VM). Voor v1 met één engine is `FlutterEngine` + `FlutterEngineCache` voldoende en eenvoudiger.

### Gebruik met FlutterFragment
```java
FlutterFragment flutterFragment = FlutterFragment
    .withCachedEngine(TermuxApplication.FLUTTER_ENGINE_ID)
    .shouldAttachEngineToActivity(true)
    .build();
```

`shouldAttachEngineToActivity(true)` zorgt dat plugins die `ActivityAware` zijn correct werken.

### GeneratedPluginRegistrant (FLUT-04)
Flutter genereert `GeneratedPluginRegistrant.java` in het `.android/` directory van de module. Bij source inclusion wordt dit automatisch aangeroepen door de Flutter embedding. Handmatig aanroepen is niet nodig tenzij je een engine buiten het standaard lifecycle gebruikt:

```java
GeneratedPluginRegistrant.registerWith(flutterEngine);
```

Dit aanroepen direct ná `new FlutterEngine(this)` en vóór `executeDartEntrypoint` is safe.

### Memory overwegingen
Een pre-warmed FlutterEngine houdt ~30-50MB RAM vast, ook als de Flutter UI niet zichtbaar is. Op de Xiaomi 17 Ultra (12GB+ RAM) is dit geen probleem. Engine pas vernietigen in `Application.onTerminate()` (nooit aangeroepen op Android in productie) of nooit — engine leeft mee met app lifecycle.

---

## 5. CI/CD Two-Stage Build

### Huidige CI staat
- **debug_build.yml**: Setup Java 17 → `./gradlew assembleDebug`
- **release_build.yml**: Setup Java 17 → Decode keystore → `./gradlew assembleRelease`
- Geen Flutter setup aanwezig

### Twee-stage aanpak: source inclusion (Optie A)

Bij source inclusion via settings.gradle bouwt Gradle de Flutter module automatisch. Er is geen apart Flutter build-step nodig — maar de Flutter SDK moet beschikbaar zijn in de CI runner.

```yaml
- name: Setup Flutter
  uses: subosito/flutter-action@v2
  with:
    flutter-version: '3.41.4'
    channel: 'stable'
    cache: true

- name: Flutter pub get
  run: |
    cd flutter_module
    flutter pub get

- name: Run Pigeon code generation
  run: |
    cd flutter_module
    dart run pigeon --input pigeons/terminal_bridge.dart
    dart run pigeon --input pigeons/system_bridge.dart

- name: Build APK
  run: ./gradlew assembleDebug
```

### Twee-stage aanpak: AAR pre-build (Optie B)

Expliciete twee fasen:
```yaml
# Stage 1: Flutter module bouwen
- name: Setup Flutter
  uses: subosito/flutter-action@v2
  with:
    flutter-version: '3.41.4'

- name: Build Flutter AAR
  run: |
    cd flutter_module
    flutter build aar --no-debug --no-profile

# Stage 2: Gradle build
- name: Build APK
  run: ./gradlew assembleRelease
```

AAR output gaat naar `flutter_module/build/host/outputs/repo/`. Dan in `app/build.gradle`:
```groovy
repositories {
    maven { url "${rootProject.projectDir}/flutter_module/build/host/outputs/repo" }
    maven { url "https://storage.googleapis.com/download.flutter.io" }
}
dependencies {
    releaseImplementation 'com.example.flutter_module:flutter_release:1.0'
    debugImplementation 'com.example.flutter_module:flutter_debug:1.0'
}
```

### Aanbeveling: Optie A voor CI
Source inclusion is eenvoudiger. De Gradle build roept automatisch `flutter build` aan via de gegenereerde `.android/build.gradle`. Caching:

```yaml
- name: Setup Flutter
  uses: subosito/flutter-action@v2
  with:
    flutter-version: '3.41.4'
    channel: 'stable'
    cache: true  # Cache ~/.pub-cache

- name: Cache Gradle
  uses: actions/cache@v4
  with:
    path: |
      ~/.gradle/caches
      ~/.gradle/wrapper
    key: gradle-${{ hashFiles('**/*.gradle*', '**/gradle-wrapper.properties') }}
```

### Pigeon codegen in CI
Pigeon-gegenereerde bestanden (Java + Dart) committen naar de repo. Zo hoeft CI geen aparte codegen-stap te doen — alleen `flutter pub get` is nodig. De gegenereerde files in `app/src/main/java/com/termux/bridge/` en `flutter_module/lib/generated/` zijn gewone source files.

### Workflow structuur na wijziging (beide workflows)
1. Checkout
2. Setup Java 17
3. Setup Flutter 3.41.4
4. `flutter pub get` in `flutter_module/`
5. (Release only) Decode keystore
6. `./gradlew assembleDebug` of `assembleRelease`
7. Artifact upload

---

## 6. TermuxActivity Migration Risks

### Wat verandert bij Activity → FragmentActivity

`FragmentActivity` is een subklasse van `ComponentActivity` (AndroidX) welke een subklasse is van `Activity`. De public API is grotendeels identiek. Kritieke verschillen:

**1. `getSupportFragmentManager()` vs `getFragmentManager()`**
TermuxActivity gebruikt nergens `getFragmentManager()` — dit is geen issue. Na migratie wordt `getSupportFragmentManager()` beschikbaar.

**2. `onBackPressed()` deprecatie**
`FragmentActivity` (en `ComponentActivity`) depreceert `onBackPressed()` ten gunste van `OnBackPressedDispatcher`. De bestaande `onBackPressed()` implementatie in TermuxActivity (drawer sluiten of finish) werkt nog steeds, maar geeft een deprecation warning. Dit is niet kritiek voor v1.

**3. Window insets**
`TermuxActivityRootView` implementeert `ViewTreeObserver.OnGlobalLayoutListener` en heeft een custom `WindowInsetsListener`. De `fitsSystemWindows="true"` op de root view is al ingesteld. `FragmentActivity` behandelt window insets identiek aan `Activity` — geen breakage verwacht.

**4. Theme vereiste**
`FragmentActivity` vereist een AppCompat theme (of Material Components theme) als parent. In AndroidManifest.xml:
```xml
android:theme="@style/Theme.Termux"
```
`Theme.Termux` is momenteel **niet gedefinieerd** in de codebase als expliciete style. De app haalt `Theme.Termux` en `Theme.Termux_Black` op via `setActivityTheme()` in `onCreate()`. Deze styles zijn afkomstig van de Termux upstream source — maar in de huidige repo zijn ze niet aanwezig. De `styles.xml` in `app/src/main/res/values/` definieert alleen `AppTheme`.

**Dit is een kritiek aandachtspunt**: Als `Theme.Termux` niet AppCompat-based is, crasht de app met `IllegalStateException: You need to use a Theme.AppCompat theme (or descendant) with this activity` zodra `FragmentActivity` als superclass wordt gebruikt.

**Oplossing**: Theme.Termux moet gedefinieerd worden als AppCompat-based (parent: `Theme.AppCompat.NoActionBar`):
```xml
<style name="Theme.Termux" parent="Theme.AppCompat.NoActionBar">
    <item name="colorPrimary">@color/soul_primary</item>
    <!-- ... -->
</style>
<style name="Theme.Termux_Black" parent="Theme.AppCompat.NoActionBar">
    <!-- ... -->
</style>
```

**5. DrawerLayout + FragmentActivity**
`DrawerLayout` uit AndroidX werkt volledig met zowel `Activity` als `FragmentActivity`. Geen wijzigingen nodig.

**6. ServiceConnection interface**
`TermuxActivity implements ServiceConnection` — dit is een Android interface, onafhankelijk van de Activity superklasse. Geen wijziging nodig.

**7. `AlertDialog.Builder`**
De bestaande code gebruikt `android.app.AlertDialog.Builder`. Bij AppCompat-theme werkt dit prima, maar `androidx.appcompat.app.AlertDialog.Builder` is de aanbevolen versie. Niet kritiek voor werking, wel voor consistent theming.

**8. `onCreateContextMenu` / `registerForContextMenu`**
Context menus werken identiek in `FragmentActivity`. Geen wijziging nodig.

### Migratie aanpak

Minimale wijzigingen (zoals besloten in 03-CONTEXT.md):
1. `extends Activity` → `extends FragmentActivity`
2. Import: `android.app.Activity` → `androidx.fragment.app.FragmentActivity`
3. Theme.Termux en Theme.Termux_Black definiëren als AppCompat-descendant in styles.xml
4. Gradle dependency toevoegen: `androidx.fragment:fragment:1.6.2`

`AppCompatActivity` is ook mogelijk (en biedt meer AppCompat features), maar `FragmentActivity` is de minimale vereiste voor `FlutterFragment`.

### TermuxActivityRootView risico
`TermuxActivityRootView extends LinearLayout` — custom view, niet Activity-afhankelijk. Geen risico.

### ViewPager (terminal toolbar)
Gebruikt `androidx.viewpager.widget.ViewPager` — al AndroidX, werkt met FragmentActivity.

### HelpActivity theme
`android:theme="@android:style/Theme.Material.Light.DarkActionBar"` — dit is geen AppCompat theme. Deze activiteit wordt niet gemigreerd (geen FlutterFragment nodig), dus geen issue.

---

## 7. Validation Architecture

### FLUT-01: Flutter module aangemaakt
- **Verificatie**: `ls flutter_module/pubspec.yaml` bestaat, `flutter_module/lib/main.dart` bestaat
- **CI check**: Build faalt als module ontbreekt (source inclusion zal mislukken)

### FLUT-02: FlutterEngine pre-warmed
- **Test**: App starten, via ADB logs checken: `adb logcat | grep -i "flutter\|FlutterEngine"`
- **Verificatie**: `FlutterEngineCache.getInstance().contains(FLUTTER_ENGINE_ID)` in TermuxActivity.onCreate()
- **Timing**: Meten via logcat timestamps — engine start in Application.onCreate(), toggle in TermuxActivity

### FLUT-03: FlutterFragment geïntegreerd met toggle
- **Test**: Toggle button indrukken, Flutter view verschijnt
- **ADB**: `adb shell input tap X Y` op toggle button coordinaat
- **Logcat**: Fragment lifecycle events in logcat controleren

### FLUT-04: GeneratedPluginRegistrant correct aangeroepen
- **Verificatie**: Geen runtime exception bij engine start: `"No implementation found for method"`
- **Log**: Flutter console output via `adb logcat | grep flutter`

### FLUT-05: Layout toggle terminal↔Flutter
- **Test**: Toggle heen-en-weer, terminal processen blijven draaien
- **Verificatie**: `ps aux` in terminal uitvoeren, schakelen naar Flutter, terugschakelen — output nog zichtbaar

### PIGB-01: Pigeon schema gedefinieerd
- **Verificatie**: Gegenereerde Java files aanwezig in `app/src/main/java/com/termux/bridge/`
- **Build check**: Compileert zonder fouten

### PIGB-02: TerminalBridge executeCommand
- **Test**: Via Flutter UI (test interface) een commando invoeren (`echo "pigeon-test"`)
- **Verificatie**: Output verschijnt in terminal view bij terugschakelen

### PIGB-03: SoulBridge terminal output streaming
- **Test**: In terminal een `for i in $(seq 1 20); do echo $i; sleep 0.05; done` uitvoeren
- **Verificatie**: Flutter UI ontvangt updates, max 10/sec (niet 20/sec — debounce werkt)
- **Log**: Timestamp logging in SoulBridgeApi.onTerminalOutput() aanroepen

### PIGB-04: Bidirectionele communicatie
- **Test**: Combinatietest — Flutter stuurt commando, terminal voert uit, output stroomt terug naar Flutter

### PIGB-05: cmd-proxy vervangen
- **Verificatie**: cmd-proxy was HTTP op port 18790. Na implementatie: `curl localhost:18790` geeft geen response — niet meer nodig
- **Functionele test**: Elk cmd-proxy commando dat eerder werkte, nu via Pigeon laten lopen

### CICD-03: Twee-stage CI build
- **Verificatie**: GitHub Actions workflow slaagt met Flutter setup stap
- **Check**: `gh run list --workflow debug_build.yml` — groene run na Flutter stap toevoegen

---

## Key Risks

### Risico 1: Theme.Termux niet AppCompat-based (KRITIEK)
**Beschrijving**: `FragmentActivity` vereist een AppCompat-descendant theme. Als `Theme.Termux` (opgegeven in AndroidManifest.xml) niet als AppCompat style bestaat of geen AppCompat parent heeft, crasht de app met `IllegalStateException` bij iedere launch na de migratie.

**Mitigation**: Vóór de Activity migratie: definieer `Theme.Termux` en `Theme.Termux_Black` expliciet in `styles.xml` met `parent="Theme.AppCompat.NoActionBar"`. De huidige `styles.xml` heeft alleen `AppTheme`. Controleer ook de termux-shared `themes.xml` — die heeft `Theme.AppCompat.TermuxReportActivity` al als AppCompat style.

### Risico 2: AGP 8.x breekt NDK build
**Beschrijving**: De app heeft een NDK build voor bootstrap `.zip` files (`src/main/cpp/Android.mk`). AGP 8.x heeft gewijzigde NDK build semantiek. Mogelijk conflicten met `ndkBuild` configuratie.

**Mitigation**: NDK 22 is compatible met AGP 8.x. De `ndkBuild` block in `externalNativeBuild` werkt in AGP 8.x. Wel: de `lintOptions` block moet naar `lint` worden hernoemd (deprecation in AGP 7.0, removed in AGP 8.0 is niet het geval — removed in AGP 9.0). Gradle sync zal eventuele issues direct tonen.

### Risico 3: TermuxActivityRootView keyboard inset handling
**Beschrijving**: `TermuxActivityRootView` heeft custom keyboard inset handling via `WindowInsetsListener` en een GlobalLayoutListener. FlutterFragment neemt de volledige container in en heeft zijn eigen keyboard handling. Dit kan resulteren in dubbele inset application of keyboard-overlap issues wanneer Flutter zichtbaar is.

**Mitigation**: Bij het bouwen van de toggle: wanneer Flutter VISIBLE is, de `WindowInsetsListener` tijdelijk uitschakelen (`setOnApplyWindowInsetsListener(null)`) en herstellen bij terugschakelen. Flutter's eigen keyboard handling werkt correct als de container `fitsSystemWindows="false"` heeft.

### Risico 4: FlutterEngine pre-warming vertraagt app start
**Beschrijving**: `FlutterEngine` instantiëren in `Application.onCreate()` blokkert de main thread tot de Dart VM opstart. Dit kan app-starttime verhogen met 200-500ms, merkbaar als "jank" bij het openen van de app.

**Mitigation**: `FlutterEngine` initialisatie uitvoeren op een background thread:
```java
new Thread(() -> {
    FlutterEngine engine = new FlutterEngine(TermuxApplication.this);
    // Dart entrypoint in UI thread starten (vereiste van Flutter embedding)
    new Handler(Looper.getMainLooper()).post(() -> {
        engine.getDartExecutor().executeDartEntrypoint(
            DartExecutor.DartEntrypoint.createDefault());
        FlutterEngineCache.getInstance().put(FLUTTER_ENGINE_ID, engine);
    });
}).start();
```
Let op: `executeDartEntrypoint` moet op de main thread.

### Risico 5: Pigeon Java codegen vereist juiste pigeon versie
**Beschrijving**: Pigeon ≥ 10.x genereert standaard Kotlin voor Android. Java output vereist expliciete `javaOut` configuratie. Als dit vergeten wordt, genereert Pigeon alleen Kotlin files die niet compileren in een puur Java module.

**Mitigation**: Zet in `PigeonOptions` altijd expliciet `javaOut` én `javaOptions` met het package. Controleer dat de Kotlin Gradle plugin aanwezig is in het app module (voor compilatie van Flutter embedding Kotlin classes), ook al is de app-code zelf Java.

---

## Recommendations

1. **Gradle upgrade eerst, afzonderlijk testen**: Upgrade AGP naar 8.3.2 + Gradle 8.5 als eerste stap, vóór enige Flutter-gerelateerde wijziging. Dit geeft een clean baseline en isoleert AGP-specifieke problemen. Controleer direct na upgrade dat de NDK build en bestaande APK-build nog werken.

2. **Theme.Termux definiëren vóór Activity migratie**: Voeg `Theme.Termux` en `Theme.Termux_Black` als AppCompat-descendant styles toe aan `styles.xml` vóórdat `FragmentActivity` wordt gebruikt. Dit is de meest voorspelbare crash-oorzaak.

3. **Source inclusion (Optie A) boven AAR**: Source inclusion vereenvoudigt de CI/CD workflow (één gradle build, Flutter SDK aanwezig in runner is voldoende) en maakt hot-reload tijdens ontwikkeling mogelijk. AAR is alleen zinvol als de Flutter module door een apart team beheerd wordt.

4. **Pigeon-gegenereerde files committen**: Commit de gegenereerde Java en Dart files. Dit vermijdt codegen in CI en maakt de build reproduceerbaar zonder extra Dart tooling stap.

5. **FlutterEngine op background thread pre-warmen**: Verplaats de engine instantiatie naar een worker thread (maar `executeDartEntrypoint` op main thread) om app-starttime niet te beïnvloeden.

6. **Minimale v1 Flutter UI**: De Flutter module hoeft in phase 3 alleen een test-interface te bevatten (execute command input + output view). Geen Riverpod, geen Claude API, geen chat UI. Dit houdt de scope beheersbaar en de build-tijd laag.

7. **Toggle button in drawer**: Voeg de SOUL toggle toe als knop in de bestaande left_drawer (naast settings en new_session buttons). Minimalistische integratie zonder extra toolbar of FAB.

---

*Research for: 03-flutter-integration*
