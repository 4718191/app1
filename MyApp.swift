import SwiftUI
import SwiftData
import UserNotifications

@main
struct MyApp: App {
    init() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            print("알림 권한: \(granted)")
        }
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(for: Food.self)
    }
}
