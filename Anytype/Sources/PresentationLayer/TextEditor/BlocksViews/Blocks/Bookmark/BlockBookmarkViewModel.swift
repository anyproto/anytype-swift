import Combine
import Services
import UIKit
import AnytypeCore

// https://www.figma.com/file/3lljgCRXYLiUeefJSxN1aC/Components?node-id=106%3A745
final class BlockBookmarkViewModel: BlockViewModelProtocol {
    var hashable: AnyHashable { info.id }
    
    var info: BlockInformation { infoProvider.info }
    let editorCollectionController: EditorCollectionReloadable
    let objectDetailsProvider: ObjectDetailsInfomationProvider
    let infoProvider: BlockModelInfomationProvider
    var subscriptions = [AnyCancellable]()
    
    let showBookmarkBar: (BlockInformation) -> ()
    let openUrl: (AnytypeURL) -> ()
    
    var bookmarkData: BlockBookmark {
        guard case let .bookmark(data) = info.content else {
            anytypeAssertionFailure("BookmarkViewModel's blockInformation has wrong content type")
            return .empty()
        }
        
        return data
    }
    
    init(
        editorCollectionController: EditorCollectionReloadable,
        objectDetailsProvider: ObjectDetailsInfomationProvider,
        infoProvider: BlockModelInfomationProvider,
        showBookmarkBar: @escaping (BlockInformation) -> (),
        openUrl: @escaping (AnytypeURL) -> ()
    ) {
        self.editorCollectionController = editorCollectionController
        self.objectDetailsProvider = objectDetailsProvider
        self.infoProvider = infoProvider
        self.showBookmarkBar = showBookmarkBar
        self.openUrl = openUrl
        
        setup()
    }
    
    private func setup() {
        objectDetailsProvider
            .$details
            .receiveOnMain()
            .sink { [weak editorCollectionController, weak self] _ in
            guard let self else { return }
            editorCollectionController?.reconfigure(items: [.block(self)])
        }.store(in: &subscriptions)
    }
    
    func makeContentConfiguration(maxWidth width: CGFloat) -> UIContentConfiguration {
        let backgroundColor = info.backgroundColor.map(UIColor.VeryLight.uiColor(from:)) ?? nil
        
        guard let objectDetails = objectDetailsProvider.details else {
            anytypeAssertionFailure("Coudn't find object details for bookmark")
            return UnsupportedBlockViewModel(info: info).makeContentConfiguration(maxWidth: width)
        }

        let payload = BlockBookmarkPayload(bookmarkData: bookmarkData, objectDetails: objectDetails)

        switch bookmarkData.state {
        case .empty:
            return emptyViewConfiguration(text: Loc.Content.Bookmark.add, state: .default)
        case .fetching:
            return emptyViewConfiguration(text: Loc.Content.Bookmark.loading, state: .uploading)
        case .done:
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
            guard let objectDetails = objectDetailsProvider.details else {
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
}

private extension BlockInformation {
    var bookmarkContent: BlockBookmark {
        guard case let .bookmark(dataView) = content else {
            return .empty()
        }
        
        return dataView
    }
}
