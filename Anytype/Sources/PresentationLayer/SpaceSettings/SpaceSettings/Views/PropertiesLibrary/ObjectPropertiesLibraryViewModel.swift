import SwiftUI
import Services
import AnytypeCore


@MainActor
final class ObjectPropertiesLibraryViewModel: ObservableObject, PropertyInfoCoordinatorViewOutput {
    
    @Published var rows: [RelationDetails] = []
    @Published var propertyInfo: PropertyInfoData?
    
    @Injected(\.searchService)
    private var searchService: any SearchServiceProtocol
    @Injected(\.relationsService)
    private var relationsService: any RelationsServiceProtocol
    
    @Injected(\.dataviewService)
    private var dataviewService: any DataviewServiceProtocol
    
    private let spaceId: String
    
    init(spaceId: String) {
        self.spaceId = spaceId
    }
    
    func onAppear() async {
        // TBD: Subscription
        rows = (try? await searchService.searchRelations(text: "", excludedIds: [], spaceId: spaceId)) ?? []
    }
    
    func onRowTap(_ row: RelationDetails) {
        guard let supportedFormat = row.format.supportedFormat else {
            anytypeAssertionFailure("Unsupported format \(row.format)")
            return
        }
        
        propertyInfo = PropertyInfoData(
            name: row.name,
            objectId: "",
            spaceId: row.spaceId,
            target: .library,
            mode: .edit(relationId: row.id, format: supportedFormat, limitedObjectTypes: row.objectTypes.isEmpty ? nil : row.objectTypes)
        )
    }
    
    func onNewPropertyTap() {
        propertyInfo = PropertyInfoData(
            name: "",
            objectId: "",
            spaceId: spaceId,
            target: .library,
            mode: .create(format: .text)
        )
    }
    
    // MARK: - PropertyInfoCoordinatorViewOutput
    func didPressConfirm(_ relation: RelationDetails) { }
}
