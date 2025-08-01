import Foundation
import SwiftUI
import EventKit
import UserNotifications

// MARK: - Reminder Model
struct VisualReminder: Identifiable, Codable {
    let id = UUID()
    var title: String
    var notes: String
    var photoData: Data?
    var reminderDate: Date
    var isCompleted: Bool = false
    var appleReminderID: String?
    var createdAt: Date = Date()
    
    // Computed properties
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: reminderDate)
    }
    
    var isOverdue: Bool {
        return !isCompleted && reminderDate < Date()
    }
    
    var timeUntilReminder: String {
        let timeInterval = reminderDate.timeIntervalSinceNow
        if timeInterval <= 0 {
            return "Overdue"
        }
        
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) % 3600 / 60
        
        if hours > 24 {
            let days = hours / 24
            return "\(days) day\(days == 1 ? "" : "s")"
        } else if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - Reminder Store
class ReminderStore: ObservableObject {
    @Published var reminders: [VisualReminder] = []
    private let eventStore = EKEventStore()
    
    init() {
        loadReminders()
        requestRemindersAccess()
        requestNotificationPermission()
    }
    
    // MARK: - CRUD Operations
    func addReminder(_ reminder: VisualReminder) {
        reminders.append(reminder)
        saveReminders()
        
        // Create Apple Reminder if access is granted
        if EKEventStore.authorizationStatus(for: .reminder) == .authorized {
            createAppleReminder(for: reminder)
        }
        
        // Schedule local notification
        scheduleNotification(for: reminder)
    }
    
    func updateReminder(_ reminder: VisualReminder) {
        if let index = reminders.firstIndex(where: { $0.id == reminder.id }) {
            reminders[index] = reminder
            saveReminders()
            
            // Update Apple Reminder if it exists
            if let appleReminderID = reminder.appleReminderID {
                updateAppleReminder(reminder, withID: appleReminderID)
            }
        }
    }
    
    func deleteReminder(_ reminder: VisualReminder) {
        reminders.removeAll { $0.id == reminder.id }
        saveReminders()
        
        // Delete Apple Reminder if it exists
        if let appleReminderID = reminder.appleReminderID {
            deleteAppleReminder(withID: appleReminderID)
        }
        
        // Cancel local notification
        cancelNotification(for: reminder)
    }
    
    func toggleCompletion(for reminder: VisualReminder) {
        var updatedReminder = reminder
        updatedReminder.isCompleted.toggle()
        updateReminder(updatedReminder)
    }
    
    // MARK: - Apple Reminders Integration
    private func requestRemindersAccess() {
        eventStore.requestAccess(to: .reminder) { [weak self] granted, error in
            DispatchQueue.main.async {
                if granted {
                    print("Reminders access granted")
                } else {
                    print("Reminders access denied: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    }
    
    private func createAppleReminder(for reminder: VisualReminder) {
        let ekReminder = EKReminder(eventStore: eventStore)
        ekReminder.title = reminder.title
        ekReminder.notes = reminder.notes
        ekReminder.dueDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminder.reminderDate)
        ekReminder.calendar = eventStore.defaultCalendarForNewReminders()
        
        do {
            try eventStore.save(ekReminder, commit: true)
            // Update our reminder with the Apple Reminder ID
            var updatedReminder = reminder
            updatedReminder.appleReminderID = ekReminder.calendarItemIdentifier
            updateReminder(updatedReminder)
        } catch {
            print("Failed to create Apple Reminder: \(error)")
        }
    }
    
    private func updateAppleReminder(_ reminder: VisualReminder, withID id: String) {
        let predicate = eventStore.predicateForReminders(in: nil)
        eventStore.fetchReminders(matching: predicate) { [weak self] ekReminders in
            guard let ekReminders = ekReminders else { return }
            
            if let ekReminder = ekReminders.first(where: { $0.calendarItemIdentifier == id }) {
                ekReminder.title = reminder.title
                ekReminder.notes = reminder.notes
                ekReminder.dueDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminder.reminderDate)
                ekReminder.isCompleted = reminder.isCompleted
                
                do {
                    try self?.eventStore.save(ekReminder, commit: true)
                } catch {
                    print("Failed to update Apple Reminder: \(error)")
                }
            }
        }
    }
    
    private func deleteAppleReminder(withID id: String) {
        let predicate = eventStore.predicateForReminders(in: nil)
        eventStore.fetchReminders(matching: predicate) { [weak self] ekReminders in
            guard let ekReminders = ekReminders else { return }
            
            if let ekReminder = ekReminders.first(where: { $0.calendarItemIdentifier == id }) {
                do {
                    try self?.eventStore.remove(ekReminder, commit: true)
                } catch {
                    print("Failed to delete Apple Reminder: \(error)")
                }
            }
        }
    }
    
    // MARK: - Persistence
    private func saveReminders() {
        if let encoded = try? JSONEncoder().encode(reminders) {
            UserDefaults.standard.set(encoded, forKey: "VisualReminders")
        }
    }
    
    private func loadReminders() {
        if let data = UserDefaults.standard.data(forKey: "VisualReminders"),
           let decoded = try? JSONDecoder().decode([VisualReminder].self, from: data) {
            reminders = decoded
        }
    }
    
    // MARK: - Filtering
    var activeReminders: [VisualReminder] {
        reminders.filter { !$0.isCompleted }
    }
    
    var completedReminders: [VisualReminder] {
        reminders.filter { $0.isCompleted }
    }
    
    var overdueReminders: [VisualReminder] {
        activeReminders.filter { $0.isOverdue }
    }
    
    var upcomingReminders: [VisualReminder] {
        activeReminders.filter { !$0.isOverdue }
    }
    
    // MARK: - Local Notifications
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    print("Notification permission granted")
                } else {
                    print("Notification permission denied: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    }
    
    private func scheduleNotification(for reminder: VisualReminder) {
        let content = UNMutableNotificationContent()
        content.title = reminder.title
        content.body = reminder.notes.isEmpty ? "Time for your visual reminder!" : reminder.notes
        content.sound = .default
        
        // Add photo to notification if available
        if let photoData = reminder.photoData {
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(reminder.id).jpg")
            try? photoData.write(to: tempURL)
            let attachment = try? UNNotificationAttachment(identifier: "photo", url: tempURL, options: nil)
            if let attachment = attachment {
                content.attachments = [attachment]
            }
        }
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminder.reminderDate),
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: reminder.id.uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            }
        }
    }
    
    private func cancelNotification(for reminder: VisualReminder) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [reminder.id.uuidString])
    }
} 