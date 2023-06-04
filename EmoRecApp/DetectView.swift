//
//  DetectView.swift
//  emorec
//
//  Created by Katherine Chen on 6/4/23.
//

import SwiftUI

struct DetectView: View {
    @State var toCamera = false
    @State var toUpload = false
    var body: some View {
        NavigationView {
            VStack {
                Text("Capture or upload an image")
                HStack {
                    NavigationLink(destination: CameraView(), isActive: $toCamera) {
                        Button(action: { self.toCamera = true }) {
                            CircularButton(systemName: "camera")
                        }
                    }
                    NavigationLink(destination: UploadView(), isActive: $toUpload) {
                        Button(action: { self.toUpload = true }) {
                            CircularButton(systemName: "photo.on.rectangle")
                        }
                    }
                }
            }.navigationBarTitle("Detect Emotion")
        }
    }
}

struct CameraView: View {
    var body: some View {
        Text("Camera View")
    }
}

struct UploadView: View {
    var body: some View {
        Text("Upload View")
    }
}
