import SwiftUI

struct SetDragAndDropConfiguration {
    let groupId: String
    let configurationId: String?
}

protocol SetDragAndDropDelegate {
    func onDrag(from: SetDragAndDropConfiguration, to: SetDragAndDropConfiguration)
    func onDrop(configurationId: String, fromGroupId: String, toGroupId: String) -> Bool
}

extension EditorSetViewModel: SetDragAndDropDelegate {
    func onDrag(from: SetDragAndDropConfiguration, to: SetDragAndDropConfiguration) {
        guard from.configurationId != to.configurationId else {
            return
        }
        
        if from.groupId == to.groupId,
           let fromId = from.configurationId, let toId = to.configurationId {
            swipeItemsInTheSameColumn(
                groupId: from.groupId,
                fromId: fromId,
                toId: toId
            )
        } else {
            swipeItemsInDifferentColumns(from: from, to: to)
        }
    }
    
    func onDrop(configurationId: String, fromGroupId: String, toGroupId: String) -> Bool {
        if fromGroupId == toGroupId,
            let configurations = configurationsDict[fromGroupId]
        {
            let groupObjectIds = GroupObjectIds(
                groupId: fromGroupId,
                objectIds: configurations.map { $0.id }
            )
            objectOrderUpdate(with: [groupObjectIds])
        } else if fromGroupId != toGroupId,
                  let fromConfigurations = configurationsDict[fromGroupId],
                  let toConfigurations = configurationsDict[toGroupId]
        {
            updateObjectDetails(
                configurationId,
                groupId: toGroupId
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
    
    private func swipeItemsInTheSameColumn(groupId: String, fromId: String, toId: String) {
        guard var configurations = configurationsDict[groupId],
              let fromIndex = configurations.index(id: fromId),
              let toIndex = configurations.index(id: toId) else {
            return
        }

        withAnimation(.slowIteractiveSpring) {
            let dropAfter = toIndex > fromIndex
            configurations.move(
                fromOffsets: IndexSet(integer: fromIndex),
                toOffset: dropAfter ? toIndex + 1 : toIndex
            )
            configurationsDict[groupId] = configurations
        }
    }
    
    private func swipeItemsInDifferentColumns(from: SetDragAndDropConfiguration, to: SetDragAndDropConfiguration) {
        guard var fromConfigurations = configurationsDict[from.groupId],
              var toConfigurations = configurationsDict[to.groupId],
              let fromConfigurationId = from.configurationId,
              let fromIndex = fromConfigurations.index(id: fromConfigurationId) else {
            return
        }

        var toIndex = 0
        if let toConfigurationId = to.configurationId {
            toIndex = toConfigurations.index(id: toConfigurationId) ?? 0
        }

        withAnimation(.slowIteractiveSpring) {
            let fromConfiguration = fromConfigurations[fromIndex]
            fromConfigurations.remove(at: fromIndex)

            let dropAfter = toIndex > fromIndex
            let dropIndex = dropAfter ? toIndex + 1 : toIndex
            toConfigurations.insert(fromConfiguration, at: dropIndex)

            configurationsDict[from.groupId] = fromConfigurations
            configurationsDict[to.groupId] = toConfigurations
        }
    }
}
