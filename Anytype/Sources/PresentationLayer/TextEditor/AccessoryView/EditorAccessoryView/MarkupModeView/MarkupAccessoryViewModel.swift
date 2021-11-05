//
//  MarkupAccessoryViewModel.swift
//  Anytype
//
//  Created by Denis Batvinkin on 05.11.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import BlocksModels
import SwiftUI
import Combine

final class MarkupAccessoryViewModel: ObservableObject {
    let markupOptions: [MarkupKind] = MarkupKind.allCases
    @Published private var markupCalculator: MarkupStateCalculator?
    private let actionHandler: BlockActionHandlerProtocol
    private let router: EditorRouterProtocol
    private let pageService = PageService()
    private var blockId: BlockId = ""
    private var range: NSRange = .zero
    private let document: BaseDocumentProtocol
    private var cancellables = [AnyCancellable]()

    init(document: BaseDocumentProtocol, actionHandler: BlockActionHandlerProtocol, router: EditorRouterProtocol) {
        self.actionHandler = actionHandler
        self.router = router
        self.document = document
        self.subscribeOnBlocksChanges()
    }

    func selectBlock(_ block: BlockModelProtocol, text: NSAttributedString, range: NSRange) {
        let restrictions = BlockRestrictionsBuilder.build(contentType: block.information.content.type)
        blockId = block.information.id

        setRange(range: range, text: text, restrictions: restrictions)
    }

    func updateRange(range: NSRange) {
        guard let currentMarkupCalculator = markupCalculator else {
            return
        }

        let currentText = currentMarkupCalculator.attributedText
        let currentRestrictions = currentMarkupCalculator.restrictions

        setRange(range: range, text: currentText, restrictions: currentRestrictions)
    }

    private func setRange(range: NSRange, text: NSAttributedString, restrictions: BlockRestrictions) {
        self.range = range

        markupCalculator = MarkupStateCalculator(
            attributedText: text,
            range: range,
            restrictions: restrictions,
            alignment: nil
        )
    }

    func action(_ markup: MarkupKind) {
        switch markup {
        case .fontStyle(let fontStyle):
            actionHandler.changeTextStyle(fontStyle.blockActionHandlerTypeMarkup, range: range, blockId: blockId)
        case .link:
            showLinkToSearch(blockId: blockId, range: range)
        }
    }

    func iconColor(for markup: MarkupKind) -> Color {
        let state = markupState(for: markup)

        switch state {
        case .disabled:
            return .buttonInactive
        case .applied:
            return .buttonSelected
        case .notApplied:
            return .buttonActive
        }
    }

    private func markupState(for markup: MarkupKind) -> MarkupState {
        switch markup {
        case .fontStyle(let fontStyle):
            return markupCalculator?.state(for: fontStyle.blockActionHandlerTypeMarkup) ?? .disabled
        case .link:
            return markupCalculator?.linkState() ?? .disabled
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

    private func subscribeOnBlocksChanges() {
        document.updatePublisher.sink { [weak self] update in
            guard let self = self else { return }
            guard case let .blocks(blocks) = update else { return }

            let isCurrentBlock = blocks.contains(where: { blockId in
                blockId == self.blockId
            })

            guard isCurrentBlock, let (block, textBlockContent) = self.blockData(blockId: self.blockId) else { return }

            let currentText = textBlockContent.anytypeText(using: self.document.detailsStorage).attrString
            self.selectBlock(block, text: currentText, range: self.range)
        }.store(in: &cancellables)
    }

    private func blockData(blockId: BlockId) -> (BlockModelProtocol, BlockText)? {
        guard let model = document.blocksContainer.model(id: blockId) else {
            return nil
        }
        guard case let .text(content) = model.information.content else {
            return nil
        }
        return (model, content)
    }
}
