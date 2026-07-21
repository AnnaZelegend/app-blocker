import Foundation
import FamilyControls
import DeviceActivity
import ManagedSettings

/// Drives a recurring daily block window (e.g. 9am-5pm) using DeviceActivity.
/// Uses its own ManagedSettingsStore ("AppBlocker.Schedule") so it never
/// clobbers apps blocked manually via BlockedAppsStore's "AppBlocker" store.
@MainActor
final class ScheduleStore: ObservableObject {
    @Published var selection: FamilyActivitySelection {
        didSet { persistSelection() }
    }
    @Published var startTime: DateComponents {
        didSet { persistTimesAndRearm() }
    }
    @Published var endTime: DateComponents {
        didSet { persistTimesAndRearm() }
    }
    @Published private(set) var isEnabled: Bool

    private let defaults = UserDefaults(suiteName: AppGroup.identifier)
    private let center = DeviceActivityCenter()
    private let activityName = DeviceActivityName("com.yourcompany.appblocker.schedule")

    init() {
        let d = UserDefaults(suiteName: AppGroup.identifier)
        if let data = d?.data(forKey: ScheduleKeys.selection),
           let decoded = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) {
            selection = decoded
        } else {
            selection = FamilyActivitySelection()
        }
        startTime = DateComponents(
            hour: (d?.object(forKey: ScheduleKeys.startHour) as? Int) ?? 9,
            minute: (d?.object(forKey: ScheduleKeys.startMinute) as? Int) ?? 0
        )
        endTime = DateComponents(
            hour: (d?.object(forKey: ScheduleKeys.endHour) as? Int) ?? 17,
            minute: (d?.object(forKey: ScheduleKeys.endMinute) as? Int) ?? 0
        )
        isEnabled = d?.bool(forKey: ScheduleKeys.enabled) ?? false
    }

    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
        defaults?.set(enabled, forKey: ScheduleKeys.enabled)
        if enabled {
            startMonitoring()
        } else {
            stopMonitoring()
        }
    }

    private func startMonitoring() {
        let schedule = DeviceActivitySchedule(
            intervalStart: startTime,
            intervalEnd: endTime,
            repeats: true
        )
        do {
            try center.startMonitoring(activityName, during: schedule)
        } catch {
            print("Failed to start schedule monitoring: \(error)")
        }
    }

    private func stopMonitoring() {
        center.stopMonitoring([activityName])
        let scheduleShield = ManagedSettingsStore(named: .init("AppBlocker.Schedule"))
        scheduleShield.shield.applications = nil
        scheduleShield.shield.applicationCategories = nil
    }

    private func persistSelection() {
        guard let data = try? JSONEncoder().encode(selection) else { return }
        defaults?.set(data, forKey: ScheduleKeys.selection)
    }

    private func persistTimesAndRearm() {
        defaults?.set(startTime.hour, forKey: ScheduleKeys.startHour)
        defaults?.set(startTime.minute, forKey: ScheduleKeys.startMinute)
        defaults?.set(endTime.hour, forKey: ScheduleKeys.endHour)
        defaults?.set(endTime.minute, forKey: ScheduleKeys.endMinute)
        if isEnabled {
            startMonitoring()
        }
    }
}
