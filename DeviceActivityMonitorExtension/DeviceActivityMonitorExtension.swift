import DeviceActivity
import FamilyControls
import ManagedSettings

// Applies/clears the scheduled shield when a DeviceActivitySchedule interval
// starts and ends. Runs out-of-process, so it reads the selection that
// ScheduleStore persisted to the shared App Group.
class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    private let scheduleShield = ManagedSettingsStore(named: .init("AppBlocker.Schedule"))
    private let defaults = UserDefaults(suiteName: AppGroup.identifier)

    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)

        guard let data = defaults?.data(forKey: ScheduleKeys.selection),
              let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) else {
            return
        }
        scheduleShield.shield.applications = selection.applicationTokens.isEmpty
            ? nil
            : selection.applicationTokens
        scheduleShield.shield.applicationCategories = selection.categoryTokens.isEmpty
            ? nil
            : .specific(selection.categoryTokens)
    }

    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        scheduleShield.shield.applications = nil
        scheduleShield.shield.applicationCategories = nil
    }
}
