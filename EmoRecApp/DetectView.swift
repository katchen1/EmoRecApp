//
//  DetectView.swift
//  emorec
//
//  Created by Katherine Chen on 6/4/23.
//

import SwiftUI
import UIKit
import CoreML
import CoreImage

struct DetectView: View {
    @State var toCamera = false
    @State var toUpload = false
    @State var showCamera = false
    @State var showImagePicker = false
    @State var showCameraError = false
    @State var prediction: Prediction?
    @State var image: UIImage?
    @State var model: densenetmodel
    @State var multiArray: MLMultiArray?

    init() {
        // Initialize the densenetmodel with a configuration
        do {
            let configuration = MLModelConfiguration()
            model = try densenetmodel(configuration: configuration)
        } catch {
            fatalError("Failed to create densenetmodel: \(error)")
        }
    }
    
    var body: some View {
        VStack(spacing: 7) {
            if image == nil {
                Text("Capture or upload an image")
            }
            
            if let prediction = prediction {
                HStack {
                    Text(prediction.emoji).font(.system(size: 50))
                    VStack(alignment: .leading) {
                        Text(prediction.emotion.capitalized).bold()
                        Text("Score: \(String(format: "%.0f%%", prediction.score * 100))")
                    }
                }
            }
            
            if let selectedImage = image {
                Image(uiImage: selectedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: UIScreen.main.bounds.width - 35, height: UIScreen.main.bounds.width - 70)
            }
            
            if multiArray != nil {
                HStack(spacing: 10) {
                    Text("[DEBUG] Model input:").foregroundColor(.gray)
                    MultiArrayImageView(multiArray: multiArray!)
                }
            }
            
            if image != nil {
                Button(action: {
                    prediction = predictEmotion(model: model, image: image)
                    multiArray = prediction?.multiArray
                }) {
                    RectangularTextButton(text: "😀😞😡😲🤢😱😐?")
                }
            }
            
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
                    Camera(image: self.$image)
                }
                Button(action: { self.showImagePicker = true }) {
                    CircularButton(systemName: "photo.on.rectangle")
                }.sheet(isPresented: $showImagePicker, onDismiss: loadImage) {
                    ImagePicker(image: self.$image)
                }
            }
        }
        .alert(isPresented: $showCameraError) {
            Alert(
                title: Text("Camera Not Available"),
                message: Text("The camera is not available on this device."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    func loadImage() {
        guard let selectedImage = image else { return }
        // Process the selected image
        self.prediction = nil;
        self.image = selectedImage;
    }
}

struct MultiArrayImageView: View {
    let multiArray: MLMultiArray
    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<48) { y in
                HStack(spacing: 0) {
                    ForEach(0..<48) { x in
                        let index = (y * 48 + x) * 3
                        let r = CGFloat(multiArray[index].floatValue)
                        let g = CGFloat(multiArray[index + 1].floatValue)
                        let b = CGFloat(multiArray[index + 2].floatValue)
                        Color(red: r, green: g, blue: b)
                            .frame(width: 1, height: 1)
                    }
                }
            }
        }
    }
}


struct Camera: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var image: UIImage?

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
            if let uiImage = info[.editedImage] as? UIImage {
                parent.image = uiImage
            } else if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
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
