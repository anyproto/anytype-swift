//
//  ObjectLayoutRow.swift
//  Anytype
//
//  Created by Konstantin Mordan on 06.07.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import SwiftUI
import Services

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
            Image(asset: layout.iconAsset)
                .frame(width: 44, height: 44)
                .border(8, color: .Button.active.opacity(0.4))
            
            Spacer.fixedWidth(12)
            
            VStack(alignment: .leading, spacing: 0) {
                Spacer()
                
                HStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 0) {
                        AnytypeText(layout.title, style: .uxTitle2Medium, color: .Text.primary)
                        AnytypeText(layout.description, style: .caption1Regular, color: .Text.secondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.9)
                    }
                    
                    Spacer(minLength: 12)
                    
                    if isSelected {
                        Image(asset: .X24.tick).frame(width: 24, height: 24).foregroundColor(.Button.button)
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
    
    var iconAsset: ImageAsset {
        switch self {
        case .basic:
            return .Layout.basic
        case .profile, .participant:
            return .Layout.profile
        case .todo:
            return .Layout.task
        case .note:
            return .Layout.note
        case .set, .collection, .bookmark, .space, .file, .image, .objectType, .UNRECOGNIZED, .relation, .relationOption, .dashboard, .relationOptionsList, .pdf, .audio, .video, .date, .spaceView:
            return .noImage
        }
    }
    
    var title: String {
        switch self {
        case .basic:
            return Loc.basic
        case .profile, .participant:
            return Loc.profile
        case .todo:
            return Loc.task
        case .note:
            return Loc.note
        case .set:
            return Loc.set
        case .collection:
            return Loc.collection
        case .bookmark, .space, .file, .image, .objectType, .UNRECOGNIZED, .relation, .relationOption, .dashboard, .relationOptionsList, .pdf, .audio, .video, .date, .spaceView:
            return ""
        }
    }
    
    var description: String {
        switch self {
        case .basic:
            return Loc.standardLayoutForCanvasBlocks
        case .profile, .participant:
            return Loc.companiesContactsFriendsAndFamily
        case .todo:
            return Loc.actionFocusedLayoutWithACheckbox
        case .note:
            return Loc.designedToCaptureThoughtsQuickly
        case .set, .collection:
            return Loc.collectionOfObjects
        case .bookmark, .space, .file, .image, .objectType, .UNRECOGNIZED, .relation, .relationOption, .dashboard, .relationOptionsList, .pdf, .audio, .video, .date, .spaceView:
            return ""
        }
    }
    
}

struct DocumentLayoutTypeRow_Previews: PreviewProvider {
    static var previews: some View {
        ObjectLayoutRow(layout: .basic, isSelected: true, onTap: {})
            .background(Color.blue)
    }
}
