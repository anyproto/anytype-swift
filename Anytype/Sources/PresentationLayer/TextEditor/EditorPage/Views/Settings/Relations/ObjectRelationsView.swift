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
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                Section(
                    header: AnytypeText(
                        "In this object".localized,
                        style: .uxTitle1Semibold,
                        color: .textPrimary
                    )
                        .padding(.vertical, 12)
                ) {
                    ForEach(viewModel.rowViewModels) { rowViewModel in
                        ObjectRelationRow(viewModel: rowViewModel)
                    }
                }
            }.padding(.horizontal, 20)
        }
    }
    
}

struct ObjectRelationsView_Previews: PreviewProvider {
        
    static var previews: some View {
        ObjectRelationsView(
            viewModel: ObjectRelationsViewModel(
                rowViewModels: [
                    ObjectRelationRowData(
                        id: "1",
                        name: "Relation name1",
                        value: .text("text"),
                        hint: "hint"
                    ),
                    ObjectRelationRowData(
                        id: "2",
                        name: "Relation name2",
                        value: .text("text2"),
                        hint: "hint"
                    ),
                    ObjectRelationRowData(
                        id: "3",
                        name: "Relation name3",
                        value: .text("text3"),
                        hint: "hint"
                    ),
                ]
            )
        )
    }
}
