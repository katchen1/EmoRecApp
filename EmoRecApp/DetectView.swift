//
//  DetectView.swift
//  emorec
//
//  Created by Katherine Chen on 6/4/23.
//

import SwiftUI
import UIKit

struct DetectView: View {
    @State var toCamera = false
    @State var toUpload = false
    @State var showCamera = false
    @State var showImagePicker = false
    @State var showCameraError = false
    @State var image: UIImage?
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Capture or upload an image")
                HStack {
                    Button(action: {
                        if UIImagePickerController.isSourceTypeAvailable(.camera) {
                            self.showCamera = true
                        } else {
                            self.showCameraError = true
                        }
                    }) {
                        CircularButton(systemName: "camera")
                    }.sheet(isPresented: $showCamera, onDismiss: loadImage) {
                        Camera()
                    }
                    Button(action: { self.showImagePicker = true }) {
                        CircularButton(systemName: "photo.on.rectangle")
                    }.sheet(isPresented: $showImagePicker, onDismiss: loadImage) {
                        ImagePicker(image: self.$image)
                    }
                }
            }
            .navigationBarTitle("Detect Emotion")
            .alert(isPresented: $showCameraError) {
                Alert(
                    title: Text("Camera Not Available"),
                    message: Text("The camera is not available on this device."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    func loadImage() {
        guard let selectedImage = image else { return }
        // Process the selected image here
        print(selectedImage.size)
    }
}

struct Camera: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // No need to update the view controller
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: Camera

        init(parent: Camera) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            // Handle the captured image here if needed
            parent.presentationMode.wrappedValue.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct UploadView: View {
    var body: some View {
        Text("Upload View")
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var image: UIImage?
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        @Binding var presentationMode: PresentationMode
        @Binding var image: UIImage?
        
        init(presentationMode: Binding<PresentationMode>, image: Binding<UIImage?>) {
            _presentationMode = presentationMode
            _image = image
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.editedImage] as? UIImage {
                image = uiImage
            } else if let uiImage = info[.originalImage] as? UIImage {
                image = uiImage
            }
            
            presentationMode.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            presentationMode.dismiss()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(presentationMode: presentationMode, image: $image)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
        // No need to update the view controller
    }
}
