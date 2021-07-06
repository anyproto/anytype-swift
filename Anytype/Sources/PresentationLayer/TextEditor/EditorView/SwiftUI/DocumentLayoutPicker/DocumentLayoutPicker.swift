//
//  DocumentLayoutPicker.swift
//  Anytype
//
//  Created by Konstantin Mordan on 06.07.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import SwiftUI
import BlocksModels

struct DocumentLayoutPicker: View {
    @State private var selectedLayout: DetailsLayout = .basic
    
    var body: some View {
        VStack {
            ForEach(DetailsLayout.allCases, id: \.self) { layout in
                DocumentLayoutTypeRow(
                    layout: layout,
                    isSelected: layout == selectedLayout
                )
                .onTapGesture {
                    selectedLayout = layout
                }
            }
            Spacer()
        }
    }
}

struct DocumentLayoutPicker_Previews: PreviewProvider {
    static var previews: some View {
        DocumentLayoutPicker()
    }
}
