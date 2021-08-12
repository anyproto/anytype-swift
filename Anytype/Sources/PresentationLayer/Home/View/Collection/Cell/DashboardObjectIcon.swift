//
//  DashboardObjectIcon.swift
//  DashboardObjectIcon
//
//  Created by Konstantin Mordan on 12.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import SwiftUI
import Kingfisher

struct DashboardObjectIcon: View {
    
    let icon: DocumentIconType
    
    var body: some View {
        switch icon {
        case let .basic(basicIcon):
            makeBasicIconView(basicIcon)
        case let .profile(profileIcon):
            makeProfileIconView(profileIcon)
        }
    }
    
    private func makeBasicIconView(_ basicIcon: DocumentIconType.Basic) -> some View {
        Group {
            switch basicIcon {
            case let .emoji(emoji):
                AnytypeText(
                    emoji.value,
                    name: .inter,
                    size: 30,
                    weight: .regular
                )
                    .frame(
                        maxWidth: Constants.iconSize.width,
                        maxHeight: Constants.iconSize.height
                    )
                    .background(Color.grayscale10)
                    .cornerRadius(Constants.emojiIconCornerRadius)
            case let .imageId(imageId):
                kfImage(
                    imageId: imageId,
                    radius: .point(Constants.basicImageIconCornerRadius)
                )
            }
        }
    }
    
    private func makeProfileIconView(_ profileIcon: DocumentIconType.Profile) -> some View {
        Group {
            switch profileIcon {
            case let .imageId(imageId):
                kfImage(
                    imageId: imageId,
                    radius: .widthFraction(0.5)
                )
            case let .placeholder(character):
                AnytypeText(
                    String(character),
                    name: .inter,
                    size: 28,
                    weight: .regular
                )
                .frame(maxWidth: 48, maxHeight: 48)
                .foregroundColor(.grayscaleWhite)
                .background(Color.grayscale30)
                
            }
        }
        .clipShape(Circle())
    }
    
    private func kfImage(imageId: String, radius: RoundCornerImageProcessor.Radius) -> KFImage {
        KFImage.url(UrlResolver.resolvedUrl(.image(id: imageId, width: .thumbnail)))
            .setProcessors([
                ResizingImageProcessor(
                    referenceSize: Constants.iconSize,
                    mode: .aspectFill
                ),
                CroppingImageProcessor(size: Constants.iconSize),
                RoundCornerImageProcessor(radius: radius)
            ])
    }
}


extension DashboardObjectIcon {
    
    enum Constants {
        static let iconSize = CGSize(width: 48, height: 48)
        
        static let basicImageIconCornerRadius: CGFloat = 2
        static let emojiIconCornerRadius: CGFloat = 10
    }
    
}

struct DashboardObjectIcon_Previews: PreviewProvider {
    static var previews: some View {
        DashboardObjectIcon(
            icon: .basic(.emoji(IconEmoji("🥶")!))
        )
    }
}
