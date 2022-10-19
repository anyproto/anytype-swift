import BlocksModels

extension DataviewGroup {
    func filter(with relationKey: String) -> DataviewFilter? {
        switch value {
        case .tag(let tag):
            return DataviewFilter(
                relationKey: relationKey,
                condition: .exactIn,
                value: tag.ids.protobufValue
            )
        case .status(let status):
            return DataviewFilter(
                relationKey: relationKey,
                condition: .equal,
                value: status.id.protobufValue
            )
        case .checkbox(let checkbox):
            return DataviewFilter(
                relationKey: relationKey,
                condition: .equal,
                value: checkbox.checked.protobufValue
            )
        default:
            return nil
        }
    }
}
