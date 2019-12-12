//
//  SimpleViews.swift
//  AnyType
//
//  Created by Denis Batvinkin on 03.12.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI
import UIKit


struct ImageWithCircleBackgroundView: View {
    var imageName: String
    var backgroundColor: Color?
    var backgoundImage: UIImage?
    
    var body: some View {
        let image = backgoundImage?.withRenderingMode(.alwaysOriginal)
        
        return ZStack {
            if backgroundColor != nil {
                backgroundColor
            } else if backgoundImage != nil {
                Image(uiImage: image!)
                    .resizable()
            }
            Image(imageName)
        }
        .clipShape(Circle())
    }
}

struct UserIconView: View {
    private var colors: [UIColor] = [.black, .gray, .yellow, .red, .purple, .blue, .green, .darkGray, .darkText]
    
    var image: UIImage?
    var color: UIColor?
    var name: String
    
    init(image: UIImage?, name: String) {
        self.image = image
        self.name = name
    }
    
    init(color: UIColor?, name: String) {
        self.color = color
        self.name = name
    }
    
    var body: some View {
        VStack {
            if image != nil {
                Image(uiImage: image!)
            } else {
                ZStack {
                    Color(color ?? colors[Int.random(in: 0..<colors.count)])
                    Text(String(name.first ?? "A"))
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
            ImageWithCircleBackgroundView(imageName: "logo-sign-part-mobile", backgroundColor: Color.secondary)
            UserIconView(image: nil, name: "Anton B")
        }
    }
}
