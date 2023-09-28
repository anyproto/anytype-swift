import AnytypeCore
import Services

struct ObjectTypesConfiguration {
    let objectTypes: [ObjectType]
    let objectTypeId: ObjectTypeId

    static let empty = ObjectTypesConfiguration(
        objectTypes: [],
        objectTypeId: .dynamic("")
    )
}

struct InstalledObjectTypeViewModel: Identifiable {
    let id: String
    let icon: Icon
    let title: String?
    let isSelected: Bool
    let onTap: () -> Void
}

extension InstalledObjectTypeViewModel {
    static let searchId = "SearchId"
}
