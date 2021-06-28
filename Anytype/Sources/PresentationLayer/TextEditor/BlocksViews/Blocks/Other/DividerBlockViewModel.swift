import Foundation
import SwiftUI
import Combine
import os
import BlocksModels
import MobileCoreServices


class DividerBlockViewModel: BaseBlockViewModel {
    private let content: BlockDivider
    
    init(
        _ block: BlockActiveRecordProtocol,
        content: BlockDivider,
        delegate: BaseBlockDelegate?,
        actionHandler: NewBlockActionHandler?,
        router: EditorRouterProtocol?
    ) {
        self.content = content
        super.init(block, delegate: delegate, actionHandler: actionHandler, router: router)
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
    override func makeContextualMenu() -> ContextualMenu {
        .init(title: "", children: [
            .init(action: .addBlockBelow),
            .init(action: .delete),
            .init(action: .duplicate)
        ])
    }
}
