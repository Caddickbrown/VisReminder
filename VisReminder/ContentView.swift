import SwiftUI
import UserNotifications

struct ContentView: View {
    @EnvironmentObject var reminderStore: ReminderStore
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Main Reminders List
            ReminderListView(reminderStore: reminderStore)
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Reminders")
                }
                .tag(0)
            
            // Statistics View
            StatisticsView(reminderStore: reminderStore)
                .tabItem {
                    Image(systemName: "chart.bar")
                    Text("Stats")
                }
                .tag(1)
            
            // Settings View
            SettingsView(reminderStore: reminderStore)
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .tag(2)
        }
        .accentColor(.blue)
    }
}

// MARK: - Statistics View
struct StatisticsView: View {
    @ObservedObject var reminderStore: ReminderStore
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Summary Cards
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        StatCard(
                            title: "Total",
                            value: "\(reminderStore.reminders.count)",
                            icon: "list.bullet",
                            color: .blue
                        )
                        
                        StatCard(
                            title: "Active",
                            value: "\(reminderStore.activeReminders.count)",
                            icon: "clock",
                            color: .green
                        )
                        
                        StatCard(
                            title: "Overdue",
                            value: "\(reminderStore.overdueReminders.count)",
                            icon: "exclamationmark.triangle",
                            color: .red
                        )
                        
                        StatCard(
                            title: "Completed",
                            value: "\(reminderStore.completedReminders.count)",
                            icon: "checkmark.circle",
                            color: .purple
                        )
                    }
                    .padding(.horizontal)
                    
                    // Recent Activity
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Activity")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        if reminderStore.reminders.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "chart.bar.xaxis")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                                Text("No activity yet")
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                        } else {
                            // Productivity Chart
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Productivity Trend")
                                    .font(.headline)
                                    .padding(.horizontal)
                                
                                HStack(spacing: 8) {
                                    ForEach(0..<7) { dayOffset in
                                        let date = Calendar.current.date(byAdding: .day, value: -dayOffset, to: Date()) ?? Date()
                                        let dayReminders = reminderStore.reminders.filter { reminder in
                                            Calendar.current.isDate(reminder.createdAt, inSameDayAs: date)
                                        }
                                        let completedCount = dayReminders.filter { $0.isCompleted }.count
                                        let totalCount = dayReminders.count
                                        
                                        VStack {
                                            Rectangle()
                                                .fill(totalCount > 0 ? Color.green.opacity(Double(completedCount) / Double(totalCount)) : Color.gray.opacity(0.3))
                                                .frame(width: 20, height: 60)
                                            
                                            Text(Calendar.current.dateFormatter.string(from: date))
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                            
                            LazyVStack(spacing: 8) {
                                ForEach(reminderStore.reminders.prefix(5)) { reminder in
                                    HStack {
                                        Circle()
                                            .fill(reminder.isCompleted ? Color.green : Color.blue)
                                            .frame(width: 8, height: 8)
                                        
                                        Text(reminder.title)
                                            .lineLimit(1)
                                        
                                        Spacer()
                                        
                                        Text(reminder.createdAt, style: .date)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Statistics")
        }
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @ObservedObject var reminderStore: ReminderStore
    @State private var showingExportSheet = false
    @State private var showingClearAlert = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Data Management")) {
                    Button(action: {
                        showingExportSheet = true
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.blue)
                            Text("Export Reminders")
                            Spacer()
                        }
                    }
                    
                    Button(role: .destructive, action: {
                        showingClearAlert = true
                    }) {
                        HStack {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                            Text("Clear All Reminders")
                            Spacer()
                        }
                    }
                }
                
                Section(header: Text("Apple Reminders Integration")) {
                    HStack {
                        Image(systemName: "bell.badge")
                            .foregroundColor(.orange)
                        Text("Sync with Apple Reminders")
                        Spacer()
                        Text(EKEventStore.authorizationStatus(for: .reminder) == .authorized ? "Enabled" : "Disabled")
                            .foregroundColor(.secondary)
                    }
                    
                    if EKEventStore.authorizationStatus(for: .reminder) != .authorized {
                        Button("Grant Access") {
                            requestRemindersAccess()
                        }
                        .foregroundColor(.blue)
                    }
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "camera")
                            .foregroundColor(.blue)
                        Text("Camera Access")
                        Spacer()
                        Text(AVCaptureDevice.authorizationStatus(for: .video) == .authorized ? "Granted" : "Not Granted")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "photo")
                            .foregroundColor(.blue)
                        Text("Photo Library Access")
                        Spacer()
                        Text(PHPhotoLibrary.authorizationStatus() == .authorized ? "Granted" : "Not Granted")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "bell")
                            .foregroundColor(.blue)
                        Text("Notification Access")
                        Spacer()
                        Text(UNUserNotificationCenter.current().authorizationStatus == .authorized ? "Granted" : "Not Granted")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
        }
        .alert("Clear All Reminders", isPresented: $showingClearAlert) {
            Button("Clear All", role: .destructive) {
                reminderStore.reminders.removeAll()
                reminderStore.saveReminders()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will permanently delete all your reminders. This action cannot be undone.")
        }
        .sheet(isPresented: $showingExportSheet) {
            ExportView(reminderStore: reminderStore)
        }
    }
    
    private func requestRemindersAccess() {
        let eventStore = EKEventStore()
        eventStore.requestAccess(to: .reminder) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    print("Reminders access granted")
                } else {
                    print("Reminders access denied")
                }
            }
        }
    }
}

// MARK: - Export View
struct ExportView: View {
    @ObservedObject var reminderStore: ReminderStore
    @Environment(\.presentationMode) var presentationMode
    @State private var showingShareSheet = false
    @State private var exportData: ExportData?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Export Reminders")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("This will create a JSON file with all your reminders data.")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                VStack(spacing: 16) {
                    Button("Export to Files") {
                        exportReminders()
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                    
                    if !reminderStore.reminders.isEmpty {
                        Text("\(reminderStore.reminders.count) reminders will be exported")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Export")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            if let exportData = exportData {
                ShareSheet(activityItems: [exportData.jsonData])
            }
        }
    }
    
    private func exportReminders() {
        let exportData = ExportData(reminders: reminderStore.reminders)
        self.exportData = exportData
        self.showingShareSheet = true
    }
}

// MARK: - Export Data Structure
struct ExportData {
    let reminders: [VisualReminder]
    let exportDate: Date
    let appVersion: String
    
    init(reminders: [VisualReminder]) {
        self.reminders = reminders
        self.exportDate = Date()
        self.appVersion = "1.0.0"
    }
    
    var jsonData: Data {
        let exportObject = ExportObject(
            reminders: reminders,
            exportDate: exportDate,
            appVersion: appVersion
        )
        
        do {
            return try JSONEncoder().encode(exportObject)
        } catch {
            print("Failed to encode export data: \(error)")
            return Data()
        }
    }
}

struct ExportObject: Codable {
    let reminders: [VisualReminder]
    let exportDate: Date
    let appVersion: String
    let totalCount: Int
    let activeCount: Int
    let completedCount: Int
    let overdueCount: Int
    
    init(reminders: [VisualReminder], exportDate: Date, appVersion: String) {
        self.reminders = reminders
        self.exportDate = exportDate
        self.appVersion = appVersion
        self.totalCount = reminders.count
        self.activeCount = reminders.filter { !$0.isCompleted }.count
        self.completedCount = reminders.filter { $0.isCompleted }.count
        self.overdueCount = reminders.filter { !$0.isCompleted && $0.isOverdue }.count
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    ContentView()
        .environmentObject(ReminderStore())
}

// MARK: - Calendar Extension
extension Calendar {
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter
    }
} 