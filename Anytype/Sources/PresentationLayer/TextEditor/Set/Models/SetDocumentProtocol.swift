import Services
import Combine

enum SetDocumentUpdate {
    case dataviewUpdated(clearState: Bool)
    case syncStatus(SyncStatus)
}

protocol SetDocumentProtocol: BaseDocumentGeneralProtocol {
    var document: BaseDocumentProtocol { get }
    var objectId: BlockId { get }
    var inlineParameters: EditorInlineSetObject? { get }
    var dataviews: [BlockDataview] { get }
    var dataViewRelationsDetails: [RelationDetails] { get }
    var isObjectLocked: Bool { get }
    var analyticsType: AnalyticsObjectType { get }
    // TODO Refactor this
    var dataBuilder: SetContentViewDataBuilder { get }
    
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
    
    func sortedRelations(for activeView: DataviewView) -> [SetRelation]
    func canStartSubscription() -> Bool
    func activeViewRelations(excludeRelations: [RelationDetails]) -> [RelationDetails]
    func objectOrderIds(for groupId: String) -> [String]
    func updateActiveViewId(_ id: BlockId)
    func isTypeSet() -> Bool
    func isRelationsSet() -> Bool
    func isBookmarksSet() -> Bool
    func isCollection() -> Bool
    
    var syncPublisher: AnyPublisher<Void, Never> { get }
    
    @MainActor
    func open() async throws
    
    @MainActor
    func openForPreview() async throws
    
    @MainActor
    func close() async throws
}
