import Foundation

final class RelationFormatsListViewModel: ObservableObject {
    
    let supportedFormatModels: [RelationFormatListCell.Model]
    
    private let onSelect: (SupportedRelationFormat) -> Void
    
    init(onSelect: @escaping (SupportedRelationFormat) -> Void) {
        self.onSelect = onSelect
        self.supportedFormatModels = SupportedRelationFormat.allCases.map {
            RelationFormatListCell.Model(
                id: $0.id,
                title: $0.title,
                icon: $0.icon,
                isSelected: false
            )
        }
    }
    
}

extension RelationFormatsListViewModel {
    
    func didSelectFormat(id: String) {
        guard let format = SupportedRelationFormat(rawValue: id) else { return }
        onSelect(format)
    }
    
}
