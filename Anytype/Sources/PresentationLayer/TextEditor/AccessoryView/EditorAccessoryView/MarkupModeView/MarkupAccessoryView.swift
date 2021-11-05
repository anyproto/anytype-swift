//
//  MarkupAccessoryView.swift
//  Anytype
//
//  Created by Denis Batvinkin on 02.11.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import UIKit
import SwiftUI
import BlocksModels

/// https://www.figma.com/file/TupCOWb8sC9NcjtSToWIkS/Mobile---main?node-id=5172%3A1931
struct MarkupAccessoryView: View {
    @StateObject var viewModel: MarkupAccessoryContentViewModel

    var body: some View {
        HStack {
            ForEach(viewModel.markupOptions, id: \.self) { item in
                Button {
                    viewModel.action(item)
                } label: {
                    item.icon
                        .renderingMode(.template)
                        .foregroundColor(.textPrimary)
                        .frame(width: 48, height: 48)

                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

final class MarkupAccessoryContentViewModel: ObservableObject {
    enum MarkupKind: CaseIterable, Equatable, Hashable {
        enum FontStyle: CaseIterable, Equatable {
            case bold
            case italic
            case strikethrough
            case keyboard
        }
        case fontStyle(FontStyle)
        case link

        static var allCases: [MarkupAccessoryContentViewModel.MarkupKind] {
            var allMarkup = FontStyle.allCases.map {
                MarkupKind.fontStyle($0)
            }
            allMarkup += [.link]
            return allMarkup
        }
    }

    private(set) var markupOptions: [MarkupKind]
    private let actionHandler: BlockActionHandlerProtocol
    private let router: EditorRouterProtocol
    private let pageService = PageService()
    private var blockId: BlockId = ""
    var range: NSRange = .zero

    init(markupOptions: [MarkupKind], actionHandler: BlockActionHandlerProtocol, router: EditorRouterProtocol) {
        self.markupOptions = markupOptions
        self.actionHandler = actionHandler
        self.router = router
    }

    func selectBlock(_ block: BlockModelProtocol) {
        let restrictions = BlockRestrictionsBuilder.build(contentType: block.information.content.type)
        self.blockId = block.information.id
        markupOptions = availableMarkup(for: restrictions)
    }

    func action(_ markup: MarkupKind) {
        switch markup {
        case .fontStyle(let fontStyle):
            actionHandler.handleAction(.toggleFontStyle(fontStyle.blockActionHandlerTypeMarkup, range), blockId: blockId)
        case .link:
            showLinkToSearch(blockId: blockId, range: range)
        }
    }

    private func availableMarkup(for restrictions: BlockRestrictions) -> [MarkupKind] {
        MarkupKind.allCases.filter { markup -> Bool in
            switch markup {
            case .fontStyle(.bold):
                return restrictions.canApplyBold
            case .fontStyle(.italic):
                return restrictions.canApplyItalic
            case .fontStyle(.strikethrough), .fontStyle(.keyboard), .link:
                return restrictions.canApplyOtherMarkup
            }
        }
    }

    private func showLinkToSearch(blockId: BlockId, range: NSRange) {
        router.showLinkToObject { [weak self] searchKind in
            switch searchKind {
            case let .object(linkBlockId):
                self?.actionHandler.handleAction(.setLinkToObject(linkBlockId: linkBlockId, range), blockId: blockId)
            case let .createObject(name):
                if let linkBlockId = self?.pageService.createPage(name: name) {
                    self?.actionHandler.handleAction(.setLinkToObject(linkBlockId: linkBlockId, range), blockId: blockId)
                }
            case let .web(url):
                let link = URL(string: url)
                self?.actionHandler.handleAction(.setLink(link, range), blockId: blockId)
            }
        }
    }
}

extension MarkupAccessoryContentViewModel.MarkupKind {

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

extension MarkupAccessoryContentViewModel.MarkupKind.FontStyle {

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
