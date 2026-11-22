// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get app_name => 'DayLog';

  @override
  String get app_splashLoading => 'Preparing your board…';

  @override
  String get app_tabQuests => 'Quests';

  @override
  String get app_tabMissions => 'Missions';

  @override
  String get app_tabSettings => 'Settings';

  @override
  String app_postedMissions(String names) {
    return 'Posted: $names';
  }

  @override
  String get app_reconcileFailed => 'Recurring missions could not be checked.';

  @override
  String get common_cancel => 'Cancel';

  @override
  String get common_delete => 'Delete';

  @override
  String get common_edit => 'Edit';

  @override
  String get common_save => 'Save';

  @override
  String get common_retry => 'Try again';

  @override
  String get common_close => 'Close';

  @override
  String get common_continue => 'Continue';

  @override
  String get common_back => 'Back';

  @override
  String get common_discard => 'Discard';

  @override
  String common_plusXp(int xp) {
    final intl.NumberFormat xpNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String xpString = xpNumberFormat.format(xp);

    return '+$xpString XP';
  }

  @override
  String common_questCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count quests',
      one: '$count quest',
    );
    return '$_temp0';
  }

  @override
  String get common_today => 'today';

  @override
  String get common_yesterday => 'yesterday';

  @override
  String hero_level(int level) {
    return 'Level $level';
  }

  @override
  String hero_nameAndLevel(String name, int level) {
    return '$name · Level $level';
  }

  @override
  String hero_xpProgress(int current, int threshold) {
    final intl.NumberFormat currentNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String currentString = currentNumberFormat.format(current);
    final intl.NumberFormat thresholdNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String thresholdString = thresholdNumberFormat.format(threshold);

    return '$currentString / $thresholdString XP';
  }

  @override
  String hero_xpRemaining(int xp) {
    final intl.NumberFormat xpNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String xpString = xpNumberFormat.format(xp);

    return '$xpString to go';
  }

  @override
  String hero_levelBadgeLabel(int level) {
    return 'Level $level';
  }

  @override
  String hero_progressLabel(int current, int threshold) {
    final intl.NumberFormat currentNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String currentString = currentNumberFormat.format(current);
    final intl.NumberFormat thresholdNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String thresholdString = thresholdNumberFormat.format(threshold);

    return 'Level progress: $currentString of $thresholdString XP';
  }

  @override
  String get board_title => 'Board';

  @override
  String board_subtitle(int count, String date) {
    return '$count open · $date';
  }

  @override
  String get board_todaySection => 'Today';

  @override
  String get board_todoSection => 'Todo';

  @override
  String get board_todayEmpty => 'Drag a quest here to focus on it today.';

  @override
  String get board_todoEmpty => 'New quests are posted here.';

  @override
  String get quest_boardLabel => 'Board';

  @override
  String get quest_boardNone => 'Off the board';

  @override
  String get board_doneSection => 'Done today';

  @override
  String board_doneSummary(int count, int xp) {
    final intl.NumberFormat xpNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String xpString = xpNumberFormat.format(xp);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count quests',
      one: '$count quest',
    );
    return '$_temp0 · $xpString XP';
  }

  @override
  String get board_emptyTitle => 'The board is empty';

  @override
  String get board_emptyBody =>
      'Quests that belong to a mission live under Missions. Tap the + button to post a quest of your own — maybe something you meant to do today anyway. Every one you finish earns XP.';

  @override
  String get board_swipeHint =>
      'Swipe left to edit or delete · tap the circle to complete';

  @override
  String board_rewardWithdrawn(int xp) {
    final intl.NumberFormat xpNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String xpString = xpNumberFormat.format(xp);

    return '$xpString XP withdrawn';
  }

  @override
  String board_rewardWithdrawnMissionReopened(int xp) {
    final intl.NumberFormat xpNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String xpString = xpNumberFormat.format(xp);

    return '$xpString XP withdrawn · mission reopened';
  }

  @override
  String quest_completedTodayAt(String time) {
    return 'today $time';
  }

  @override
  String get quest_completedYesterday => 'yesterday';

  @override
  String quest_completedOn(String date) {
    return '$date';
  }

  @override
  String get quest_deadlineLabel => 'Deadline';

  @override
  String get quest_deadlineNone => 'No deadline';

  @override
  String get quest_deadlineLinkedHint =>
      'The quest shows in the calendar as an event.';

  @override
  String quest_dueOn(String date) {
    return 'Due $date';
  }

  @override
  String quest_overdueOn(String date) {
    return 'Overdue: $date';
  }

  @override
  String get quest_effortMoment => 'Moment';

  @override
  String get quest_effortHour => 'Hour';

  @override
  String get quest_effortPart => 'Part of a day';

  @override
  String get quest_effortDay => 'Full day';

  @override
  String get quest_effortMomentTime => 'up to ~30 min';

  @override
  String get quest_effortHourTime => 'up to ~2 h';

  @override
  String get quest_effortPartTime => '2–4 h';

  @override
  String get quest_effortDayTime => 'the whole day';

  @override
  String get quest_effortHint =>
      'Pick by how much time it will take. A trip, waiting around or something unpleasant? Go one step up — effort earns more XP.';

  @override
  String get a11y_addQuest => 'Post a quest';

  @override
  String get a11y_addMission => 'Start a mission';

  @override
  String a11y_completeQuest(String name) {
    return 'Complete quest $name';
  }

  @override
  String a11y_reopenQuest(String name) {
    return 'Reopen quest $name';
  }

  @override
  String get a11y_dragHint => 'Press and hold, then drag';

  @override
  String a11y_editQuest(String name) {
    return 'Edit quest $name';
  }

  @override
  String a11y_deleteQuest(String name) {
    return 'Delete quest $name';
  }

  @override
  String a11y_editMission(String name) {
    return 'Edit mission $name';
  }

  @override
  String a11y_deleteMission(String name) {
    return 'Delete mission $name';
  }

  @override
  String a11y_openMission(String name) {
    return 'Open mission $name';
  }

  @override
  String get a11y_missionMenu => 'Mission menu';

  @override
  String a11y_effort(int step, int total) {
    return 'Effort $step of $total';
  }

  @override
  String a11y_missionProgress(int done, int total) {
    return '$done of $total quests done';
  }

  @override
  String a11y_questCompleted(String name, int xp) {
    final intl.NumberFormat xpNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String xpString = xpNumberFormat.format(xp);

    return 'Quest $name completed, +$xpString XP';
  }

  @override
  String a11y_questReopened(String name) {
    return 'Quest $name reopened';
  }

  @override
  String a11y_missionCompleted(String name, int xp) {
    final intl.NumberFormat xpNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String xpString = xpNumberFormat.format(xp);

    return 'Mission $name completed, bonus +$xpString XP';
  }

  @override
  String a11y_missionReopened(String name) {
    return 'Mission $name reopened';
  }

  @override
  String a11y_levelUp(int level) {
    return 'Level up, level $level';
  }

  @override
  String get a11y_dismissReward => 'Dismiss reward';

  @override
  String get a11y_removeRow => 'Remove row';

  @override
  String get a11y_pickPostingDay => 'Pick the posting day';

  @override
  String get quest_sheetCreateTitle => 'New quest';

  @override
  String get quest_sheetEditTitle => 'Edit quest';

  @override
  String get quest_nameLabel => 'What needs doing';

  @override
  String get quest_namePlaceholder => 'Hang the laundry';

  @override
  String get quest_effortLabel => 'Effort';

  @override
  String get quest_missionLabel => 'Part of a mission';

  @override
  String get quest_missionNone => 'No mission';

  @override
  String quest_addedToMission(String name) {
    return 'Added to mission $name';
  }

  @override
  String get quest_noteLabel => 'Note';

  @override
  String get quest_notePlaceholder =>
      'Optional — where, how, what not to forget…';

  @override
  String get quest_createAction => 'Post quest';

  @override
  String get quest_doneLockedHint =>
      'Only the name and note of a done quest can be changed.';

  @override
  String get quest_deleteTitle => 'Delete quest?';

  @override
  String quest_deleteBody(String name) {
    return 'Quest “$name” will be deleted.';
  }

  @override
  String quest_deleteDoneBody(String name) {
    return 'Quest “$name” will be deleted. The XP already earned is kept.';
  }

  @override
  String get sheet_discardTitle => 'Discard changes?';

  @override
  String get sheet_discardBody => 'What you entered will not be saved.';

  @override
  String get sheet_keepEditing => 'Keep editing';

  @override
  String get reward_questComplete => 'QUEST COMPLETE';

  @override
  String get reward_levelUp => 'LEVEL UP';

  @override
  String get reward_missionComplete => 'MISSION COMPLETE';

  @override
  String reward_levelUpBody(int level) {
    return 'You reached level $level';
  }

  @override
  String reward_levelNumber(int level) {
    return '$level';
  }

  @override
  String reward_missionLine(String name) {
    return 'Mission · $name';
  }

  @override
  String reward_missionProgress(int done, int total) {
    return '$done of $total quests';
  }

  @override
  String reward_missionRemaining(int xp) {
    final intl.NumberFormat xpNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String xpString = xpNumberFormat.format(xp);

    return '$xpString XP remaining';
  }

  @override
  String reward_missionBonusHint(int xp) {
    final intl.NumberFormat xpNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String xpString = xpNumberFormat.format(xp);

    return 'Completing the mission brings another +$xpString XP';
  }

  @override
  String get reward_missionReady =>
      'All quests are done — complete the mission to claim the bonus.';

  @override
  String get reward_completeMission => 'Complete mission';

  @override
  String get missions_title => 'Missions';

  @override
  String missions_openCount(int count) {
    return '$count in progress';
  }

  @override
  String missions_doneCount(int count) {
    return '$count completed';
  }

  @override
  String get missions_sectionOpen => 'In progress';

  @override
  String get missions_sectionDoneToday => 'Completed today';

  @override
  String missions_remaining(int xp) {
    final intl.NumberFormat xpNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String xpString = xpNumberFormat.format(xp);

    return 'Remaining: $xpString XP';
  }

  @override
  String get missions_bonusCaption => 'on completion';

  @override
  String get missions_earnedCaption => 'earned';

  @override
  String get missions_readyToComplete => 'Ready to complete';

  @override
  String missions_completedLine(int count, String time) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count quests',
      one: '$count quest',
    );
    return '$_temp0 · completed today at $time';
  }

  @override
  String get missions_emptyTitle => 'No missions yet';

  @override
  String get missions_emptyBody =>
      'A mission is a bigger goal made of quests. Completing it earns bonus XP.';

  @override
  String get missions_emptyAction => 'Start a mission';

  @override
  String get missions_recurringCaption => 'Recurring mission';

  @override
  String get mission_sheetCreateTitle => 'New mission';

  @override
  String get mission_sheetEditTitle => 'Edit mission';

  @override
  String get mission_nameLabel => 'Mission name';

  @override
  String get mission_namePlaceholder => 'Big autumn clean-up';

  @override
  String get mission_bonusLabel => 'Completion reward';

  @override
  String get mission_bonusSmall => 'Small';

  @override
  String get mission_bonusMedium => 'Medium';

  @override
  String get mission_bonusLarge => 'Large';

  @override
  String get mission_bonusHelp => 'On top of the XP for each quest.';

  @override
  String mission_questsLabel(int count) {
    return 'Quests in mission · $count';
  }

  @override
  String get mission_questNamePlaceholder => 'Quest name';

  @override
  String get mission_addQuest => 'Add quest';

  @override
  String get mission_createAction => 'Start mission';

  @override
  String get mission_editBonusNote =>
      'The bonus already earned does not change.';

  @override
  String get mission_editQuestsNote =>
      'Quests are edited on the mission screen.';

  @override
  String get time_reminderEveryDay => 'Every day';

  @override
  String get mission_progressLabel => 'Progress';

  @override
  String mission_progressText(int done, int total) {
    return '$done of $total quests done';
  }

  @override
  String mission_bonusOnCompletion(int xp) {
    final intl.NumberFormat xpNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String xpString = xpNumberFormat.format(xp);

    return '+$xpString XP on completion';
  }

  @override
  String get mission_sectionRemaining => 'Remaining';

  @override
  String get mission_sectionDone => 'Done';

  @override
  String mission_sectionSummary(int count, int xp) {
    final intl.NumberFormat xpNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String xpString = xpNumberFormat.format(xp);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count quests',
      one: '$count quest',
    );
    return '$_temp0 · $xpString XP';
  }

  @override
  String get mission_menuEdit => 'Edit mission';

  @override
  String get mission_menuAddQuest => 'Add quest';

  @override
  String get mission_menuDelete => 'Delete mission';

  @override
  String get mission_addQuestToMission => 'Add quest to mission';

  @override
  String get mission_completeAction => 'Complete mission';

  @override
  String get mission_completedTitle => 'Mission complete';

  @override
  String mission_completedBonus(int xp) {
    final intl.NumberFormat xpNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String xpString = xpNumberFormat.format(xp);

    return 'Bonus earned +$xpString XP';
  }

  @override
  String mission_completedOn(String date) {
    return 'Completed $date';
  }

  @override
  String get mission_bonusWithdrawn =>
      'The bonus was withdrawn and the mission is open again.';

  @override
  String get mission_emptyTitle => 'This mission has no quests yet';

  @override
  String get mission_emptyBody => 'Tap “Add quest” to post the first step.';

  @override
  String get mission_deleteTitle => 'Delete mission?';

  @override
  String mission_deleteBody(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Mission “$name” will be deleted along with its $count quests. The XP already earned is kept.',
      one:
          'Mission “$name” will be deleted along with its $count quest. The XP already earned is kept.',
      zero: 'Mission “$name” will be deleted. The XP already earned is kept.',
    );
    return '$_temp0';
  }

  @override
  String get settings_title => 'Settings';

  @override
  String get settings_groupProfile => 'Profile';

  @override
  String get settings_groupLanguage => 'Language';

  @override
  String get settings_groupAppearance => 'Appearance';

  @override
  String get settings_groupRules => 'Recurring missions';

  @override
  String get settings_licenses => 'Licenses';

  @override
  String get settings_groupAbout => 'About';

  @override
  String get settings_heroNameLabel => 'Hero name';

  @override
  String get settings_heroNamePlaceholder => 'What should we call you?';

  @override
  String settings_heroNameCounter(int current, int max) {
    return '$current / $max';
  }

  @override
  String settings_totalXp(int xp) {
    final intl.NumberFormat xpNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String xpString = xpNumberFormat.format(xp);

    return '$xpString XP in total';
  }

  @override
  String get settings_languageCs => 'Čeština';

  @override
  String get settings_languageEn => 'English';

  @override
  String get settings_themeLight => 'Light';

  @override
  String get settings_themeDark => 'Dark';

  @override
  String get settings_themeSystem => 'System';

  @override
  String settings_version(String version) {
    return 'version $version';
  }

  @override
  String settings_rulesActive(int count) {
    return '$count active';
  }

  @override
  String get rule_addRow => 'Add a recurring mission';

  @override
  String get rule_addHint =>
      'A mission posted by hand replaces the nearest automatic one.';

  @override
  String get rule_postNow => 'Post now';

  @override
  String get rule_posted => 'Posted';

  @override
  String get rule_cadenceDaily => 'Daily';

  @override
  String get rule_cadenceWeekly => 'Weekly';

  @override
  String get rule_cadenceBiweekly => 'Every 2 weeks';

  @override
  String get rule_cadenceMonthly => 'Monthly';

  @override
  String get rule_cadenceQuarterly => 'Quarterly';

  @override
  String get rule_cadenceYearly => 'Yearly';

  @override
  String rule_line(String cadence, int count, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count quests',
      one: '$count quest',
    );
    return '$cadence · $_temp0 · next $date';
  }

  @override
  String rule_postedMessage(String name) {
    return 'Mission “$name” posted.';
  }

  @override
  String get rule_postedSkippedNote =>
      'The nearest scheduled posting is skipped.';

  @override
  String get rule_postedClosedNote =>
      'The unfinished previous mission was closed without a bonus.';

  @override
  String get rule_sheetTitle => 'Recurring mission';

  @override
  String get rule_sheetEditTitle => 'Edit rule';

  @override
  String get rule_nameLabel => 'Mission name';

  @override
  String get rule_cadenceLabel => 'Repeat';

  @override
  String get rule_postingDayLabel => 'Always post on';

  @override
  String rule_postingMonthDay(int day) {
    return 'Day $day of the month';
  }

  @override
  String get rule_postingDayWeekdayTitle => 'Day of the week';

  @override
  String get rule_postingDayMonthTitle => 'Day of the month';

  @override
  String get rule_postingDayDateTitle => 'Date';

  @override
  String get rule_helpNoCarryOver =>
      'Unfinished quests from the previous period do not carry over. Posting by hand (in Settings) replaces the nearest automatic posting.';

  @override
  String get rule_editNote => 'Changes apply to the next posted mission only.';

  @override
  String get rule_saveAction => 'Save rule';

  @override
  String get rule_deleteAction => 'Delete rule';

  @override
  String get rule_deleteTitle => 'Delete rule?';

  @override
  String rule_deleteBody(String name) {
    return 'The mission currently posted stays, but no further missions will be posted from “$name”.';
  }

  @override
  String get error_nameRequired => 'Enter a name.';

  @override
  String get error_nameTooLong => 'The name can be at most 80 characters.';

  @override
  String get error_noteTooLong => 'The note can be at most 500 characters.';

  @override
  String get error_heroNameTooLong => 'The name can be at most 40 characters.';

  @override
  String get error_noQuestTemplate => 'Add at least one quest with a name.';

  @override
  String get error_missionNotOpen =>
      'This mission is no longer open. Pick another one, or none.';

  @override
  String get error_validation => 'That value is not valid.';

  @override
  String get error_itemChanged =>
      'That item has changed in the meantime. The list was refreshed.';

  @override
  String get error_storage =>
      'The data could not be saved. Nothing was changed.';

  @override
  String get error_unknown => 'Something went wrong.';

  @override
  String get app_tabCalendar => 'Calendar';

  @override
  String get calendar_today => 'Today';

  @override
  String get calendar_prevMonth => 'Previous month';

  @override
  String get calendar_nextMonth => 'Next month';

  @override
  String get calendar_pickMonth => 'Choose month and year';

  @override
  String get calendar_search => 'Search events';

  @override
  String get calendar_filter => 'Filter by type';

  @override
  String get calendar_add => 'Add event';

  @override
  String calendar_cellLabel(String date, int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString events',
      one: '1 event',
      zero: 'no events',
    );
    return '$date, $_temp0';
  }

  @override
  String calendar_moreEvents(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '+$countString';
  }

  @override
  String get calendar_monthPickerTitle => 'Month and year';

  @override
  String get calendar_prevYear => 'Previous year';

  @override
  String get calendar_nextYear => 'Next year';

  @override
  String get calendar_filterTitle => 'Event types';

  @override
  String get calendar_filterDone => 'Done';

  @override
  String get calendar_filterShowAll => 'Show all types';

  @override
  String get calendar_filterHidesAll => 'The filter hides all events.';

  @override
  String get calendar_typeDance => 'Dance';

  @override
  String get calendar_typeWork => 'Work';

  @override
  String get calendar_typeBirthday => 'Birthday';

  @override
  String get calendar_typeNameDay => 'Name day';

  @override
  String get calendar_typePublicHoliday => 'Public holiday';

  @override
  String get calendar_typeNotableDay => 'Notable day';

  @override
  String get calendar_typeGaming => 'Gaming';

  @override
  String get calendar_typeDoctor => 'Doctor';

  @override
  String get calendar_typeOffice => 'Office';

  @override
  String get calendar_typeHairdresser => 'Hairdresser';

  @override
  String get calendar_typeMeeting => 'Meeting';

  @override
  String get calendar_typeSeminar => 'Seminar';

  @override
  String get calendar_typeLesson => 'Lesson';

  @override
  String get calendar_typeQuest => 'Quest';

  @override
  String get calendar_allDay => 'All day';

  @override
  String calendar_dayEvents(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString events',
      one: '1 event',
      zero: 'No events',
    );
    return '$_temp0';
  }

  @override
  String get calendar_dayEmpty => 'No events';

  @override
  String get calendar_start => 'Start';

  @override
  String get calendar_end => 'End';

  @override
  String get calendar_notes => 'Details';

  @override
  String get calendar_repeat => 'Repeat';

  @override
  String get calendar_location => 'Address';

  @override
  String get calendar_notSet => 'Not set';

  @override
  String calendar_completedAt(String time, int xp) {
    final intl.NumberFormat xpNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String xpString = xpNumberFormat.format(xp);

    return 'Done at $time · +$xpString XP';
  }

  @override
  String get calendar_edit => 'Edit';

  @override
  String get calendar_duplicate => 'Duplicate';

  @override
  String get calendar_menu => 'More actions';

  @override
  String get calendar_locationCopied => 'Address copied';

  @override
  String get calendar_eventGone => 'This event no longer exists.';

  @override
  String get calendar_repeatNever => 'Never';

  @override
  String get calendar_repeatDaily => 'Every day';

  @override
  String get calendar_repeatWeekly => 'Every week';

  @override
  String get calendar_repeatMonthly => 'Every month';

  @override
  String get calendar_repeatYearly => 'Every year';

  @override
  String get calendar_repeatEaster => 'Every year, relative to Easter';

  @override
  String get calendar_repeatNth => 'Every year, by weekday';

  @override
  String get calendar_repeatDescDaily => 'every day';

  @override
  String calendar_repeatDescWeekly(String weekday) {
    return 'every week on $weekday';
  }

  @override
  String calendar_repeatDescMonthly(int day) {
    final intl.NumberFormat dayNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String dayString = dayNumberFormat.format(day);

    return 'every month on day $dayString';
  }

  @override
  String calendar_repeatDescYearly(String date) {
    return 'every year on $date';
  }

  @override
  String get calendar_repeatDescEaster => 'every year, relative to Easter';

  @override
  String calendar_repeatDescNth(String ordinal, String weekday, String month) {
    return 'every year, $ordinal $weekday of $month';
  }

  @override
  String calendar_repeatUntil(String repeat, String date) {
    return '$repeat, until $date';
  }

  @override
  String get calendar_repeatEnds => 'Repeat until';

  @override
  String get calendar_repeatNoEnd => 'No end';

  @override
  String get calendar_formCreateTitle => 'New event';

  @override
  String get calendar_formEditTitle => 'Edit event';

  @override
  String get calendar_formNameHint => 'Event title';

  @override
  String get calendar_formNoteHint => 'Add details';

  @override
  String get calendar_formLocationHint => 'Address';

  @override
  String get calendar_formType => 'Event type';

  @override
  String get calendar_onBoard => 'On the board';

  @override
  String calendar_onBoardXp(int xp) {
    final intl.NumberFormat xpNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String xpString = xpNumberFormat.format(xp);

    return 'For completing: +$xpString XP';
  }

  @override
  String calendar_addressSuggestion(String address) {
    return 'Use address $address';
  }

  @override
  String get calendar_errorName => 'Enter an event title.';

  @override
  String get calendar_errorNameLong => 'The title is too long.';

  @override
  String get calendar_errorEnd => 'The end cannot be before the start.';

  @override
  String get calendar_errorRepeatEnd =>
      'The repeat end cannot be before the start.';

  @override
  String get calendar_errorNoteLong => 'The details are too long.';

  @override
  String get calendar_errorLocationLong => 'The address is too long.';

  @override
  String get calendar_saveFailed => 'Saving failed. Try again.';

  @override
  String get calendar_deleteTitle => 'Delete event?';

  @override
  String calendar_deleteBody(String name) {
    return 'The event “$name” will be deleted.';
  }

  @override
  String calendar_deleteRepeatBody(String name) {
    return 'The event “$name” repeats. What do you want to delete?';
  }

  @override
  String get calendar_deleteOnlyThis => 'Only this event';

  @override
  String get calendar_deleteThisAndFollowing => 'This and all following';

  @override
  String get calendar_deleteAll => 'All events in the series';

  @override
  String calendar_deleted(String name) {
    return 'Event “$name” deleted';
  }

  @override
  String get calendar_undo => 'Undo';

  @override
  String get calendar_deleteFailed => 'Deleting failed.';

  @override
  String get calendar_searchPrompt => 'Type a title, details or a place.';

  @override
  String get calendar_searchNone => 'Nothing found';

  @override
  String a11y_completeEvent(String name) {
    return 'Complete event $name';
  }

  @override
  String a11y_reopenEvent(String name) {
    return 'Reopen event $name';
  }

  @override
  String a11y_eventCompleted(String name, int xp) {
    final intl.NumberFormat xpNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String xpString = xpNumberFormat.format(xp);

    return 'Event $name completed, +$xpString XP';
  }

  @override
  String get calendar_taskAllDay => 'All day';

  @override
  String get calendar_clearRepeatEnd => 'Remove the repeat end';

  @override
  String get app_tabNotes => 'Notes';

  @override
  String get notes_title => 'Notes';

  @override
  String notes_folderCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count folders',
      one: '$count folder',
    );
    return '$_temp0';
  }

  @override
  String notes_noteCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notes',
      one: '$count note',
    );
    return '$_temp0';
  }

  @override
  String get notes_folderEmpty => 'Empty folder';

  @override
  String get notes_sectionFolders => 'Folders';

  @override
  String get notes_sectionNotes => 'Notes';

  @override
  String get notes_emptyTitle => 'Nothing here yet';

  @override
  String get notes_emptyBody => 'Add a note or a folder with the plus button.';

  @override
  String get notes_addTitle => 'Add';

  @override
  String get notes_addNote => 'New note';

  @override
  String get notes_addNoteHint => 'A blank page with the editor';

  @override
  String get notes_addFolder => 'New folder';

  @override
  String get notes_addFolderHint => 'For organising notes and other folders';

  @override
  String notes_addWhere(String place) {
    return 'It will be created in $place';
  }

  @override
  String get notes_createFolder => 'Create folder';

  @override
  String get notes_nameLabel => 'Name';

  @override
  String get notes_renameTitle => 'Rename';

  @override
  String get notes_moveTitle => 'Move';

  @override
  String notes_moveNote(String name) {
    return 'Note “$name”';
  }

  @override
  String notes_moveFolder(String name) {
    return 'Folder “$name”';
  }

  @override
  String get notes_moveRootTag => 'top level';

  @override
  String get notes_moveCurrentTag => 'current location';

  @override
  String notes_moveConfirm(String name) {
    return 'Move to $name';
  }

  @override
  String get notes_actionRename => 'Rename';

  @override
  String get notes_actionMove => 'Move';

  @override
  String get notes_actionDelete => 'Delete';

  @override
  String get notes_actionTrash => 'Move to Trash';

  @override
  String notes_deleteFolderTitle(String name) {
    return 'Move $name to the Trash?';
  }

  @override
  String notes_deleteFolderBody(String contents) {
    return 'The folder holds $contents. They move to the Trash with it and are deleted for good after 30 days.';
  }

  @override
  String notes_joinAnd(String first, String second) {
    return '$first and $second';
  }

  @override
  String get notes_deleteConfirm => 'Move to Trash';

  @override
  String get notes_movedToTrash => 'Moved to the Trash';

  @override
  String get notes_untitled => 'Untitled';

  @override
  String get notes_errorGeneric => 'That did not work.';

  @override
  String get notes_trashButton => 'Trash';

  @override
  String get trash_title => 'Trash';

  @override
  String trash_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '$count item',
    );
    return '$_temp0';
  }

  @override
  String get trash_info =>
      'Items stay in the Trash for 30 days and are then deleted for good. A folder is restored with its content.';

  @override
  String get trash_section => 'Deleted';

  @override
  String trash_noteLine(String from, String when) {
    return 'from $from · $when';
  }

  @override
  String trash_folderLine(String notes, String from, String when) {
    return 'folder, $notes · from $from · $when';
  }

  @override
  String trash_daysLeft(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return 'deleted in $_temp0';
  }

  @override
  String get trash_restore => 'Restore';

  @override
  String get trash_forever => 'Forever';

  @override
  String get trash_emptyAction => 'Empty Trash';

  @override
  String get trash_emptyStateTitle => 'The Trash is empty';

  @override
  String get trash_emptyStateBody =>
      'Deleted notes and folders stay here for 30 days.';

  @override
  String get trash_foreverTitle => 'Delete for good?';

  @override
  String trash_foreverBody(String name) {
    return '$name will be deleted for good with its content and cannot be restored.';
  }

  @override
  String get trash_foreverConfirm => 'Delete for good';

  @override
  String get trash_emptyTitle => 'Empty the Trash?';

  @override
  String trash_emptyBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items will be',
      one: '$count item will be',
    );
    return '$_temp0 deleted for good with their content and cannot be restored.';
  }

  @override
  String get trash_restored => 'Restored';

  @override
  String get trash_openHint => 'Double tap to preview';

  @override
  String get trash_previewEmpty => 'Empty note';

  @override
  String get trash_deleted => 'Deleted for good';

  @override
  String get trash_emptied => 'The Trash was emptied';

  @override
  String get editor_done => 'Done';

  @override
  String get editor_hint => 'Start writing…';

  @override
  String get editor_titleHint => 'Title';

  @override
  String get editor_saveFailed => 'The note could not be saved.';

  @override
  String get editor_tooLong =>
      'The note is too long, at most 100,000 characters.';

  @override
  String get editor_fmtBold => 'Bold';

  @override
  String get editor_fmtItalic => 'Italic';

  @override
  String get editor_fmtHeading => 'Heading';

  @override
  String get editor_fmtList => 'Bulleted list';

  @override
  String get editor_fmtChecklist => 'Checklist';

  @override
  String get editor_fmtQuote => 'Quote';

  @override
  String get editor_fmtCode => 'Code';

  @override
  String get editor_fmtLink => 'Link';

  @override
  String get editor_linkLabel => 'Address';

  @override
  String get editor_linkApply => 'Apply link';

  @override
  String get a11y_nodeMenu => 'Item menu';

  @override
  String a11y_openFolder(String name) {
    return 'Open folder $name';
  }

  @override
  String a11y_openNote(String name) {
    return 'Open note $name';
  }

  @override
  String a11y_renameNode(String name) {
    return 'Rename $name';
  }

  @override
  String a11y_moveNode(String name) {
    return 'Move $name';
  }

  @override
  String a11y_trashNode(String name) {
    return 'Delete $name';
  }

  @override
  String a11y_restoreNode(String name) {
    return 'Restore $name';
  }

  @override
  String a11y_foreverNode(String name) {
    return 'Delete $name for good';
  }

  @override
  String a11y_breadcrumbTo(String name) {
    return 'Go to $name';
  }

  @override
  String get a11y_taskToggle => 'Toggle done';

  @override
  String get settings_shortcutTitle => 'Home Screen shortcut';

  @override
  String get settings_shortcutSubtitle =>
      'Open DayLog on the screen you choose with a single tap.';

  @override
  String get settings_shortcutPickLabel => 'Which screen should the icon open?';

  @override
  String get settings_shortcutCopyLink => 'Copy link';

  @override
  String get settings_shortcutCopied => 'Link copied';

  @override
  String get settings_shortcutStep1 => 'Copy the link above.';

  @override
  String get settings_shortcutStep2 =>
      'On your iPhone open the Shortcuts app and tap +.';

  @override
  String get settings_shortcutStep3 =>
      'Tap Add Action, search for Open URLs and pick it.';

  @override
  String get settings_shortcutStep4 =>
      'Paste the copied link into the URL field.';

  @override
  String get settings_shortcutStep5 =>
      'Tap the share icon and choose Add to Home Screen.';

  @override
  String get settings_shortcutStep6 =>
      'Name the shortcut, change the icon if you like, and tap Add.';

  @override
  String get settings_shortcutNote =>
      'Works on iPhone only. You can move the finished icon into a folder.';

  @override
  String get settings_groupData => 'Data';

  @override
  String get settings_exportTitle => 'Export data';

  @override
  String get settings_exportSubtitle =>
      'Saves all data into one file you can move elsewhere.';

  @override
  String get settings_exportFailed => 'The export failed. Please try again.';

  @override
  String get shell_tabTimer => 'Timer';

  @override
  String get shell_destinationHistory => 'History';

  @override
  String get shell_destinationStatistics => 'Statistics';

  @override
  String get shell_groupTime => 'Time';

  @override
  String get shell_groupPlanning => 'Planning';

  @override
  String get shell_openMenu => 'Menu';

  @override
  String get time_commonCancel => 'Cancel';

  @override
  String get time_commonBack => 'Back';

  @override
  String get time_commonSave => 'Save';

  @override
  String get time_commonDelete => 'Delete';

  @override
  String get time_commonSubmit => 'Submit';

  @override
  String get time_commonSkip => 'Skip';

  @override
  String get time_commonReset => 'Reset';

  @override
  String get time_errorDatabaseUnavailable =>
      'Database unavailable. Please try again.';

  @override
  String get time_errorSaveEntryFailed =>
      'Failed to save entry. Please try again.';

  @override
  String get time_errorSaveFailed => 'Failed to save. Please try again.';

  @override
  String get time_errorDescriptionEmpty => 'Description cannot be empty.';

  @override
  String get time_errorEndBeforeStart => 'End time must be after start time.';

  @override
  String get time_errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get time_projectNameHint => 'Project name...';

  @override
  String get time_descriptionHint => 'Describe what you worked on...';

  @override
  String get time_timeFieldStart => 'Start';

  @override
  String get time_timeFieldEnd => 'End';

  @override
  String time_durationMinutesLabel(int minutes) {
    return '$minutes min';
  }

  @override
  String time_durationMinutesOnly(int minutes) {
    return '${minutes}m';
  }

  @override
  String time_durationHoursOnly(int hours) {
    return '${hours}h';
  }

  @override
  String time_durationHoursMinutes(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String get time_weekdayMon => 'Mo';

  @override
  String get time_weekdayTue => 'Tu';

  @override
  String get time_weekdayWed => 'We';

  @override
  String get time_weekdayThu => 'Th';

  @override
  String get time_weekdayFri => 'Fr';

  @override
  String get time_weekdaySat => 'Sa';

  @override
  String get time_weekdaySun => 'Su';

  @override
  String get time_activityWork => 'Work';

  @override
  String get time_activityHousework => 'Housework';

  @override
  String get time_activityCommute => 'Travel';

  @override
  String get time_activityEntertainment => 'Entertainment';

  @override
  String get time_activityExercise => 'Exercise';

  @override
  String get time_activitySelfDevelopment => 'Self-development';

  @override
  String get time_activityRest => 'Rest';

  @override
  String get time_activityHygiene => 'Hygiene';

  @override
  String get time_activityMeal => 'Meal';

  @override
  String get time_activityMeeting => 'Meeting';

  @override
  String get time_activityCommunication => 'Communication';

  @override
  String get time_activityOther => 'Other';

  @override
  String get time_subtypePaid => 'Paid';

  @override
  String get time_subtypeUnpaid => 'Unpaid';

  @override
  String get time_subtypeEntertainmentActive => 'Active entertainment';

  @override
  String get time_subtypeEntertainmentPassive => 'Passive entertainment';

  @override
  String get time_subtypeWalk => 'Walk';

  @override
  String get time_subtypeRunning => 'Running';

  @override
  String get time_subtypeGym => 'Gym';

  @override
  String get time_subtypeBooks => 'Reading books';

  @override
  String get time_subtypeStudy => 'Study';

  @override
  String get time_subtypeAi => 'AI consultation';

  @override
  String get time_subtypeRestActive => 'Active rest';

  @override
  String get time_subtypeRestPassive => 'Passive rest';

  @override
  String get time_subtypeGeneral => 'General';

  @override
  String get time_subtypeToilet => 'Toilet';

  @override
  String get time_subtypeBreakfast => 'Breakfast';

  @override
  String get time_subtypeLunch => 'Lunch';

  @override
  String get time_subtypeDinner => 'Dinner';

  @override
  String get time_subtypeSnack => 'Snack';

  @override
  String get time_subtypeShopping => 'Shopping';

  @override
  String get time_pickerTypeCaption => 'Type';

  @override
  String time_pickerSubtypeHeading(String type) {
    return 'Refine: $type';
  }

  @override
  String get time_pickerSubtypeHint => 'Choose one';

  @override
  String get time_customNameHint => 'What did you do?';

  @override
  String get time_statsByCustomName => 'Other by name';

  @override
  String get time_timerPhaseReady => 'READY';

  @override
  String get time_timerPhaseFocus => 'FOCUS';

  @override
  String get time_timerPhasePaused => 'PAUSED';

  @override
  String get time_timerPhaseTimeUp => 'TIME UP';

  @override
  String get time_timerPhaseLogging => 'LOGGING';

  @override
  String get time_timerResetTitle => 'Reset timer?';

  @override
  String get time_timerResetBody => 'Do you really want to reset the timer?';

  @override
  String get time_timerTimeUpTitle => 'Time is up!';

  @override
  String get time_ringingDismiss => 'Dismiss';

  @override
  String get time_descriptionClearFormTooltip => 'Clear form';

  @override
  String get time_descriptionTitle => 'What did you accomplish?';

  @override
  String get time_editSheetTitle => 'Edit description';

  @override
  String get time_manualEntryTitle => 'Add entry';

  @override
  String get time_historyTitle => 'History';

  @override
  String get time_historyLoadError => 'Failed to load entries.';

  @override
  String time_historyEntryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries',
      one: '$count entry',
    );
    return '$_temp0';
  }

  @override
  String time_historyTotalLabel(String duration) {
    return 'Total: $duration';
  }

  @override
  String get time_historyDeleteEntryTitle => 'Delete entry?';

  @override
  String get time_historyDeleteEntryBody => 'This action cannot be undone.';

  @override
  String get time_historyDbUnavailableShort => 'Database unavailable.';

  @override
  String get time_historyDeleteEntryFailed => 'Failed to delete entry.';

  @override
  String get time_historyEmptyTitle => 'No entries for this day';

  @override
  String get time_historyEmptySubtitle => 'Start a timer to log your work';

  @override
  String get time_dayToday => 'Today';

  @override
  String get time_dayYesterday => 'Yesterday';

  @override
  String get time_statsTitle => 'Statistics';

  @override
  String get time_statsPeriodDay => 'Day';

  @override
  String get time_statsPeriodWeek => 'Week';

  @override
  String get time_statsLoadFailed => 'Failed to load statistics.';

  @override
  String get time_statsThisWeek => 'This week';

  @override
  String get time_statsNoEntriesPeriod => 'No entries for this period';

  @override
  String get time_statsByActivityType => 'By activity type';

  @override
  String get time_statsByProject => 'By project';

  @override
  String get time_statsTotalTracked => 'Total tracked';

  @override
  String get time_statsUntrackedTime => 'Untracked time';

  @override
  String get time_settingsRemindersSection => 'Reminders';

  @override
  String get time_settingsRecurringRemindersLabel => 'Recurring reminders';

  @override
  String get time_settingsTestingSection => 'Testing';

  @override
  String get time_settingsTestNotificationButton =>
      'Test notification (in 5 s)';

  @override
  String get time_settingsShowModalDebugButton => 'Show modal directly (debug)';

  @override
  String get time_settingsNoRemindersYet =>
      'First create at least one recurring reminder.';

  @override
  String time_settingsTestNotificationTitle(String name) {
    return '🧪 Test: $name';
  }

  @override
  String get time_settingsTestNotificationScheduled =>
      'Test notification will arrive in 5 seconds.';

  @override
  String get time_settingsNoReminder => 'No reminder.';

  @override
  String get time_reminderDeleteTitle => 'Delete reminder?';

  @override
  String time_reminderDeleteBody(String name) {
    return 'Reminder \"$name\" will be permanently deleted.';
  }

  @override
  String get time_reminderDeleteFailed => 'Failed to delete reminder.';

  @override
  String get time_remindersEmptyTitle => 'You don\'t have any reminders yet';

  @override
  String get time_remindersEmptySubtitle =>
      'Tap + to create your first reminder';

  @override
  String get time_remindersLoadFailed => 'Failed to load reminders.';

  @override
  String get time_reminderSnooze => 'Snooze';

  @override
  String get time_reminderDone => 'Done';

  @override
  String get time_reminderCompletionUpdateFailed =>
      'Failed to update completion status.';

  @override
  String get time_reminderActiveToggleFailed => 'Failed to update reminder.';

  @override
  String time_reminderCapacityError(int available, int required) {
    return 'Not enough notification slots: $available available, $required needed.';
  }

  @override
  String get time_reminderDiscardTitle => 'Discard changes?';

  @override
  String get time_reminderDiscardBody => 'Unsaved changes will be lost.';

  @override
  String get time_reminderDiscardConfirm => 'Discard';

  @override
  String get time_reminderEditTitle => 'Edit reminder';

  @override
  String get time_reminderNewTitle => 'New reminder';

  @override
  String get time_reminderNameHint => 'Name';

  @override
  String get time_reminderFromLabel => 'From';

  @override
  String get time_reminderToLabel => 'To';

  @override
  String get time_reminderOvernightNote =>
      'Window spans past midnight into the next day.';

  @override
  String get time_reminderIntervalLabel => 'Repeat interval';

  @override
  String get time_reminderActiveDaysLabel => 'Active days';

  @override
  String get time_reminderActiveLabel => 'Active';

  @override
  String get time_reminderEditBarrierLabel => 'Reminder edit dialog';

  @override
  String get time_recurringReminderDefaultNotificationBody => 'Tap to open';

  @override
  String get time_durationDecreaseLabel => 'Shorten the timer';

  @override
  String get time_durationIncreaseLabel => 'Lengthen the timer';

  @override
  String get time_timerStartLabel => 'Start the timer';

  @override
  String get time_timerPauseLabel => 'Pause the timer';

  @override
  String get time_timerResumeLabel => 'Resume the timer';

  @override
  String get time_timerStopLabel => 'Stop and log';

  @override
  String get time_timerFinishLabel => 'Finish now';

  @override
  String get settings_importTitle => 'Import data';

  @override
  String get settings_importSubtitle =>
      'Loads an export file of QuestLog, TimeLog or DayLog.';

  @override
  String get settings_importConfirmTitle => 'Replace the data?';

  @override
  String settings_importConfirmBody(
    String source,
    String version,
    String date,
    String summary,
  ) {
    return 'The file $source $version from $date replaces these tables (rows in the file, rows now):\n$summary';
  }

  @override
  String settings_importSummaryLine(String table, int rows, int current) {
    return '$table: $rows / $current';
  }

  @override
  String get settings_importConfirmAction => 'Replace';

  @override
  String get settings_importDoneTitle => 'Import finished';

  @override
  String settings_importDoneBody(int rows, int tables) {
    return 'Loaded $rows rows into $tables tables.';
  }

  @override
  String get settings_importPreferencesFailed =>
      'The timer and reminder settings could not be saved; the data is loaded.';

  @override
  String get settings_importFailedNotJson =>
      'The file is not a data export (it is not valid JSON).';

  @override
  String get settings_importFailedWrongFormat =>
      'This file is not an export of QuestLog, TimeLog or DayLog.';

  @override
  String get settings_importFailedNewerFormat =>
      'The file is from a newer version that this app cannot read.';

  @override
  String settings_importFailedMissingSection(String detail) {
    return 'The file lacks the part \"$detail\".';
  }

  @override
  String settings_importFailedUnknownTable(String detail) {
    return 'The file has a table \"$detail\" that the app does not know. Nothing was changed.';
  }

  @override
  String settings_importFailedUnknownColumn(String detail) {
    return 'The file has a column \"$detail\" that the app does not know. Nothing was changed.';
  }

  @override
  String settings_importFailedForeignKey(String detail) {
    return 'The data in the file does not refer to itself correctly (table \"$detail\"). Nothing was changed.';
  }

  @override
  String settings_importFailedCountMismatch(String detail) {
    return 'A row count does not match ($detail). Nothing was changed.';
  }

  @override
  String get settings_importFailedGeneric =>
      'The import failed. Nothing was changed.';

  @override
  String get time_timerCompleteNotificationBody => 'Timer complete!';

  @override
  String get time_liveActivityCompleted => 'Timer complete!';

  @override
  String get time_liveActivityDone => 'Done!';

  @override
  String get time_liveActivityPaused => 'paused';

  @override
  String get time_historySwipeHint => 'Tap to edit · swipe left to delete';

  @override
  String get time_reminderSwipeHint =>
      'Tap to edit · swipe left to delete · use the circle to mark done';

  @override
  String get time_timerLogCaption => 'Log';

  @override
  String get time_timerFinishCaption => 'Finish';

  @override
  String get settings_groupAppearanceLanguage => 'Appearance and language';

  @override
  String get settings_groupPlanning => 'Planning';

  @override
  String get settings_groupDeviceData => 'Device and data';

  @override
  String get settings_editHeroName => 'Edit name';

  @override
  String get settings_languageCsShort => 'CZ';

  @override
  String get settings_languageEnShort => 'EN';

  @override
  String get time_statsTracked => 'Tracked';

  @override
  String get time_statsUntracked => 'Untracked';

  @override
  String get time_reminderMinutesUnit => 'minutes';

  @override
  String time_reminderWindow(String from, String to, int minutes) {
    return '$from–$to · every $minutes min';
  }

  @override
  String get time_previousPeriod => 'Previous period';

  @override
  String get time_nextPeriod => 'Next period';

  @override
  String get shell_modulesTitle => 'Modules';

  @override
  String get shell_launcherHint =>
      'Tip: swipe across the module button to go back to the previous module';

  @override
  String get shell_drawerSectionTime => 'Time';

  @override
  String get shell_drawerSectionPlanning => 'Planning';

  @override
  String shell_moduleButtonLabel(String module) {
    return '$module, switch module';
  }

  @override
  String get shell_previousModule => 'Previous module';

  @override
  String get settings_groupExperiments => 'Experiments';

  @override
  String get settings_moduleButtonSide => 'Module button';

  @override
  String get settings_moduleButtonLeft => 'Left';

  @override
  String get settings_moduleButtonRight => 'Right';

  @override
  String get settings_drawerEnabled => 'Side menu';

  @override
  String get settings_historyTagStyle => 'History type tag';

  @override
  String get settings_historyTagPill => 'Tag';

  @override
  String get settings_historyTagSmall => 'Small';

  @override
  String get settings_historyTagDot => 'Dot';

  @override
  String get settings_historyTagText => 'Text';

  @override
  String get settings_titleWeight => 'Title weight';
}
