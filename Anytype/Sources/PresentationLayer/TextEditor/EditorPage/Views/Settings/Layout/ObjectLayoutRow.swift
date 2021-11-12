//
//  ObjectLayoutRow.swift
//  Anytype
//
//  Created by Konstantin Mordan on 06.07.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import SwiftUI
import BlocksModels

struct ObjectLayoutRow: View {
    
    let layout: DetailsLayout
    let isSelected: Bool
    
    let onTap: () -> Void
    
    var body: some View {
        Button {
            onTap()
        }
        label: {
            HStack(spacing: 12) {
                layout.icon.frame(width: 44, height: 44)
                VStack(alignment: .leading, spacing: 0) {
                    AnytypeText(layout.title, style: .uxTitle2Medium, color: .textPrimary)
                    AnytypeText(layout.description, style: .caption1Regular, color: .textSecondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image.LayoutSettings.checkmark.frame(width: 24, height: 24).foregroundColor(.buttonSelected)
                }
            }
        }
        .padding(.top, 12)
        .modifier(DividerModifier(spacing: 12))
            
    }
}

private extension DetailsLayout {
    
    var icon: Image {
        switch self {
        case .basic:
            return Image.LayoutSettings.basic
        case .profile:
            return Image.LayoutSettings.profile
        case .todo:
            return Image.LayoutSettings.todo
        case .note:
            return Image.LayoutSettings.note
        }
    }
    
    var title: String {
        switch self {
        case .basic:
            return "Basic".localized
        case .profile:
            return "Profile".localized
        case .todo:
            return "Task".localized
        case .note:
            return "Note".localized
        }
    }
    
    var description: String {
        switch self {
        case .basic:
            return "Standard layout for canvas blocks".localized
        case .profile:
            return "Companies, contacts, friends, and family".localized
        case .todo:
            return "Action-focused layout with a checkbox".localized
        case .note:
            return "Designed to capture thoughts quickly".localized
        }
    }
    
}

struct DocumentLayoutTypeRow_Previews: PreviewProvider {
    static var previews: some View {
        ObjectLayoutRow(layout: .basic, isSelected: true, onTap: {})
            .background(Color.blue)
    }
}
