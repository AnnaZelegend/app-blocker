import ManagedSettings
import ManagedSettingsUI
import UIKit

// Customizes the lock screen iOS shows in place of a blocked app.
class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        Self.lockedConfiguration
    }

    override func configuration(
        shielding application: Application,
        in category: ActivityCategory
    ) -> ShieldConfiguration {
        Self.lockedConfiguration
    }

    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        Self.lockedConfiguration
    }

    override func configuration(
        shielding webDomain: WebDomain,
        in category: ActivityCategory
    ) -> ShieldConfiguration {
        Self.lockedConfiguration
    }

    private static var lockedConfiguration: ShieldConfiguration {
        ShieldConfiguration(
            backgroundBlurStyle: .systemMaterialDark,
            title: ShieldConfiguration.Label(text: "App Blocked", color: .white),
            subtitle: ShieldConfiguration.Label(
                text: "Open AppBlocker and tap Unlock to use this app again.",
                color: .white
            ),
            primaryButtonLabel: ShieldConfiguration.Label(text: "OK", color: .white),
            primaryButtonBackgroundColor: .systemBlue
        )
    }
}
