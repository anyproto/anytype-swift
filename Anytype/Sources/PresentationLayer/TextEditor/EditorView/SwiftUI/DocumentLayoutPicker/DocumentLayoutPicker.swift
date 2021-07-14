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
        VStack(alignment: .center, spacing: 0) {
            DragIndicator()
            AnytypeText("Choose layout type", style: .headlineSemibold)
                .padding([.top, .bottom], 12)
            layoutList
            Spacer()
        }
    }
    
    private var layoutList: some View {
        VStack(spacing: 16) {
            ForEach(DetailsLayout.allCases, id: \.self) { layout in
                DocumentLayoutTypeRow(
                    layout: layout,
                    isSelected: layout == selectedLayout,
                    onTap: {
                        selectedLayout = layout
                    }
                )
                .modifier(DividerModifier(spacing: 16))
            }
        }
        .padding(.top, 16)
        .padding([.leading, .trailing], 20)
        
    }
}

struct DocumentLayoutPicker_Previews: PreviewProvider {
    static var previews: some View {
        DocumentLayoutPicker()
    }
}
