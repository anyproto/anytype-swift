import Foundation

final class NewRelationOptionsSearchPresenter: ObservableObject {
    
    @Published var sections: [RelationOptionsSearchSectionModel] = []
    
    private let interactor: NewRelationOptionsSearchInteractorInput
    
    init(interactor: NewRelationOptionsSearchInteractorInput) {
        self.interactor = interactor
    }
    
}

extension NewRelationOptionsSearchPresenter {
    
    func search(text: String) {
        interactor.obtainOptions(for: text) { items in
            // handleItems
        }
    }
    
}
