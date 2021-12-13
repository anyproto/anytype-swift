import Combine
import BlocksModels
import AnytypeCore
import ProtobufMessages

final class EditorSetViewModel: ObservableObject {
    private var dataViewId: BlockId = ""
    private var cachedDataView = BlockDataview.empty
    var dataView: BlockDataview {
        extractDataViewFromDocument() ?? cachedDataView
    }
    
    var colums: [SetColumData] {
        dataView.activeViewRelations
            .filter { $0.isHidden == false }
            .map { SetColumData(key: $0.key, value: $0.name) }
    }
    
    var rows: [SetTableViewRowData] {
        records.map {
            let relations = relationsBuilder.buildRelations(
                using: dataView.activeViewRelations,
                objectId: $0.id,
                detailsStorage: detailsStorage
            ).all
            
            let sortedRelations = colums.compactMap { colum in
                relations.first { $0.id == colum.key }
            }
            
            return SetTableViewRowData(
                id: $0.id,
                type: $0.editorViewType,
                title: $0.title,
                icon: $0.objectIconImage,
                allRelations: sortedRelations,
//                allMetadata: [], // todo: Use metadata from rows data
                colums: colums
            )
        }
    }
 
    let document: BaseDocument
    var details: ObjectDetails {
        document.objectDetails ?? .empty
    }
    var featuredRelations: [Relation] {
        document.parsedRelations.featuredRelationsForEditor(type: details.objectType)
    }
    
    var router: EditorRouterProtocol!
    private let relationsBuilder = RelationsBuilder(scope: .type)
    
    @Published private var records: [ObjectDetails] = []
    private var detailsStorage = ObjectDetailsStorage()
    private var subscription: AnyCancellable?
    
    init(document: BaseDocument) {
        self.document = document
        subscription = document.updatePublisher.sink { [weak self] in
            self?.onDataChange($0)
        }
        
        if !document.open() { router.goBack() }
        if !setupDataview() { router.goBack() }
        
        magic()
    }
    
    private func onDataChange(_ data: EventsListenerUpdate) {
        objectWillChange.send()
    }
    
    func onAppear() {
        
    }
    
    private func setupDataview() -> Bool {
        let dataViews = document.flattenBlocks.compactMap { block -> (id: BlockId, data: BlockDataview)? in
            if case .dataView(let data) = block.information.content {
                return (block.information.id, data)
            }
            return nil
        }
        
        guard let dataView = dataViews.first else {
            if dataViews.isEmpty { anytypeAssertionFailure("No dataview block in Set", domain: .editorSet) }
            else { anytypeAssertionFailure("More then one dataview block in Set", domain: .editorSet) }
            return false
        }
        
        self.dataViewId = dataView.id
        self.cachedDataView = dataView.data
        
        return true
    }
    
    private func magic() {
        guard let activeView = dataView.activeView else {
            anytypeAssertionFailure("Empty active view", domain: .editorSet)
            return
        }
        
        guard let response = Anytype_Rpc.Block.Dataview.ViewSetActive.Service.invoke(
            contextID: document.objectId, blockID: dataViewId, viewID: activeView.id, offset: 0, limit: 300
        ).getValue() else { return }
        
        let data = response.event.messages.compactMap { message -> Anytype_Event.Block.Dataview.RecordsSet? in
            switch message.value! {
            case .blockDataviewRecordsSet(let data):
                return data
            default:
                return nil
            }
        }.first!
        
        self.records = data.records.compactMap { record -> ObjectDetails? in
            let idValue = record.fields["id"]
            let idString = idValue?.unwrapedListValue.stringValue
                
            guard let id = idString, id.isNotEmpty else { return nil }
            
            return ObjectDetails(id: id, values: record.fields)
        }
        
        records.forEach { detailsStorage.add(details: $0) }
    }
    
    private func extractDataViewFromDocument() -> BlockDataview? {
        document.flattenBlocks
            .filter { $0.information.id == dataViewId }
            .compactMap { block in
                if case .dataView(let data) = block.information.content {
                    return data
                }
                
                return nil
            }
            .first
    }
}
