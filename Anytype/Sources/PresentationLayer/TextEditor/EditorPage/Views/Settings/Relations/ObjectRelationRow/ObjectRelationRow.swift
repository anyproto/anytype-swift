//
//  ObjectRelationRow.swift
//  Anytype
//
//  Created by Konstantin Mordan on 04.11.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import SwiftUI

struct ObjectRelationRow: View {
    
    let viewModel: ObjectRelationRowData
    let onStarTap: (String) -> ()
    
    var body: some View {
        GeometryReader { gr in
            // If we will use spacing more than 0 it will be added to
            // `Spacer()` from both sides as a result
            // `Spacer` will take up more space
            HStack(spacing: 0) {
                name
                    .frame(width: gr.size.width * 0.4, alignment: .leading)
                Spacer.fixedWidth(8)
                valueView
                Spacer(minLength: 8)
                starImageView
            }
            .frame(width: gr.size.width, height: gr.size.height)
        }
        .frame(height: 48)
        .modifier(DividerModifier(spacing:0))
    }
    
    private var name: some View {
        AnytypeText(viewModel.name, style: .relation1Regular, color: .textSecondary)
    }
    
    private var valueView: some View {
        Group {
            let value = viewModel.value
            let hint = viewModel.hint
            switch value {
            case .text(let string):
                TextRelationView(value: string, hint: hint)
                
            case .status(let statusRelation):
                StatusRelationView(value: statusRelation, hint: hint)
                
            case .checkbox(let bool):
                CheckboxRelationView(isChecked: bool)
                
            case .tag(let tags):
                TagRelationView(value: tags, hint: hint)
                
            case .object(let objectRelation):
                ObjectRelationView(value: objectRelation, hint: hint)
                
            case .unknown(let string):
                ObjectRelationRowHintView(hint: string)
            }
        }
    }
    
    private var starImageView: some View {
        Button {
            onStarTap(viewModel.id)
        } label: {
            viewModel.isFeatured ?
            Image.Relations.removeFromFeatured :
            Image.Relations.addToFeatured
        }.frame(width: 24, height: 24)
    }
}

struct ObjectRelationRow_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            ObjectRelationRow(
                viewModel: ObjectRelationRowData(
                    id: "1", name: "Relation name",
                    value: .tag([
                        TagRelation(text: "text", textColor: .darkTeal, backgroundColor: .grayscaleWhite),
                        TagRelation(text: "text2", textColor: .darkRed, backgroundColor: .lightRed),
                        TagRelation(text: "text", textColor: .darkTeal, backgroundColor: .lightTeal),
                        TagRelation(text: "text2", textColor: .darkRed, backgroundColor: .lightRed)
                    ]),
                    hint: "hint",
                    isFeatured: false,
                    isEditable: true
                ),
                onStarTap: { _ in }
            )
            ObjectRelationRow(
                viewModel: ObjectRelationRowData(
                    id: "1", name: "Relation name",
                    value: .text("hello"),
                    hint: "hint",
                    isFeatured: false,
                    isEditable: false
                ),
                onStarTap: { _ in }
            )
        }
    }
}
