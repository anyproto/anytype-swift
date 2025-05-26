import SwiftUI
import Services
import AnytypeCore


@MainActor
final class ObjectPropertiesLibraryViewModel: ObservableObject, PropertyInfoCoordinatorViewOutput {
    
    @Published var rows: [RelationDetails] = []
    @Published var propertyInfo: PropertyInfoData?
    
    @Injected(\.relationDetailsStorage)
    private var relationDetailsStorage: any RelationDetailsStorageProtocol
    
    @Injected(\.relationsService)
    private var relationsService: any RelationsServiceProtocol
    
    @Injected(\.dataviewService)
    private var dataviewService: any DataviewServiceProtocol
    
    private let spaceId: String
    
    init(spaceId: String) {
        self.spaceId = spaceId
    }
    
    func startSubscriptions() async {
        for await rows in relationDetailsStorage.relationsDetailsPublisher(spaceId: spaceId).values {
            self.rows = rows
        }
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
