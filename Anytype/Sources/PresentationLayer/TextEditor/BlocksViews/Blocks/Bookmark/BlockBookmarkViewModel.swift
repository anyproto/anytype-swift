import Combine
import BlocksModels
import UIKit

// https://www.figma.com/file/3lljgCRXYLiUeefJSxN1aC/Components?node-id=106%3A745
struct BlockBookmarkViewModel: BlockViewModelProtocol {    
    var hashable: AnyHashable {
        [
            indentationLevel,
            information
        ] as [AnyHashable]
    }
    
    let indentationLevel: Int
    
    let information: BlockInformation
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
            )
        case let .fetched(payload):
            return BlockBookmarkConfiguration(payload: payload)
        case let .onlyURL(url):
            return BlockBookmarkOnlyUrlConfiguration(ulr: url)
        }
    }
    
    func didSelectRowInTableView() {
        guard let url = URL(string: bookmarkData.url) else {
            showBookmarkBar(information)
            return
        }
        
        openUrl(url)
    }
}
