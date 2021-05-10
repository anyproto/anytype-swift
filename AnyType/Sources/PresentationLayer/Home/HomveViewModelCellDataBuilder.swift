import Combine
import BlocksModels

// TODO: Use single subscriptions for all changes instead of per cell approach
extension HomeViewModel {
    
    func buildCellData(pageLinkViewModel: BlockPageLinkViewModel) -> PageCellData {
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
    
    func onDashboardUpdate(_ updateResult: DocumentViewModelUpdateResult) {
        switch updateResult.updates {
        case .general:
            let viewModels = updateResult.models.compactMap { $0 as? BlockPageLinkViewModel }
            cellData = viewModels.map { buildCellData(pageLinkViewModel: $0) }
        case let .update(update):
            insertBlocks(update.addedIds, models: updateResult.models)
            handleMoves(moves: update.movedIds)
            removeBlocks(update.deletedIds)
        }
    }
    
    private func removeBlocks(_ removals: Set<BlockId>) {
        if !removals.isEmpty {
            cellData = cellData.filter { !removals.contains($0.id) }
        }
    }
    
    private func insertBlocks(_ insertions: [EventHandlerUpdateChange], models: [BaseBlockViewModel]) {
        insertions.forEach { insertChange in
            let insertBlockId = insertChange.targetBlockId
            let blockIdAfterWhichToInsert = insertChange.afterBlockId
            guard let blockToAdd = models.first(where: { $0.blockId == insertBlockId }) as? BlockPageLinkViewModel,
                  let afterBlockIndex = cellData.firstIndex(where: { $0.id == blockIdAfterWhichToInsert }) else {
                return
            }
            let data = buildCellData(pageLinkViewModel: blockToAdd)
            // Because we insert block after specified block we should +1
            cellData.insert(data, at: afterBlockIndex + 1)
        }
    }
    
    private func handleMoves(moves: Set<EventHandlerUpdateChange>) {
        moves.forEach { move in
            let targetId = move.targetBlockId
            let moveAfterBlockId = move.afterBlockId
            guard let movedBlockIndex = cellData.firstIndex(where: { $0.id == targetId }),
                  let afterBlockIndex = cellData.firstIndex(where: {$0.id == moveAfterBlockId}) else {
                return
            }
            // Because we move block after specified block we should +1
            cellData.move(fromOffsets: IndexSet([movedBlockIndex]), toOffset: afterBlockIndex + 1)
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
