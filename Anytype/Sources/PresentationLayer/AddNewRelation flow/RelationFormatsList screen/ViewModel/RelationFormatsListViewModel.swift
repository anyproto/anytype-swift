import Foundation
import UIKit

@MainActor
final class RelationFormatsListViewModel: ObservableObject {
    
    let supportedFormatModels: [RelationFormatListCell.Model]

    private let onFormatSelect: (SupportedRelationFormat) -> Void
    
    init(
        selectedFormat: SupportedRelationFormat,
        onFormatSelect: @escaping (SupportedRelationFormat) -> Void
    ) {
        self.onFormatSelect = onFormatSelect
        self.supportedFormatModels = SupportedRelationFormat.allCases.asRelationFormatListCellModels(selectedFormat: selectedFormat)
    }
    
}

// MARK: - Internal functions

extension RelationFormatsListViewModel {
    
    func didSelectFormat(id: String) {
        guard let format = SupportedRelationFormat(rawValue: id) else { return }
        UISelectionFeedbackGenerator().selectionChanged()
        onFormatSelect(format)
    }
    
}

// MARK: - Array private extension

private extension Array where Element == SupportedRelationFormat {
    
    func asRelationFormatListCellModels(selectedFormat: SupportedRelationFormat) -> [RelationFormatListCell.Model] {
        map {
            RelationFormatListCell.Model(
                id: $0.id,
                title: $0.title,
                iconAsset: $0.iconAsset,
                isSelected: $0 == selectedFormat
            )
        }
    }
    
}
