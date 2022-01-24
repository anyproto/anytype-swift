import Foundation
import BlocksModels
import SwiftUI
import Combine

final class TextRelationDetailsViewModel: ObservableObject {
    
    var heightPublisher: Published<CGFloat>.Publisher { $height }
    @Published var height: CGFloat = 0
    
    var onDismiss: () -> Void = {}
    
    @Published var value: String = ""
    
    let type: TextRelationEditingViewType
    
    private let relation: Relation
    private let service: TextRelationDetailsServiceProtocol
        
    private var cancellable: AnyCancellable?
    
    init(
        value: String,
        type: TextRelationEditingViewType,
        relation: Relation,
        service: TextRelationDetailsServiceProtocol
    ) {
        self.value = value
        self.type = type
        self.relation = relation
        self.service = service
        
        cancellable = self.$value
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.saveValue()
            }
    }
    
    var title: String {
        relation.name
    }
    
}

extension TextRelationDetailsViewModel: RelationDetailsViewModelProtocol {
    
    func makeViewController() -> UIViewController {
        TextRelationDetailsViewController(viewModel: self)
    }
}

extension TextRelationDetailsViewModel: RelationEditingViewModelProtocol {
    
    func saveValue() {
        service.saveRelation(value: value, key: relation.id, textType: type)
    }
    
    func makeView() -> AnyView {
        TextRelationDetailsView(viewModel: self).eraseToAnyView()
    }
    
}
