import ProtobufMessages
import BlocksModels
import AnytypeCore
import SwiftProtobuf

final class MiddlewareEventConverter {
    private let infoContainer: InfoContainerProtocol
    private let relationStorage: RelationsMetadataStorageProtocol
    private let detailsStorage: ObjectDetailsStorage
    private let restrictionsContainer: ObjectRestrictionsContainer
    
    private let informationCreator: BlockInformationCreator
    
    
    init(
        infoContainer: InfoContainerProtocol,
        relationStorage: RelationsMetadataStorageProtocol,
        informationCreator: BlockInformationCreator,
        detailsStorage: ObjectDetailsStorage = ObjectDetailsStorage.shared,
        restrictionsContainer: ObjectRestrictionsContainer
    ) {
        self.infoContainer = infoContainer
        self.relationStorage = relationStorage
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
                return info.updated(fields: fields.fields.toFieldTypeMap())
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
                    backgroundColor: MiddlewareColor(rawValue: updateData.backgroundColor)
                )
            })
            return .blocks(blockIds: [updateData.id])
            
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
                info.updated(alignment: modelAlignment)
            }
            return .blocks(blockIds: [blockId])
        
        case let .objectDetailsSet(data):
            guard let details = detailsStorage.set(data: data) else { return nil }
            return .details(id: details.id)
            
        case let .objectDetailsAmend(data):
            let oldDetails = detailsStorage.get(id: data.id)
            let newDetails = detailsStorage.amend(data: data)
            
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

            return .details(id: data.id)
            
        case let .objectDetailsUnset(data):
            guard let details = detailsStorage.unset(data: data) else { return nil }
            return .details(id: details.id)
            
        case .objectRelationsSet(let set):
            relationStorage.set(
                relations: set.relations.map { RelationMetadata(middlewareRelation: $0) }
            )
            
            #warning("TODO: add relations update")
            return .general
            
        case .objectRelationsAmend(let amend):
            relationStorage.amend(
                relations: amend.relations.map { RelationMetadata(middlewareRelation: $0) }
            )
            
            #warning("TODO: add relations update")
            return .general
            
        case .objectRelationsRemove(let remove):
            relationStorage.remove(relationKeys: remove.keys)
            
            #warning("TODO: add relations update")
            return .general
            
        case let .blockSetFile(newData):
            guard newData.hasState else {
                return .general
            }
            
            infoContainer.update(blockId: newData.id, update: { info in
                var info = info
                
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
                var info = info
                switch info.content {
                case let .bookmark(bookmark):
                    var bookmark = bookmark
                    
                    if data.hasURL {
                        bookmark.url = data.url.value
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
                    anytypeAssertionFailure("Wrong conten \(info.content) in blockSetDiv", domain: .middlewareEventConverter)
                    return nil
                }
            })
            return .blocks(blockIds: [data.id])
        
        case .objectShow(let data):
            guard data.rootID.isNotEmpty else {
                anytypeAssertionFailure("Empty root id", domain: .middlewareEventConverter)
                return nil
            }

            let parsedBlocks = data.blocks.compactMap {
                BlockInformationConverter.convert(block: $0)
            }
            let parsedDetails = data.details.map {
                ObjectDetails(id: $0.id, values: $0.details.fields)
            }

            buildBlocksTree(information: parsedBlocks, rootId: data.rootID, container: infoContainer)

            parsedDetails.forEach { detailsStorage.add(details: $0) }
    
            relationStorage.set(
                relations: data.relations.map { RelationMetadata(middlewareRelation: $0) }
            )
            
            let restrinctions = MiddlewareObjectRestrictionsConverter.convertObjectRestrictions(middlewareRestrictions: data.restrictions)
            restrictionsContainer.restrinctions = restrinctions
            return .general
        case .accountConfigUpdate(let config):
            AccountConfigurationProvider.shared.config = .init(config: config.config)
            return nil
            
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
        case .blockDataviewSourceSet(let data):
            infoContainer.updateDataview(blockId: data.id) { dataView in
                return dataView.updated(source: data.source)
            }
            
            return .general
        case .blockDataviewRelationDelete(let data):
            infoContainer.updateDataview(blockId: data.id) { dataView in
                guard let index = dataView.relations.firstIndex(where: { $0.key == data.relationKey }) else {
                    anytypeAssertionFailure("Not found key \(data.relationKey) in dataview: \(dataView)", domain: .middlewareEventConverter)
                    return dataView
                }
                
                var newRelations = dataView.relations
                newRelations.remove(at: index)
                
                return dataView.updated(relations: newRelations)
            }
            
            return .general
        case .blockDataviewRelationSet(let data):
            infoContainer.updateDataview(blockId: data.id) { dataView in
                let relation = RelationMetadata(middlewareRelation: data.relation)
                
                var newRelations = dataView.relations
                if let index = newRelations.firstIndex(where: { $0.key == relation.key }) {
                    newRelations[index] = relation
                } else {
                    newRelations.append(relation)
                }
                
                return dataView.updated(relations: newRelations)
            }
            
            return .general
        default:
            anytypeAssertionFailure("Unsupported event: \(event)", domain: .middlewareEventConverter)
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
        return toggleStyleChanged ? .general : .blocks(blockIds: [newData.id])
    }
    
    private func buildBlocksTree(information: [BlockInformation], rootId: BlockId, container: InfoContainerProtocol) {
        
        information.forEach { container.add($0) }
        let roots = information.filter { $0.id == rootId }

        guard roots.count != 0 else {
            anytypeAssertionFailure("Unknown situation. We can't have zero roots.", domain: .middlewareEventConverter)
            return
        }

        if roots.count != 1 {
            // this situation is not possible, but, let handle it.
            anytypeAssertionFailure(
                "We have several roots for our rootId. Not possible, but let us handle it.",
                domain: .middlewareEventConverter
            )
        }

        let rootId = roots[0].id

        IndentationBuilder.build(container: container, id: rootId)
    }
}
