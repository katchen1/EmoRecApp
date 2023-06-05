//
//  PracticeView.swift
//  emorec
//
//  Created by Katherine Chen on 6/4/23.
//

import SwiftUI

struct PracticeView: View {
    @State var emotionView = EmotionView()
    
    var body: some View {
        NavigationView {
            VStack (alignment: .leading) {
                Text("I want to practice expressing...")
                NavigationToEmotion(emotion: "happiness", buttonText: "😀 Happiness", emotionView: self.emotionView)
                NavigationToEmotion(emotion: "sadness", buttonText: "😞 Sadness", emotionView: self.emotionView)
                NavigationToEmotion(emotion: "anger", buttonText: "😡 Anger", emotionView: self.emotionView)
                NavigationToEmotion(emotion: "surprise", buttonText: "😲 Surprise", emotionView: self.emotionView)
                NavigationToEmotion(emotion: "disgust", buttonText: "🤢 Disgust", emotionView: self.emotionView)
                NavigationToEmotion(emotion: "fear", buttonText: "😱 Fear", emotionView: self.emotionView)
                NavigationToEmotion(emotion: "neutral", buttonText: "😐 Neutral", emotionView: self.emotionView)
                Spacer()
            }
            .padding()
            .navigationBarTitle("Practice")
        }
    }
}

struct EmotionView: View {
    @State var toCamera = false
    
    var emotion = ""
    
    var emoji = ["happiness": "😀", "sadness": "😞", "anger": "😡", "surprise": "😲", "disgust": "🤢", "fear": "😱", "neutral": "😐" ]
    
    var description = ["happiness": "We feel happiness when good things happen to us and we live pleasant moments.", "sadness": "We experience sadness when we feel a deep sense of sorrow, disappointment, or loss.", "anger": "Anger is an intense emotion that arises when we feel frustrated, threatened, or wronged.", "surprise": "Surprise is an emotion we experience when something unexpected or astonishing happens.", "disgust": "Disgust is an emotion that arises when we encounter something revolting or offensive.", "fear": "Fear is a strong emotion that arises when we perceive a threat or danger.", "neutral": "Neutral describes a state of being neither positive nor negative, without strong emotional expression."]
    
    var instructions = ["happiness": "1. Smile.\n2. Brighten your eyes.\n3. Relax your facial muscles.\n4. Add a gentle laugh.", "sadness": "1. Allow your smile to fade.\n2. Soften your gaze, making your eyes appear less bright.\n3. Let your facial muscles relax, showing a slight droop or heaviness.\n4. Avoid laughter and let out a gentle sigh or a quiet sob.", "anger": "1. Tighten your lips, pressing them firmly together.\n2. Narrow your eyes, creating an intense and piercing gaze.\n3. Tense your facial muscles, emphasizing your jawline and forehead.\n4. Channel your anger with a forceful exhale or growl.", "surprise": "1. Part your lips slightly, creating an \"O\" shape.\n2. Widen your eyes, allowing your eyebrows to raise in a startled manner.\n3. Open your mouth slightly, as if gasping or catching your breath.\n4. Let out a short and sharp intake of air to express surprise.", "disgust": "1. Curl your upper lip slightly, as if you are smelling something unpleasant.\n2. Wrinkle your nose, creating a crinkled appearance.\n3. Narrow your eyes and furrow your brow, conveying a sense of distaste.\n4. Gently retch or gag to express disgust.", "fear": "1. Tense your facial muscles, particularly around your eyes and forehead.\n2. Widely open your eyes, making them appear larger.\n3. Slightly part your lips, as if you are holding your breath.\n4. Take quick, shallow breaths or let out a high-pitched scream to convey fear.", "neutral": "1. Keep your facial muscles relaxed and in a neutral position.\n2. Maintain a relaxed gaze, without any specific intensity or brightness.\n3. Keep your lips in a natural, neutral position without any distinct expression.\n4. Maintain a calm and steady breath, without any additional laughter or sighs."]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Group {
                    Text(emoji[emotion]! + " " + description[emotion]!)
                    Divider()
                    Text("📝 Instructions").bold()
                    Text(instructions[emotion]!)
                        .padding(EdgeInsets(top: 1, leading: 0, bottom: 0, trailing: 0))
                    Divider()
                    Text("🖼️ Example Images").bold()
                    ScrollView(.horizontal) {
                        LazyHStack {
                            CustomImage(imageName: emotion + "-1-min")
                            CustomImage(imageName: emotion + "-2-min")
                            CustomImage(imageName: emotion + "-3-min")
                        }.frame(height: 200)
                    }
                    Divider()
                    Text("👉 Practice").bold()
                    NavigationLink(destination: UploadView(), isActive: $toCamera) {
                        Button(action: { self.toCamera = true }) {
                            RectangularImageButton(systemName: "camera")
                        }
                    }
                }
            }
            .padding()
            .navigationBarTitle(emotion.capitalized)
        }
    }
}

struct NavigationToEmotion: View {
    @State var emotion: String
    @State var buttonText: String
    @State var emotionView: EmotionView
    @State var toEmotion = false
    
    init(emotion: String, buttonText: String, emotionView: EmotionView) {
        self.emotion = emotion
        self.buttonText = buttonText
        self.emotionView = emotionView
    }
    
    var body: some View {
        NavigationLink(
            destination: emotionView,
            isActive: $toEmotion
        ) {
            Button(action: {
                toEmotion = true
                emotionView.emotion = emotion
            }) {
                RectangularTextButton(text: buttonText)
            }
        }
    }
}
