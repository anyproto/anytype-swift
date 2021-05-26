import Combine
import BlocksModels

// TODO: Use single subscriptions for all changes instead of per cell approach
extension HomeViewModel {
    
    func onDashboardUpdate(_ updateResult: DocumentViewModelUpdateResult) {
        switch updateResult.updates {
        case .general:
            let newCellData = buldCellData(updateResult)

            DispatchQueue.main.async { [weak self] in
                self?.cellData = newCellData
            }
            
        case .update(let payload):
            for blockId in payload.updatedIds {
                guard let newDetails = self.document.getDetails(by: blockId)?.currentDetails else {
                    assertionFailure("Could not find object with id: \(blockId)")
                    return
                }
    
                cellData.first { $0.destinationId == blockId }.flatMap { data in
                    var data = data
                    
                    data.title = newDetails.name ?? ""
                    data.icon = newDetails.documentIcon
                    data.isLoading = false

                    cellData.index(id: data.id).flatMap { index in
                        cellData[index] = data
                    }
                }
            }
        }
    }
    
    private func buldCellData(_ updateResult: DocumentViewModelUpdateResult) -> [PageCellData] {
        let viewModels = updateResult.models.compactMap { $0 as? BlockPageLinkViewModel }
        cellSubscriptions = []
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
    
    private func destinationId(_ pageLinkViewModel: BlockPageLinkViewModel) -> String {
        let targetBlockId: String
        if case let .link(link) = pageLinkViewModel.getBlock().blockModel.information.content {
            targetBlockId = link.targetBlockID
        }
        else {
            assertionFailure("No target id for \(pageLinkViewModel)")
            targetBlockId = ""
        }
        return targetBlockId
    }
    
}
