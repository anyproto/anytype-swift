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
                TextRelationView(
                    value: nil,
                    hint: relationEntity.relation.format.placeholder
                )
                Spacer()
            }
            .frame(width: gr.size.width, height: gr.size.height)
        }
        .frame(height: 44)
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
