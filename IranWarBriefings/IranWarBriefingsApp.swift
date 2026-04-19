import SwiftUI
import FirebaseCore

@main
struct IranWarBriefingsApp: App {
    private let isFirebaseConfigured: Bool

    init() {
        isFirebaseConfigured = Self.configureFirebase()
    }

    var body: some Scene {
        WindowGroup {
            if isFirebaseConfigured {
                SessionRootView()
            } else {
                FirebaseSetupView()
            }
        }
    }

    private static func configureFirebase() -> Bool {
        guard FirebaseApp.app() == nil else {
            return true
        }

        guard
            let filePath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
            let options = FirebaseOptions(contentsOfFile: filePath)
        else {
            return false
        }

        FirebaseApp.configure(options: options)
        return true
    }
}

private struct FirebaseSetupView: View {
    var body: some View {
        ContentUnavailableView(
            "Firebase setup required",
            systemImage: "exclamationmark.triangle",
            description: Text(
                "Add your GoogleService-Info.plist file to the app target before using authentication."
            )
        )
        .padding()
    }
}
