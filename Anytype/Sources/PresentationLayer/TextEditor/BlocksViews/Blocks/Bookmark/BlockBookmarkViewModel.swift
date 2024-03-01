import Combine
import Services
import UIKit
import AnytypeCore

// https://www.figma.com/file/3lljgCRXYLiUeefJSxN1aC/Components?node-id=106%3A745
final class BlockBookmarkViewModel: BlockViewModelProtocol {
    var hashable: AnyHashable { info.id }
    
    var info: BlockInformation { infoProvider.info }
    
    var bookmarkData: BlockBookmark {
        guard case let .bookmark(data) = info.content else {
            anytypeAssertionFailure("BookmarkViewModel's blockInformation has wrong content type")
            return .empty()
        }
        
        return data
    }
    
    private let editorCollectionController: EditorCollectionReloadable
    private var objectDetailsProvider: ObjectDetailsInfomationProvider?
    private let infoProvider: BlockModelInfomationProvider
    private let detailsStorage: ObjectDetailsStorage
    private let showBookmarkBar: (BlockInformation) -> ()
    private let openUrl: (AnytypeURL) -> ()
    
    private var subscriptions = [AnyCancellable]()
    
    init(
        editorCollectionController: EditorCollectionReloadable,
        infoProvider: BlockModelInfomationProvider,
        detailsStorage: ObjectDetailsStorage,
        showBookmarkBar: @escaping (BlockInformation) -> (),
        openUrl: @escaping (AnytypeURL) -> ()
    ) {
        self.editorCollectionController = editorCollectionController
        self.infoProvider = infoProvider
        self.detailsStorage = detailsStorage
        self.showBookmarkBar = showBookmarkBar
        self.openUrl = openUrl
    }
    
    private func setupSubscription() {
        objectDetailsProvider?
            .$details
            .receiveOnMain()
            .sink { [weak editorCollectionController, weak self] _ in
                guard let self else { return }
                editorCollectionController?.reconfigure(items: [.block(self)])
        }.store(in: &subscriptions)
    }
    
    func makeContentConfiguration(maxWidth width: CGFloat) -> UIContentConfiguration {
        setupSubscriptionIfNeeded()
        
        switch bookmarkData.state {
        case .empty:
            return emptyViewConfiguration(text: Loc.Content.Bookmark.add, state: .default)
        case .fetching:
            return emptyViewConfiguration(text: Loc.Content.Bookmark.loading, state: .uploading)
        case .done:
            guard let objectDetails = objectDetailsProvider?.details else {
                anytypeAssertionFailure("Coudn't find object details for bookmark")
                return UnsupportedBlockViewModel(info: info).makeContentConfiguration(maxWidth: width)
            }

            let backgroundColor = info.backgroundColor.map(UIColor.VeryLight.uiColor(from:)) ?? nil
            let payload = BlockBookmarkPayload(bookmarkData: bookmarkData, objectDetails: objectDetails)
            
            return BlockBookmarkConfiguration(
                payload: payload,
                backgroundColor: backgroundColor
            ).cellBlockConfiguration(
                dragConfiguration: .init(id: info.id),
                styleConfiguration: .init(backgroundColor: info.backgroundColor?.backgroundColor.color)
            )
        case .error:
            return emptyViewConfiguration(text: Loc.Content.Common.error, state: .error)
        }
    }
    
    func didSelectRowInTableView(editorEditingState: EditorEditingState) {
        
        switch bookmarkData.state {
        case .empty, .error:
            guard case .editing = editorEditingState else { return }
            showBookmarkBar(info)
        case .fetching:
            break
        case .done:
            guard let objectDetails = objectDetailsProvider?.details else {
                return
            }
            let payload = BlockBookmarkPayload(bookmarkData: bookmarkData, objectDetails: objectDetails)
            guard let url = payload.source else { return }
            openUrl(url)
        }
    }
    
    private func emptyViewConfiguration(text: String, state: BlocksFileEmptyViewState) -> UIContentConfiguration {
        BlocksFileEmptyViewConfiguration(
            imageAsset: .X32.bookmark,
            text: text,
            state: state
        ).cellBlockConfiguration(
            dragConfiguration: .init(id: info.id),
            styleConfiguration: .init(backgroundColor: info.backgroundColor?.backgroundColor.color)
        )
    }
    
    private func setupSubscriptionIfNeeded() {
        guard objectDetailsProvider.isNil, bookmarkData.targetObjectID.isNotEmpty else {
            return
        }
        objectDetailsProvider = ObjectDetailsInfomationProvider(
            detailsStorage: detailsStorage,
            targetObjectId: bookmarkData.targetObjectID,
            details: detailsStorage.get(id: bookmarkData.targetObjectID)
        )
        setupSubscription()
    }
}

private extension BlockInformation {
    var bookmarkContent: BlockBookmark {
        guard case let .bookmark(dataView) = content else {
            return .empty()
        }
        
        return dataView
    }
}
