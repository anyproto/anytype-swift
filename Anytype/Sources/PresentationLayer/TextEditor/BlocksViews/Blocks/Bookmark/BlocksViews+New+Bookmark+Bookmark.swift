import Foundation
import SwiftUI
import Combine
import os
import BlocksModels
import MobileCoreServices

// TODO: Rethink.
// Maybe we should use SwiftUI which will be embedded in UIKit.
// In this case we will receive simple updates of all views.

// MARK: ViewModel
final class BookmarkViewModel: BaseBlockViewModel {
    
    @Published private var resourcePublished: Resource?
    
    let imagesPublished = Resource.ImageLoader()
    private let service = BlockActionsServiceBookmark()
    
    private var publisher: AnyPublisher<BlockContent.Bookmark, Never> = .empty()
       
    private var subscription: AnyCancellable?
    private var toolbarSubscription: AnyCancellable?
    
    // MARK: - Initializers
    
    override init(_ block: BlockActiveRecordModelProtocol, delegate: BaseBlockDelegate?) {
        super.init(block, delegate: delegate)
        self.setup()
    }
    
    // MARK: - Overrided functions
    
    override func makeContentConfiguration() -> UIContentConfiguration {
        var configuration = ContentConfiguration.init(block.blockModel.information)
        configuration.contextMenuHolder = self
        return configuration
    }
    
    override func didSelectRowInTableView() {
        // we should show image picker only for empty state
        // TODO: Need to think about error state, reload or something
        
        // Think what we should check...
        // Empty URL?
        if case let .bookmark(value) = block.content, !value.url.isEmpty {
            assertionFailure("User pressed on BookmarkBlocksViews when our state is not empty. Our URL is not empty")
            return
        }
                        
        send(userAction: .bookmark(toolbarActionSubject))
    }
    
    override func handle(toolbarAction: BlockToolbarAction) {
        switch toolbarAction {
        case let .bookmark(.fetch(value)):
            self.update { (block) in
                switch block.content {
                case let .bookmark(bookmark):
                    var bookmark = bookmark
                    bookmark.url = value.absoluteString
                    
                    var blockModel = block.blockModel
                    blockModel.information.content = .bookmark(bookmark)
                default: return
                }
            }
        default: return
        }
    }
    
    override var diffable: AnyHashable {
        let diffable = super.diffable
        if case let .bookmark(value) = block.content {
            let newDiffable: [String: AnyHashable] = [
                "parent": diffable,
                "bookmark": ["url": value.url, "title": value.title]
            ]
            return .init(newDiffable)
        }
        return diffable
    }

    override func makeContextualMenu() -> BlocksViews.ContextualMenu {
        .init(title: "", children: [
            .create(action: .general(.addBlockBelow)),
            .create(action: .general(.delete)),
            .create(action: .general(.duplicate)),
        ])
    }
    
    private func setup() {
        self.setupSubscribers()
    }
    
    func setupSubscribers() {
//            self.toolbarSubscription = self.toolbarActionSubject.sink { [weak self] (value) in
//                self?.handle(toolbarAction: value)
//            }
        self.publisher = block.didChangeInformationPublisher().map({ value -> BlockContent.Bookmark? in
            switch value.content {
            case let .bookmark(value): return value
            default: return nil
            }
        }).safelyUnwrapOptionals().eraseToAnyPublisher()
        
        /// Also embed image data to state.
        self.subscription = self.publisher.sink(receiveValue: { [weak self] (value) in
            let resource = ResourceConverter.asOurModel(value)
            self?.resourcePublished = resource
            self?.setupImages(resource)
        })
    }
    
    // MARK: Images
    func setupImages(_ resource: Resource?) {
        switch resource?.state {
        case let .fetched(payload):
            switch (payload.hasImage(), payload.hasIcon()) {
            case (false, false): self.imagesPublished.resetImages()
            default:
                if payload.hasImage() {
                    self.imagesPublished.subscribeImage(payload.image)
                }
                if payload.hasIcon() {
                    /// create publisher that uploads image
                    self.imagesPublished.subscribeIcon(payload.icon)
                }
            }
        default: return
        }
    }
    
}
