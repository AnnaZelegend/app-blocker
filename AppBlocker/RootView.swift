import SwiftUI
import FamilyControls

struct RootView: View {
    @State private var authorizationStatus = AuthorizationCenter.shared.authorizationStatus

    var body: some View {
        Group {
            if authorizationStatus == .approved {
                HomeView()
            } else {
                AuthorizationView(authorizationStatus: $authorizationStatus)
            }
        }
        .onAppear {
            authorizationStatus = AuthorizationCenter.shared.authorizationStatus
        }
    }
}

struct AuthorizationView: View {
    @Binding var authorizationStatus: AuthorizationStatus
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.shield")
                .font(.system(size: 56))
                .foregroundStyle(.tint)
            Text("AppBlocker")
                .font(.title.bold())
            Text("Grant Screen Time access so AppBlocker can lock the apps you choose.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 32)

            Button("Grant Access") {
                Task {
                    do {
                        try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
                        authorizationStatus = AuthorizationCenter.shared.authorizationStatus
                    } catch {
                        errorMessage = error.localizedDescription
                    }
                }
            }
            .buttonStyle(.borderedProminent)

            if let errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
                    .font(.footnote)
                    .padding(.horizontal, 32)
            }
        }
        .padding()
    }
}
