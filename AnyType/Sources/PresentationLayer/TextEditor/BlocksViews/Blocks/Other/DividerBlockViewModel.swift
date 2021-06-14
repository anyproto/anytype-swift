import Foundation
import SwiftUI
import Combine
import os
import BlocksModels
import MobileCoreServices


class DividerBlockViewModel: BaseBlockViewModel {
    private var subscription: AnyCancellable?
    @Published private var statePublished: DividerBlockUIKitViewState?
    private var publisher: AnyPublisher<BlockContent.Divider, Never> = .empty()
    
    override func makeContentConfiguration() -> UIContentConfiguration {
        var configuration = DividerBlockContentConfiguration(block.blockModel.information)
        configuration.contextMenuHolder = self
        return configuration
    }
    
    // MARK: Subclassing
    override init(_ block: BlockActiveRecordModelProtocol) {
        super.init(block)
        self.setup()
    }
    
    // MARK: Subclassing / Events
    private func setup() {
        self.setupSubscribers()
    }
    
    func setupSubscribers() {
        let publisher = block.didChangeInformationPublisher().map({ value -> BlockContent.Divider? in
            switch value.content {
            case let .divider(value): return value
            default: return nil
            }
        }).safelyUnwrapOptionals().eraseToAnyPublisher()
        self.subscription = publisher.sink(receiveValue: { [weak self] (value) in
            let style = DividerBlockUIKitViewStateConverter.asOurModel(value.style)
            let state = style.flatMap(DividerBlockUIKitViewState.init)
            self?.statePublished = state
        })
    }
    
    override var diffable: AnyHashable {
        let diffable = super.diffable
        if case let .divider(value) = block.content {
            let newDiffable: [String: AnyHashable] = [
                "parent": diffable,
                "dividerValue": value.style
            ]
            return .init(newDiffable)
        }
        return diffable
    }
    
    // MARK: Contextual Menu
    override func makeContextualMenu() -> BlocksViews.ContextualMenu {
        .init(title: "", children: [
            .create(action: .general(.addBlockBelow)),
            .create(action: .general(.delete)),
            .create(action: .general(.duplicate))
        ])
    }
    
    override func handle(contextualMenuAction: BlocksViews.ContextualMenu.MenuAction.Action) {
        switch contextualMenuAction {
        case .specific(.turnInto):
            let input: FilteringPayload = .other([.lineDivider, .dotsDivider])
            self.send(userAction: .turnIntoBlock(.init(output: self.toolbarActionSubject, input: input)))
        default: super.handle(contextualMenuAction: contextualMenuAction)
        }
    }

}
