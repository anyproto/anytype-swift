import Combine
import BlocksModels

import SwiftUI
final class HomeCellDataBuilder {
    private let document: BaseDocumentProtocol
    init(document: BaseDocumentProtocol) {
        self.document = document
    }
    
    func buldCellData(_ searchResults: [SearchResult]) -> [PageCellData] {
        searchResults.map { PageCellData.create(searchResult: $0) }
    }
    
    func buldFavoritesData(_ updateResult: BaseDocumentUpdateResult) -> [PageCellData] {
        let links: [HomePageLink] = updateResult.models.compactMap(blockToPageLink)
        
        return links
            .filter { $0.type == .page }
            .map { buildPageCellData(pageLink: $0) }
    }
    
    private func blockToPageLink(_ blockModel: BlockModelProtocol) -> HomePageLink? {
        guard case .link(let link) = blockModel.information.content else { return nil }

        let details = document.getDetails(by: link.targetBlockID)?.currentDetails
        return HomePageLink(
            blockId: blockModel.information.id,
            targetBlockId: link.targetBlockID,
            details: details,
            type: link.style
        )
    }
    
    private func buildPageCellData(pageLink: HomePageLink) -> PageCellData {
        return PageCellData(
            id: pageLink.blockId,
            destinationId: pageLink.targetBlockId,
            icon: pageLink.details?.icon,
            title: pageLink.details?.pageCellTitle ?? .default(title: ""),
            type: pageLink.type.rawValue,
            isLoading: pageLink.isLoading,
            isArchived: pageLink.details?.isArchived ?? false
        )
    }
    
    func updatedCellData(newDetails: DetailsData, oldData: PageCellData) -> PageCellData {
        return PageCellData(
            id: oldData.id,
            destinationId: oldData.destinationId,
            icon: newDetails.icon,
            title: newDetails.pageCellTitle,
            type: oldData.type,
            isLoading: false,
            isArchived: newDetails.isArchived ?? false
        )
    }
}
