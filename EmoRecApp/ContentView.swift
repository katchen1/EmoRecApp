//
//  ContentView.swift
//  emorec
//
//  Created by Katherine Chen on 6/4/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            DetectView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Detect")
                }
            PracticeView()
                .tabItem {
                    Image(systemName: "face.smiling")
                    Text("Practice")
                }
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Settings")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


