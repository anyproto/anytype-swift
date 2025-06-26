import Foundation
import ProtobufMessages
import AnytypeCore

public extension InfoContainerProtocol {
    
    func dataviewViewSet(data: Anytype_Event.Block.Dataview.ViewSet) {
        guard let view = data.view.asModel else { return }
        
        updateDataview(blockId: data.id) { dataView in
            var newViews = dataView.views
            if let index = dataView.views.firstIndex(where: { $0.id == view.id }) {
                newViews[index] = view
            } else {
                newViews.insert(view, at: dataView.views.count)
            }
            
            return dataView.updated(views: newViews)
        }
    }
    
    func dataviewViewDelete(data: Anytype_Event.Block.Dataview.ViewDelete) {
        updateDataview(blockId: data.id) { dataView in
            guard let index = dataView.views.firstIndex(where: { $0.id == data.viewID }) else {
                anytypeAssertionFailure("Not found view in delete", info: ["dataViewId": data.viewID])
                return dataView
            }
            
            var dataView = dataView
            if dataView.views[index].id == dataView.activeViewId {
                let newId = dataView.views.findNextSupportedView(mainIndex: index)?.id ?? ""
                dataView = dataView.updated(activeViewId: newId)
            }
            
            var newViews = dataView.views
            newViews.remove(at: index)
            return dataView.updated(views: newViews)
        }
    }
    
    func dataviewViewOrder(data: Anytype_Event.Block.Dataview.ViewOrder) {
        updateDataview(blockId: data.id) { dataView in
            let newViews = data.viewIds.compactMap { id -> DataviewView? in
                guard let view = dataView.views.first(where: { $0.id == id }) else {
                    anytypeAssertionFailure("Not found view in order", info: ["id": id])
                    return nil
                }
                return view
            }
            
            return dataView.updated(views: newViews)
        }
    }
    
    func dataViewGroupOrderUpdate(data: Anytype_Event.Block.Dataview.GroupOrderUpdate) {
        guard data.hasGroupOrder else { return }
        
        updateDataview(blockId: data.id) { dataView in
            var groupOrders = dataView.groupOrders
            if let groupIndex = groupOrders.firstIndex(where: { $0.viewID == data.groupOrder.viewID }) {
                groupOrders[groupIndex] = data.groupOrder
            } else {
                groupOrders.append(data.groupOrder)
            }
            
            return dataView.updated(groupOrders: groupOrders)
        }
    }
    
    func dataViewObjectOrderUpdate(data: Anytype_Event.Block.Dataview.ObjectOrderUpdate) {
        updateDataview(blockId: data.id) { dataView in
            var objectOrders = dataView.objectOrders
            let objectOrderIndex = objectOrders.firstIndex { $0.viewID == data.viewID && $0.groupID == data.groupID }
            var objectOrder: DataviewObjectOrder
            if let objectOrderIndex {
                objectOrder = objectOrders[objectOrderIndex]
            } else {
                objectOrder = DataviewObjectOrder(viewID: data.viewID, groupID: data.groupID, objectIds: [])
            }
            var objectOrderIds = objectOrder.objectIds
            
            data.sliceChanges.forEach { change in
                let afterIdIndex = objectOrderIds.firstIndex(of: change.afterID)
                
                switch change.op {
                case .add:
                    var addIndex = 0
                    if let afterIdIndex {
                        addIndex = afterIdIndex + 1
                    }
                    objectOrderIds.insert(contentsOf: change.ids, at: addIndex)
                    objectOrder.objectIds = objectOrderIds
                case .move:
                    change.ids.enumerated().forEach { index, id in
                        guard let objectIndex = objectOrderIds.firstIndex(of: id) else { return }
                        let orderIndex = (afterIdIndex ?? 0) + index
                        let appendix = orderIndex < objectOrderIds.count ? 1 : 0
                        let moveIndex = afterIdIndex == nil ? index : orderIndex + appendix
                        objectOrderIds.move(
                            fromOffsets: IndexSet(integer: objectIndex),
                            toOffset: moveIndex
                        )
                    }
                    objectOrder.objectIds = objectOrderIds
                case .remove:
                    objectOrder.objectIds = objectOrderIds.filter { !change.ids.contains($0) }
                case .replace:
                    objectOrder.objectIds = change.ids
                default:
                    break
                }
                
                if let objectOrderIndex {
                    objectOrders[objectOrderIndex] = objectOrder
                } else {
                    objectOrders.append(objectOrder)
                }
            }
            
            return dataView.updated(objectOrders: objectOrders)
        }
    }
    
    func dataviewRelationDelete(data: Anytype_Event.Block.Dataview.RelationDelete) {
        updateDataview(blockId: data.id) { dataView in
            let newRelationLinks = dataView.relationLinks.filter { !data.relationKeys.contains($0.key) }
            return dataView.updated(relationLinks: newRelationLinks)
        }
    }
    
    func dataviewRelationSet(data: Anytype_Event.Block.Dataview.RelationSet) {
        updateDataview(blockId: data.id) { dataView in
            let newRelationLinks = data.relationLinks.map { PropertyLink(middlewareRelationLink: $0) }
            return dataView.updated(relationLinks: dataView.relationLinks + newRelationLinks)
        }
    }
    
    func dataviewViewUpdate(data: Anytype_Event.Block.Dataview.ViewUpdate) {
        updateDataview(blockId: data.id) { [weak self] dataView in
            guard let self, let viewIndex = dataView.views.firstIndex(where: { $0.id == data.viewID }) else {
                return dataView
            }
            var views = dataView.views
            var view = views[viewIndex]
            
            if data.hasFields {
                view = view.updated(with: data.fields)
            }
            
            self.updateFilters(data, view: &view)
            self.updateSorts(data, view: &view)
            self.updateOptions(data, view: &view)
            
            views[viewIndex] = view
            return dataView.updated(views: views)
        }
    }
    
    func dataviewTargetObjectIDSet(data: Anytype_Event.Block.Dataview.TargetObjectIdSet) {
        updateDataview(blockId: data.id) { dataView in
            return dataView.updated(targetObjectID: data.targetObjectID)
        }
    }
    
    func dataviewIsCollectionSet(data: Anytype_Event.Block.Dataview.IsCollectionSet) {
        updateDataview(blockId: data.id) { dataView in
            return dataView.updated(isCollection: data.value)
        }
    }
    
    // MARK: - Private
    
    private func updateFilters(_ update: Anytype_Event.Block.Dataview.ViewUpdate, view: inout DataviewView) {
        var filters = view.filters
        update.filter.forEach { update in
            switch update.operation {
            case .add(let add):
                addItems(&filters, addItems: add.items, afterId: add.afterID)
            case .move(let move):
                moveItems(&filters, moveIds: move.ids, afterId: move.afterID)
            case .remove(let remove):
                removeItems(&filters, ids: remove.ids)
            case .update(let update):
                if update.hasItem {
                    updateItems(&filters, id: update.id, item: update.item)
                }
            default:
                break
            }
            
            view = view.updated(filters: filters)
        }
    }
    
    private func updateSorts(_ update: Anytype_Event.Block.Dataview.ViewUpdate, view: inout DataviewView) {
        var sorts = view.sorts
        update.sort.forEach { update in
            switch update.operation {
            case .add(let add):
                addItems(&sorts, addItems: add.items, afterId: add.afterID)
            case .move(let move):
                moveItems(&sorts, moveIds: move.ids, afterId: move.afterID)
            case .remove(let remove):
                removeItems(&sorts, ids: remove.ids)
            case .update(let update):
                if update.hasItem {
                    updateItems(&sorts, id: update.id, item: update.item)
                }
            default:
                break
            }

            view = view.updated(sorts: sorts)
        }
    }
    
    private func updateOptions(_ update: Anytype_Event.Block.Dataview.ViewUpdate, view: inout DataviewView) {
        var options = view.options
        update.relation.forEach { update in
            switch update.operation {
            case .add(let add):
                let newOptions = add.items.map { $0.asModel }
                addItems(&options, addItems: newOptions, afterId: add.afterID)
            case .move(let move):
                moveItems(&options, moveIds: move.ids, afterId: move.afterID)
            case .remove(let remove):
                removeItems(&options, ids: remove.ids)
            case .update(let update):
                if update.hasItem {
                    updateItems(&options, id: update.id, item: update.item.asModel)
                }
            default:
                break
            }
            
            view = view.updated(options: options)
        }
    }
    
    private func addItems<T: DataviewObjectIdentifiable>(_ items: inout [T], addItems: [T], afterId: String) {
        let afterIdIndex = items.firstIndex { $0.id == afterId }
        var addIndex = 0
        if let afterIdIndex {
            addIndex = afterIdIndex + 1
        }
        items.insert(contentsOf: addItems, at: addIndex)
    }
    
    private func moveItems<T: DataviewObjectIdentifiable>(_ items: inout [T], moveIds: [String], afterId: String) {
        let afterIdIndex = items.firstIndex { $0.id == afterId }
        moveIds.enumerated().forEach { index, id in
            guard let filterIndex = items.firstIndex(where: { $0.id == id }) else { return }
            let orderIndex = (afterIdIndex ?? 0) + index
            let appendix = orderIndex < items.count ? 1 : 0
            let moveIndex = afterIdIndex == nil ? index : orderIndex + appendix
            items.move(
                fromOffsets: IndexSet(integer: filterIndex),
                toOffset: moveIndex
            )
        }
    }
    
    private func removeItems<T: DataviewObjectIdentifiable>(_ items: inout [T], ids: [String]) {
        items = items.filter { !ids.contains($0.id) }
    }
    
    private func updateItems<T: DataviewObjectIdentifiable>(_ items: inout [T], id: String, item: T) {
        if let index = items.firstIndex(where: { $0.id == id }) {
            items[index] = item
        }
    }
}
