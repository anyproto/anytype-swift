//
//  SimpleViews.swift
//  AnyType
//
//  Created by Denis Batvinkin on 03.12.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI
import UIKit

extension SwiftUI.Image {
    struct CorrectAspectRatioProvider {
        func aspectRatio(_ value: CGSize) -> CGFloat {
            guard value.height != 0, value.width != 0 else { return 0 }
            let width = value.width
            let height = value.height
            return width < height ? width / height : height / width
        }
    }
    
    func correctAspectRatio(ofImage: UIImage, contentMode: ContentMode) -> some View {
        self.aspectRatio(CorrectAspectRatioProvider().aspectRatio(ofImage.size), contentMode: contentMode)
    }
}

struct ImageWithCircleBackgroundView: View {
    var imageName: String
    var backgroundColor: UIColor? // TODO: Remove it.
    var backgroundImage: UIImage?
    
    func aspectRatio() -> CGFloat {
        if let image = self.backgroundImage, image.size.height != 0, image.size.width != 0 {
            let width = image.size.width
            let height = image.size.height
            return width < height ? width / height : height / width
        }
        
        // If any dimension equal zero, well...
        // Don't do anything.
        return 0
    }
    
    // Swift 5.2
    func chosenImage() -> AnyView {
        if let value = self.backgroundColor {
            return .init(Color(value))
        }
        else if let value = self.backgroundImage {
            return .init(Image(uiImage: value).renderingMode(.original).resizable().correctAspectRatio(ofImage: value, contentMode: .fill))
        }
        else {
            return .init(Color(.clear))
        }
    }
    
    // TODO:
    // It works in Swift 5.3
    // So, whenever it possible, replace it.
    func chosenImage() -> some View {
        Group {
            if let value = self.backgroundColor {
                Color(value)
            }
            else if let value = self.backgroundImage {
                Image(uiImage: value).renderingMode(.original).resizable().correctAspectRatio(ofImage: value, contentMode: .fill)
            }
            else {
                Color(.clear)
            }
        }
    }
    
    var body: some View {
        ZStack {
            self.chosenImage()
            Image(self.imageName)
        }
        .clipShape(Circle())
    }
}

struct UserIconView: View {
//    private var colors: [UIColor] = [.black, .gray, .yellow, .red, .purple, .blue, .green, .darkGray, .darkText]
    
    var image: UIImage?
    var color: UIColor?
    var name: String
    
//    private func randomColor() -> UIColor {
//        self.colors[Int.random(in: 0..<self.colors.count)]
//    }
    
    private func defaultColor() -> UIColor {
        return .black
    }
    
    private var chosenColor: UIColor {
        self.color ?? self.defaultColor()
    }
    
    private func defaultInitialGlyph() -> Character {
        return "A"
    }
    
    private var chosenInitialGlyph: Character {
        self.name.first ?? self.defaultInitialGlyph()
    }
    
//    init(image: UIImage?, name: String) {
//        self.image = image
//        self.name = name
//    }
//
//    init(color: UIColor?, name: String) {
//        self.color = color
//        self.name = name
//    }
    
    var body: some View {
        VStack(spacing: 0) {
            if let value = self.image {
                Image(uiImage: value).renderingMode(.original).resizable().correctAspectRatio(ofImage: value, contentMode: .fill)
            }
            else {
                ZStack {
                    Color(self.chosenColor)
                    Text(String(self.chosenInitialGlyph))
                        .fontWeight(.bold)
                        .font(.title)
                        .foregroundColor(Color.white)
                }
            }
        }
        .clipShape(Circle())
    }
}

struct SimpleViews_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ImageWithCircleBackgroundView(imageName: "logo-sign-part-mobile", backgroundColor: .secondarySystemBackground)
            UserIconView(image: UIImage(named: "logo-sign-part-mobile"), color: nil, name: "Anton B")
        }
    }
}
