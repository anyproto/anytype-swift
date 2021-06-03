import Combine
import BlocksModels

import SwiftUI
final class HomeCellDataBuilder {
    private let document: BaseDocumentProtocol
    init(document: BaseDocumentProtocol) {
        self.document = document
    }
    
    func buldCellData(_ updateResult: BaseDocumentUpdateResult) -> [PageCellData] {
        let links: [HomePageLink] = updateResult.models.compactMap(activeRecordToPageLink)
        
        return links
            .filter { $0.type == .page }
            .map { buildPageCellData(pageLink: $0) }
    }
    
    private func activeRecordToPageLink(_ activeRecord: BlockActiveRecordModelProtocol) -> HomePageLink? {
        guard case .link(let link) = activeRecord.content else { return nil }

        let details = document.getDetails(by: link.targetBlockID)?.currentDetails
        return HomePageLink(
            blockId: activeRecord.blockId,
            targetBlockId: link.targetBlockID,
            details: details,
            type: link.style
        )
    }
    
    private func buildPageCellData(pageLink: HomePageLink) -> PageCellData {
        return PageCellData(
            id: pageLink.blockId,
            destinationId: pageLink.targetBlockId,
            icon: pageLink.details?.documentIcon,
            title: pageLink.details?.name ?? "",
            type: pageLink.type.rawValue,
            isLoading: pageLink.isLoading,
            isArchived: pageLink.details?.isArchived ?? false
        )
    }
    
    func updatedCellData(newDetails: DetailsData, oldData: PageCellData) -> PageCellData {
        return PageCellData(
            id: oldData.id,
            destinationId: oldData.destinationId,
            icon: newDetails.documentIcon,
            title: newDetails.name ?? "",
            type: oldData.type,
            isLoading: false,
            isArchived: newDetails.isArchived ?? false
        )
    }
}
