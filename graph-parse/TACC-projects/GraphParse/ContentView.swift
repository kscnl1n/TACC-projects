//
//  ContentView.swift
//  GraphParse
//
//  Created by TACC Staff on 1/30/25.
//
import SwiftUI
import UIKit
import FirebaseStorage

// Entry point of the app
struct ContentView: View {
    var body: some View {
        CameraUploadView()
    }
}

#Preview {
    ContentView()
}

// Main UI for capturing and uploading images
struct CameraUploadView: View {
    @State private var image: UIImage?  // Stores captured image
    @State private var isShowingCamera = false  // Controls camera visibility
    @State private var uploadedImageURL: String?  // Stores uploaded image URL

    var body: some View {
        VStack {
            Text("GraphParse")
                .font(.largeTitle)
            Text("We'll turn your sketch into a graph.")

            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 200)
                    .cornerRadius(10)

                if let uploadedImageURL = uploadedImageURL {
                    Text("Image Uploaded!")
                        .foregroundColor(.green)
                    Text("Processing at: \(uploadedImageURL)")
                        .font(.caption)
                        .foregroundColor(.blue)
                } else {
                    Text("Uploading...")
                }
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 300, height: 200)
                    .cornerRadius(10)
                    .overlay(
                        Text("Tap to Capture")
                            .foregroundColor(.black)
                    )
                    .onTapGesture {
                        isShowingCamera = true
                    }
            }
        }
        .sheet(isPresented: $isShowingCamera) {
            ImagePicker(image: $image, onUploadComplete: { uploadedURL in
                if let uploadedURL = uploadedURL {
                    self.uploadedImageURL = uploadedURL
                    sendImageURLToServer(imageURL: uploadedURL)
                }
            })
        }
    }
}

// Image Picker for capturing images
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    var onUploadComplete: (String?) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self, onUploadComplete: onUploadComplete)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        let onUploadComplete: (String?) -> Void

        init(_ parent: ImagePicker, onUploadComplete: @escaping (String?) -> Void) {
            self.parent = parent
            self.onUploadComplete = onUploadComplete
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let selectedImage = info[.originalImage] as? UIImage {
                parent.image = selectedImage
                uploadToFirebase(image: selectedImage) { uploadedURL in
                    self.onUploadComplete(uploadedURL)
                }
            }
            picker.dismiss(animated: true)
        }
    }
}

// Firebase Image Upload Function
func uploadToFirebase(image: UIImage, completion: @escaping (String?) -> Void) {
    guard let imageData = image.jpegData(compressionQuality: 0.8) else {
        print("Error: Failed to convert image to data")
        completion(nil)
        return
    }

    // Set up Firebase storage with a custom bucket
    let storage = Storage.storage(url: "gs://graphparse.firebasestorage.app")
    let storageRef = storage.reference()
    let imageRef = storageRef.child("images/\(UUID().uuidString).jpg")

    // Upload image to Firebase Storage
    imageRef.putData(imageData, metadata: nil) { metadata, error in
        if let error = error {
            print("Upload failed: \(error.localizedDescription)")
            completion(nil)
            return
        }

        // Retrieve the download URL
        imageRef.downloadURL { url, error in
            if let error = error {
                print("Failed to retrieve download URL: \(error.localizedDescription)")
                completion(nil)
            } else {
                completion(url?.absoluteString)
            }
        }
    }
}

// Mock function for sending URL to backend
func sendImageURLToServer(imageURL: String) {
    print("Image URL sent to server: \(imageURL)")
}
