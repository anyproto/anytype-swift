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
            ).asCellBlockConfiguration
        case let .fetched(payload):
            return BlockBookmarkConfiguration(payload: payload).asCellBlockConfiguration
        case let .onlyURL(url):
            return BlockBookmarkOnlyUrlConfiguration(ulr: url).asCellBlockConfiguration
        }
    }
    
    func didSelectRowInTableView() {
        guard let url = URL(string: bookmarkData.url) else {
            showBookmarkBar(info)
            return
        }
        
        openUrl(url)
    }
}
