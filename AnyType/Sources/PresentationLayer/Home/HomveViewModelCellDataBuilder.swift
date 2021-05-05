import Combine
import BlocksModels

// TODO: Use single subscriptions for all changes instead of per cell approach
extension HomeViewModel {
    func updateCellData(viewModels: [BlockPageLinkViewModel]) {
        self.cellData = viewModels.map { pageLinkViewModel in
            let details = pageLinkViewModel.getDetailsViewModel().currentDetails
            
            pageLinkViewModel.getDetailsViewModel().wholeDetailsPublisher.reciveOnMain().sink { [weak self] details in
                guard let self = self, let index = self.cellData.index(id: pageLinkViewModel.blockId) else {
                    return
                }
                
                var data = self.cellData[index]
                data.title = details.title?.value ?? ""
                data.icon = self.iconData(details)
                
                self.cellData[index] = data
            }.store(in: &cellSubscriptions)
            
            return PageCellData(
                id: pageLinkViewModel.blockId,
                destinationId: destinationId(pageLinkViewModel),
                icon: iconData(details),
                title: details.title?.value ?? "",
                type: "Page"
            )
        }
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
    
    private func iconData(_ details: DetailsInformationProvider) -> PageCellIcon? {
        if let imageId = details.iconImage?.value, !imageId.isEmpty {
            return .imageId(imageId)
        } else if let emoji = details.iconEmoji?.value, !emoji.isEmpty {
            return .emoji(emoji)
        }
        
        return nil
    }
}
