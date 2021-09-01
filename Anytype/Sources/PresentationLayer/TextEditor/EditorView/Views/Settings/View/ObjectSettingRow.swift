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
            HStack(spacing: 12) {
                setting.image.frame(width: 44, height: 44)
                
                VStack(alignment: .leading, spacing: 0) {
                    AnytypeText(setting.title, style: .uxTitle2Regular, color: .textPrimary)
                        .padding(.vertical, 2)
                    AnytypeText(setting.description, style: .caption1Regular, color: .textSecondary)
                        .padding(.vertical, 2)
                }
                
                Spacer()
                
                Image.arrow.frame(width: 24, height: 24)
                
            }
            .padding(.top, 10)
            .modifier(DividerModifier(spacing: 10))
        }
        
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
