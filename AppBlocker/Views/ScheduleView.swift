import SwiftUI
import FamilyControls

struct ScheduleView: View {
    @StateObject private var scheduleStore = ScheduleStore()
    @State private var isPickerPresented = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle(
                        "Enable Schedule",
                        isOn: Binding(
                            get: { scheduleStore.isEnabled },
                            set: { scheduleStore.setEnabled($0) }
                        )
                    )
                } footer: {
                    Text("Automatically block the apps below every day during this window, on top of anything you block manually.")
                }

                Section("Block Window") {
                    DatePicker("Starts", selection: startBinding, displayedComponents: .hourAndMinute)
                    DatePicker("Ends", selection: endBinding, displayedComponents: .hourAndMinute)
                }

                Section("Apps") {
                    Button {
                        isPickerPresented = true
                    } label: {
                        Label("Choose Apps", systemImage: "plus")
                    }
                    Text(selectionSummary)
                        .foregroundStyle(.secondary)
                        .font(.footnote)
                }
            }
            .navigationTitle("Schedule")
            .familyActivityPicker(
                isPresented: $isPickerPresented,
                selection: Binding(
                    get: { scheduleStore.selection },
                    set: { scheduleStore.selection = $0 }
                )
            )
        }
    }

    private var selectionSummary: String {
        let apps = scheduleStore.selection.applicationTokens.count
        let categories = scheduleStore.selection.categoryTokens.count
        if apps == 0 && categories == 0 {
            return "No apps selected yet."
        }
        return "\(apps) app(s), \(categories) categorie(s) selected"
    }

    private var startBinding: Binding<Date> {
        Binding(
            get: { Calendar.current.date(from: scheduleStore.startTime) ?? Date() },
            set: { scheduleStore.startTime = Calendar.current.dateComponents([.hour, .minute], from: $0) }
        )
    }

    private var endBinding: Binding<Date> {
        Binding(
            get: { Calendar.current.date(from: scheduleStore.endTime) ?? Date() },
            set: { scheduleStore.endTime = Calendar.current.dateComponents([.hour, .minute], from: $0) }
        )
    }
}
