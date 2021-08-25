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
            let imageGuideline = TodoObjectIconImageGuidelineFactory.imageGuideline(for: sizeGroup)
            switch imageGuideline {
            case .none:
                EmptyView()
            case .some(let imageGuideline):
                Image(
                    uiImage: painter.todoImage(
                        isChecked: isChecked,
                        imageGuideline: imageGuideline
                    )
                )
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
