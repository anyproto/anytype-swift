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
            LazyVStack(spacing: 0) {
                ForEach(viewModel.sections) { section in
                    VStack(alignment: .leading, spacing: 0) {
                        Section(
                            header: AnytypeText(
                                section.title,
                                style: .uxTitle1Semibold,
                                color: .textPrimary
                            )
                                .padding(.vertical, 12)
                        ) {
                            ForEach(section.relations) { relation in
                                ObjectRelationRow(viewModel: relation)
                            }
                        }
                        
                        Spacer()
                            .frame(height: 20)
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
                sections: [
                    ObjectRelationsSection(
                        id: "id",
                        title: "title",
                        relations: [
                            ObjectRelationRowData(
                                id: "1",
                                name: "Relation name1",
                                value: .text("text"),
                                hint: "hint",
                                isFeatured: false
                                
                            ),
                            ObjectRelationRowData(
                                id: "2",
                                name: "Relation name2",
                                value: .text("text2"),
                                hint: "hint",
                                isFeatured: false
                            ),
                            ObjectRelationRowData(
                                id: "3",
                                name: "Relation name3",
                                value: .tag([
                                    TagRelation(text: "text", textColor: .darkTeal, backgroundColor: .grayscaleWhite),
                                    TagRelation(text: "text2", textColor: .darkRed, backgroundColor: .lightRed),
                                    TagRelation(text: "text", textColor: .darkTeal, backgroundColor: .lightTeal),
                                    TagRelation(text: "text2", textColor: .darkRed, backgroundColor: .lightRed)
                                ]),
                                hint: "hint",
                                isFeatured: false
                            )
                        ]
                    ),
                    ObjectRelationsSection(
                        id: "id1",
                        title: "title2",
                        relations: [
                            ObjectRelationRowData(
                                id: "12",
                                name: "Relation name1",
                                value: .text("text"),
                                hint: "hint",
                                isFeatured: false
                            ),
                            ObjectRelationRowData(
                                id: "22",
                                name: "Relation name2",
                                value: .text("text2"),
                                hint: "hint",
                                isFeatured: false
                            ),
                            ObjectRelationRowData(
                                id: "32",
                                name: "Relation name3",
                                value: .text("text3"),
                                hint: "hint",
                                isFeatured: false
                            )
                        ]
                    )
                ]
            )
        )
    }
}
