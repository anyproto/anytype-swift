import Foundation

final class RelationFormatsViewModel: ObservableObject {
    
    let supportedFormatModels: [RelationFormatCell.Model]
    
    private let onSelect: (SupportedRelationFormat) -> Void
    
    init(onSelect: @escaping (SupportedRelationFormat) -> Void) {
        self.onSelect = onSelect
        self.supportedFormatModels = SupportedRelationFormat.allCases.map {
            RelationFormatCell.Model(
                id: $0.id,
                title: $0.title,
                icon: $0.icon,
                isSelected: false
            )
        }
    }
    
}

extension RelationFormatsViewModel {
    
    func didSelectFormat(id: String) {
        guard let format = SupportedRelationFormat(rawValue: id) else { return }
        onSelect(format)
    }
    
}
