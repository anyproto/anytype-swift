//
//  ButtonsView.swift
//  Anytype
//
//  Created by Dmitry Bilienko on 24.11.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import SwiftUI

struct TwoStandardButtonsView: View {
    let leftButtonData: StandardButtonData
    let rightButtonData: StandardButtonData

    var body: some View {
        HStack(spacing: 8) {
            StandardButton(data: leftButtonData)
            StandardButton(data: rightButtonData)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}

struct TwoStandardButtonsView_Previews: PreviewProvider {
    static var previews: some View {
        TwoStandardButtonsView(
            leftButtonData: .init(
                text: "Cancel",
                style: .secondary,
                action: {}
            ),
            rightButtonData:
                    .init(
                        text: "Move",
                        style: .primary,
                        action: {}
                    )
        )
            .previewLayout(.fixed(width: 340, height: 68))
    }
}
