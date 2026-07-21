import Foundation
import FamilyControls
import ManagedSettings

@MainActor
final class BlockedAppsStore: ObservableObject {
    @Published private(set) var selection: FamilyActivitySelection

    private let managedSettingsStore = ManagedSettingsStore(named: .init("AppBlocker"))
    private let defaults = UserDefaults(suiteName: AppGroup.identifier)
    private let selectionKey = "blockedAppsSelection"

    init() {
        if let data = UserDefaults(suiteName: AppGroup.identifier)?.data(forKey: selectionKey),
           let decoded = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) {
            selection = decoded
        } else {
            selection = FamilyActivitySelection()
        }
        applyShield()
    }

    /// Called after the user picks apps/categories in the FamilyActivityPicker.
    func updateSelection(_ newSelection: FamilyActivitySelection) {
        selection = newSelection
        persist()
        applyShield()
    }

    func unlock(application token: ApplicationToken) {
        selection.applicationTokens.remove(token)
        persist()
        applyShield()
    }

    func unlock(category token: ActivityCategoryToken) {
        selection.categoryTokens.remove(token)
        persist()
        applyShield()
    }

    func unlockAll() {
        selection = FamilyActivitySelection()
        persist()
        applyShield()
    }

    private func applyShield() {
        managedSettingsStore.shield.applications = selection.applicationTokens.isEmpty
            ? nil
            : selection.applicationTokens
        managedSettingsStore.shield.applicationCategories = selection.categoryTokens.isEmpty
            ? nil
            : .specific(selection.categoryTokens)
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(selection) else { return }
        defaults?.set(data, forKey: selectionKey)
    }
}
