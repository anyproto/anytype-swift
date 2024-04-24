import Foundation
import UIKit

final class RelationFormatsListViewModel: ObservableObject {
    
    let supportedFormatModels: [RelationFormatListCell.Model]
    
    private weak var output: RelationFormatsListModuleOutput?
    
    init(
        selectedFormat: SupportedRelationFormat,
        output: RelationFormatsListModuleOutput?
    ) {
        self.output = output
        self.supportedFormatModels = SupportedRelationFormat.allCases.asRelationFormatListCellModels(selectedFormat: selectedFormat)
    }
    
}

// MARK: - Internal functions

extension RelationFormatsListViewModel {
    
    func didSelectFormat(id: String) {
        guard let format = SupportedRelationFormat(rawValue: id) else { return }
        UISelectionFeedbackGenerator().selectionChanged()
        output?.didSelectFormat(format)
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
