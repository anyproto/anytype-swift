import SwiftUI
import AnytypeCore
import BlocksModels

extension HomeViewModel {
    func onSubscriptionUpdate(id: SubscriptionId, _ update: SubscriptionUpdate) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            withAnimation(self.animationsEnabled ? .spring() : nil) {
                self.updateCollections(id: id, update)
            }
        }
    }
    
    private func updateCollections(id: SubscriptionId, _ update: SubscriptionUpdate) {
        withAnimation(animationsEnabled ? .spring() : nil) {
            switch update {
            case .initialData(let data):
                switch id {
                case .history:
                    historyCellData = cellDataBuilder.buildCellData(data)
                case .archive:
                    binCellData = cellDataBuilder.buildCellData(data)
                case .shared:
                    sharedCellData = cellDataBuilder.buildCellData(data)
                case .sets:
                    setsCellData = cellDataBuilder.buildCellData(data)
                }
                
            case .update(let data):
                let newData = cellDataBuilder.buildCellData(data)
                guard let index = indexInCollection(id: id, blockId: newData.id, assert: false) else { return }
                switch id {
                case .history:
                    historyCellData[index] = newData
                case .archive:
                    binCellData[index] = newData
                case .shared:
                    sharedCellData[index] = newData
                case .sets:
                    setsCellData[index] = newData
                }
                
            case .remove(let blockId):
                guard let index = indexInCollection(id: id, blockId: blockId) else { return }
                switch id {
                case .history:
                    historyCellData.remove(at: index)
                case .archive:
                    binCellData.remove(at: index)
                case .shared:
                    sharedCellData.remove(at: index)
                case .sets:
                    setsCellData.remove(at: index)
                }
                
            case let .add(details, afterId):
                guard let index = indexInCollection(id: id, afterId: afterId) else { return }
                let newData = cellDataBuilder.buildCellData(details)
                
                switch id {
                case .history:
                    historyCellData.insert(newData, at: index)
                case .archive:
                    binCellData.insert(newData, at: index)
                case .shared:
                    sharedCellData.insert(newData, at: index)
                case .sets:
                    setsCellData.insert(newData, at: index)
                }
                
            case let .move(from, after):
                guard let index = indexInCollection(id: id, blockId: from) else { break }
                guard let insertIndex = indexInCollection(id: id, afterId: after) else { break }
                
                switch id {
                case .history:
                    historyCellData.moveElement(from: index, to: insertIndex)
                case .archive:
                    binCellData.moveElement(from: index, to: insertIndex)
                case .shared:
                    sharedCellData.moveElement(from: index, to: insertIndex)
                case .sets:
                    setsCellData.moveElement(from: index, to: insertIndex)
                }
            }
        }
    }
    
    private func indexInCollection(id: SubscriptionId, afterId: BlockId?) -> Int? {
        guard let afterId = afterId else { return 0 }
        guard let index = indexInCollection(id: id, blockId: afterId) else { return nil }
        
        return index + 1
    }

    private func indexInCollection(id: SubscriptionId, blockId: BlockId, assert: Bool = true) -> Int? {
        switch id {
        case .history:
            guard let index = historyCellData.firstIndex(where: { $0.id == blockId }) else {
                if assert {
                    anytypeAssertionFailure("No history cell found for blockId: \(blockId)", domain: .homeView)
                }
                return nil
            }
            
            return index
        case .archive:
            guard let index = binCellData.firstIndex(where: { $0.id == blockId }) else {
                if assert {
                    anytypeAssertionFailure("No bin cell found for blockId: \(blockId)", domain: .homeView)
                }
                return nil
            }
            return index
        case .shared:
            guard let index = sharedCellData.firstIndex(where: { $0.id == blockId }) else {
                if assert {
                    anytypeAssertionFailure("No shared cell found for blockId: \(blockId)", domain: .homeView)
                }
                return nil
            }
            return index
        case .sets:
            guard let index = setsCellData.firstIndex(where: { $0.id == blockId }) else {
                if assert {
                    anytypeAssertionFailure("No sets cell found for blockId: \(blockId)", domain: .homeView)
                }
                return nil
            }
            return index
        }
    }
}
