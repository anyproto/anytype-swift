import Combine
import BlocksModels
import UIKit

// https://www.figma.com/file/3lljgCRXYLiUeefJSxN1aC/Components?node-id=106%3A745
struct BlockBookmarkViewModel: BlockViewModelProtocol {    
    var hashable: AnyHashable { [ info ] as [AnyHashable] }
    
    let info: BlockInformation
    let bookmarkData: BlockBookmark
    let objectDetails: ObjectDetails?
    
    let showBookmarkBar: (BlockInformation) -> ()
    let openUrl: (URL) -> ()
    
    func makeContentConfiguration(maxWidth _: CGFloat) -> UIContentConfiguration {
        let backgroundColor = info.backgroundColor.map(UIColor.Background.uiColor(from:)) ?? nil

        let state = BlockBookmarkState(bookmarkData: bookmarkData, objectDetails: objectDetails)
        
        switch state {
        case .none:
            return BlocksFileEmptyViewConfiguration(
                imageAsset: .TextEditor.BlockFile.Empty.bookmark,
                text: Loc.addAWebBookmark,
                state: .default
            ).cellBlockConfiguration(
                indentationSettings: .init(with: info.configurationData),
                dragConfiguration: .init(id: info.id)
            )
        case let .fetched(payload):
            return BlockBookmarkConfiguration(
                payload: payload,
                backgroundColor: backgroundColor
            )
                .cellBlockConfiguration(
                indentationSettings: .init(with: info.configurationData),
                dragConfiguration: .init(id: info.id)
            )
        case let .onlyURL(url):
            return BlockBookmarkOnlyUrlConfiguration(ulr: url)
                .cellBlockConfiguration(
                indentationSettings: .init(with: info.configurationData),
                dragConfiguration: .init(id: info.id)
            )
        }
    }
    
    func didSelectRowInTableView(editorEditingState: EditorEditingState) {
        if let url = URL(string: bookmarkData.url) {
            openUrl(url)

            return
        }

        guard case .editing = editorEditingState else { return }

        showBookmarkBar(info)
    }
}
