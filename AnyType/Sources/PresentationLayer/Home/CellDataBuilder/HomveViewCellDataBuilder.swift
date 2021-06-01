import Combine
import BlocksModels

import SwiftUI
final class HomveViewCellDataBuilder {
    private let converter: CompoundViewModelConverter
    init(document: BaseDocumentProtocol) {
        converter = CompoundViewModelConverter(document: document)
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
    
    func buldCellData(_ updateResult: BaseDocumentUpdateResult) -> [PageCellData] {
        let blockViewModels = converter.convert(updateResult.models, router: nil)
        let viewModels = blockViewModels.compactMap { $0 as? BlockPageLinkViewModel }
        return viewModels.map { buildPageCellData(pageLinkViewModel: $0) }
    }
    
    private func buildPageCellData(pageLinkViewModel: BlockPageLinkViewModel) -> PageCellData {
        let details = pageLinkViewModel.getDetailsViewModel().currentDetails
        let isLoadings = details.parentId == nil
            
        return PageCellData(
            id: pageLinkViewModel.blockId,
            destinationId: pageLinkViewModel.targetBlockId,
            icon: details.documentIcon,
            title: details.name ?? "",
            type: "Page",
            isLoading: isLoadings
        )
    }
}
