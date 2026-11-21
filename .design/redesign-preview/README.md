# DayLog redesign: visual reference

This folder is the visual reference for specs `004-design-system`, `005-module-navigation` and
`006-screen-redesign`. It was agreed with Martin over three review rounds on 2026-11-21. An implementing agent reads
the spec first; this folder shows what the result must look like.

## What is here

```
.design/redesign-preview/
├── README.md        this file
├── index.html       round 3: consistency rules + 10 remaining key screens (authoritative)
├── round2.html      round 2: the five agreed screens, the two navigation variants, title weights (authoritative)
├── round1.html      round 1: small / medium / large options per screen (history only, NOT a target)
├── shots/           screenshots of the app BEFORE the redesign, light and dark (the "now" column)
├── renders/         PNG of every mockup phone, light/ and dark/, 2.7x (the "new" column)
└── render.mjs       regenerates renders/ from the two authoritative pages
```

Open a page in a browser to compare "now" and "new" side by side; the theme toggle at the top switches every
mockup between light and dark. Without a browser, read the PNGs in `renders/`.

Regenerate the renders after editing a page (Chromium is pre-installed in the sandbox, never run
`playwright install`):

```bash
NODE_PATH=../WorkLog/node_modules node .design/redesign-preview/render.mjs
```

## Precedence

When two sources disagree, the higher one wins:

1. The requirements of specs 004–006 (exact values, behaviour).
2. `index.html` (round 3) and its renders `renders/*/r3-*.png`.
3. `round2.html` (round 2) and its renders `renders/*/r2-*.png`.
4. `round1.html` is superseded and is never a target.

Known differences the specs resolve (the mockups were drawn before these were decided):

- Round 2 screens set titles at weight 750 and show the old five-tab bottom bar. The specs use weight 600 (the
  default of the Title_Weight experiment) and the module bar of round 2 variant 2.
- Round 2 Statistics has a back arrow; with module navigation Statistics, History and Missions are tabs of their
  module and have no back arrow.
- Round 2 Settings shows the language as `CZ` / `EN`: the segment labels are `CZ` and `EN`, with the full language
  names as semantics labels.
- Round 2 Quests omits the swipe hint; the hint stays as a small faint line (spec 006, Requirement 7).

## Render index

| Render | Screen | Spec |
|---|---|---|
| `r2-timer` | Timer at rest | 006 Req 2 |
| `r2-stats` | Statistics, day | 006 Req 3 |
| `r2-quests` | Quest board | 006 Req 7 |
| `r2-calendar`, `r2-calendar-sheet` | Calendar month, day sheet | 006 Req 12, 13 |
| `r2-settings` | Settings | 006 Req 20 |
| `r2-nav2-timer`, `r2-nav2-quests`, `r2-nav2-calendar` | Module bar (chosen variant 2) | 005 Req 2 |
| `r2-nav2-timer-launcher` | Module launcher | 005 Req 3 |
| `r2-nav1-timer-drawer` | Module drawer (the drawer content; the bar is variant 2) | 005 Req 6 |
| `r2-nav1-*` other | Variant 1 bars: rejected, reference only | - |
| `r2-title-weight-500…800` | Title weight options | 004 Req 2, 005 Req 8 |
| `r3-history` | History | 006 Req 4 |
| `r3-logsheet` | Time entry sheet | 006 Req 5 |
| `r3-dialog` | Confirm dialog | 004 Req 8 |
| `r3-missions` | Missions | 006 Req 8 |
| `r3-mission` | Mission detail | 006 Req 9 |
| `r3-questadd` | New quest sheet (pattern of every form sheet) | 004 Req 7, 006 Req 10 |
| `r3-notes`, `r3-folder` | Notes, folder | 006 Req 15, 16 |
| `r3-reminders`, `r3-reminderadd` | Reminders, reminder sheet | 006 Req 21, 22 |

Mockup text is Czech because Martin uses the app in Czech; the English UI uses the existing English strings.
