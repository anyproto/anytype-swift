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
        case .icon(let type):
            iconImage(type: type)
        case .todo(let isChecked):
            todoIconImage(isChecked: isChecked)
        case .placeholder(let character):
            stringIconImage(
                character.flatMap { String($0) } ?? "",
                textColor: UIColor.textTertiary,
                backgroundColor: .grayscale10
            )
        }
    }
    
    private func iconImage(type: ObjectIconType) -> some View {
        Group {
            switch type {
            case .basic(let id):
                loadableIconImage(id: id)
            case .profile(let profile):
                profileIconImage(profile: profile)
            case .emoji(let iconEmoji):
                stringIconImage(
                    iconEmoji.value,
                    textColor: .grayscaleWhite,
                    backgroundColor: .grayscale10
                )
            }
        }
    }
    
    private func loadableIconImage(id: String) -> some View {
        Group {
            switch position.objectIconImageGuidelineSet.imageGuideline(for: iconImage) {
            case .none:
                EmptyView()
            case .some(let imageGuideline):
                kfImage(imageId: id, imageGuidline: imageGuideline)
            }
        }
    }
    
    private func profileIconImage(profile: ObjectIconType.Profile) -> some View {
        Group {
            switch profile {
            case .imageId(let id):
                loadableIconImage(id: id)
            case .character(let character):
                stringIconImage(String(character),
                                textColor: .grayscaleWhite,
                                backgroundColor: .dividerSecondary)
            }
        }
    }
    
    private func stringIconImage(_ string: String, textColor: UIColor, backgroundColor: UIColor) -> some View {
        Group {
            let imageGuideline = position.objectIconImageGuidelineSet.imageGuideline(
                for: iconImage
            )
            let font = position.objectIconImageFontSet.imageFont(for: iconImage)
            
            if let imageGuideline = imageGuideline, let font = font {
                Image(
                    uiImage: painter.image(
                        with: string,
                        font: font,
                        textColor: textColor,
                        imageGuideline: imageGuideline,
                        backgroundColor: backgroundColor
                    )
                )
            } else {
                EmptyView()
            }
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
    
    private func kfImage(imageId: String, imageGuidline: ImageGuideline) -> KFImage {
        KFImage.url(UrlResolver.resolvedUrl(.image(id: imageId, width: .thumbnail)))
            .setProcessors([
                ResizingImageProcessor(
                    referenceSize: imageGuidline.size,
                    mode: .aspectFill
                ),
                CroppingImageProcessor(size: imageGuidline.size),
                RoundCornerImageProcessor(
                    radius: .point(imageGuidline.cornersGuideline.radius),
                    backgroundColor: imageGuidline.cornersGuideline.backgroundColor
                )
            ])
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
