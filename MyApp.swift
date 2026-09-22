import SwiftUI
import SwiftData
import UserNotifications

@main
struct MyApp: App {
    @AppStorage("appearanceMode") private var appearanceMode: String = "system"

    init() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            print("알림 권한: \(granted)")
        }
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .preferredColorScheme(colorScheme(for: appearanceMode))
        }
        .modelContainer(for: Food.self)
    }

    func colorScheme(for mode: String) -> ColorScheme? {
        switch mode {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }
}
