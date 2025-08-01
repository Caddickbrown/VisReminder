import SwiftUI
import AVFoundation
import Photos

struct PhotoCaptureView: View {
    @Binding var selectedImage: UIImage?
    @Binding var isShowingCamera: Bool
    @Binding var isShowingPhotoPicker: Bool
    @State private var showingImageSource = false
    @State private var cameraPermissionGranted = false
    @State private var photoLibraryPermissionGranted = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Image Display
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 300)
                    .cornerRadius(12)
                    .overlay(
                        Button(action: {
                            selectedImage = nil
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                                .background(Color.white)
                                .clipShape(Circle())
                        }
                        .padding(8),
                        alignment: .topTrailing
                    )
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 300)
                    .overlay(
                        VStack {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            Text("Tap to add photo")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                    )
            }
            
            // Photo Capture Buttons
            HStack(spacing: 20) {
                Button(action: {
                    checkCameraPermission()
                }) {
                    HStack {
                        Image(systemName: "camera")
                        Text("Take Photo")
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                }
                
                Button(action: {
                    checkPhotoLibraryPermission()
                }) {
                    HStack {
                        Image(systemName: "photo.on.rectangle")
                        Text("Choose Photo")
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(10)
                }
            }
        }
        .sheet(isPresented: $isShowingCamera) {
            CameraView(selectedImage: $selectedImage)
        }
        .sheet(isPresented: $isShowingPhotoPicker) {
            PhotoPicker(selectedImage: $selectedImage)
        }
        .alert("Camera Access", isPresented: .constant(!cameraPermissionGranted && showingImageSource)) {
            Button("Settings") {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Camera access is required to take photos. Please enable it in Settings.")
        }
    }
    
    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            cameraPermissionGranted = true
            isShowingCamera = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    cameraPermissionGranted = granted
                    if granted {
                        isShowingCamera = true
                    }
                }
            }
        case .denied, .restricted:
            cameraPermissionGranted = false
            showingImageSource = true
        @unknown default:
            break
        }
    }
    
    private func checkPhotoLibraryPermission() {
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized, .limited:
            photoLibraryPermissionGranted = true
            isShowingPhotoPicker = true
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { status in
                DispatchQueue.main.async {
                    photoLibraryPermissionGranted = status == .authorized || status == .limited
                    if photoLibraryPermissionGranted {
                        isShowingPhotoPicker = true
                    }
                }
            }
        case .denied, .restricted:
            photoLibraryPermissionGranted = false
            showingImageSource = true
        @unknown default:
            break
        }
    }
}

// MARK: - Camera View
struct CameraView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.editedImage] as? UIImage {
                parent.selectedImage = image
            } else if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

// MARK: - Photo Picker
struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: PhotoPicker
        
        init(_ parent: PhotoPicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.editedImage] as? UIImage {
                parent.selectedImage = image
            } else if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
} 