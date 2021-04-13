import Foundation
import SwiftUI
import Combine
import os
import BlocksModels
import MobileCoreServices


class DividerBlockViewModel: BlocksViews.Base.ViewModel {
    private var subscription: AnyCancellable?
    @Published private var statePublished: DividerBlockUIKitView.State?
    private var publisher: AnyPublisher<BlockContent.Divider, Never> = .empty()
    
    override var availableTurnIntoTypes: [BlocksViews.Toolbar.BlocksTypes] {
        [.other(.lineDivider), .other(.dotsDivider)]
    }
    
    override func makeUIView() -> UIView {
        DividerBlockUIKitView().configured(publisher: self.$statePublished.eraseToAnyPublisher())
    }
    
    override func makeContentConfiguration() -> UIContentConfiguration {
        var configuration = DividerBlockContentConfiguration(self.getBlock().blockModel.information)
        configuration.contextMenuHolder = self
        return configuration
    }
    
    // MARK: Subclassing
    override init(_ block: BlockModel) {
        super.init(block)
        self.setup()
    }
    
    // MARK: Subclassing / Events
    private func setup() {
        self.setupSubscribers()
    }
    
    func setupSubscribers() {
        let publisher = self.getBlock().didChangeInformationPublisher().map({ value -> BlockContent.Divider? in
            switch value.content {
            case let .divider(value): return value
            default: return nil
            }
        }).safelyUnwrapOptionals().eraseToAnyPublisher()
        self.subscription = publisher.sink(receiveValue: { [weak self] (value) in
            let style = DividerBlockUIKitView.StateConverter.asOurModel(value.style)
            let state = style.flatMap(DividerBlockUIKitView.State.init)
            self?.statePublished = state
        })
    }
    
    override func makeDiffable() -> AnyHashable {
        let diffable = super.makeDiffable()
        if case let .divider(value) = self.getBlock().blockModel.information.content {
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
            .create(action: .general(.duplicate)),
            .create(action: .specific(.turnInto)),
            .create(action: .general(.moveTo)),
        ])
    }
    
    override func handle(contextualMenuAction: BlocksViews.ContextualMenu.MenuAction.Action) {
        switch contextualMenuAction {
        case .specific(.turnInto):
            let input: BlocksViews.UserAction.ToolbarOpenAction.TurnIntoBlock.Input = .init(payload: .init(filtering: .other([.lineDivider, .dotsDivider])))
            self.send(userAction: .toolbars(.turnIntoBlock(.init(output: self.toolbarActionSubject, input: input))))
        default: super.handle(contextualMenuAction: contextualMenuAction)
        }
    }

}
