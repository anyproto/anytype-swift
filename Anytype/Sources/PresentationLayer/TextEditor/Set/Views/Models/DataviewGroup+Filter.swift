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
    
    func backgroundColor(optionDetails: (String) -> ObjectDetails?) -> BlockBackgroundColor? {
        switch value {
        case .tag(let tag):
            guard let firstTagId = tag.ids.first,
                  let details = optionDetails(firstTagId) else { return nil }
            return MiddlewareColor(rawValue: details.relationOptionColor)?.backgroundColor
        case .status(let status):
            guard let details = optionDetails(status.id) else { return nil }
            return MiddlewareColor(rawValue: details.relationOptionColor)?.backgroundColor
        default:
            return nil
        }
    }

    func header(checkboxTitle: String, optionDetails: (String) -> ObjectDetails?) -> SetKanbanColumnHeaderType {
        switch value {
        case .tag(let tag):
            let tags = tag.ids
                .compactMap { optionDetails($0) }
                .map { PropertyOption(details: $0) }
                .map { Property.Tag.Option(option: $0) }
            return tags.isEmpty ? .uncategorized : .tag(tags)
        case .status(let status):
            guard let details = optionDetails(status.id) else {
                return .uncategorized
            }
            let option = PropertyOption(details: details)
            return .status([Property.Status.Option(option: option)])
        case .checkbox(let checkbox):
            return .checkbox(title: checkboxTitle, isChecked: checkbox.checked)
        default:
            return .uncategorized
        }
    }
}
