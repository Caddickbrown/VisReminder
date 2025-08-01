import SwiftUI

struct ReminderListView: View {
    @ObservedObject var reminderStore: ReminderStore
    @State private var showingAddReminder = false
    @State private var searchText = ""
    @State private var selectedFilter: ReminderFilter = .all
    
    enum ReminderFilter: String, CaseIterable {
        case all = "All"
        case active = "Active"
        case overdue = "Overdue"
        case upcoming = "Upcoming"
        case completed = "Completed"
    }
    
    var filteredReminders: [VisualReminder] {
        let filtered = reminderStore.reminders.filter { reminder in
            searchText.isEmpty || 
            reminder.title.localizedCaseInsensitiveContains(searchText) ||
            reminder.notes.localizedCaseInsensitiveContains(searchText)
        }
        
        switch selectedFilter {
        case .all:
            return filtered
        case .active:
            return filtered.filter { !$0.isCompleted }
        case .overdue:
            return filtered.filter { $0.isOverdue }
        case .upcoming:
            return filtered.filter { !$0.isCompleted && !$0.isOverdue }
        case .completed:
            return filtered.filter { $0.isCompleted }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Filter Picker
                Picker("Filter", selection: $selectedFilter) {
                    ForEach(ReminderFilter.allCases, id: \.self) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                // Reminder List
                if filteredReminders.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "bell.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text(emptyStateMessage)
                            .font(.title2)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                        
                        Button(action: {
                            showingAddReminder = true
                        }) {
                            HStack {
                                Image(systemName: "plus")
                                Text("Create Your First Reminder")
                            }
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(filteredReminders) { reminder in
                            NavigationLink(destination: ReminderDetailView(reminder: reminder, reminderStore: reminderStore)) {
                                ReminderRowView(reminder: reminder, reminderStore: reminderStore)
                            }
                        }
                        .onDelete(perform: deleteReminders)
                    }
                    .searchable(text: $searchText, prompt: "Search reminders...")
                }
            }
            .navigationTitle("Visual Reminders")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddReminder = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddReminder) {
                AddReminderView(reminderStore: reminderStore)
            }
        }
    }
    
    private var emptyStateMessage: String {
        switch selectedFilter {
        case .all:
            return "No reminders yet.\nTap + to create your first visual reminder!"
        case .active:
            return "No active reminders.\nAll caught up!"
        case .overdue:
            return "No overdue reminders.\nGreat job staying on top of things!"
        case .upcoming:
            return "No upcoming reminders.\nTime to plan something new!"
        case .completed:
            return "No completed reminders.\nStart checking off your tasks!"
        }
    }
    
    private func deleteReminders(offsets: IndexSet) {
        for index in offsets {
            let reminder = filteredReminders[index]
            reminderStore.deleteReminder(reminder)
        }
    }
}

// MARK: - Reminder Row View
struct ReminderRowView: View {
    let reminder: VisualReminder
    @ObservedObject var reminderStore: ReminderStore
    
    var body: some View {
        HStack(spacing: 12) {
            // Photo Thumbnail
            if let photoData = reminder.photoData,
               let image = UIImage(data: photoData) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
            }
            
            // Reminder Details
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(reminder.title)
                        .font(.headline)
                        .strikethrough(reminder.isCompleted)
                        .foregroundColor(reminder.isCompleted ? .gray : .primary)
                    
                    Spacer()
                    
                    // Status Indicator
                    if reminder.isOverdue && !reminder.isCompleted {
                        Text("OVERDUE")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.red)
                            .cornerRadius(4)
                    }
                }
                
                if !reminder.notes.isEmpty {
                    Text(reminder.notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                HStack {
                    Image(systemName: "clock")
                        .font(.caption)
                        .foregroundColor(.blue)
                    Text(reminder.formattedDate)
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    Spacer()
                    
                    if !reminder.isCompleted {
                        Text(reminder.timeUntilReminder)
                            .font(.caption)
                            .foregroundColor(reminder.isOverdue ? .red : .green)
                    }
                }
            }
            
            // Completion Toggle
            Button(action: {
                reminderStore.toggleCompletion(for: reminder)
            }) {
                Image(systemName: reminder.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(reminder.isCompleted ? .green : .gray)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Add Reminder View
struct AddReminderView: View {
    @ObservedObject var reminderStore: ReminderStore
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title = ""
    @State private var notes = ""
    @State private var selectedImage: UIImage?
    @State private var reminderDate = Date()
    @State private var isShowingCamera = false
    @State private var isShowingPhotoPicker = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Reminder Details")) {
                    TextField("Title", text: $title)
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section(header: Text("Photo")) {
                    PhotoCaptureView(
                        selectedImage: $selectedImage,
                        isShowingCamera: $isShowingCamera,
                        isShowingPhotoPicker: $isShowingPhotoPicker
                    )
                }
                
                Section(header: Text("Reminder Time")) {
                    DatePicker("Remind me at", selection: $reminderDate, displayedComponents: [.date, .hourAndMinute])
                }
            }
            .navigationTitle("New Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveReminder()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
    
    private func saveReminder() {
        let photoData = selectedImage?.jpegData(compressionQuality: 0.8)
        
        let reminder = VisualReminder(
            title: title,
            notes: notes,
            photoData: photoData,
            reminderDate: reminderDate
        )
        
        reminderStore.addReminder(reminder)
        presentationMode.wrappedValue.dismiss()
    }
} 