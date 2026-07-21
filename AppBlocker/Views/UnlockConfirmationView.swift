import SwiftUI

/// A short forced pause before an app is unlocked, so unlocking is a
/// deliberate decision rather than a reflex tap.
struct UnlockConfirmationView: View {
    let onConfirm: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var remaining = 10
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "hourglass")
                .font(.system(size: 48))
                .foregroundStyle(.tint)

            Text("Take a breath before unlocking")
                .font(.headline)

            Text("This short pause is here so unlocking is a decision, not a reflex.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            if remaining > 0 {
                Text("\(remaining)")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .monospacedDigit()
            } else {
                Button("Unlock") {
                    onConfirm()
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }

            Button("Cancel", role: .cancel) {
                dismiss()
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
        }
        .padding()
        .onReceive(timer) { _ in
            if remaining > 0 {
                remaining -= 1
            }
        }
    }
}
