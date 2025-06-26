import Services

extension DataviewGroup {    
    func filter(with relationKey: String) -> DataviewFilter? {
        switch value {
        case .tag(let tag):
            return DataviewFilter(
                relationKey: relationKey,
                condition: tag.ids.isEmpty ? .empty : .exactIn,
                value: tag.ids.protobufValue
            )
        case .status(let status):
            return DataviewFilter(
                relationKey: relationKey,
                condition: status.id.isEmpty ? .empty : .equal,
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
    
    func backgroundColor(document: some BaseDocumentProtocol) -> BlockBackgroundColor? {
        switch value {
        case .tag(let tag):
            guard let firstTagId = tag.ids.first,
                  let details = document.detailsStorage.get(id: firstTagId) else { return nil }
            return MiddlewareColor(rawValue: details.relationOptionColor)?.backgroundColor
        case .status(let status):
            guard let details = document.detailsStorage.get(id: status.id) else { return nil }
            return MiddlewareColor(rawValue: details.relationOptionColor)?.backgroundColor
        default:
            return nil
        }
    }
    
    func header(with groupRelationKey: String, document: some BaseDocumentProtocol) -> SetKanbanColumnHeaderType {
        switch value {
        case .tag(let tag):
            let tags = tag.ids
                .compactMap { document.detailsStorage.get(id: $0) }
                .map { PropertyOption(details: $0) }
                .map { Relation.Tag.Option(option: $0) }
            return tags.isEmpty ? .uncategorized : .tag(tags)
        case .status(let status):
            guard let optionDetails = document.detailsStorage.get(id: status.id) else {
                return .uncategorized
            }
            let option = PropertyOption(details: optionDetails)
            return .status([Relation.Status.Option(option: option)])
        case .checkbox(let checkbox):
            return .checkbox(title: groupRelationKey.capitalized, isChecked: checkbox.checked)
        default:
            return .uncategorized
        }
    }
}
