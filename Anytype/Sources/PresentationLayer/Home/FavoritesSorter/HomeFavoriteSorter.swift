import Foundation
import AnytypeCore
import BlocksModels

final class HomeFavoritesSorter {
    
    private let document: BaseDocumentProtocol
    
    init(document: BaseDocumentProtocol) {
        self.document = document
    }
    
    func sort(data: [HomeCellData]) -> [HomeCellData] {
        let links: [String] = document.children.compactMap(blockToTargetPageLink)
        
        return data.sorted { l, r in
            guard let lIndex = links.firstIndex(of: l.id) else {
                anytypeAssertionFailure(
                    "Favorite object not found in links: \(l.id)",
                    domain: .homeView
                )
                return true
            }
            
            guard let rIndex = links.firstIndex(of: r.id) else {
                anytypeAssertionFailure(
                    "Favorite object not found in links: \(r.id)",
                    domain: .homeView
                )
                return false
            }
            
            return lIndex < rIndex
        }
    }
    
    // MARK: - Private
    
    private func blockToTargetPageLink(_ info: BlockInformation) -> String? {
        guard case .link(let link) = info.content else {
            anytypeAssertionFailure(
                "Not link type in home screen dashboard: \(info.content)",
                domain: .homeView
            )
            return nil
        }
        
        return link.targetBlockID
    }
}
