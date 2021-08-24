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
        }
    }
    
    private func makeBasicIconView(_ basicIcon: DocumentIconType.Basic) -> some View {
        Group {
            switch basicIcon {
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
                    radius: .widthFraction(Constants.profileImageIconCornerRadius)
                )
            case let .placeholder(character):
                AnytypeText(
                    String(character),
                    name: .inter,
                    size: 28,
                    weight: .regular
                )
                    .frame(
                        maxWidth: Constants.iconSize.width,
                        maxHeight: Constants.iconSize.height
                    )
                .foregroundColor(.grayscaleWhite)
                .background(Color.dividerSecondary)
                .clipShape(Circle())
            }
        }
        
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
        static let profileImageIconCornerRadius: CGFloat = 0.5
    }
    
}

struct DashboardObjectIcon_Previews: PreviewProvider {
    static var previews: some View {
        DashboardObjectIcon(
            icon: .emoji(IconEmoji("🥶")!)
        )
    }
}
