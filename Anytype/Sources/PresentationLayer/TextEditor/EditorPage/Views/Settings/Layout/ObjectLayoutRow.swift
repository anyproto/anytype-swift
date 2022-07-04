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
            row
        }
    }
    
    private var row: some View {
        HStack(spacing: 0) {
            layout.icon.frame(width: 44, height: 44)
            
            Spacer.fixedWidth(12)
            
            VStack(alignment: .leading, spacing: 0) {
                Spacer()
                
                HStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 0) {
                        AnytypeText(layout.title, style: .uxTitle2Medium, color: .textPrimary)
                        AnytypeText(layout.description, style: .caption1Regular, color: .textSecondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.9)
                    }
                    
                    Spacer(minLength: 12)
                    
                    if isSelected {
                        Image.optionChecked.frame(width: 24, height: 24).foregroundColor(.buttonSelected)
                    }
                }
                
                Spacer()
                AnytypeDivider()
            }
        }
        .frame(height: 60)
        .padding(.horizontal, 16)
    }
    
}

private extension DetailsLayout {
    
    var icon: Image {
        switch self {
        case .basic:
            return .LayoutSettings.basic
        case .profile:
            return .LayoutSettings.profile
        case .todo:
            return .LayoutSettings.todo
        case .note:
            return .LayoutSettings.note
        case .set:
            return .noImage
        }
    }
    
    var title: String {
        switch self {
        case .basic:
            return Loc.basic
        case .profile:
            return Loc.profile
        case .todo:
            return Loc.task
        case .note:
            return Loc.note
        case .set:
            return Loc.set
        }
    }
    
    var description: String {
        switch self {
        case .basic:
            return Loc.standardLayoutForCanvasBlocks
        case .profile:
            return Loc.companiesContactsFriendsAndFamily
        case .todo:
            return Loc.actionFocusedLayoutWithACheckbox
        case .note:
            return Loc.designedToCaptureThoughtsQuickly
        case .set:
            return Loc.collectionOfObjects
        }
    }
    
}

struct DocumentLayoutTypeRow_Previews: PreviewProvider {
    static var previews: some View {
        ObjectLayoutRow(layout: .basic, isSelected: true, onTap: {})
            .background(Color.blue)
    }
}
