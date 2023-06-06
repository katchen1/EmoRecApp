//
//  ContentView.swift
//  emorec
//
//  Created by Katherine Chen on 6/4/23.
//

import SwiftUI

var navBarTitles = [0: "Detect Emotion", 1: "Practice", 2: "Settings"]

struct ContentView: View {
    @State var toMainView = false
    @State var selection = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.accentColor
                VStack {
                    Text("Welcome to EmoRec!").bold()
                    Text("\n😀😞😡😲🤢😱😐\n\nEmoRec is an app for\ndetecting emotion in images and\npracticing expressing emotion.")
                        .multilineTextAlignment(.center)
                    NavigationLink(
                        destination: MainView(),
                        isActive: $toMainView
                    ) {
                        Button(action: { toMainView = true }) {
                            Text("Start")
                                .font(.headline)
                                .padding()
                                .background(Color.white)
                                .foregroundColor(Color.black)
                                .cornerRadius(10)
                                .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 8)
                        }
                        .padding()
                    }
                }
            }
            .navigationBarHidden(true)
            .ignoresSafeArea()
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct MainView: View {
    @State private var selection = 0
        
    var body: some View {
        TabView(selection: $selection) {
            DetectView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Detect")
                }
                .tag(0)
                
            
            PracticeView()
                .tabItem {
                    Image(systemName: "face.smiling")
                    Text("Practice")
                }
                .tag(1)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Settings")
                }
                .tag(2)
        }.navigationBarTitle(navBarTitles[selection]!)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


