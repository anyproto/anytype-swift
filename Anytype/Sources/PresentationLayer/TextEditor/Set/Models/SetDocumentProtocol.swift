import Services
import Combine

enum SetDocumentUpdate {
    case dataviewUpdated(clearState: Bool)
    case syncStatus(SyncStatus)
}

protocol SetDocumentProtocol: BaseDocumentGeneralProtocol {
    var document: BaseDocumentProtocol { get }
    var objectId: String { get }
    var blockId: String { get }
    var targetObjectId: String { get }
    var inlineParameters: EditorInlineSetObject? { get }
    var blockDataview: BlockDataview? { get }
    var dataViewRelationsDetails: [RelationDetails] { get }
    var analyticsType: AnalyticsObjectType { get }
    // TODO Refactor this
    var dataBuilder: SetContentViewDataBuilder { get }
    
    var featuredRelationsForEditor: [Relation] { get }
    var parsedRelations: ParsedRelations { get }
    var setPermissions: SetPermissions { get }
    
    var setUpdatePublisher: AnyPublisher<SetDocumentUpdate, Never> { get }
    
    var dataView: BlockDataview { get }
    var dataviewPublisher: AnyPublisher<BlockDataview, Never> { get }
    
    var activeView: DataviewView { get }
    var activeViewPublisher: AnyPublisher<DataviewView, Never> { get }

    var activeViewSorts: [SetSort] { get }
    func sorts(for viewId: String) -> [SetSort]
    
    var activeViewFilters: [SetFilter] { get }
    func filters(for viewId: String) -> [SetFilter]
    
    func view(by id: String) -> DataviewView
    func sortedRelations(for viewId: String) -> [SetRelation]
    func canStartSubscription() -> Bool
    func viewRelations(viewId: String, excludeRelations: [RelationDetails]) -> [RelationDetails]
    func objectOrderIds(for groupId: String) -> [String]
    func updateActiveViewIdAndReload(_ id: String)
    func isTypeSet() -> Bool
    func isSetByRelation() -> Bool
    func isBookmarksSet() -> Bool
    func isCollection() -> Bool
    func isActiveHeader() -> Bool
    func defaultObjectTypeForActiveView() throws -> ObjectType
    func defaultObjectTypeForView(_ view: DataviewView) throws -> ObjectType
    var syncPublisher: AnyPublisher<Void, Never> { get }
    
    @MainActor
    func open() async throws
    
    @MainActor
    func openForPreview() async throws
    
    @MainActor
    func close() async throws
}
