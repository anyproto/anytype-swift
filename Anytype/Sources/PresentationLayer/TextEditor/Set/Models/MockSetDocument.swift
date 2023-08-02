import Foundation
import Services
import Combine

final class MockSetDocument: SetDocumentProtocol {
    var document: BaseDocumentProtocol { fatalError() }
    
    var objectId: BlockId { "" }
    
    var targetObjectID: String? { "" }
    
    var dataviews: [BlockDataview] { [] }
    
    var dataViewRelationsDetails: [Services.RelationDetails] { [] }
    
    var sortedRelations: [SetRelation] { [] }
    
    var isObjectLocked: Bool { false }
    
    var analyticsType: AnalyticsObjectType { .custom }
    
    var dataBuilder: SetContentViewDataBuilder { fatalError() }
    
    var featuredRelationsForEditor: [Relation] { [] }
    
    var parsedRelations: ParsedRelations { .empty }
    
    var setUpdatePublisher: AnyPublisher<SetDocumentUpdate, Never> { fatalError() }
    
    var dataView: Services.BlockDataview { fatalError() }
    
    var dataviewPublisher: AnyPublisher<Services.BlockDataview, Never> { fatalError() }
    
    var activeView: Services.DataviewView { fatalError() }
    
    var activeViewPublisher: AnyPublisher<Services.DataviewView, Never> { fatalError() }
    
    var sorts: [SetSort] { [] }
    
    var sortsPublisher: AnyPublisher<[SetSort], Never> { fatalError() }
    
    var filters: [SetFilter] { [] }
    
    var filtersPublisher: AnyPublisher<[SetFilter], Never> { fatalError() }
    
    func canStartSubscription() -> Bool { false }
    
    func activeViewRelations(excludeRelations: [Services.RelationDetails]) -> [Services.RelationDetails] { [] }
    
    func objectOrderIds(for groupId: String) -> [String] { [] }
    
    func updateActiveViewId(_ id: Services.BlockId) { }
    
    func isRelationsSet() -> Bool { false }
    
    func isBookmarksSet() -> Bool { false }
    
    func isCollection() -> Bool { false }
    
    var syncPublisher: AnyPublisher<Void, Never> { fatalError() }
    
    func open() async throws { }
    
    func openForPreview() async throws { }
    
    func close() async throws { }
    
    var details: ObjectDetails? { nil }
    
    var detailsPublisher: AnyPublisher<Services.ObjectDetails, Never> { fatalError() }
    
    var updatePublisher: AnyPublisher<DocumentUpdate, Never> { fatalError() }
}
