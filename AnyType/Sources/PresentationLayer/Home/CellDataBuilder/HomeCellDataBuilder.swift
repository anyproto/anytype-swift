import Combine
import BlocksModels

import SwiftUI
final class HomeCellDataBuilder {
    private let document: BaseDocumentProtocol
    init(document: BaseDocumentProtocol) {
        self.document = document
    }
    
    func buldCellData(_ updateResult: BaseDocumentUpdateResult) -> [PageCellData] {
        let links: [HomePageLink] = updateResult.models.compactMap { activeRecord in
            switch activeRecord.content {
            case .link(let link):
                let details = document.getDetails(by: link.targetBlockID)?.currentDetails
                return HomePageLink(
                    blockId: activeRecord.blockId,
                    targetBlockId: link.targetBlockID,
                    details: details,
                    type: link.style
                )
            default:
                return nil
            }
        }
        
        return links.filter{ $0.type == .page }.map { buildPageCellData(pageLink: $0) }
    }
    
    private func buildPageCellData(pageLink: HomePageLink) -> PageCellData {
        return PageCellData(
            id: pageLink.blockId,
            destinationId: pageLink.targetBlockId,
            icon: pageLink.details?.documentIcon,
            title: pageLink.details?.name ?? "",
            type: pageLink.type.rawValue,
            isLoading: pageLink.isLoading
        )
    }
    
    func updatedCellData(newDetails: DetailsProviderProtocol, oldData: PageCellData) -> PageCellData {
        return PageCellData(
            id: oldData.id,
            destinationId: oldData.destinationId,
            icon: newDetails.documentIcon,
            title: newDetails.name ?? "",
            type: oldData.type,
            isLoading: false
        )
    }
}
