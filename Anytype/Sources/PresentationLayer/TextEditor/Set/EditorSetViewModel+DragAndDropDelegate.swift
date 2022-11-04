import SwiftUI

struct KanbanDragAndDropConfiguration {
    let subscriptionId: SubscriptionId
    let configurationId: String?
}

protocol KanbanDragAndDropDelegate {
    func onDrag(from: KanbanDragAndDropConfiguration, to: KanbanDragAndDropConfiguration)
    func onDrop(fromSubId: SubscriptionId, toSubId: SubscriptionId) -> Bool
}

extension EditorSetViewModel: KanbanDragAndDropDelegate {
    func onDrag(from: KanbanDragAndDropConfiguration, to: KanbanDragAndDropConfiguration) {
        guard from.configurationId != to.configurationId else {
            return
        }
        
        if from.subscriptionId.value == to.subscriptionId.value,
           let fromId = from.configurationId, let toId = to.configurationId {
            swipeItemsInTheSameColumn(
                subId: from.subscriptionId,
                fromId: fromId,
                toId: toId
            )
        } else {
            swipeItemsInDifferentColumns(from: from, to: to)
        }
    }
    
    func onDrop(fromSubId: SubscriptionId, toSubId: SubscriptionId) -> Bool {
        if fromSubId.value == toSubId.value, let configurations = configurationsDict[fromSubId] {
            let groupObjectIds = GroupObjectIds(
                groupId: fromSubId.value,
                objectIds: configurations.map { $0.id }
            )
            objectOrderUpdate(with: [groupObjectIds])
        } else if fromSubId.value != toSubId.value,
                  let fromConfigurations = configurationsDict[fromSubId],
                  let toConfigurations = configurationsDict[toSubId]
        {
            let fromGroupObjectIds = GroupObjectIds(
                groupId: fromSubId.value,
                objectIds: fromConfigurations.map { $0.id }
            )
            let toGroupObjectIds = GroupObjectIds(
                groupId: toSubId.value,
                objectIds: toConfigurations.map { $0.id }
            )
            objectOrderUpdate(with: [fromGroupObjectIds, toGroupObjectIds])
        } else {
            return false
        }
        
        return true
    }
    
    private func swipeItemsInTheSameColumn(subId: SubscriptionId, fromId: String, toId: String) {
        guard var configurations = configurationsDict[subId] else {
            return
        }
        guard let fromIndex = configurations.index(id: fromId),
              let toIndex = configurations.index(id: toId) else {
            return
        }
        
        withAnimation(.spring()) {
            let dropAfter = toIndex > fromIndex
            configurations.move(
                fromOffsets: IndexSet(integer: fromIndex),
                toOffset: dropAfter ? toIndex + 1 : toIndex
            )
            configurationsDict[subId] = configurations
        }
    }
    
    private func swipeItemsInDifferentColumns(from: KanbanDragAndDropConfiguration, to: KanbanDragAndDropConfiguration) {
        guard var fromConfigurations = configurationsDict[from.subscriptionId],
              var toConfigurations = configurationsDict[to.subscriptionId],
              let fromConfigurationId = from.configurationId,
              let fromIndex = fromConfigurations.index(id: fromConfigurationId) else {
            return
        }
        
        var toIndex = 0
        if let toConfigurationId = to.configurationId {
            toIndex = toConfigurations.index(id: toConfigurationId) ?? 0
        }
        
        withAnimation(.spring()) {
            let fromConfig = fromConfigurations[fromIndex]
            fromConfigurations.remove(at: fromIndex)
            
            let dropAfter = toIndex > fromIndex
            let dropIndex = dropAfter ? toIndex + 1 : toIndex
            toConfigurations.insert(fromConfig, at: dropIndex)
            
            configurationsDict[from.subscriptionId] = fromConfigurations
            configurationsDict[to.subscriptionId] = toConfigurations
        }
    }
}
