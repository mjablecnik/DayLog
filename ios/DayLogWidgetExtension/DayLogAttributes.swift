import ActivityKit
import Foundation

// Must match the identical struct in ios/Runner/LiveActivityManager.swift
public struct DayLogAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public var endAt: Date
        public var isPaused: Bool
        public var pausedSecondsLeft: Int?
        public var isCompleted: Bool
    }
    public var totalSeconds: Int
    // Texts from the Flutter side (ARB files, language of the app).
    public var completedText: String
    public var doneText: String
    public var pausedText: String
}
