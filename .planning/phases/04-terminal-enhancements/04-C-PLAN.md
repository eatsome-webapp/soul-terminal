---
phase: 4
plan: C
title: "Command Palette with Fuzzy Search"
wave: 1
depends_on: []
autonomous: true
requirements: [TERM-03]
files_modified:
  - app/src/main/java/com/termux/app/terminal/TermuxTerminalViewClient.java
  - app/src/main/java/com/termux/app/TermuxActivity.java
  - app/src/main/java/com/termux/app/terminal/CommandPaletteAdapter.java
  - app/src/main/res/layout/command_palette_dialog.xml
  - app/src/main/res/layout/command_palette_item.xml
---

# Plan 04-C: Command Palette with Fuzzy Search

<objective>
Add a command palette triggered by Ctrl+Shift+P that shows a searchable list of sessions and built-in actions (new session, kill session, rename session, toggle Flutter view). Uses an AlertDialog with an EditText filter and ListView (RecyclerView is not available), following the existing dialog patterns in the codebase. Fuzzy matching uses simple case-insensitive substring matching.
</objective>

<tasks>

<task id="04-C-01">
<title>Create command palette dialog layout XML</title>
<read_first>
- app/src/main/res/layout/item_terminal_sessions_list.xml
</read_first>
<action>
Create `app/src/main/res/layout/command_palette_dialog.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:orientation="vertical"
    android:padding="16dp">

    <EditText
        android:id="@+id/command_palette_search"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:hint="Type to search..."
        android:inputType="text"
        android:singleLine="true"
        android:importantForAutofill="no" />

    <ListView
        android:id="@+id/command_palette_list"
        android:layout_width="match_parent"
        android:layout_height="300dp"
        android:layout_marginTop="8dp" />

</LinearLayout>
```

Create `app/src/main/res/layout/command_palette_item.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:orientation="vertical"
    android:padding="12dp"
    android:background="?android:attr/selectableItemBackground">

    <TextView
        android:id="@+id/palette_item_label"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:textSize="16sp"
        android:textColor="?android:attr/textColorPrimary" />

    <TextView
        android:id="@+id/palette_item_subtitle"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:textSize="12sp"
        android:textColor="?android:attr/textColorSecondary"
        android:visibility="gone" />

</LinearLayout>
```

Note: Uses ListView (not RecyclerView) because `androidx.recyclerview` is not in build.gradle dependencies.
</action>
<acceptance_criteria>
- File `app/src/main/res/layout/command_palette_dialog.xml` exists
- command_palette_dialog.xml contains `android:id="@+id/command_palette_search"`
- command_palette_dialog.xml contains `android:id="@+id/command_palette_list"`
- File `app/src/main/res/layout/command_palette_item.xml` exists
- command_palette_item.xml contains `android:id="@+id/palette_item_label"`
</acceptance_criteria>
</task>

<task id="04-C-02">
<title>Create CommandPaletteAdapter for list items (ListView)</title>
<read_first>
- app/src/main/java/com/termux/app/terminal/TermuxSessionsListViewController.java
</read_first>
<action>
Create `app/src/main/java/com/termux/app/terminal/CommandPaletteAdapter.java` using `BaseAdapter` with a `ListView` (RecyclerView is not available in build.gradle dependencies):

```java
package com.termux.app.terminal;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

import com.termux.R;

import java.util.ArrayList;
import java.util.List;

public class CommandPaletteAdapter extends BaseAdapter {

    public static class PaletteItem {
        public final String label;
        public final String subtitle;
        public final Runnable action;

        public PaletteItem(String label, String subtitle, Runnable action) {
            this.label = label;
            this.subtitle = subtitle;
            this.action = action;
        }
    }

    public interface OnItemClickListener {
        void onItemClick(PaletteItem item);
    }

    private final List<PaletteItem> mAllItems;
    private final List<PaletteItem> mFilteredItems;
    private OnItemClickListener mClickListener;

    public CommandPaletteAdapter(List<PaletteItem> items) {
        mAllItems = new ArrayList<>(items);
        mFilteredItems = new ArrayList<>(items);
    }

    public void setOnItemClickListener(OnItemClickListener listener) {
        mClickListener = listener;
    }

    public void filter(String query) {
        mFilteredItems.clear();
        if (query == null || query.isEmpty()) {
            mFilteredItems.addAll(mAllItems);
        } else {
            String lowerQuery = query.toLowerCase();
            for (PaletteItem item : mAllItems) {
                if (item.label.toLowerCase().contains(lowerQuery) ||
                    (item.subtitle != null && item.subtitle.toLowerCase().contains(lowerQuery))) {
                    mFilteredItems.add(item);
                }
            }
        }
        notifyDataSetChanged();
    }

    @Override
    public int getCount() {
        return mFilteredItems.size();
    }

    @Override
    public PaletteItem getItem(int position) {
        return mFilteredItems.get(position);
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        if (convertView == null) {
            convertView = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.command_palette_item, parent, false);
        }

        PaletteItem item = mFilteredItems.get(position);
        TextView label = convertView.findViewById(R.id.palette_item_label);
        TextView subtitle = convertView.findViewById(R.id.palette_item_subtitle);

        label.setText(item.label);
        if (item.subtitle != null && !item.subtitle.isEmpty()) {
            subtitle.setText(item.subtitle);
            subtitle.setVisibility(View.VISIBLE);
        } else {
            subtitle.setVisibility(View.GONE);
        }

        return convertView;
    }
}
```
</action>
<acceptance_criteria>
- File `app/src/main/java/com/termux/app/terminal/CommandPaletteAdapter.java` exists
- CommandPaletteAdapter.java extends `BaseAdapter`
- CommandPaletteAdapter.java contains `class PaletteItem`
- CommandPaletteAdapter.java contains `public void filter(String query)`
- CommandPaletteAdapter.java contains `item.label.toLowerCase().contains(lowerQuery)`
- CommandPaletteAdapter.java contains `interface OnItemClickListener`
- CommandPaletteAdapter.java does NOT import `RecyclerView`
</acceptance_criteria>
</task>

<task id="04-C-03">
<title>Add showCommandPalette method to TermuxActivity</title>
<read_first>
- app/src/main/java/com/termux/app/TermuxActivity.java
- app/src/main/java/com/termux/app/terminal/TermuxTerminalSessionClient.java
- app/src/main/java/com/termux/app/TermuxService.java
</read_first>
<action>
In `TermuxActivity.java`:

1. Add imports:
   ```java
   import android.text.Editable;
   import android.text.TextWatcher;
   import android.widget.EditText;
   import android.widget.ListView;
   import com.termux.app.terminal.CommandPaletteAdapter;
   import java.util.ArrayList;
   import java.util.List;
   ```
   (Only add what's not already imported.)

2. Add the `showCommandPalette()` method. Place it after the existing dialog-related methods (near line 660 where `showContextMenu` and other dialog methods are):

   ```java
   public void showCommandPalette() {
       if (mTermuxService == null) return;

       List<CommandPaletteAdapter.PaletteItem> items = new ArrayList<>();

       // Add sessions
       List<TermuxService.TermuxSession> sessions = mTermuxService.getTermuxSessions();
       for (int i = 0; i < sessions.size(); i++) {
           final int sessionIndex = i;
           TerminalSession termSession = sessions.get(i).getTerminalSession();
           String name = termSession.mSessionName;
           if (name == null || name.isEmpty()) {
               name = "Session " + (i + 1);
           }
           items.add(new CommandPaletteAdapter.PaletteItem(
               name,
               "Switch to session",
               () -> mTermuxTerminalSessionClient.switchToSession(sessionIndex)
           ));
       }

       // Add built-in actions
       items.add(new CommandPaletteAdapter.PaletteItem(
           "New session",
           "Create a new terminal session",
           () -> mTermuxTerminalSessionClient.addNewSession(false, null)
       ));

       items.add(new CommandPaletteAdapter.PaletteItem(
           "Kill current session",
           "Close the current terminal session",
           () -> {
               TerminalSession current = getCurrentSession();
               if (current != null) {
                   current.finishIfRunning();
               }
           }
       ));

       items.add(new CommandPaletteAdapter.PaletteItem(
           "Rename session",
           "Rename the current terminal session",
           () -> {
               TerminalSession current = getCurrentSession();
               if (current != null) {
                   mTermuxTerminalSessionClient.renameSession(current);
               }
           }
       ));

       items.add(new CommandPaletteAdapter.PaletteItem(
           "Toggle Flutter view",
           "Show or hide the Flutter view",
           () -> toggleFlutterView()
       ));

       // Build dialog
       View dialogView = getLayoutInflater().inflate(R.layout.command_palette_dialog, null);
       EditText searchInput = dialogView.findViewById(R.id.command_palette_search);
       ListView listView = dialogView.findViewById(R.id.command_palette_list);

       CommandPaletteAdapter adapter = new CommandPaletteAdapter(items);
       listView.setAdapter(adapter);

       AlertDialog dialog = new AlertDialog.Builder(this)
           .setTitle("Command Palette")
           .setView(dialogView)
           .setNegativeButton(android.R.string.cancel, null)
           .create();

       listView.setOnItemClickListener((parent, view, position, id) -> {
           CommandPaletteAdapter.PaletteItem item = adapter.getItem(position);
           dialog.dismiss();
           item.action.run();
       });

       searchInput.addTextChangedListener(new TextWatcher() {
           @Override
           public void beforeTextChanged(CharSequence s, int start, int count, int after) {}
           @Override
           public void onTextChanged(CharSequence s, int start, int before, int count) {
               adapter.filter(s.toString());
           }
           @Override
           public void afterTextChanged(Editable s) {}
       });

       dialog.show();

       // Focus the search input and show keyboard
       searchInput.requestFocus();
   }
   ```

   Also add the import for `TerminalSession` if not present:
   ```java
   import com.termux.terminal.TerminalSession;
   ```
</action>
<acceptance_criteria>
- TermuxActivity.java contains `public void showCommandPalette()`
- TermuxActivity.java contains `"Command Palette"`
- TermuxActivity.java contains `"New session"`
- TermuxActivity.java contains `"Kill current session"`
- TermuxActivity.java contains `"Rename session"`
- TermuxActivity.java contains `"Toggle Flutter view"`
- TermuxActivity.java contains `adapter.filter(s.toString())`
- TermuxActivity.java contains `CommandPaletteAdapter`
</acceptance_criteria>
</task>

<task id="04-C-04">
<title>Intercept Ctrl+Shift+P in TermuxTerminalViewClient</title>
<read_first>
- app/src/main/java/com/termux/app/terminal/TermuxTerminalViewClient.java
</read_first>
<action>
In `TermuxTerminalViewClient.java`, in the `onKeyDown(int keyCode, KeyEvent e, TerminalSession currentSession)` method (line 231), add a Ctrl+Shift+P check BEFORE the existing `Ctrl+Alt` block (before line 237).

After the `handleVirtualKeys` check (line 232) and after the `KEYCODE_ENTER` finished-session check (line 234-236), add:

```java
// Command palette: Ctrl+Shift+P
if (e.isCtrlPressed() && e.isShiftPressed() && keyCode == KeyEvent.KEYCODE_P) {
    mActivity.showCommandPalette();
    return true;
}
```

This must be placed BEFORE the `e.isCtrlPressed() && e.isAltPressed()` block so that Ctrl+Shift+P is intercepted first. Place it after line 236 (the closing brace of the ENTER check) and before line 237 (`} else if (!mActivity.getProperties()...`).
</action>
<acceptance_criteria>
- TermuxTerminalViewClient.java contains `e.isCtrlPressed() && e.isShiftPressed() && keyCode == KeyEvent.KEYCODE_P`
- TermuxTerminalViewClient.java contains `mActivity.showCommandPalette()`
- The Ctrl+Shift+P check appears before the `e.isCtrlPressed() && e.isAltPressed()` block
</acceptance_criteria>
</task>

</tasks>

<verification>
1. Build via GitHub Actions — `./gradlew assembleDebug` must succeed
2. Install APK and connect a hardware keyboard (or use Hacker's Keyboard)
3. Press Ctrl+Shift+P — command palette dialog should appear with search bar and list of items
4. Type "new" — only "New session" should remain visible in the filtered list
5. Type "sess" — all session items and session-related actions should appear
6. Tap "New session" — dialog closes, new session is created
7. Tap a session item — dialog closes, app switches to that session
8. Press Back or tap Cancel — dialog closes without action
9. Normal terminal key input must not be affected (Ctrl+Shift+P is the only new shortcut)
</verification>

<must_haves>
- Ctrl+Shift+P opens the command palette dialog
- Palette lists all active sessions with their names
- Palette lists built-in actions: New session, Kill current session, Rename session, Toggle Flutter view
- Typing in the search field filters items using case-insensitive substring matching
- Selecting an item executes the action and closes the dialog
- No crash when palette is opened with zero sessions or dismissed during rotation
</must_haves>
