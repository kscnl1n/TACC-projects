//
//  ContentView.swift
//  GraphParse
//
//  Created by TACC Staff on 1/30/25.
//
import SwiftUI
import UIKit
import FirebaseStorage

struct ContentView: View {
    var body: some View {
        CameraUploadView()
    }
}

#Preview {
    ContentView() 
}

struct CameraUploadView: View {
    @State private var image: UIImage?
    @State private var isShowingCamera = false
    @State private var uploadedImageURL: String?  // Store uploaded image URL
    
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
                    Text("Uploading...")  // Show status while uploading
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
            // Function to create an instance of ImagePicker,
            // a UI View controller representable object that
            // allows the user to pick an image (from the camera or
            // photo library).
            // It passes the image binding (image: $image)
            // meaning ImagePicker can modify they image state variable
            // in CameraUploadView.
            ImagePicker(image: $image, onUploadComplete: { uploadedURL in
                if let uploadedURL = uploadedURL {
                    self.uploadedImageURL = uploadedURL
                    sendImageURLToServer(imageURL: uploadedURL)  // Send to backend
                }
            })
        }
    }
}

// Our image picker function allows the user to capture an image with their camera. At the end we call the uploadToFirebase function to upload that image to our firebase server.
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    var onUploadComplete: (String?) -> Void  // New callback function
    
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
                self.onUploadComplete(uploadedURL)  // Call the callback function with the uploaded image URL
                }
            }
        picker;.dismiss(animated: true)
        }
    }
}


