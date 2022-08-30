import Combine
import BlocksModels
import UIKit
import AnytypeCore

// https://www.figma.com/file/3lljgCRXYLiUeefJSxN1aC/Components?node-id=106%3A745
struct BlockBookmarkViewModel: BlockViewModelProtocol {    
    var hashable: AnyHashable { [ info, objectDetails ] as [AnyHashable] }
    
    let info: BlockInformation
    let bookmarkData: BlockBookmark
    let objectDetails: ObjectDetails?
    
    let showBookmarkBar: (BlockInformation) -> ()
    let openUrl: (URL) -> ()
    
    func makeContentConfiguration(maxWidth _: CGFloat) -> UIContentConfiguration {
        let backgroundColor = info.backgroundColor.map(UIColor.Background.uiColor(from:)) ?? nil

        let payload = BlockBookmarkPayload(bookmarkData: bookmarkData, objectDetails: objectDetails)

        if FeatureFlags.bookmarksFlowP2 {
            switch bookmarkData.state {
            case .empty:
                return emptyViewConfiguration(state: .default)
            case .fetching:
                return emptyViewConfiguration(state: .uploading)
            case .done:
                return BlockBookmarkConfiguration(
                    payload: payload,
                    backgroundColor: backgroundColor
                )
                    .cellBlockConfiguration(
                    indentationSettings: .init(with: info.configurationData),
                    dragConfiguration: .init(id: info.id)
                )
            case .error:
                return emptyViewConfiguration(state: .error)
            }
        } else {
            switch bookmarkData.state {
            case .empty, .fetching, .error:
                return emptyViewConfiguration(state: .default)
            case .done:
                return BlockBookmarkConfiguration(
                    payload: payload,
                    backgroundColor: backgroundColor
                )
                    .cellBlockConfiguration(
                    indentationSettings: .init(with: info.configurationData),
                    dragConfiguration: .init(id: info.id)
                )
            }
        }
    }
    
    func didSelectRowInTableView(editorEditingState: EditorEditingState) {
        
        switch bookmarkData.state {
        case .empty, .error:
            guard let url = URL(string: bookmarkData.url) else { return }
            openUrl(url)
        case .fetching:
            break
        case .done:
            guard case .editing = editorEditingState else { return }
            showBookmarkBar(info)
        }
    }
    
    private func emptyViewConfiguration(state: BlocksFileEmptyViewState) -> UIContentConfiguration {
        BlocksFileEmptyViewConfiguration(
            imageAsset: .TextEditor.BlockFile.Empty.bookmark,
            text: Loc.addAWebBookmark,
            state: state
        ).cellBlockConfiguration(
                indentationSettings: .init(with: info.configurationData),
                dragConfiguration: .init(id: info.id)
            )
    }
}
