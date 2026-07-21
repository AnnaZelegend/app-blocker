import SwiftUI
import FamilyControls
import ManagedSettings
import ManagedSettingsUI

struct HomeView: View {
    @EnvironmentObject private var store: BlockedAppsStore
    @State private var isPickerPresented = false
    @State private var pendingApplicationUnlock: ApplicationToken?
    @State private var pendingCategoryUnlock: ActivityCategoryToken?

    private var hasBlockedItems: Bool {
        !store.selection.applicationTokens.isEmpty || !store.selection.categoryTokens.isEmpty
    }

    var body: some View {
        NavigationStack {
            List {
                if hasBlockedItems {
                    Section {
                        ForEach(Array(store.selection.applicationTokens), id: \.self) { token in
                            HStack {
                                Label(token)
                                Spacer()
                                Button("Unlock") {
                                    pendingApplicationUnlock = token
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                        ForEach(Array(store.selection.categoryTokens), id: \.self) { token in
                            HStack {
                                Label(token)
                                Spacer()
                                Button("Unlock") {
                                    pendingCategoryUnlock = token
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                    } header: {
                        Text("Blocked")
                    } footer: {
                        Text("These apps show a lock screen when opened. Tap Unlock here to use one again.")
                    }

                    Section {
                        Button("Unlock All", role: .destructive) {
                            store.unlockAll()
                        }
                    }
                } else {
                    ContentUnavailableView(
                        "Nothing Blocked",
                        systemImage: "checkmark.shield",
                        description: Text("Tap Add Apps to choose apps to lock.")
                    )
                }
            }
            .navigationTitle("AppBlocker")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isPickerPresented = true
                    } label: {
                        Label("Add Apps", systemImage: "plus")
                    }
                }
            }
            .familyActivityPicker(
                isPresented: $isPickerPresented,
                selection: Binding(
                    get: { store.selection },
                    set: { store.updateSelection($0) }
                )
            )
            .sheet(isPresented: unlockSheetBinding) {
                UnlockConfirmationView(onConfirm: confirmPendingUnlock)
                    .presentationDetents([.medium])
            }
        }
    }

    private var unlockSheetBinding: Binding<Bool> {
        Binding(
            get: { pendingApplicationUnlock != nil || pendingCategoryUnlock != nil },
            set: { isPresented in
                if !isPresented {
                    pendingApplicationUnlock = nil
                    pendingCategoryUnlock = nil
                }
            }
        )
    }

    private func confirmPendingUnlock() {
        if let token = pendingApplicationUnlock {
            store.unlock(application: token)
        }
        if let token = pendingCategoryUnlock {
            store.unlock(category: token)
        }
        pendingApplicationUnlock = nil
        pendingCategoryUnlock = nil
    }
}
