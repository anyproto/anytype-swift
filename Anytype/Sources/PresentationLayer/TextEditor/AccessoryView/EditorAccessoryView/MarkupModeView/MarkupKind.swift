//
//  MarkupKind.swift
//  Anytype
//
//  Created by Denis Batvinkin on 05.11.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import SwiftUI


extension MarkupAccessoryViewModel {
    enum FontStyle: CaseIterable {
        case bold
        case italic
        case strikethrough
        case keyboard
    }

    enum MarkupKind: CaseIterable {
        case fontStyle(FontStyle)
        case link
        case color

        static var allCases: [MarkupAccessoryViewModel.MarkupKind] {
            var allMarkup = FontStyle.allCases.map {
                MarkupKind.fontStyle($0)
            }
            allMarkup += [.link, .color]

            return allMarkup
        }
    }
}

extension MarkupAccessoryViewModel.MarkupKind {

    var icon: Image {
        switch self {
        case .fontStyle(.bold):
            return Image(uiImage: .textAttributes.bold)
        case .fontStyle(.italic):
            return Image(uiImage: .textAttributes.italic)
        case .fontStyle(.strikethrough):
            return Image(uiImage: .textAttributes.strikethrough)
        case .fontStyle(.keyboard):
            return Image(uiImage: .textAttributes.code)
        case .link:
            return Image(uiImage: .textAttributes.url)
        case .color:
            return Image(uiImage: .textAttributes.color)
        }
    }

    func hasMarkup(for text: NSAttributedString, range: NSRange) -> Bool {
        switch self {
        case let .fontStyle(fontStyle):
            return text.hasMarkup(fontStyle.markupType, range: range)
        case .link:
            return text.linkState(range: range).isNotNil || text.linkToObjectState(range: range).isNotNil
        case .color:
            return true
        }
    }
}

extension MarkupAccessoryViewModel.FontStyle {
    var markupType: MarkupType {
        switch self {
        case .bold:
            return .bold
        case .italic:
            return .italic
        case .strikethrough:
            return .strikethrough
        case .keyboard:
            return .keyboard
        }
    }
}
