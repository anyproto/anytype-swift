import SwiftUI
import Services
import AnytypeCore


@MainActor
final class ObjectPropertiesLibraryViewModel: ObservableObject, PropertyInfoCoordinatorViewOutput {
    
    @Published var userProperties: [PropertyDetails] = []
    @Published var systemProperties: [PropertyDetails] = []
    @Published var propertyInfo: PropertyInfoData?
    
    @Injected(\.propertyDetailsStorage)
    private var propertyDetailsStorage: any PropertyDetailsStorageProtocol
    
    @Injected(\.propertiesService)
    private var propertiesService: any PropertiesServiceProtocol
    
    @Injected(\.dataviewService)
    private var dataviewService: any DataviewServiceProtocol
    
    let spaceId: String
    
    init(spaceId: String) {
        self.spaceId = spaceId
    }
    
    func startSubscriptions() async {
        for await rows in propertyDetailsStorage.relationsDetailsPublisher(spaceId: spaceId).values {
            let visibleProperties = rows.filter { !$0.isHidden }
            
            self.systemProperties = visibleProperties.filter {
                BundledPropertyKey.systemKeys.map(\.rawValue).contains($0.key)
            }
            self.userProperties = visibleProperties.filter {
                !BundledPropertyKey.systemKeys.map(\.rawValue).contains($0.key)
            }
        }
    }
    
    func onRowTap(_ row: PropertyDetails) {
        guard let supportedFormat = row.format.supportedFormat else {
            anytypeAssertionFailure("Unsupported format \(row.format)")
            return
        }
        
        propertyInfo = PropertyInfoData(
            name: row.name,
            objectId: nil,
            spaceId: row.spaceId,
            target: .library,
            mode: .edit(relationId: row.id, format: supportedFormat, limitedObjectTypes: row.objectTypes.isEmpty ? nil : row.objectTypes),
            isReadOnly: row.isReadOnly
        )
    }
    
    func onNewPropertyTap() {
        propertyInfo = PropertyInfoData(
            name: "",
            objectId: nil,
            spaceId: spaceId,
            target: .library,
            mode: .create(format: .text),
            isReadOnly: false
        )
    }
    
    // MARK: - PropertyInfoCoordinatorViewOutput
    func didPressConfirm(_ relation: PropertyDetails) { }
}
