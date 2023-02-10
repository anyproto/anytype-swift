import BlocksModels
import Combine

enum SetDocumentUpdate {
    case dataviewUpdated(clearState: Bool)
    case syncStatus(SyncStatus)
}

protocol SetDocumentProtocol: BaseDocumentGeneralProtocol {
    var document: BaseDocumentProtocol { get }
    var objectId: BlockId { get }
    var targetObjectID: String? { get }
    var dataviews: [BlockDataview] { get }
    var dataViewRelationsDetails: [RelationDetails] { get }
    var sortedRelations: [SetRelation] { get }
    var isObjectLocked: Bool { get }
    
    var featuredRelationsForEditor: [Relation] { get }
    var parsedRelations: ParsedRelations { get }
    
    var setUpdatePublisher: AnyPublisher<SetDocumentUpdate, Never> { get }
    
    var dataView: BlockDataview { get }
    var dataviewPublisher: AnyPublisher<BlockDataview, Never> { get }
    
    var activeView: DataviewView { get }
    var activeViewPublisher: AnyPublisher<DataviewView, Never> { get }

    var sorts: [SetSort] { get }
    var sortsPublisher: AnyPublisher<[SetSort], Never> { get }
    
    var filters: [SetFilter] { get }
    var filtersPublisher: AnyPublisher<[SetFilter], Never> { get }
    
    func activeViewRelations(excludeRelations: [RelationDetails]) -> [RelationDetails]
    func updateActiveViewId(_ id: BlockId)
    func isRelationsSet() -> Bool
    func isBookmarksSet() -> Bool
    
    @MainActor
    func open() async throws
    
    @MainActor
    func openForPreview() async throws
}
