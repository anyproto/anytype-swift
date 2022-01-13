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
            let relations = relationsBuilder.parsedRelations(
                relationMetadatas: dataView.activeViewRelations,
                objectId: $0.id
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
    private var subscription: AnyCancellable?
    
    private let subscriptionService = ServiceLocator.shared.subscriptionService()
    
    init(document: BaseDocument) {
        self.document = document
        subscription = document.updatePublisher.sink { [weak self] in
            self?.onDataChange($0)
        }
        
        if !document.open() { router.goBack() }
        if !setupDataview() { router.goBack() }
        
        setupSubscriptions()
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
    
    private func setupSubscriptions() {
        guard let activeView = dataView.activeView else {
            anytypeAssertionFailure("Empty active view", domain: .editorSet)
            return
        }

        subscriptionService.startSubscription(
            data: .set(
                source: dataView.source,
                sorts: activeView.sorts,
                filters: activeView.filters,
                relations: activeView.relations
            )
        ) { [weak self] subId, update in
            self?.records.applySubscriptionUpdate(update)
        }
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
