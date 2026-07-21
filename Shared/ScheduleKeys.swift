import Foundation

// Shared between the main app (ScheduleStore) and DeviceActivityMonitorExtension,
// which runs out-of-process and reads the same App Group UserDefaults.
enum ScheduleKeys {
    static let selection = "scheduleSelection"
    static let startHour = "scheduleStartHour"
    static let startMinute = "scheduleStartMinute"
    static let endHour = "scheduleEndHour"
    static let endMinute = "scheduleEndMinute"
    static let enabled = "scheduleEnabled"
}
