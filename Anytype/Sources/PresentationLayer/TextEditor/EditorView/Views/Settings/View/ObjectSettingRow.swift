//
//  ObjectSettingRow.swift
//  Anytype
//
//  Created by Konstantin Mordan on 15.07.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import SwiftUI

struct ObjectSettingRow: View {
    
    let setting: ObjectSetting
    let onTap: () -> Void
    
    var body: some View {
        Button {
            onTap()
        }
        label: {
            HStack(spacing: Constants.space) {
                setting.image.frame(
                    width: Constants.iconWidth,
                    height: Constants.iconWidth
                )
                
                VStack(alignment: .leading, spacing: 0) {
                    AnytypeText(
                        setting.title,
                        style: .uxTitle2Medium,
                        color: .textPrimary
                    )
                    
                    Spacer.fixedHeight(2)
                    
                    AnytypeText(
                        setting.description,
                        style: .caption1Regular,
                        color: .textSecondary
                    )
                }
                
                Spacer()
                
                Image.arrow
                
            }
            .padding(.top, Constants.verticalInset)
            .modifier(
                DividerModifier(
                    spacing: Constants.verticalInset,
                    leadingPadding: Constants.space + Constants.iconWidth
                )
            )
        }
        
    }
    
    private enum Constants {
        static let verticalInset: CGFloat = 10
        static let iconWidth: CGFloat = 44
        static let space: CGFloat = 12
    }
}

private extension ObjectSetting {
    
    var title: String {
        switch self {
        case .icon:
            return "Icon"
        case .cover:
            return "Cover"
        case .layout:
            return "Layout"
        }
    }
    
    var description: String {
        switch self {
        case .icon:
            return "Emoji or image for object"
        case .cover:
            return "Background picture"
        case .layout:
            return "Arrangement of objects on a canvas"
        }
    }
    
    var image: Image {
        switch self {
        case .icon:
            return Image.ObjectSettings.icon
        case .cover:
            return Image.ObjectSettings.cover
        case .layout:
            return Image.ObjectSettings.layout
        }
    }
}

struct ObjectSettingRowView_Previews: PreviewProvider {
    static var previews: some View {
        ObjectSettingRow(setting: .layout) {}
    }
}
