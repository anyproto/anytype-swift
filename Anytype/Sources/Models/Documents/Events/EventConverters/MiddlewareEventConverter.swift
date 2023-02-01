import ProtobufMessages
import BlocksModels
import AnytypeCore
import SwiftProtobuf
import Foundation

final class MiddlewareEventConverter {
    private let infoContainer: InfoContainerProtocol
    private let relationLinksStorage: RelationLinksStorageProtocol
    private let detailsStorage: ObjectDetailsStorage
    private let restrictionsContainer: ObjectRestrictionsContainer
    
    private let informationCreator: BlockInformationCreator
    
    
    init(
        infoContainer: InfoContainerProtocol,
        relationLinksStorage: RelationLinksStorageProtocol,
        informationCreator: BlockInformationCreator,
        detailsStorage: ObjectDetailsStorage = ObjectDetailsStorage.shared,
        restrictionsContainer: ObjectRestrictionsContainer
    ) {
        self.infoContainer = infoContainer
        self.relationLinksStorage = relationLinksStorage
        self.informationCreator = informationCreator
        self.detailsStorage = detailsStorage
        self.restrictionsContainer = restrictionsContainer
    }
    
    func convert(_ event: Anytype_Event.Message.OneOf_Value) -> DocumentUpdate? {
        switch event {
        case let .threadStatus(status):
            return SyncStatus(status.summary.status).flatMap { .syncStatus($0) }
        case let .blockSetFields(fields):
            infoContainer.update(blockId: fields.id) { info in
                return info.updated(fields: fields.fields.fields)
            }
            return .blocks(blockIds: [fields.id])
        case let .blockAdd(value):
            value.blocks
                .compactMap(BlockInformationConverter.convert(block:))
                .forEach { block in
                    infoContainer.add(block)
                }
            // Because blockAdd message will always come together with blockSetChildrenIds
            // and it is easier to create update from those message
            return nil
        
        case let .blockDelete(value):
            value.blockIds.forEach { blockId in
                infoContainer.remove(id: blockId)
            }
            // Because blockDelete message will always come together with blockSetChildrenIds
            // and it is easier to create update from those message
            return nil
    
        case let .blockSetChildrenIds(data):
            infoContainer
                .setChildren(ids: data.childrenIds, parentId: data.id)
            return .general
        case let .blockSetText(newData):
            return blockSetTextUpdate(newData)
        case let .blockSetBackgroundColor(updateData):
            infoContainer.update(blockId: updateData.id, update: { info in
                return info.updated(
                    backgroundColor: MiddlewareColor(rawValue: updateData.backgroundColor) ?? .default
                )
            })

            var childIds = infoContainer.recursiveChildren(of: updateData.id).map { $0.id }
            childIds.append(updateData.id)
            
            return .blocks(blockIds: Set(childIds))
            
        case let .blockSetAlign(value):
            let blockId = value.id
            let alignment = value.align
            guard let modelAlignment = alignment.asBlockModel else {
                anytypeAssertionFailure(
                    "We cannot parse alignment: \(value)",
                    domain: .middlewareEventConverter
                )
                return .general
            }
            
            infoContainer.update(blockId: blockId) { info in
                info.updated(horizontalAlignment: modelAlignment)
            }
            return .blocks(blockIds: [blockId])
        
        case let .objectDetailsSet(data):
            guard let details = detailsStorage.set(data: data) else { return nil }
            
            // if `type` deleted we should reload featured relations block
            if details.isDeleted {
                return .general
            }
            
            return .details(id: details.id)
            
        case let .objectDetailsAmend(data):
            let oldDetails = detailsStorage.get(id: data.id)
            
            guard let newDetails = detailsStorage.amend(data: data) else { return nil }

            guard let oldDetails = oldDetails else {
                return .details(id: data.id)
            }
            
            // change layout from `todo` to `basic` should trigger update title
            // in order to remove chackmark
            guard oldDetails.layout == newDetails.layout else {
                return .general
            }

            // if `type` changed we should reload featured relations block
            guard oldDetails.type == newDetails.type else {
                return .general
            }
            
            let relationKeys = data.details.map { $0.key }
            if relationLinksStorage.contains(relationKeys: relationKeys) {
                return .general
            }
            
            return .details(id: data.id)
            
        case let .objectDetailsUnset(data):
            guard let details = detailsStorage.unset(data: data) else { return nil }
            return .details(id: details.id)
            
        case .objectRelationsAmend(let amend):
            relationLinksStorage.amend(
                relationLinks: amend.relationLinks.map { RelationLink(middlewareRelationLink: $0) }
            )
            
            return .general
            
        case .objectRelationsRemove(let remove):
            relationLinksStorage.remove(relationKeys: remove.relationKeys)
            
            return .general
            
        case let .blockSetFile(newData):
            guard newData.hasState else {
                return .general
            }
            
            infoContainer.update(blockId: newData.id, update: { info in
                switch info.content {
                case let .file(fileData):
                    var fileData = fileData
                    
                    if newData.hasType {
                        if let contentType = FileContentType(newData.type.value) {
                            fileData.contentType = contentType
                        }
                    }

                    if newData.hasState {
                        if let state = newData.state.value.asModel {
                            fileData.state = state
                        }
                    }
                    
                    if newData.hasName {
                        fileData.metadata.name = newData.name.value
                    }
                    
                    if newData.hasHash {
                        fileData.metadata.hash = newData.hash.value
                    }
                    
                    if newData.hasMime {
                        fileData.metadata.mime = newData.mime.value
                    }
                    
                    if newData.hasSize {
                        fileData.metadata.size = newData.size.value
                    }
                    
                    return info.updated(content: .file(fileData))
                default:
                    anytypeAssertionFailure("Wrong content: \(info.content) in blockSetFile", domain: .middlewareEventConverter)
                    return nil
                }
            })
            return .blocks(blockIds: [newData.id])
        case let .blockSetBookmark(data):
            
            let blockId = data.id
            
            infoContainer.update(blockId: blockId, update: { info in
                switch info.content {
                case let .bookmark(bookmark):
                    var bookmark = bookmark
                    
                    if data.hasURL {
                        bookmark.source = AnytypeURL(string: data.url.value)
                    }
                    
                    if data.hasTitle {
                        bookmark.title = data.title.value
                    }

                    if data.hasDescription_p {
                        bookmark.theDescription = data.description_p.value
                    }

                    if data.hasImageHash {
                        bookmark.imageHash = data.imageHash.value
                    }

                    if data.hasFaviconHash {
                        bookmark.faviconHash = data.faviconHash.value
                    }

                    if data.hasType {
                        if let type = data.type.value.asModel {
                            bookmark.type = type
                        }
                    }
                    
                    if data.hasTargetObjectID {
                        bookmark.targetObjectID = data.targetObjectID.value
                    }
                    
                    if data.hasState {
                        bookmark.state = data.state.value.asModel
                    }
                    
                    return info.updated(content: .bookmark(bookmark))

                default:
                    anytypeAssertionFailure("Wrong content \(info.content) in blockSetBookmark", domain: .middlewareEventConverter)
                    return nil
                }
            })
            return .blocks(blockIds: [blockId])
            
        case let .blockSetDiv(data):
            guard data.hasStyle else {
                return .general
            }
            
            let blockId = data.id
            
            infoContainer.update(blockId: blockId, update: { info in
                switch info.content {
                case let .divider(divider):
                    var divider = divider
                                        
                    if let style = BlockDivider.Style(data.style.value) {
                        divider.style = style
                    }
                    
                    return info.updated(content: .divider(divider))
                    
                default:
                    anytypeAssertionFailure("Wrong content \(info.content) in blockSetDiv", domain: .middlewareEventConverter)
                    return nil
                }
            })
            return .blocks(blockIds: [data.id])
        case .blockSetLink(let data):

            infoContainer.update(blockId: data.id) { info in
                switch info.content {
                case let .link(blockLink):
                    var blockLink = blockLink

                    if data.hasIconSize {
                        blockLink.appearance.iconSize = data.iconSize.value.asModel
                    }

                    if data.hasCardStyle {
                        blockLink.appearance.cardStyle = data.cardStyle.value.asModel
                    }

                    if data.hasDescription_p {
                        blockLink.appearance.description = data.description_p.value.asModel
                    }

                    if data.hasRelations {
                        blockLink.appearance.relations = data.relations.value.compactMap(BlockLink.Relation.init(rawValue:))
                    }

                    if data.hasTargetBlockID {
                        blockLink.targetBlockID = data.targetBlockID.value
                    }

                    return info.updated(content: .link(blockLink))

                default:
                    anytypeAssertionFailure("Wrong content \(info.content) in blockSetLink", domain: .middlewareEventConverter)
                    return nil
                }
            }
            return .blocks(blockIds: [data.id])
            
        //MARK: - Dataview
        case .blockDataviewViewSet(let data):
            guard let view = data.view.asModel else { return nil }
            
            infoContainer.updateDataview(blockId: data.id) { dataView in
                var newViews = dataView.views
                if let index = dataView.views.firstIndex(where: { $0.id == view.id }) {
                    newViews[index] = view
                } else {
                    newViews.insert(view, at: dataView.views.count)
                }
                
                return dataView.updated(views: newViews)
            }
            
            return .general
        case .blockDataviewViewOrder(let data):
            infoContainer.updateDataview(blockId: data.id) { dataView in
                let newViews = data.viewIds.compactMap { id -> DataviewView? in
                    guard let view = dataView.views.first(where: { $0.id == id }) else {
                        anytypeAssertionFailure("Not found view in order with id: \(id)", domain: .middlewareEventConverter)
                        return nil
                    }
                    return view
                }
                
                return dataView.updated(views: newViews)
            }
            return .general
        case .blockDataviewViewDelete(let data):
            infoContainer.updateDataview(blockId: data.id) { dataView in
                guard let index = dataView.views.firstIndex(where: { $0.id == data.viewID }) else {
                    anytypeAssertionFailure("Not found view in delete with id: \(data.viewID)", domain: .middlewareEventConverter)
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
            
            return .general
        case .blockDataviewRelationDelete(let data):
            infoContainer.updateDataview(blockId: data.id) { dataView in
                let newRelationLinks = dataView.relationLinks.filter { !data.relationKeys.contains($0.key) }
                return dataView.updated(relationLinks: newRelationLinks)
            }
            
            return .general
        case .blockDataviewRelationSet(let data):
            infoContainer.updateDataview(blockId: data.id) { dataView in
                let newRelationLinks = data.relationLinks.map { RelationLink(middlewareRelationLink: $0) }
                return dataView.updated(relationLinks: dataView.relationLinks + newRelationLinks)
            }
            
            return .general
        case .blockDataViewGroupOrderUpdate(let data):
            handleDataViewGroupOrderUpdate(data)
            return .general
        case .blockDataViewObjectOrderUpdate(let data):
            handleDataViewObjectOrderUpdate(data)
            return .general
        case .blockDataviewTargetObjectIDSet(let data):
            infoContainer.updateDataview(blockId: data.id) { dataView in
                return dataView.updated(targetObjectID: data.targetObjectID)
            }
            return .general
        case .blockDataviewViewUpdate(let data):
            handleBlockDataviewViewUpdate(data)
            return .general
        case .blockSetRelation(let data):
            infoContainer.update(blockId: data.id) { info in
                return info.updated(content: .relation(BlockRelation(key: data.key.value)))
            }
            return .general // Relace to `.blocks(blockIds: [data.id])` after implment task https://linear.app/anytype/issue/IOS-914
        case .accountShow,
                .accountUpdate, // Event not working on middleware. See AccountManager.
                .accountDetails, // Skipped
                .accountConfigUpdate, // Remote config updates
                .objectRemove, // Remove from History Object wich was deleted. For Desktop purposes
                .subscriptionAdd, // Implemented in `SubscriptionsService`
                .subscriptionRemove, // Implemented in `SubscriptionsService`
                .subscriptionPosition, // Implemented in `SubscriptionsService`
                .subscriptionCounters, // Implemented in `SubscriptionsService`
                .subscriptionGroups, // Implemented in `GroupsSubscriptionsHandler`
                .blockDataviewSourceSet, // will be deleted on middle soon
                .filesUpload,
                .marksInfo,
                .blockSetRestrictions,
                .blockSetLatex,
                .blockSetVerticalAlign,
                .blockSetTableRow,
                .blockDataviewOldRelationSet,
                .blockDataviewOldRelationDelete,
                .userBlockJoin,
                .userBlockLeft,
                .userBlockSelectRange,
                .userBlockTextRange,
                .ping,
                .processNew,
                .processUpdate,
                .processDone,
                .blockSetWidget:
            return nil
        }
    }
    
    private func blockSetTextUpdate(_ newData: Anytype_Event.Block.Set.Text) -> DocumentUpdate {
        guard let info = infoContainer.get(id: newData.id) else {
            anytypeAssertionFailure(
                "Block model with id \(newData.id) not found in container",
                domain: .middlewareEventConverter
            )
            return .general
        }
        guard case let .text(oldText) = info.content else {
            anytypeAssertionFailure(
                "Block model doesn't support text:\n \(info)",
                domain: .middlewareEventConverter
            )
            return .general
        }
        
        guard let newInformation = informationCreator.createBlockInformation(from: newData),
              case let .text(textContent) = newInformation.content else {
            return .general
        }
        infoContainer.add(newInformation)
        
        // If toggle changed style to another style or vice versa
        // we should rebuild all view to display/hide toggle's child blocks
        let isOldStyleToggle = oldText.contentType == .toggle
        let isNewStyleToggle = textContent.contentType == .toggle
        let toggleStyleChanged = isOldStyleToggle != isNewStyleToggle


        var childIds = infoContainer.recursiveChildren(of: newData.id).map { $0.id }
        childIds.append(newData.id)

        return toggleStyleChanged ? .general : .blocks(blockIds: Set(childIds))
    }
    
    private func handleDataViewGroupOrderUpdate(_ update: Anytype_Event.Block.Dataview.GroupOrderUpdate) {
        guard update.hasGroupOrder else { return }
        
        infoContainer.updateDataview(blockId: update.id) { dataView in
            var groupOrders = dataView.groupOrders
            if let groupIndex = groupOrders.firstIndex(where: { $0.viewID == update.groupOrder.viewID }) {
                groupOrders[groupIndex] = update.groupOrder
            } else {
                groupOrders.append(update.groupOrder)
            }
            
            return dataView.updated(groupOrders: groupOrders)
        }
    }

    private func handleDataViewObjectOrderUpdate(_ update: Anytype_Event.Block.Dataview.ObjectOrderUpdate) {
        infoContainer.updateDataview(blockId: update.id) { dataView in
            var objectOrders = dataView.objectOrders
            let objectOrderIndex = objectOrders.firstIndex { $0.viewID == update.viewID && $0.groupID == update.groupID }
            var objectOrder: DataviewObjectOrder
            if let objectOrderIndex {
                objectOrder = objectOrders[objectOrderIndex]
            } else {
                objectOrder = DataviewObjectOrder(viewID: update.viewID, groupID: update.groupID, objectIds: [])
            }
            var objectOrderIds = objectOrder.objectIds
            
            update.sliceChanges.forEach { change in
                let idx = objectOrderIds.firstIndex(of: change.afterID)
                
                switch change.op {
                case .add:
                    if objectOrderIds.isEmpty {
                        objectOrderIds.append(contentsOf: change.ids)
                    } else {
                        var addIndex = 0
                        if let idx {
                            addIndex = idx + 1
                        }
                        objectOrderIds.insert(contentsOf: change.ids, at: addIndex)
                    }
                    objectOrder.objectIds = objectOrderIds
                case .move:
                    change.ids.enumerated().forEach { index, id in
                        guard let objectIndex = objectOrderIds.firstIndex(of: id) else { return }
                        let orderIndex = (idx ?? 0) + index
                        let appendix = orderIndex < objectOrderIds.count ? 1 : 0
                        let moveIndex = idx == nil ? index : orderIndex + appendix
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
    
    private func handleBlockDataviewViewUpdate(_ update: Anytype_Event.Block.Dataview.ViewUpdate) {
        infoContainer.updateDataview(blockId: update.id) { [weak self] dataView in
            guard let self, let viewIndex = dataView.views.firstIndex(where: { $0.id == update.viewID }) else {
                return dataView
            }
            var views = dataView.views
            var view = views[viewIndex]
            
            if update.hasFields {
                view = view.updated(with: update.fields)
            }
            
            self.updateFilters(update, view: &view)
            self.updateSorts(update, view: &view)
            self.updateOptions(update, view: &view)
            
            views[viewIndex] = view
            return dataView.updated(views: views)
        }
    }
    
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
