//
//  MarkupKind.swift
//  Anytype
//
//  Created by Denis Batvinkin on 05.11.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import SwiftUI


extension MarkupAccessoryViewModel {
    enum MarkupKind: CaseIterable, Equatable, Hashable {
        enum FontStyle: CaseIterable, Equatable {
            case bold
            case italic
            case strikethrough
            case keyboard
        }
        case fontStyle(FontStyle)
        case link

        static var allCases: [MarkupAccessoryViewModel.MarkupKind] {
            var allMarkup = FontStyle.allCases.map {
                MarkupKind.fontStyle($0)
            }
            allMarkup += [.link]
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
        }
    }
}

extension MarkupAccessoryViewModel.MarkupKind.FontStyle {

    var blockActionHandlerTypeMarkup: TextAttributesType {
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
