import SwiftUI

struct ReminderDetailView: View {
    let reminder: VisualReminder
    @ObservedObject var reminderStore: ReminderStore
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    @State private var showingShareSheet = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Photo Section
                if let photoData = reminder.photoData,
                   let image = UIImage(data: photoData) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 200)
                        .overlay(
                            VStack {
                                Image(systemName: "photo")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                                Text("No photo")
                                    .foregroundColor(.gray)
                            }
                        )
                }
                
                // Reminder Details
                VStack(alignment: .leading, spacing: 16) {
                    // Title and Status
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(reminder.title)
                                .font(.title2)
                                .fontWeight(.bold)
                                .strikethrough(reminder.isCompleted)
                                .foregroundColor(reminder.isCompleted ? .gray : .primary)
                            
                            if reminder.isOverdue && !reminder.isCompleted {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.red)
                                    Text("OVERDUE")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        // Completion Toggle
                        Button(action: {
                            reminderStore.toggleCompletion(for: reminder)
                        }) {
                            Image(systemName: reminder.isCompleted ? "checkmark.circle.fill" : "circle")
                                .font(.title)
                                .foregroundColor(reminder.isCompleted ? .green : .gray)
                        }
                    }
                    
                    // Notes
                    if !reminder.notes.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text(reminder.notes)
                                .font(.body)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    // Time Information
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.blue)
                            Text("Reminder Time")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Date & Time:")
                                    .fontWeight(.medium)
                                Spacer()
                                Text(reminder.formattedDate)
                                    .foregroundColor(.blue)
                            }
                            
                            if !reminder.isCompleted {
                                HStack {
                                    Text("Time until reminder:")
                                        .fontWeight(.medium)
                                    Spacer()
                                    Text(reminder.timeUntilReminder)
                                        .foregroundColor(reminder.isOverdue ? .red : .green)
                                }
                            }
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    // Apple Reminders Integration Status
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "bell.badge")
                                .foregroundColor(.orange)
                            Text("Apple Reminders")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Image(systemName: reminder.appleReminderID != nil ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(reminder.appleReminderID != nil ? .green : .red)
                            Text(reminder.appleReminderID != nil ? "Synced with Apple Reminders" : "Not synced with Apple Reminders")
                                .font(.caption)
                                .foregroundColor(reminder.appleReminderID != nil ? .green : .red)
                        }
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    // Creation Info
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.purple)
                            Text("Created")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                        
                        Text(reminder.createdAt, style: .date)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding()
                            .background(Color.purple.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("Reminder Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {
                        showingEditSheet = true
                    }) {
                        Label("Edit", systemImage: "pencil")
                    }
                    
                    Button(action: {
                        showingShareSheet = true
                    }) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                    
                    Button(role: .destructive, action: {
                        showingDeleteAlert = true
                    }) {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditReminderView(reminder: reminder, reminderStore: reminderStore)
        }
        .alert("Delete Reminder", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                reminderStore.deleteReminder(reminder)
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete this reminder? This action cannot be undone.")
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareReminderView(reminder: reminder)
        }
    }
}

// MARK: - Edit Reminder View
struct EditReminderView: View {
    let reminder: VisualReminder
    @ObservedObject var reminderStore: ReminderStore
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title: String
    @State private var notes: String
    @State private var selectedImage: UIImage?
    @State private var reminderDate: Date
    @State private var isShowingCamera = false
    @State private var isShowingPhotoPicker = false
    
    init(reminder: VisualReminder, reminderStore: ReminderStore) {
        self.reminder = reminder
        self.reminderStore = reminderStore
        self._title = State(initialValue: reminder.title)
        self._notes = State(initialValue: reminder.notes)
        self._reminderDate = State(initialValue: reminder.reminderDate)
        
        if let photoData = reminder.photoData {
            self._selectedImage = State(initialValue: UIImage(data: photoData))
        }
    }
    
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
            .navigationTitle("Edit Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
    
    private func saveChanges() {
        let photoData = selectedImage?.jpegData(compressionQuality: 0.8)
        
        var updatedReminder = reminder
        updatedReminder.title = title
        updatedReminder.notes = notes
        updatedReminder.photoData = photoData
        updatedReminder.reminderDate = reminderDate
        
        reminderStore.updateReminder(updatedReminder)
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Share Reminder View
struct ShareReminderView: View {
    let reminder: VisualReminder
    @Environment(\.presentationMode) var presentationMode
    @State private var showingShareSheet = false
    @State private var shareItems: [Any] = []
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Share Reminder")
                    .font(.title2)
                    .fontWeight(.bold)
                
                if let photoData = reminder.photoData,
                   let image = UIImage(data: photoData) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 300)
                        .cornerRadius(12)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text(reminder.title)
                        .font(.headline)
                    
                    if !reminder.notes.isEmpty {
                        Text(reminder.notes)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    
                    Text("Reminder for: \(reminder.formattedDate)")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                
                Button("Share") {
                    prepareShareItems()
                    showingShareSheet = true
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Share")
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
            ShareSheet(activityItems: shareItems)
        }
    }
    
    private func prepareShareItems() {
        var items: [Any] = []
        
        // Add text
        let text = """
        Visual Reminder: \(reminder.title)
        
        \(reminder.notes.isEmpty ? "No additional notes" : reminder.notes)
        
        Reminder for: \(reminder.formattedDate)
        
        Shared from VisReminder
        """
        items.append(text)
        
        // Add image if available
        if let photoData = reminder.photoData,
           let image = UIImage(data: photoData) {
            items.append(image)
        }
        
        shareItems = items
    }
} 