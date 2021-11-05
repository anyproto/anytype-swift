//
//  ObjectRelationRow.swift
//  Anytype
//
//  Created by Konstantin Mordan on 04.11.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import SwiftUI
import BlocksModels

struct ObjectRelationRow: View {
    
    let relationEntity: RelationEntity
    
    var body: some View {
        GeometryReader { gr in
            HStack(spacing: 8) {
                AnytypeText(
                    relationEntity.relation.name,
                    style: .relation1Regular,
                    color: .textSecondary
                )
                    .frame(width: gr.size.width * 0.4, alignment: .leading)
                valueView
                Spacer()
            }
            .frame(width: gr.size.width, height: gr.size.height)
        }
        .frame(height: 44)
    }
    
    private var valueView: some View {
        Group {
            switch relationEntity.relation.format {
            case .longText:
                TextRelationView(
                    value: relationEntity.value?.stringValue,
                    hint: relationEntity.relation.format.hint
                )
            case .shortText:
                TextRelationView(
                    value: relationEntity.value?.stringValue,
                    hint: relationEntity.relation.format.hint
                )
            case .number:
                TextRelationView(
                    value: RelationValueConverter.numberString(from: relationEntity.value),
                    hint: relationEntity.relation.format.hint
                )
            case .status:
                EmptyView()
            case .date:
                TextRelationView(
                    value: RelationValueConverter.dateString(from: relationEntity.value),
                    hint: relationEntity.relation.format.hint
                )
            case .file:
                EmptyView()
            case .checkbox:
                CheckboxRelationView(
                    isChecked: relationEntity.value?.boolValue ?? false
                )
            case .url:
                TextRelationView(
                    value: relationEntity.value?.stringValue,
                    hint: relationEntity.relation.format.hint
                )
            case .email:
                TextRelationView(
                    value: relationEntity.value?.stringValue,
                    hint: relationEntity.relation.format.hint
                )
            case .phone:
                TextRelationView(
                    value: relationEntity.value?.stringValue,
                    hint: relationEntity.relation.format.hint
                )
            case .emoji:
                EmptyView()
            case .tag:
                EmptyView()
            case .object:
                EmptyView()
            case .relations:
                EmptyView()
            case .unrecognized:
                EmptyView()
            }
        }
    }
}

struct ObjectRelationRow_Previews: PreviewProvider {
    static var previews: some View {
        ObjectRelationRow(
            relationEntity: RelationEntity(
                relation: Relation(
                    key: "key",
                    name: "Relation name",
                    format: .shortText,
                    isHidden: false,
                    isReadOnly: true,
                    isMulti: false,
                    selections: [],
                    objectTypes: []
                ),
                value: nil
            )
        )
    }
}
