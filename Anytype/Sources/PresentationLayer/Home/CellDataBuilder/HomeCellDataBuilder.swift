import Combine
import BlocksModels
import AnytypeCore

import SwiftUI
final class HomeCellDataBuilder {
    private let document: BaseDocumentProtocol
    init(document: BaseDocumentProtocol) {
        self.document = document
    }
    
    func buildCellData(_ searchResults: [DetailsDataProtocol]) -> [HomeCellData] {
        searchResults.map { HomeCellData.create(searchResult: $0) }
    }
    
    func buildFavoritesData(_ updateResult: BaseDocumentUpdateResult) -> [HomeCellData] {
        let links: [HomePageLink] = updateResult.models.compactMap(blockToPageLink)
        
        return links
            .filter {
                guard let details = $0.details, !$0.isLoading else {
                    return true
                }
                
                return ObjectTypeProvider.isSupported(typeUrl: details.typeUrl)

            }
            .map { buildHomeCellData(pageLink: $0) }
    }
    
    private func blockToPageLink(_ blockModel: BlockModelProtocol) -> HomePageLink? {
        guard case .link(let link) = blockModel.information.content else { return nil }

        let details = document.getDetails(id: link.targetBlockID)?.currentDetails
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
    
    func updatedCellData(newDetails: DetailsDataProtocol, oldData: HomeCellData) -> HomeCellData {
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
