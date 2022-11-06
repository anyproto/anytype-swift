import SwiftUI

struct KanbanDragAndDropConfiguration {
    let groupId: String
    let configurationId: String?
}

protocol KanbanDragAndDropDelegate {
    func onDrag(from: KanbanDragAndDropConfiguration, to: KanbanDragAndDropConfiguration)
    func onDrop(configurationId: String, fromGroupId: String, toGroupId: String) -> Bool
}

extension EditorSetViewModel: KanbanDragAndDropDelegate {
    func onDrag(from: KanbanDragAndDropConfiguration, to: KanbanDragAndDropConfiguration) {
        guard from.configurationId != to.configurationId else {
            return
        }
        
        if from.groupId == to.groupId,
           let fromId = from.configurationId, let toId = to.configurationId {
            swipeItemsInTheSameColumn(
                subscriptionId: SubscriptionId(value: from.groupId),
                fromId: fromId,
                toId: toId
            )
        } else {
            swipeItemsInDifferentColumns(from: from, to: to)
        }
    }
    
    func onDrop(configurationId: String, fromGroupId: String, toGroupId: String) -> Bool {
        if fromGroupId == toGroupId,
            let configurations = configurationsDict[SubscriptionId(value: fromGroupId)]
        {
            let groupObjectIds = GroupObjectIds(
                groupId: fromGroupId,
                objectIds: configurations.map { $0.id }
            )
            objectOrderUpdate(with: [groupObjectIds])
        } else if fromGroupId != toGroupId,
                  let fromConfigurations = configurationsDict[SubscriptionId(value: fromGroupId)],
                  let toConfigurations = configurationsDict[SubscriptionId(value: toGroupId)]
        {
            updateDetails(
                groupId: toGroupId,
                detailsId: configurationId
            )
            let fromGroupObjectIds = GroupObjectIds(
                groupId: fromGroupId,
                objectIds: fromConfigurations.map { $0.id }
            )
            let toGroupObjectIds = GroupObjectIds(
                groupId: toGroupId,
                objectIds: toConfigurations.map { $0.id }
            )
            objectOrderUpdate(with: [fromGroupObjectIds, toGroupObjectIds])
        } else {
            return false
        }
        
        return true
    }
    
    private func swipeItemsInTheSameColumn(subscriptionId: SubscriptionId, fromId: String, toId: String) {
        guard var configurations = configurationsDict[subscriptionId] else {
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
            configurationsDict[subscriptionId] = configurations
        }
    }
    
    private func swipeItemsInDifferentColumns(from: KanbanDragAndDropConfiguration, to: KanbanDragAndDropConfiguration) {
        let fromSubscriptionId = SubscriptionId(value: from.groupId)
        let toSubscriptionId = SubscriptionId(value: to.groupId)
        guard var fromConfigurations = configurationsDict[fromSubscriptionId],
              var toConfigurations = configurationsDict[toSubscriptionId],
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

            configurationsDict[fromSubscriptionId] = fromConfigurations
            configurationsDict[toSubscriptionId] = toConfigurations
        }
    }
}
