import SwiftUI

struct SetDragAndDropConfiguration {
    let groupId: String
    let configurationId: String?
}

@MainActor
protocol SetDragAndDropDelegate {
    var canDragCards: Bool { get }
    func onDrag(from: SetDragAndDropConfiguration, to: SetDragAndDropConfiguration)
    func onDrop(configurationId: String, fromGroupId: String, toGroupId: String) -> Bool
    func onDragCancelled()
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
    
    func onDragCancelled() {
        revertOptimisticCardMoves()
    }

    func onDrop(configurationId: String, fromGroupId: String, toGroupId: String) -> Bool {
        guard canDragCards else {
            revertOptimisticCardMoves()
            return false
        }

        if fromGroupId == toGroupId,
            let configurations = configurationsDict[fromGroupId]
        {
            // ObjectOrderUpdate replaces the whole (viewId, groupId) list; persisting a
            // partially loaded column would destroy the order of the unloaded cards.
            guard isGroupFullyLoaded(fromGroupId) else {
                revertOptimisticCardMoves()
                return false
            }
            let groupObjectIds = GroupObjectIds(
                groupId: fromGroupId,
                objectIds: configurations.map { $0.id }
            )
            objectOrderUpdate(with: [groupObjectIds])
        } else if fromGroupId != toGroupId,
                  configurationsDict[fromGroupId].isNotNil,
                  configurationsDict[toGroupId].isNotNil
        {
            let moved = updateObjectDetails(
                configurationId,
                fromGroupId: fromGroupId,
                toGroupId: toGroupId
            )
            guard moved else { return false }

            var groupObjectIds = [GroupObjectIds]()
            if isGroupFullyLoaded(fromGroupId), let fromConfigurations = configurationsDict[fromGroupId] {
                groupObjectIds.append(GroupObjectIds(groupId: fromGroupId, objectIds: fromConfigurations.map { $0.id }))
            }
            if isGroupFullyLoaded(toGroupId), let toConfigurations = configurationsDict[toGroupId] {
                groupObjectIds.append(GroupObjectIds(groupId: toGroupId, objectIds: toConfigurations.map { $0.id }))
            }
            if groupObjectIds.isNotEmpty {
                objectOrderUpdate(with: groupObjectIds)
            }
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

        var toIndex = toConfigurations.count
        if let toConfigurationId = to.configurationId {
            toIndex = toConfigurations.index(id: toConfigurationId) ?? toConfigurations.count
        }

        withAnimation(.slowIteractiveSpring) {
            let fromConfiguration = fromConfigurations[fromIndex]
            fromConfigurations.remove(at: fromIndex)

            toConfigurations.insert(fromConfiguration, at: toIndex)

            configurationsDict[from.groupId] = fromConfigurations
            configurationsDict[to.groupId] = toConfigurations
        }
    }
}
