//
//  Utils.swift
//  emorec
//
//  Created by Katherine Chen on 6/4/23.
//

import SwiftUI
import UIKit
import WebKit

struct CircularButton: View {
    var systemName: String
    
    init(systemName: String) {
        self.systemName = systemName
    }
    
    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: 30))
            .frame(width: 100, height: 100)
            .foregroundColor(Color.white)
            .background(Color.accentColor)
            .clipShape(Circle())
            .buttonStyle(PlainButtonStyle())
            .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 8)
    }
}

struct RectangularTextButton: View {
    var text: String
    
    init(text: String) {
        self.text = text
    }
    
    var body: some View {
        Text(text)
            .frame(width: UIScreen.main.bounds.width - 35, height: 50)
            .foregroundColor(Color.black)
            .background(Color(red: 0.85, green: 0.85, blue: 0.85))
            .clipShape(Rectangle())
            .cornerRadius(10)
            .buttonStyle(PlainButtonStyle())
    }
}

struct RectangularImageButton: View {
    var systemName: String
    
    init(systemName: String) {
        self.systemName = systemName
    }
    
    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: 30))
            .frame(width: UIScreen.main.bounds.width - 35, height: 50)
            .foregroundColor(Color.white)
            .background(Color.accentColor)
            .clipShape(Rectangle())
            .cornerRadius(10)
            .buttonStyle(PlainButtonStyle())
            .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 8)
    }
}

struct CustomImage: View {
    var imageName: String
    
    init(imageName: String) {
        self.imageName = imageName
    }
    
    var body: some View {
        Image(imageName)
            .resizable()
            .frame(width: 300, height: 200)
            .cornerRadius(10)
            .scaledToFit()
    }
}

struct BulletPointText: View {
    var text: String
    
    init(text: String) {
        self.text = text
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            VStack {
                Spacer().frame(height: 5)
                Image(systemName: "circle.fill")
                    .font(.system(size: 10))
                    .frame(width: 10)
            }
            Text(text)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
