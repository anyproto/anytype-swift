//
//  ObjectLayoutPicker.swift
//  Anytype
//
//  Created by Konstantin Mordan on 06.07.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import SwiftUI
import BlocksModels


struct ObjectLayoutPicker: View {
    
    @EnvironmentObject private var viewModel: ObjectLayoutPickerViewModel
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            DragIndicator(bottomPadding: 0)
            AnytypeText("Choose layout type", style: .uxTitle1Semibold)
                .padding([.top, .bottom], 12)
            layoutList
        }
        .background(Color.background)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.35), radius: 40, x: 0, y: 4)
    }
    
    private var layoutList: some View {
        VStack(spacing: 0) {
            ForEach(DetailsLayout.allCases, id: \.self) { layout in
                ObjectLayoutRow(
                    layout: layout,
                    isSelected: layout == viewModel.selectedLayout,
                    onTap: {
                        viewModel.didSelectLayout(layout)
                    }
                )
            }
        }
        .padding([.leading, .trailing, .bottom], 20)
    }
}

struct DocumentLayoutPicker_Previews: PreviewProvider {
    static var previews: some View {
        ObjectLayoutPicker()
    }
}
