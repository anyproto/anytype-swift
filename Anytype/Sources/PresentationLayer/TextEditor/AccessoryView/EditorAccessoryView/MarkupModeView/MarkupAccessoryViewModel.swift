//
//  MarkupAccessoryViewModel.swift
//  Anytype
//
//  Created by Denis Batvinkin on 05.11.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import BlocksModels


final class MarkupAccessoryViewModel: ObservableObject {
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
            actionHandler.changeTextStyle(fontStyle.blockActionHandlerTypeMarkup, range: range, blockId: blockId)
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
                self?.actionHandler.setLinkToObject(linkBlockId: linkBlockId, range: range, blockId: blockId)
            case let .createObject(name):
                if let linkBlockId = self?.pageService.createPage(name: name) {
                    self?.actionHandler.setLinkToObject(linkBlockId: linkBlockId, range: range, blockId: blockId)
                }
            case let .web(url):
                self?.actionHandler.setLink(url: URL(string: url), range: range, blockId: blockId)
            }
        }
    }
}
