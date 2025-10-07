import Services

extension ObjectDetails {
    static func mock(name: String) -> ObjectDetails {
        ObjectDetails(id: "", values: [
            BundledPropertyKey.name.rawValue: name.protobufValue
        ])
    }
}
