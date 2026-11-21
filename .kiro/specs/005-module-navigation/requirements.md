# Requirements Document

## Introduction

DayLog now holds what used to be separate apps, and its navigation (five fixed tabs plus a drawer with every page)
no longer scales: History and Statistics hide behind two small icons on the Timer, Missions only in the drawer, and
every future page would make the drawer longer. On 2026-11-21 Martin chose a navigation by modules (round 2 of
`.design/redesign-preview/`, variant 2): the app is split into Modules, the bottom bar shows only the pages of the
current Module, and a Module_Button at the edge of the bar opens a Module_Launcher to switch Modules. The drawer stays
as an optional second way.

Because the Module_Button is a new kind of control, Martin wants to try it on his phone before committing to it. This
spec therefore also adds an Experiments group to Settings with three switches: the side of the Module_Button, the
drawer on or off, and the Title_Weight of spec `004-design-system`.

This spec depends on spec `004-design-system` (App_Header, Header_Action, Grouped_List, Segmented_Control, App_Sheet,
glow roles, Title_Weight theme input). It changes the Shell (`lib/shell/`), the header leading element of the module
pages and the Settings page; the restyling of the page contents is spec `006-screen-redesign`. The visual reference
is `.design/redesign-preview/renders/*/r2-nav2-*.png` (module bar and launcher) and
`renders/*/r2-nav1-timer-drawer.png` (drawer content). Project location: `/workspace/DayLog`.

## Glossary

- **App**: The DayLog Flutter app at `/workspace/DayLog`.
- **Shell**: The root screen in `lib/shell/app_shell.dart` that hosts the pages, the Module_Bar, the Drawer and the Reconciliation.
- **Destination**: One page of the App, the existing enum in `lib/shell/destination.dart`: timer, history, statistics, quests, missions, calendar, notes, settings.
- **Module**: A group of Destinations that belong together: Time (timer, history, statistics), Quests (quests, missions), Calendar (calendar), Notes (notes), Settings (settings).
- **Module_Page**: A Destination as a tab of its Module.
- **Module_Bar**: The bottom bar that shows the Module_Button and the Module_Pages of the current Module; it replaces the five-tab `BottomBar`.
- **Module_Button**: The brass square button at one edge of the Module_Bar that shows the icon of the current Module and opens the Module_Launcher.
- **Module_Launcher**: The bottom sheet that lists every Module as a tile and Settings as a row.
- **Previous_Module**: The Module that was current before the current one in this session.
- **Location**: A pair of Module and Module_Page.
- **Last_Location**: The Location shown when the App was last left, stored on the device.
- **Drawer**: The side panel of the Shell, redesigned to list the Modules with chips for their other pages.
- **Menu_Button**: The leading header button that opens the Drawer (`lib/ui_kit/common/menu_button.dart`).
- **Experiment_Settings**: The device-local switches of the Experiments group: Module_Button_Side, Drawer_Enabled and Title_Weight.
- **Module_Button_Side**: Left or right; the edge of the Module_Bar where the Module_Button sits. Left by default.
- **Drawer_Enabled**: On or off; whether the Drawer and the Menu_Button exist. On by default.
- **Title_Weight**: As defined in spec `004-design-system`: 500, 600, 700 or 800; 600 by default.
- **Deep_Link**: A URL `daylog://<destination>` that opens a Destination (existing).
- **Settings_Page**: The screen in `lib/settings/ui/settings_screen.dart`.
- **App_Header**, **Header_Action**, **Grouped_List**, **List_Row**, **Segmented_Control**, **App_Sheet**, **Glow**: As defined in spec `004-design-system`.
- **Icon_Tile**: As defined in spec `004-design-system`.
- **Type_Filter**: The calendar's stored set of shown event types (`lib/calendar/data/calendar_filter_store.dart`), mentioned as the pattern for loading device preferences.

## Requirements

### Requirement 1: Modules

**User Story:** As Martin, I want the app split into modules, so that each part feels like its own small app and new pages have an obvious home.

#### Acceptance Criteria

1. THE App SHALL define five Modules in this order: Time, Quests, Calendar, Notes, Settings.
2. THE App SHALL assign the Module_Pages as follows: Time = Časovač (timer), Historie (history), Statistiky (statistics); Quests = Questy (quests), Mise (missions); Calendar = Kalendář (calendar); Notes = Poznámky (notes); Settings = Nastavení (settings).
3. THE App SHALL give each Module a name and an icon: Time `timer` „Časovač“, Quests `quests` „Questy“, Calendar `calendar` „Kalendář“, Notes `notes` „Poznámky“, Settings `gear` „Nastavení“ (English: Timer, Quests, Calendar, Notes, Settings).
4. THE App SHALL derive the Module of every Destination from this assignment, so that adding a Destination to a Module adds a Module_Page without other changes.

### Requirement 2: Module bar

**User Story:** As Martin, I want the bottom bar to show only the pages of the module I am in, with one button to change modules, so that History and Statistics are one tap away and the bar never gets crowded.

#### Acceptance Criteria

1. THE Module_Bar SHALL show the Module_Button, a vertical hairline separator and one tab per Module_Page of the current Module.
2. THE Module_Button SHALL be a 50 × 50 logical pixel square with a corner radius of 16, the `brass` fill, the icon of the current Module in `inkOnBrass` and the button Glow, centred in a 66 logical pixel wide slot.
3. THE separator SHALL be a 1 logical pixel `lineStrong` line inset 16 logical pixels from the top and bottom of the bar content, with 6 logical pixels of space on each side.
4. THE Module_Bar tabs SHALL show an icon above a label, the label in 12 logical pixels at weight 500 with no letter spacing.
5. THE Module_Bar SHALL draw the tab of the shown Module_Page in `brassText` with a weight 700 label and the other tabs in `text` at 58 % opacity.
6. THE Module_Bar SHALL NOT draw a pill or other indicator behind the selected tab.
7. WHILE the current Module has more than one Module_Page, THE Module_Bar SHALL share the remaining width equally among its tabs.
8. WHILE the current Module has exactly one Module_Page, THE Module_Bar SHALL draw its single tab at a width of at most 92 logical pixels next to the separator.
9. THE Module_Bar SHALL use the `boardRaised` fill, a hairline `boardLine` top border and a content height of 66 logical pixels above the bottom safe area.
10. WHEN a tab is tapped, THE Shell SHALL show its Module_Page.
11. THE Module_Bar SHALL stay visible on every Module_Page and SHALL NOT be shown on routes pushed above the Shell (detail screens, editors, Settings sub-pages).

### Requirement 3: Module launcher

**User Story:** As Martin, I want to switch modules from the bottom of the screen, so that I can do it with one thumb.

#### Acceptance Criteria

1. WHEN the Module_Button is tapped, THE Shell SHALL open the Module_Launcher as an App_Sheet titled „Moduly“ with a close Header_Action.
2. THE Module_Launcher SHALL show the Modules Time, Quests, Calendar and Notes as tiles in a two-column grid with 12 logical pixels of gap.
3. THE Module_Launcher tile SHALL show a 40 logical pixel Icon_Tile with a corner radius of 12, the Module name in 17 logical pixels at weight 700 and the names of its Module_Pages joined by „ · “ in 12.5 logical pixels with the `textDim` colour, on the `card` fill with a hairline border and a corner radius of 20, at least 112 logical pixels high.
4. THE Module_Launcher SHALL mark the tile of the current Module with a 2 logical pixel `brass` border, a `brass` tint of 8 % over `card` and an Icon_Tile filled with `brass` and an `inkOnBrass` icon.
5. THE Module_Launcher SHALL show Settings under the grid as a List_Row with the `gear` Icon_Tile, the label „Nastavení“ and a chevron, in a Grouped_List.
6. THE Module_Launcher SHALL show the hint „Tip: přejetím po tlačítku modulu se vrátíš na předchozí modul“ under the Settings row in 12.5 logical pixels with the `textFaint` colour, centred.
7. WHEN a tile or the Settings row is tapped, THE Shell SHALL close the Module_Launcher and show the last shown Module_Page of that Module, or its first Module_Page when none was shown in this session.
8. WHEN the tile of the current Module is tapped, THE Shell SHALL close the Module_Launcher and keep the shown Module_Page.

### Requirement 4: Previous module gesture

**User Story:** As Martin, I want one gesture to jump back to the module I came from, so that switching between the timer and the quests is instant.

#### Acceptance Criteria

1. WHEN the user drags horizontally on the Module_Button by at least 24 logical pixels in either direction, THE Shell SHALL show the last shown Module_Page of the Previous_Module.
2. WHEN the Shell switches to the Previous_Module, THE Shell SHALL make the Module it left the new Previous_Module.
3. IF there is no Previous_Module in this session, THEN THE Shell SHALL keep the current Module and give no feedback.
4. WHEN the gesture switches the Module, THE App SHALL give a light haptic tap.
5. THE Module_Button SHALL offer the switch as a custom semantics action labelled „Předchozí modul“ while a Previous_Module exists.

### Requirement 5: Location memory

**User Story:** As Martin, I want the app to open where I left it and each module to remember its page, so that I never have to find my place again.

#### Acceptance Criteria

1. WHILE the App runs, THE Shell SHALL remember the last shown Module_Page of each Module.
2. WHEN the shown Location changes, THE Shell SHALL store it as the Last_Location on the device.
3. WHEN the App starts without a Deep_Link, THE Shell SHALL show the Last_Location.
4. IF no Last_Location is stored or it names an unknown Destination, THEN THE Shell SHALL show the Timer page of the Time Module.
5. WHEN the App starts or resumes through a Deep_Link, THE Shell SHALL show the Destination of the link in its Module and SHALL make the Module shown before it the Previous_Module.
6. THE Shell SHALL keep every page mounted while the App runs, so that each page keeps its scroll position (existing behaviour).

### Requirement 6: Drawer

**User Story:** As Martin, I want the drawer to list the modules with shortcuts to their pages, so that I can still reach any page in two taps when I prefer it.

#### Acceptance Criteria

1. THE Drawer SHALL show the title „DayLog“ in 26 logical pixels at weight 800, then one row per Module Time, Quests, Calendar and Notes, then a hairline divider and a Settings row at the bottom.
2. THE Drawer Module row SHALL show a 42 logical pixel icon tile with a corner radius of 13 (the `tone` fill and a `text` icon) and the Module name in 17 logical pixels at weight 650.
3. THE Drawer SHALL mark the row of the current Module with the `brassSoft` fill and an icon tile filled with `brass` and an `inkOnBrass` icon.
4. THE Drawer SHALL show under each Module row a chip for every Module_Page except the first, in 13 logical pixels at weight 600 on the `card` fill with a hairline border, indented to the Module name.
5. WHEN a Module row is tapped, THE Shell SHALL close the Drawer and show the last shown Module_Page of that Module.
6. WHEN a chip is tapped, THE Shell SHALL close the Drawer and show that Module_Page.
7. WHILE Drawer_Enabled is on, THE Shell SHALL open the Drawer by the Menu_Button and by a drag from the left screen edge.
8. WHILE Drawer_Enabled is off, THE Shell SHALL NOT open the Drawer by any gesture and THE Menu_Button SHALL draw nothing.

### Requirement 7: Headers of module pages

**User Story:** As Martin, I want the pages that became tabs to look like tabs, so that no page offers a back arrow to nowhere.

#### Acceptance Criteria

1. THE App SHALL show every Module_Page with an App_Header whose leading element is the Menu_Button.
2. THE History, Statistics and Missions pages SHALL NOT show a back button.
3. THE Timer page SHALL show the title „Časovač“ and SHALL NOT show the History and Statistics icon buttons.
4. THE App SHALL keep the existing back or close leading element on every route pushed above the Shell.
5. WHEN Statistics becomes the shown Module_Page, THE Shell SHALL recompute its figures (existing behaviour).

### Requirement 8: Experiments

**User Story:** As Martin, I want switches for the new navigation and the title weight, so that I can try the variants on my phone before we decide.

#### Acceptance Criteria

1. THE Settings_Page SHALL show a group „Experimenty“ directly before the group „O aplikaci“.
2. THE Experiments group SHALL contain a List_Row „Tlačítko modulů“ with a Segmented_Control „Vlevo“ / „Vpravo“ bound to Module_Button_Side.
3. THE Experiments group SHALL contain a List_Row „Boční menu“ with a switch bound to Drawer_Enabled.
4. THE Experiments group SHALL contain a List_Row „Tloušťka nadpisů“ with a Segmented_Control „500“ / „600“ / „700“ / „800“ bound to Title_Weight.
5. WHEN an Experiment_Settings value changes, THE App SHALL apply it at once, without a restart.
6. WHILE Module_Button_Side is right, THE Module_Bar SHALL draw the separator and the Module_Button at its right edge and keep the order of the tabs.
7. WHEN Title_Weight changes, THE App SHALL rebuild the theme with the new weight for the page and sheet title roles.
8. THE App SHALL store Experiment_Settings in the device preferences under the keys `ui_module_button_side`, `ui_drawer_enabled` and `ui_title_weight`.
9. IF a stored Experiment_Settings value is missing or invalid, THEN THE App SHALL use its default.
10. THE data importer SHALL NOT write keys that start with `ui_`, so that importing an export never changes the Experiment_Settings or the Last_Location of the device.

### Requirement 9: Deep links and shortcuts

**User Story:** As Martin, I want my home-screen shortcuts to keep working, so that the new navigation breaks nothing I set up.

#### Acceptance Criteria

1. WHEN a Deep_Link `daylog://<destination>` arrives, THE Shell SHALL close the routes above it and show that Destination in its Module (existing link names unchanged).
2. THE Shortcut screen SHALL keep offering every Destination except Settings as a target.
3. THE `ShellMenuScope.openPage` callback SHALL keep switching to a Destination by its link name.

### Requirement 10: Accessibility

**User Story:** As a user of assistive technology, I want the new controls to be announced clearly, so that I can navigate by voice and switch.

#### Acceptance Criteria

1. THE Module_Button SHALL expose a button semantics node labelled „<Module name>, přepnout modul“ (English „<Module name>, switch module“).
2. THE Module_Bar tabs SHALL expose button semantics with the selected state on the shown Module_Page.
3. THE Module_Launcher tiles SHALL expose button semantics with the selected state on the current Module.
4. THE Module_Button, the tabs, the tiles and the Drawer rows and chips SHALL be at least 44 × 44 logical pixels.
5. WHILE the device asks for reduced motion, THE Module_Launcher and the Drawer SHALL appear with the existing reduced fade instead of a slide.

### Requirement 11: Quality

**User Story:** As a developer, I want the navigation covered by tests, so that later changes do not break switching.

#### Acceptance Criteria

1. THE App SHALL have tests for the Module assignment, the Module_Bar (both sides, one and several pages), the Module_Launcher, the previous-module gesture, the Location memory, the Drawer (enabled and disabled), the Experiments group and Deep_Links.
2. THE App SHALL keep the existing Shell behaviour tests green: Reconciliation, splash gating, snackbar clearing on page change and the reward overlay over pushed routes.
3. WHEN this spec is complete, THE App SHALL pass `scripts/check.sh`, and the real Linux app SHALL start on its Last_Location with the Module_Bar visible.
4. THE App SHALL keep every new user-facing string in both ARB files with the prefix `shell_` or `settings_` and a description in `app_cs.arb`.
