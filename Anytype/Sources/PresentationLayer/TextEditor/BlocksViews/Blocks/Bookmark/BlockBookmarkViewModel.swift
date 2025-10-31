import Combine
import Services
import UIKit
import AnytypeCore

// https://www.figma.com/file/3lljgCRXYLiUeefJSxN1aC/Components?node-id=106%3A745
@MainActor
final class BlockBookmarkViewModel: BlockViewModelProtocol {
    
    let className = "BlockBookmarkViewModel"
    nonisolated var info: BlockInformation { infoProvider.info }
    
    var bookmarkData: BlockBookmark {
        guard case let .bookmark(data) = info.content else {
            anytypeAssertionFailure("BookmarkViewModel's blockInformation has wrong content type")
            return .empty()
        }
        
        return data
    }
    
    private let editorCollectionController: any EditorCollectionReloadable
    private let infoProvider: BlockModelInfomationProvider
    private let document: any BaseDocumentProtocol
    private let showBookmarkBar: (BlockInformation) -> ()
    private let openUrl: (AnytypeURL) -> ()
    
    private var subscriptions = [AnyCancellable]()
    private var targetDetails: ObjectDetails?
    
    init(
        editorCollectionController: some EditorCollectionReloadable,
        infoProvider: BlockModelInfomationProvider,
        document: some BaseDocumentProtocol,
        showBookmarkBar: @escaping (BlockInformation) -> (),
        openUrl: @escaping (AnytypeURL) -> ()
    ) {
        self.editorCollectionController = editorCollectionController
        self.infoProvider = infoProvider
        self.document = document
        self.showBookmarkBar = showBookmarkBar
        self.openUrl = openUrl
    }
    
    private func setupSubscription() {
        document.subscribeForDetails(objectId: bookmarkData.targetObjectID)
            .receiveOnMain()
            .sink { [weak editorCollectionController, weak self] details in
                guard let self else { return }
                self.targetDetails = details
                editorCollectionController?.reconfigure(items: [.block(self)])
        }.store(in: &subscriptions)
    }
    
    func makeContentConfiguration(maxWidth width: CGFloat) -> any UIContentConfiguration {
        setupSubscriptionIfNeeded()
        
        switch bookmarkData.state {
        case .empty:
            return emptyViewConfiguration(text: Loc.Content.Bookmark.add, state: .default)
        case .fetching:
            return emptyViewConfiguration(text: Loc.Content.Bookmark.loading, state: .uploading)
        case .done:
            guard let objectDetails = targetDetails else {
                // TODO: Rollback
//                anytypeAssertionFailure("Coudn't find object details for bookmark")
                return UnsupportedBlockViewModel(info: info).makeContentConfiguration(maxWidth: width)
            }

            let backgroundColor = info.backgroundColor.map(UIColor.VeryLight.uiColor(from:)) ?? nil
            let payload = BlockBookmarkPayload(bookmarkData: bookmarkData, objectDetails: objectDetails)
            
            return BlockBookmarkConfiguration(
                payload: payload,
                backgroundColor: backgroundColor
            ).cellBlockConfiguration(
                dragConfiguration: .init(id: info.id),
                styleConfiguration: CellStyleConfiguration(backgroundColor: info.backgroundColor?.backgroundColor.color)
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
            guard let objectDetails = targetDetails else {
                return
            }
            let payload = BlockBookmarkPayload(bookmarkData: bookmarkData, objectDetails: objectDetails)
            guard let url = payload.source else { return }
            openUrl(url)
        }
    }
    
    private func emptyViewConfiguration(text: String, state: BlocksFileEmptyViewState) -> any UIContentConfiguration {
        BlocksFileEmptyViewConfiguration(
            imageAsset: .X32.bookmark,
            text: text,
            state: state
        ).cellBlockConfiguration(
            dragConfiguration: .init(id: info.id),
            styleConfiguration: CellStyleConfiguration(backgroundColor: info.backgroundColor?.backgroundColor.color)
        )
    }
    
    private func setupSubscriptionIfNeeded() {
        guard subscriptions.isEmpty, bookmarkData.targetObjectID.isNotEmpty else {
            return
        }
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
