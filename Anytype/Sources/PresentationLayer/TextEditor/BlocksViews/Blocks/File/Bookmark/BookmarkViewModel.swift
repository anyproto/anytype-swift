import Combine
import BlocksModels
import UIKit

final class BookmarkViewModel: BaseBlockViewModel {
    
    let imagesPublished = Resource.ImageLoader()
    private var subscription: AnyCancellable?
    
    init(
        block: BlockActiveRecordProtocol,
        delegate: BlockDelegate?,
        router: EditorRouterProtocol,
        actionHandler: EditorActionHandlerProtocol
    ) {
        super.init(block, delegate: delegate, actionHandler: actionHandler, router: router)

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
                router.openUrl($0)
            }
        } else {
            router.showBookmark(model: block) { [weak self] url in
                guard let self = self else { return }
                self.actionHandler.handleAction(.fetch(url: url), info: self.block.blockModel.information)
            }
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

    override func makeContextualMenu() -> ContextualMenu {
        ContextualMenu(
            title: "",
            children: [
                .init(action: .addBlockBelow),
                .init(action: .delete),
                .init(action: .duplicate),
            ]
        )
    }
    
    // MARK: - Private functions
    
    private func setup() {
        self.subscription = block.didChangeInformationPublisher()
            .map { value -> BlockBookmark? in
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
