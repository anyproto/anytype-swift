import Foundation

final class NewRelationOptionsSearchPresenter: ObservableObject {
    
    @Published var sections: [RelationOptionsSearchSectionModel] = []
    
    private var selectedOptionIds: [String] = []
    private var result: RelationOptionsSearchResult? = nil

    private let interactor: NewRelationOptionsSearchInteractorInput
    
    init(interactor: NewRelationOptionsSearchInteractorInput) {
        self.interactor = interactor
    }
    
}

// MARK: - Internal functions

extension NewRelationOptionsSearchPresenter {
    
    func search(text: String) {
        interactor.obtainOptions(for: text) { [weak self] result in
            self?.handleObtainedOptionsResult(result)
        }
    }
    
    func didSelectOption(with id: String) {
    }
    
}

// MARK: - Private extension

private extension NewRelationOptionsSearchPresenter {
    
    func handleObtainedOptionsResult(_ result: RelationOptionsSearchResult?) {
        self.result = result
        guard let result = result else {
            self.sections = []
            return
        }
        
        
    }
    
}
