//
//  ObjectRelationRow.swift
//  Anytype
//
//  Created by Konstantin Mordan on 04.11.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import SwiftUI

struct ObjectRelationRow: View {
    
    let viewModel: ObjectRelationRowViewModel
    
    var body: some View {
        GeometryReader { gr in
            HStack(spacing: 8) {
                name
                    .frame(width: gr.size.width * 0.4, alignment: .leading)
                valueView
                
                Spacer()
            }
            .frame(width: gr.size.width, height: gr.size.height)
        }
        .frame(height: 44)
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
}

struct ObjectRelationRow_Previews: PreviewProvider {
    static var previews: some View {
        ObjectRelationRow(
            viewModel: ObjectRelationRowViewModel(
                name: "Relation name",
                value: .text("Hello"),
                hint: "hint"
            )
        )
    }
}
