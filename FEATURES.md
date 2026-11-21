# Zafling — Features

The full list of what the app does. For a short overview see [README.md](./README.md); for
internals see [DOCS.md](./DOCS.md).

Zafling is one personal app for one user, built with Flutter for iOS first (the Linux desktop build is used
for development and tests). It is the merger of TimeLog and QuestLog and adds no feature of its own except
loading the data of the two old apps.

## Navigation

- A bottom bar with five tabs: **Timer** (the first screen), **Quests**, **Calendar**, **Notes** and **Settings**.
- A side drawer with the complete navigation: **Timer**, **History**, **Statistics** (group Time), **Quests**,
  **Missions**, **Calendar**, **Notes** (group Planning) and **Settings**, opened with the menu button in the
  header of every page. While History or Statistics is shown, the bar marks Timer; for Missions it marks Quests.
- A link such as `zafling://timer` opens a page: `timer`, `history`, `statistics`, `quests`, `missions`,
  `calendar`, `notes` or `settings`. A Home Screen icon from the Shortcuts app can open any of them.

## Timer, History and Statistics

- Countdown timer with adjustable duration (5–60 minutes, 5-minute steps), an alarm sound and a native
  notification when it finishes, even while backgrounded; a running or paused timer is restored after a restart.
- iOS Live Activity and Dynamic Island with pause, resume and stop from the lock screen.
- Time entries are logged on completion or manual stop, with a description and one of twelve activity types
  (Work, Housework, Meeting, Communication, Travel, Entertainment, Exercise, Self-development, Rest, Hygiene,
  Meal, Other), most with subtypes shown as shades of the type's colour. Work and Housework take a project
  name, Other a free-text name, with suggestions kept apart for paid work, unpaid work, housework and others.
- History: day navigation, a daily summary, edit and delete, and manually adding a past entry. The day starts at 03:00.
- Statistics: a daily or weekly view with a timeline, the time by activity type (with subtypes), by project and by
  name, and the untracked time (16 waking hours a day minus the tracked time).
- A daily reminder that nudges you to start a timer, and recurring reminders for habits with a time window, an
  interval and active days, which repeat until marked done and can be snoozed.

## Quests, Missions and the Board

- **Quests** are one-off tasks with an effort tier (moment, hour, part of a day, full day; 10, 25, 50 or 100 XP).
  The Board has two sections, Today and Todo; quests are reordered and moved between sections by dragging.
- **Missions** are long-term goals made of quests, with a progress ring and a bonus XP reward (small, medium,
  large) when the last quest is done. They can be reordered by dragging; their quests reach the Board only when
  posted there from the quest's edit sheet.
- **Deadline**: a quest can have a date; it shows in the Calendar as an event, and an open quest past its date is
  marked Overdue.
- **XP and levels** are shown in the hero bar; completing a quest or mission opens a reward card, and reopening
  one takes the XP back.
- **Recurring missions** are posted automatically from rules set in Settings (daily, weekly, biweekly, monthly,
  quarterly or yearly). The Board day rolls over at 04:00.

## Calendar

- A month overview, a day sheet, event detail, an event form, search and a type filter. Eleven event types, each
  with its own colour, repeating daily, weekly, monthly or yearly. The first start fills it with the Czech public
  holidays, notable and folk days and name days.
- An event with "On the board" shows on the Board on its day and earns 10 to 100 XP when completed. The address
  field suggests addresses from earlier events and forgets those unused for 30 days. An event of several days is
  drawn as one bar across its days.

## Notes

- Folders and sub-Folders of any depth hold Notes, written in a WYSIWYG editor (Markdown underneath: headings,
  bold, italic, code, links, lists, checklists, quotes) that saves by itself. A Note has a title field; left empty,
  the name follows the first line.
- Rename, move and delete; deleting moves a node to the Trash for 30 days, where it can be read, restored or
  deleted for good.

## Settings and data

- Profile name, language (Czech, English or the device's), light, dark or system appearance, recurring mission
  rules, the Home Screen shortcut guide, the daily reminder with the recurring reminders and the testing tools,
  data export and import, and the licences of the bundled font.
- One theme, the blue one, in a dark and a light variant; further themes are one more entry in a registry.
- **Export**: Settings → Data → Export data saves every table and the stored preferences into one JSON file and
  opens the share sheet.
- **Import**: Settings → Data → Import data loads an export file of QuestLog, TimeLog or Zafling, shows what it
  replaces and asks first. It runs in one transaction and compares the row counts before it commits.
- **Local only**: the data lives in one SQLite file on the device through Drift. There is no server, no account and
  no network access.

## Not in the app

Streaks, a Today page, XP for tracked time, a mini timer bar, an assistant or a journal. The Tasks tab of TimeLog was
already unreachable in TimeLog 1.2.0; neither its screen nor its data is carried over (an import skips them).
