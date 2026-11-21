import ActivityKit
import SwiftUI
import WidgetKit

// MARK: - Countdown range

/// The interval a countdown runs over. A range whose end lies before its start is
/// invalid and renders nothing, so a timer that already ran out shows 0:00.
func countdownRange(_ endAt: Date) -> ClosedRange<Date> {
    let now = Date.now
    return now...max(endAt, now)
}

// MARK: - Lock screen view

struct DayLogLockScreenView: View {
    let context: ActivityViewContext<DayLogAttributes>

    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                Text("DayLog")
                    .font(.caption2)
                    .foregroundColor(Color(hex: "#E6EAF2").opacity(0.5))
                timerLabel
            }
            Spacer()
            controlButtons
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(hex: "#0F1319"))
    }

    @ViewBuilder
    private var timerLabel: some View {
        if context.state.isCompleted {
            Text(context.attributes.completedText)
                .font(.system(.headline, design: .rounded))
                .foregroundColor(Color(hex: "#78B4C4"))
        } else if context.state.isPaused, let secs = context.state.pausedSecondsLeft {
            let mins = secs / 60
            let s = secs % 60
            Text(String(format: "%02d:%02d  %@", mins, s, context.attributes.pausedText))
                .font(.system(.title3, design: .monospaced).weight(.light))
                .foregroundColor(Color(hex: "#E6EAF2"))
        } else {
            Text(timerInterval: countdownRange(context.state.endAt), countsDown: true)
                .font(.system(.title3, design: .monospaced).weight(.light))
                .foregroundColor(Color(hex: "#E6EAF2"))
                .monospacedDigit()
        }
    }

    @ViewBuilder
    private var controlButtons: some View {
        if context.state.isCompleted {
            Link(destination: URL(string: "daylog://action/stop")!) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 38))
                    .foregroundColor(Color(hex: "#78B4C4"))
            }
            .frame(minWidth: 60, minHeight: 60)
        } else if context.state.isPaused {
            HStack(spacing: 4) {
                Link(destination: URL(string: "daylog://action/resume")!) {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 38))
                        .foregroundColor(Color(hex: "#78B4C4"))
                }
                .frame(minWidth: 60, minHeight: 60)
                Link(destination: URL(string: "daylog://action/stop")!) {
                    Image(systemName: "stop.circle.fill")
                        .font(.system(size: 38))
                        .foregroundColor(Color(hex: "#E6EAF2").opacity(0.4))
                }
                .frame(minWidth: 60, minHeight: 60)
            }
        } else {
            HStack(spacing: 4) {
                Link(destination: URL(string: "daylog://action/pause")!) {
                    Image(systemName: "pause.circle.fill")
                        .font(.system(size: 38))
                        .foregroundColor(Color(hex: "#78B4C4"))
                }
                .frame(minWidth: 60, minHeight: 60)
                Link(destination: URL(string: "daylog://action/stop")!) {
                    Image(systemName: "stop.circle.fill")
                        .font(.system(size: 38))
                        .foregroundColor(Color(hex: "#E6EAF2").opacity(0.4))
                }
                .frame(minWidth: 60, minHeight: 60)
            }
        }
    }
}

// MARK: - Widget

struct DayLogLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: DayLogAttributes.self) { context in
            DayLogLockScreenView(context: context)
                .activityBackgroundTint(Color(hex: "#0F1319"))
                .activitySystemActionForegroundColor(Color(hex: "#78B4C4"))
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Label {
                        Text("DayLog")
                            .font(.caption2)
                    } icon: {
                        Image(systemName: "timer")
                    }
                    .foregroundColor(Color(hex: "#78B4C4"))
                }
                DynamicIslandExpandedRegion(.trailing) {
                    if context.state.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color(hex: "#78B4C4"))
                    } else if context.state.isPaused {
                        Image(systemName: "pause.circle.fill")
                            .foregroundColor(Color(hex: "#78B4C4"))
                    }
                }
                DynamicIslandExpandedRegion(.center) {
                    expandedCountdown(context: context)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    expandedControls(context: context)
                }
            } compactLeading: {
                Image(systemName: "timer")
                    .foregroundColor(Color(hex: "#78B4C4"))
            } compactTrailing: {
                compactTrailing(context: context)
            } minimal: {
                Image(systemName: "timer")
                    .foregroundColor(Color(hex: "#78B4C4"))
            }
            .keylineTint(Color(hex: "#78B4C4"))
        }
    }

    @ViewBuilder
    private func expandedCountdown(context: ActivityViewContext<DayLogAttributes>) -> some View {
        if context.state.isCompleted {
            Text(context.attributes.doneText)
                .font(.system(.headline, design: .rounded))
                .foregroundColor(Color(hex: "#78B4C4"))
        } else if context.state.isPaused, let secs = context.state.pausedSecondsLeft {
            let mins = secs / 60
            let s = secs % 60
            Text(String(format: "%02d:%02d", mins, s))
                .font(.system(.title3, design: .monospaced).weight(.light))
                .foregroundColor(Color(hex: "#E6EAF2"))
        } else {
            Text(timerInterval: countdownRange(context.state.endAt), countsDown: true)
                .font(.system(.title3, design: .monospaced).weight(.light))
                .foregroundColor(Color(hex: "#E6EAF2"))
                .monospacedDigit()
        }
    }

    @ViewBuilder
    private func expandedControls(context: ActivityViewContext<DayLogAttributes>) -> some View {
        HStack(spacing: 24) {
            if context.state.isCompleted {
                Link(destination: URL(string: "daylog://action/stop")!) {
                    Label("Dismiss", systemImage: "xmark.circle")
                        .font(.caption)
                        .foregroundColor(Color(hex: "#78B4C4"))
                }
            } else if context.state.isPaused {
                Link(destination: URL(string: "daylog://action/resume")!) {
                    Label("Resume", systemImage: "play.circle")
                        .font(.caption)
                        .foregroundColor(Color(hex: "#78B4C4"))
                }
                Link(destination: URL(string: "daylog://action/stop")!) {
                    Label("Stop", systemImage: "stop.circle")
                        .font(.caption)
                        .foregroundColor(Color(hex: "#E6EAF2").opacity(0.5))
                }
            } else {
                Link(destination: URL(string: "daylog://action/pause")!) {
                    Label("Pause", systemImage: "pause.circle")
                        .font(.caption)
                        .foregroundColor(Color(hex: "#78B4C4"))
                }
                Link(destination: URL(string: "daylog://action/stop")!) {
                    Label("Stop", systemImage: "stop.circle")
                        .font(.caption)
                        .foregroundColor(Color(hex: "#E6EAF2").opacity(0.5))
                }
            }
        }
        .padding(.top, 4)
    }

    @ViewBuilder
    private func compactTrailing(context: ActivityViewContext<DayLogAttributes>) -> some View {
        if context.state.isCompleted {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(Color(hex: "#78B4C4"))
        } else if context.state.isPaused {
            Image(systemName: "pause.circle")
                .foregroundColor(Color(hex: "#78B4C4"))
        } else {
            Text(timerInterval: countdownRange(context.state.endAt), countsDown: true)
                .font(.system(.caption2, design: .monospaced))
                .foregroundColor(Color(hex: "#78B4C4"))
                .monospacedDigit()
                .multilineTextAlignment(.trailing)
                .frame(minWidth: 40, maxWidth: 52)
                .minimumScaleFactor(0.6)
        }
    }
}

// MARK: - Color hex extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6:
            (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (255, 255, 255)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: 1.0
        )
    }
}
