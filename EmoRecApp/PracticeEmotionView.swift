//
//  PracticeEmotionView.swift
//  EmoRecApp
//
//  Created by Katherine Chen on 6/4/23.
//
import SwiftUI
import UIKit

struct PracticeEmotionView: View {
    @State var toCamera = false
    @State var showCamera = false
    @State var showCameraError = false
    @State var prediction: Prediction?
    @State var image: UIImage?
    var emotion = ""
    
    init(emotion: String) {
        self.emotion = emotion
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
        let emotion = emotions.randomElement()
        let score = Double.random(in: 0.5..<1)
        self.prediction = Prediction(emotion: emotion!, score: score, emoji: emojis[emotion!]!);
        self.image = selectedImage;
    }
}
