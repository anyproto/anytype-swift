import SwiftUI
import Services
import AnytypeCore


@MainActor
final class ObjectPropertiesLibraryViewModel: ObservableObject, PropertyInfoCoordinatorViewOutput {
    
    @Published var rows: [RelationDetails] = []
    @Published var propertyInfo: PropertyInfoData?
    
    @Injected(\.propertyDetailsStorage)
    private var propertyDetailsStorage: any PropertyDetailsStorageProtocol
    
    @Injected(\.relationsService)
    private var relationsService: any RelationsServiceProtocol
    
    @Injected(\.dataviewService)
    private var dataviewService: any DataviewServiceProtocol
    
    private let spaceId: String
    
    init(spaceId: String) {
        self.spaceId = spaceId
    }
    
    func startSubscriptions() async {
        for await rows in propertyDetailsStorage.relationsDetailsPublisher(spaceId: spaceId).values {
            self.rows = rows.filter { !$0.isHidden }
        }
    }
    
    func onRowTap(_ row: RelationDetails) {
        guard let supportedFormat = row.format.supportedFormat else {
            anytypeAssertionFailure("Unsupported format \(row.format)")
            return
        }
        
        propertyInfo = PropertyInfoData(
            name: row.name,
            objectId: nil,
            spaceId: row.spaceId,
            target: .library,
            mode: .edit(relationId: row.id, format: supportedFormat, limitedObjectTypes: row.objectTypes.isEmpty ? nil : row.objectTypes)
        )
    }
    
    func onNewPropertyTap() {
        propertyInfo = PropertyInfoData(
            name: "",
            objectId: nil,
            spaceId: spaceId,
            target: .library,
            mode: .create(format: .text)
        )
    }
    
    // MARK: - PropertyInfoCoordinatorViewOutput
    func didPressConfirm(_ relation: RelationDetails) { }
}
