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
    
    let imagesPublished = Resource.ImageLoader()
    
    private let service = BlockActionsServiceBookmark()
    private let router: EditorRouterProtocol?
    
    private var subscription: AnyCancellable?
    
    // MARK: - Initializers
    
    init(
        block: BlockActiveRecordModelProtocol,
        delegate: BaseBlockDelegate?,
        router: EditorRouterProtocol?
        
    ) {
        self.router = router
        super.init(block, delegate: delegate)

        setup()
    }
    
    // MARK: - Overrided functions
    
    override func makeContentConfiguration() -> UIContentConfiguration {
        var configuration = ContentConfiguration.init(block.blockModel.information)
        configuration.contextMenuHolder = self
        return configuration
    }
    
    override func didSelectRowInTableView() {
        guard case let .bookmark(value) = block.content else { return }
        
        if !value.url.isEmpty {
            URL(string: value.url).flatMap {
                router?.openUrl($0)
            }
        } else {
            send(userAction: .bookmark(toolbarActionSubject))
        }
    }
    
    override var diffable: AnyHashable {
        let diffable = super.diffable
        
        guard case let .bookmark(value) = block.content else {
            return diffable
        }
        
        let newDiffable: [String: AnyHashable] = [
            "parent": diffable,
            "bookmark": ["url": value.url, "title": value.title]
        ]
        
        return newDiffable
    }

    override func makeContextualMenu() -> BlocksViews.ContextualMenu {
        BlocksViews.ContextualMenu(
            title: "",
            children: [
                .create(action: .general(.addBlockBelow)),
                .create(action: .general(.delete)),
                .create(action: .general(.duplicate)),
            ]
        )
    }
    
    // MARK: - Private functions
    
    private func setup() {
        self.subscription = block.didChangeInformationPublisher()
            .map { value -> BlockContent.Bookmark? in
                guard case let .bookmark(value) = value.content else {
                    return nil
                }
                
                return value
            }
            .safelyUnwrapOptionals()
            .sink { [weak self] value in
                self?.setupImages(
                    ResourceConverter.asOurModel(value)
                )
            }
    }
    
    private func setupImages(_ resource: Resource?) {
        guard case let .fetched(payload) = resource?.state else {
            return
        }
        
        payload.imageHash.flatMap {
            imagesPublished.subscribeImage($0)
        }
        
        payload.iconHash.flatMap {
            imagesPublished.subscribeIcon($0)
        }
    }
    
}
