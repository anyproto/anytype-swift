import Foundation

final class RelationFormatsListViewModel: ObservableObject {
    
    let supportedFormatModels: [RelationFormatListCell.Model]
    
    private weak var output: RelationFormatsListModuleOutput?
    
    init(output: RelationFormatsListModuleOutput) {
        self.output = output
        self.supportedFormatModels = SupportedRelationFormat.allCases.asRelationFormatListCellModels
    }
    
}

extension RelationFormatsListViewModel {
    
    func didSelectFormat(id: String) {
        guard let format = SupportedRelationFormat(rawValue: id) else { return }
        output?.didSelectFormat(format)
    }
    
}

private extension Array where Element == SupportedRelationFormat {
    
    var asRelationFormatListCellModels: [RelationFormatListCell.Model] {
        self.map {
            RelationFormatListCell.Model(
                id: $0.id,
                title: $0.title,
                icon: $0.icon,
                isSelected: false
            )
        }
    }
    
}
