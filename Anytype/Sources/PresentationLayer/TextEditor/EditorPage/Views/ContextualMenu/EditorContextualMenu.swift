//
//  EditorContextualMenu.swift
//  Anytype
//
//  Created by Dmitry Bilienko on 10.02.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import SwiftUI

enum EditorContextualOption: Int, Identifiable {
    var id: RawValue { rawValue }

    case createBookmark
    case dismiss

    var localisedString: String {
        switch self {
        case .createBookmark:
            return Loc.createBookmark
        case .dismiss:
            return Loc.dismiss
        }
    }
}

// https://www.figma.com/file/TupCOWb8sC9NcjtSToWIkS/Mobile---main?node-id=8329%3A3887
struct EditorContextualMenuView: View {
    let options: [EditorContextualOption]
    let optionTapHandler: (EditorContextualOption) -> Void

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            ForEach(options) { option in
                Button {
                    optionTapHandler(option)
                } label: {
                    Text(option.localisedString)
                        .foregroundColor(Color.textPrimary)
                        .font(AnytypeFontBuilder.font(anytypeFont: .uxCalloutRegular))
                        .padding(.leading, 16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.backgroundSecondary)
                }
                .frame(minWidth: 0, maxWidth: 224, minHeight: 0, maxHeight: 43.5)
                if(options.last != option) {
                    AnytypeDivider()
                        .frame(minWidth: 0, maxWidth: 224, maxHeight: 0.5)
                }
            }
        }
    }
}

struct EditorContextualMenuBuilder {
    static func buildContextualMenu(
        with options: [EditorContextualOption],
        handler: @escaping (EditorContextualOption) -> Void
    ) -> UIView {
        let contextualMenuView = EditorContextualMenuView(options: options, optionTapHandler: handler)
        let shadowView = RoundedShadowView(
            view: contextualMenuView.asUIView(),
            cornerRadius: 8
        )

        shadowView.shadowLayer.fillColor = UIColor.textPrimary.cgColor
        shadowView.shadowLayer.shadowOffset = .init(width: 0, height: 2)
        shadowView.shadowLayer.shadowOpacity = 0.25
        shadowView.shadowLayer.shadowRadius = 3

        return shadowView
    }
}
