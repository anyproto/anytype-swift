import Foundation
import SwiftUI
import Combine
import os
import BlocksModels
import MobileCoreServices


class DividerBlockViewModel: BaseBlockViewModel {
    private let content: BlockContent.Divider
    
    init(
        _ block: BlockActiveRecordModelProtocol,
        content: BlockContent.Divider,
        delegate: BaseBlockDelegate?
    ) {
        self.content = content
        super.init(block, delegate: delegate)
    }
    
    override func makeContentConfiguration() -> UIContentConfiguration {
        return DividerBlockContentConfiguration(content: content)
    }
    
    override var diffable: AnyHashable {
        let newDiffable: [String: AnyHashable] = [
            "parent": super.diffable,
            "dividerValue": content.style
        ]
        return .init(newDiffable)
    }
    
    // MARK: Contextual Menu
    override func makeContextualMenu() -> BlocksViews.ContextualMenu {
        .init(title: "", children: [
            .create(action: .general(.addBlockBelow)),
            .create(action: .general(.delete)),
            .create(action: .general(.duplicate))
        ])
    }
}
