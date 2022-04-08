import Foundation

final class RelationFormatsListViewModel: ObservableObject {
    
    let supportedFormatModels: [RelationFormatListCell.Model]
    
    private weak var output: RelationFormatsListModuleOutput?
    
    init(output: RelationFormatsListModuleOutput) {
        self.output = output
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
        output?.didSelectFormat(format)
    }
    
}
