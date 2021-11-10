//
//  MarkupKind.swift
//  Anytype
//
//  Created by Denis Batvinkin on 05.11.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import SwiftUI


extension MarkupAccessoryViewModel {
    enum LinkType {
        case url(URL)
        case linkToObject(String)
    }

    enum ColorType {
        case text(UIColor)
        case background(UIColor)
    }

    enum FontStyle: CaseIterable {
        case bold
        case italic
        case strikethrough
        case keyboard
    }

    enum MarkupKind {
        case fontStyle(FontStyle)
        case link(LinkType?)
        case color(ColorType?)

        static var allCases: [MarkupAccessoryViewModel.MarkupKind] {
            var allMarkup = FontStyle.allCases.map {
                MarkupKind.fontStyle($0)
            }
            allMarkup += [.link(nil), .color(nil)]

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

    var markupType: MarkupType? {
        switch self {
        case let .fontStyle(fontStyle):
            return fontStyle.markupType
        case let .link(kind):
            switch kind {
            case let .url(url):
                return .link(url)
            case let .linkToObject(blockId):
                return .linkToObject(blockId)
            case .none:
                return nil
            }
        case let .color(kind):
            switch kind {
            case let .text(color):
                return .textColor(color)
            case let .background(color):
                return .backgroundColor(color)
            case .none:
                return nil
            }
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
