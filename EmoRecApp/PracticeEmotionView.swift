//
//  PracticeEmotionView.swift
//  EmoRecApp
//
//  Created by Katherine Chen on 6/4/23.
//
import SwiftUI
import UIKit
import CoreML
import CoreImage

struct PracticeEmotionView: View {
    @State var toCamera = false
    @State var showCamera = false
    @State var showCameraError = false
    @State var prediction: Prediction?
    @State var image: UIImage?
    @State var model: densenetmodel
    @State var multiArray: MLMultiArray?
    var emotion = ""
    
    init(emotion: String) {
        self.emotion = emotion
        do {
            let configuration = MLModelConfiguration()
            model = try densenetmodel(configuration: configuration)
        } catch {
            fatalError("Failed to create densenetmodel: \(error)")
        }
    }
    
    var body: some View {
        VStack(spacing: 10) {
            if image == nil {
                Text("Take a photo of you expressing " + self.emotion + "!")
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
                    .frame(width: UIScreen.main.bounds.width - 35, height: UIScreen.main.bounds.width - 35)
            }
            
            if multiArray != nil {
                HStack(spacing: 10) {
                    Text("[DEBUG] Model input:").foregroundColor(.gray)
                    MultiArrayImageView(multiArray: multiArray!)
                }
            }
            
            if let prediction = prediction {
                if prediction.emotion == self.emotion {
                    Text("You got it!").multilineTextAlignment(.center)
                } else {
                    Text("Not quite! You expressed " + prediction.emotion + "\nrather than " + self.emotion + ". Try again.").multilineTextAlignment(.center)
                }
            }
            
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
            
        }
        .navigationBarTitle("Practice " + self.emotion.capitalized)
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
        self.prediction = predictEmotion(model: model, image: image)
        self.multiArray = prediction?.multiArray
        self.image = selectedImage;
    }
}
