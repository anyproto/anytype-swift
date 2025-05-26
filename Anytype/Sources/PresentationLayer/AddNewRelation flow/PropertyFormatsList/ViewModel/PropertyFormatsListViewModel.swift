import Foundation
import UIKit

@MainActor
final class PropertyFormatsListViewModel: ObservableObject {
    
    let supportedFormatModels: [PropertyFormatListCell.Model]

    private let onFormatSelect: (SupportedPropertyFormat) -> Void
    
    init(
        selectedFormat: SupportedPropertyFormat,
        onFormatSelect: @escaping (SupportedPropertyFormat) -> Void
    ) {
        self.onFormatSelect = onFormatSelect
        self.supportedFormatModels = SupportedPropertyFormat.allCases.asPropertyFormatListCellModels(selectedFormat: selectedFormat)
    }
    
}

// MARK: - Internal functions

extension PropertyFormatsListViewModel {
    
    func didSelectFormat(id: String) {
        guard let format = SupportedPropertyFormat(rawValue: id) else { return }
        UISelectionFeedbackGenerator().selectionChanged()
        onFormatSelect(format)
    }
    
}

// MARK: - Array private extension

private extension Array where Element == SupportedPropertyFormat {
    
    func asPropertyFormatListCellModels(selectedFormat: SupportedPropertyFormat) -> [PropertyFormatListCell.Model] {
        map {
            PropertyFormatListCell.Model(
                id: $0.id,
                title: $0.title,
                iconAsset: $0.iconAsset,
                isSelected: $0 == selectedFormat
            )
        }
    }
    
}
