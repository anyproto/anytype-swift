import Combine
import BlocksModels
import AnytypeCore

import SwiftUI
final class HomeCellDataBuilder {
    private let document: BaseDocumentProtocol
    init(document: BaseDocumentProtocol) {
        self.document = document
    }
    
    func buldCellData(_ searchResults: [SearchResult]) -> [HomeCellData] {
        searchResults.map { HomeCellData.create(searchResult: $0) }
    }
    
    func buldFavoritesData(_ updateResult: BaseDocumentUpdateResult) -> [HomeCellData] {
        let links: [HomePageLink] = updateResult.models.compactMap(blockToPageLink)
        
        return links
            .filter {
                guard let details = $0.details else {
                    return true
                }
                
                guard let typeUrl = details.typeUrl else {
                    anytypeAssertionFailure("No type url for dashboard link")
                    return false
                }
                
                return ObjectTypeProvider.supportedTypeUrls.contains(typeUrl)

            }
            .map { buildHomeCellData(pageLink: $0) }
    }
    
    private func blockToPageLink(_ blockModel: BlockModelProtocol) -> HomePageLink? {
        guard case .link(let link) = blockModel.information.content else { return nil }

        let details = document.getDetails(by: link.targetBlockID)?.currentDetails
        return HomePageLink(
            blockId: blockModel.information.id,
            targetBlockId: link.targetBlockID,
            details: details
        )
    }
    
    private func buildHomeCellData(pageLink: HomePageLink) -> HomeCellData {
        let type = pageLink.details?.typeUrl.flatMap {
            ObjectTypeProvider.objectType(url: $0)?.name
        } ?? "Object".localized
        
        return HomeCellData(
            id: pageLink.blockId,
            destinationId: pageLink.targetBlockId,
            icon: pageLink.details?.icon,
            title: pageLink.details?.pageCellTitle ?? .default(title: ""),
            type: type,
            isLoading: pageLink.isLoading,
            isArchived: pageLink.isArchived
        )
    }
    
    func updatedCellData(newDetails: DetailsData, oldData: HomeCellData) -> HomeCellData {
        return HomeCellData(
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
