//
//  SwiftUIObjectIconImageView.swift
//  SwiftUIObjectIconImageView
//
//  Created by Konstantin Mordan on 26.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import SwiftUI

struct SwiftUIObjectIconImageView: UIViewRepresentable {    
    let iconImage: ObjectIconImage
    let usecase: ObjectIconImageUsecase
    
    func makeUIView(context: Context) -> ObjectIconImageView {
        ObjectIconImageView()
    }
    
    func updateUIView(_ uiView: ObjectIconImageView, context: Context) {
        uiView.configure(
            model: ObjectIconImageView.Model(
                iconImage: iconImage,
                usecase: usecase
            )
        )
    }
}
