import Services
import Combine

enum SetDocumentUpdate {
    case dataviewUpdated(clearState: Bool)
    case syncStatus(DocumentSyncStatusData)
}

protocol SetDocumentProtocol: AnyObject, Sendable {
    var document: any BaseDocumentProtocol { get }
    var objectId: String { get }
    var spaceId: String { get }
    var blockId: String { get }
    var targetObjectId: String { get }
    var inlineParameters: EditorInlineSetObject? { get }
    var blockDataview: BlockDataview? { get }
    var dataViewRelationsDetails: [PropertyDetails] { get }
    var analyticsType: AnalyticsObjectType { get }
    var details: ObjectDetails? { get }
    // TODO Refactor this
    var dataBuilder: any SetContentViewDataBuilderProtocol { get }
    
    var featuredRelationsForEditor: [Property] { get }
    var parsedProperties: ParsedProperties { get }
    var setPermissions: SetPermissions { get }
    
    var setUpdatePublisher: AnyPublisher<SetDocumentUpdate, Never> { get }
    var detailsPublisher: AnyPublisher<ObjectDetails, Never> { get }
    
    var dataView: BlockDataview { get }
    var dataviewPublisher: AnyPublisher<BlockDataview, Never> { get }
    
    var activeView: DataviewView { get }
    var activeViewPublisher: AnyPublisher<DataviewView, Never> { get }

    var activeViewSorts: [SetSort] { get }
    func sorts(for viewId: String) -> [SetSort]
    
    var activeViewFilters: [SetFilter] { get }
    func filters(for viewId: String) -> [SetFilter]
    
    func view(by id: String) -> DataviewView
    func sortedRelations(for viewId: String) -> [SetProperty]
    func canStartSubscription() -> Bool
    func viewRelations(viewId: String, excludeRelations: [PropertyDetails]) -> [PropertyDetails]
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
    func update() async throws
    
    @MainActor
    func close() async throws
}
