//
//  ObjectRelationsView.swift
//  Anytype
//
//  Created by Konstantin Mordan on 01.11.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import SwiftUI
import BlocksModels

struct ObjectRelationsView: View {
    
    @ObservedObject var viewModel: ObjectRelationsViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator(bottomPadding: 0)
            relationsList
        }
    }
    
    private var relationsList: some View {
        List {
            Section(
                header: AnytypeText(
                    "In this object".localized,
                    style: .uxTitle1Semibold,
                    color: .textPrimary
                )
            ) {
                ForEach(viewModel.relations) { relation in
                    ObjectRelationRow(relation: relation)
                }
            }
        }
        .listStyle(.plain)
    }
    
}

struct ObjectRelationsView_Previews: PreviewProvider {
        
    static var previews: some View {
        ObjectRelationsView(
            viewModel: ObjectRelationsViewModel(
                relations: [
                    Relation(
                        key: "key1",
                        name: "Relation name",
                        format: .shortText,
                        isHidden: false,
                        isReadOnly: true,
                        isMulti: false,
                        selections: [],
                        objectTypes: []
                    ),
                    Relation(
                        key: "key2",
                        name: "Relation name",
                        format: .shortText,
                        isHidden: false,
                        isReadOnly: true,
                        isMulti: false,
                        selections: [],
                        objectTypes: []
                    ),
                    Relation(
                        key: "key3",
                        name: "Relation name",
                        format: .shortText,
                        isHidden: false,
                        isReadOnly: true,
                        isMulti: false,
                        selections: [],
                        objectTypes: []
                    )
                ]
            )
        )
    }
}
