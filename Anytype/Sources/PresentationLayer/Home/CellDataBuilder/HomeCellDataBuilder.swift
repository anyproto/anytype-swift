import Combine
import BlocksModels
import AnytypeCore
import SwiftUI

final class HomeCellDataBuilder {
    private let document: BaseDocumentProtocol
    init(document: BaseDocumentProtocol) {
        self.document = document
    }
    
    func buildCellData(_ details: [ObjectDetails]) -> [HomeCellData] {
        details.map { buildCellData($0) }
    }
    
    func buildCellData(_ detail: ObjectDetails) -> HomeCellData {
        HomeCellData.create(details: detail)
    }
    
    func buildFavoritesData() -> [HomeCellData] {
        let links: [HomePageLink] = document.flattenBlocks.compactMap(blockToPageLink)
        
        return links
            .filter {
                guard let details = $0.details, !$0.isLoading else {
                    return true
                }
                
                return ObjectTypeProvider.isSupported(typeUrl: details.type)

            }
            .map { buildHomeCellData(pageLink: $0) }
    }
    
    private func blockToPageLink(_ blockModel: BlockModelProtocol) -> HomePageLink? {
        guard case .link(let link) = blockModel.information.content else {
            anytypeAssertionFailure(
                "Not link type in home screen dashboard: \(blockModel.information.content)",
                domain: .homeView
            )
            return nil
        }
        
        let details = ObjectDetailsStorage.shared.get(id: link.targetBlockID)
        return HomePageLink(
            blockId: blockModel.information.id,
            targetBlockId: link.targetBlockID,
            details: details
        )
    }
    
    private func buildHomeCellData(pageLink: HomePageLink) -> HomeCellData {
        let type = ObjectTypeProvider.objectType(url: pageLink.details?.type)?.name ?? "Object".localized
        
        return HomeCellData(
            id: pageLink.blockId,
            destinationId: pageLink.targetBlockId,
            icon: pageLink.details?.icon,
            title: pageLink.details?.pageCellTitle ?? .default(title: ""),
            type: type,
            isLoading: pageLink.isLoading,
            isArchived: pageLink.isArchived,
            isDeleted: pageLink.isDeleted,
            viewType: pageLink.details?.editorViewType ?? .page
        )
    }
    
    func updatedCellData(newDetails: ObjectDetails, oldData: HomeCellData) -> HomeCellData {
        return HomeCellData(
            id: oldData.id,
            destinationId: oldData.destinationId,
            icon: newDetails.icon,
            title: newDetails.pageCellTitle,
            type: oldData.type,
            isLoading: false,
            isArchived: newDetails.isArchived,
            isDeleted: newDetails.isDeleted,
            viewType: newDetails.editorViewType
        )
    }
}
