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
    
    @State var multiArrayImageView: MultiArrayImageView?

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
            
            if multiArrayImageView != nil {
                HStack(spacing: 10) {
                    Text("[DEBUG] Model input:")
                    multiArrayImageView
                }
            }
            
            if image != nil {
                Button(action: {
                    prediction = predictEmotion(model: model, image: image);
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
    
    func predictEmotion(model: densenetmodel, image: UIImage?) -> Prediction {
        // Default return value
        var prediction = Prediction(emotion: "happiness", score: 0.5, emoji: emojis["happiness"]!)
        
        // Convert the image into 48 x 48 x 3
        if let image = image {
            let resizedImage = image.resized(to: CGSize(width: 48, height: 48))
            let pixelBuffer = resizedImage.toPixelBuffer()!
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            let context = CIContext()
            let cgImage = context.createCGImage(ciImage, from: ciImage.extent)!
            let resizedUIImage = UIImage(cgImage: cgImage)
            
            guard let multiArray = try? MLMultiArray(shape: [1, 48, 48, 3], dataType: .float32) else {
                fatalError("Failed to create MLMultiArray.")
            }

            let channels = 3 // Number of color channels (RGB)
            let width = 48 // Image width
            let height = 48 // Image height
            
            for y in 0..<height {
                for x in 0..<width {
                    let color = resizedUIImage.getPixelColor(pos: CGPoint(x: x, y: y))
                    let index = (y * width + x) * channels
                    let rgbValues = getRGBValues(from: color)
                    multiArray[index] = NSNumber(value: Float(rgbValues?.red ?? 0))
                    multiArray[index + 1] = NSNumber(value: Float(rgbValues?.green ?? 0))
                    multiArray[index + 2] = NSNumber(value: Float(rgbValues?.blue ?? 0))
                }
            }
            
            DispatchQueue.main.async {
                self.multiArrayImageView = MultiArrayImageView(multiArray: multiArray)
            }
            
            do {
                // Pass the input into the model and make a prediction
                let modelInput = densenetmodelInput(input_1: multiArray)
                let modelOutput = try model.prediction(input: modelInput).Identity
                
                // Loop through the output MLMultiArray
                var maxIndex = 0
                var maxValue: Float = 0.0
                var sum: Float = 0.0
                for i in 0..<modelOutput.count {
                    let value = modelOutput[i].floatValue
                    sum += value
                    if value > maxValue {
                        maxValue = value
                        maxIndex = i
                    }
                }
                
                // Print model output
                print(modelOutput)
                
                // Find the predicted emotion based on model scores
                let map = [0: "anger", 1: "disgust", 2: "fear", 3: "happiness", 4: "neutral", 5: "sadness", 6: "surprise"];
                prediction = Prediction(emotion: map[maxIndex]!, score: Double(maxValue / sum), emoji: emojis[map[maxIndex]!]!)
            } catch {
                print("Error processing image: \(error)")
            }
        }
        return prediction
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

struct Prediction {
    var emotion: String
    var score: Double
    var emoji: String
}

extension UIImage {
    func getPixelColor(pos: CGPoint) -> UIColor {

        let pixelData = self.cgImage!.dataProvider!.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)

        let pixelInfo: Int = ((Int(self.size.width) * Int(pos.y)) + Int(pos.x)) * 4

        let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
        let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
        let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
        let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)

        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    
    func resized(to newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: newSize))
        guard let resizedImage = UIGraphicsGetImageFromCurrentImageContext() else {
            fatalError("Failed to resize image.")
        }
        return resizedImage
    }
    
    func toPixelBuffer() -> CVPixelBuffer? {
        let attributes: [String: Any] = [
            kCVPixelBufferCGImageCompatibilityKey as String: kCFBooleanTrue!,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: kCFBooleanTrue!
        ]
        
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                         Int(size.width),
                                         Int(size.height),
                                         kCVPixelFormatType_32BGRA,
                                         attributes as CFDictionary,
                                         &pixelBuffer)
        
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(buffer, [])
        let pixelData = CVPixelBufferGetBaseAddress(buffer)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData,
                                width: Int(size.width),
                                height: Int(size.height),
                                bitsPerComponent: 8,
                                bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
                                space: rgbColorSpace,
                                bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        context?.translateBy(x: 0, y: size.height)
        context?.scaleBy(x: 1, y: -1)
        
        UIGraphicsPushContext(context!)
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        UIGraphicsPopContext()
        
        CVPixelBufferUnlockBaseAddress(buffer, [])
        
        return pixelBuffer
    }
}

func getRGBValues(from color: UIColor) -> (red: CGFloat, green: CGFloat, blue: CGFloat)? {
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    
    if color.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
        return (red: red, green: green, blue: blue)
    } else {
        return nil
    }
}
