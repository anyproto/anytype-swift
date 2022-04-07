import Combine
import BlocksModels
import UIKit

// https://www.figma.com/file/3lljgCRXYLiUeefJSxN1aC/Components?node-id=106%3A745
struct BlockBookmarkViewModel: BlockViewModelProtocol {    
    var hashable: AnyHashable { [ info ] as [AnyHashable] }
    
    let info: BlockInformation
    let bookmarkData: BlockBookmark
    
    let showBookmarkBar: (BlockInformation) -> ()
    let openUrl: (URL) -> ()
    
    func makeContentConfiguration(maxWidth _: CGFloat) -> UIContentConfiguration {
        switch bookmarkData.blockBookmarkState {
        case .none:
            return BlocksFileEmptyViewConfiguration(
                image: UIImage.blockFile.empty.bookmark,
                text: "Add a web bookmark".localized,
                state: .default
            ).cellBlockConfiguration(
                indentationSettings: .init(with: info.metadata),
                dragConfiguration: .init(id: info.id)
            )
        case let .fetched(payload):
            return BlockBookmarkConfiguration(payload: payload)
                .cellBlockConfiguration(
                indentationSettings: .init(with: info.metadata),
                dragConfiguration: .init(id: info.id)
            )
        case let .onlyURL(url):
            return BlockBookmarkOnlyUrlConfiguration(ulr: url)
                .cellBlockConfiguration(
                indentationSettings: .init(with: info.metadata),
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
