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
    
    let iconImage: ObjectIconImage
    let position: ObjectIconImagePosition
    
    var body: some View {
        switch iconImage {
        case .icon:
            EmptyView()
        case .todo(let isChecked):
            todoIconImage(isChecked: isChecked)
        }
    }
    
    private func todoIconImage(isChecked: Bool) -> some View {
        Group {
            if let imageGuideline = position.objectIconImageGuidelineSet.imageGuideline(for: iconImage) {
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
            iconImage: .todo(false),
            position: .openedObject
        )
    }
}
