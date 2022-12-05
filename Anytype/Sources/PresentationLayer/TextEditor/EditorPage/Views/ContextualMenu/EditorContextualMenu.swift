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
    case pasteAsText
    case pasteAsLink

    var localisedString: String {
        switch self {
        case .createBookmark:
            return Loc.LinkPaste.bookmark
        case .pasteAsText:
            return Loc.LinkPaste.text
        case .pasteAsLink:
            return Loc.LinkPaste.link
        }
    }
}

struct EditorContextualMenuView: View {
    let options: [EditorContextualOption]
    let optionTapHandler: (EditorContextualOption) -> Void

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Spacer.fixedHeight(8)
            ForEach(options) { option in
                Button {
                    optionTapHandler(option)
                } label: {
                    Text(option.localisedString)
                        .foregroundColor(Color.textPrimary)
                        .font(AnytypeFontBuilder.font(anytypeFont: .uxCalloutRegular))
                        .padding(.leading, 16)
                        .frame(maxWidth: .infinity, minHeight: 28, alignment: .leading)
                        .contentShape(Rectangle())
                }
                .frame(minWidth: 208, maxWidth: 224, minHeight: 28, maxHeight: 43.5)
                .buttonStyle(TertiaryPressedBackgroundButtonStyle())
            }
            Spacer.fixedHeight(8)
        }
    }
}
