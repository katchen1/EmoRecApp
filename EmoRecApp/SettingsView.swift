//
//  SettingsView.swift
//  emorec
//
//  Created by Katherine Chen on 6/4/23.
//

import SwiftUI

struct SettingsView: View {
    @State var toNotification = false;
    @State var toLanguage = false;
    @State var toPrivacy = false;
    @State var toAbout = false;
    @State var toFeedback = false;
    
    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                NavigationLink(
                    destination: NotificationView(),
                    isActive: $toNotification
                ) {
                    Button(action: { toNotification = true }) {
                        RectangularTextButton(text: "🔔 Notification Settings")
                    }
                }
                NavigationLink(
                    destination: LanguageView(),
                    isActive: $toLanguage
                ) {
                    Button(action: { toLanguage = true }) {
                        RectangularTextButton(text: "🔤 Language Settings")
                    }
                }
                NavigationLink(
                    destination: PrivacyView(),
                    isActive: $toPrivacy
                ) {
                    Button(action: { toPrivacy = true }) {
                        RectangularTextButton(text: "🔒 Privacy Settings")
                    }
                }
                NavigationLink(
                    destination: AboutView(),
                    isActive: $toAbout
                ) {
                    Button(action: { toAbout = true }) {
                        RectangularTextButton(text: "️️️ℹ️ About")
                    }
                }
                NavigationLink(
                    destination: FeedbackView(),
                    isActive: $toFeedback
                ) {
                    Button(action: { toFeedback = true }) {
                        RectangularTextButton(text: "💬 Feedback & Support")
                    }
                }
                Spacer()
            }
            .padding()
            .navigationBarTitle("Settings")
        }
    }
}

struct NotificationView: View {
    var body: some View {
        Text("Notification View")
    }
}

struct LanguageView: View {
    var body: some View {
        Text("Language View")
    }
}

struct PrivacyView: View {
    var body: some View {
        Text("Privacy View")
    }
}

struct AboutView: View {
    var body: some View {
        Text("About View")
    }
}

struct FeedbackView: View {
    var body: some View {
        Text("Feedback View")
    }
}
