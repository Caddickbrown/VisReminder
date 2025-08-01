import SwiftUI

@main
struct VisReminderApp: App {
    @StateObject private var reminderStore = ReminderStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(reminderStore)
        }
    }
} 