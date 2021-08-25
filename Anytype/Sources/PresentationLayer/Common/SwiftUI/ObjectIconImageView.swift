//
//  ObjectIconImageView.swift
//  ObjectIconImageView
//
//  Created by Konstantin Mordan on 25.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import SwiftUI
import Kingfisher

struct ObjectIconImageView: View {
    
    private let painter: ObjectIconImagePainterProtocol = ObjectIconImagePainter.shared
    
    let objectIconImage: ObjectIconImage
    let sizeGroup: ObjectIconImageSizeGroup
    
    var body: some View {
        switch objectIconImage {
        case .icon:
            EmptyView()
        case .todo(let isChecked):
            todoIconImage(isChecked: isChecked)
        }
    }
    
    private func todoIconImage(isChecked: Bool) -> some View {
        Group {
            if let imageGuideline = objectIconImage.imageGuideline(for: sizeGroup) {
                Image(
                    uiImage: painter.todoImage(
                        isChecked: isChecked,
                        imageGuideline: imageGuideline
                    )
                )
            } else {
                EmptyView()
            }
        }
    }
    
}

struct ObjectIconImageView_Previews: PreviewProvider {
    static var previews: some View {
        ObjectIconImageView(
            objectIconImage: .todo(false),
            sizeGroup: .openedObject
        )
    }
}
