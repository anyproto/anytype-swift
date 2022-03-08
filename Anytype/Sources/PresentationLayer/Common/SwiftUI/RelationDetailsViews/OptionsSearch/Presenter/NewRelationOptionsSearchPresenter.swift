import Foundation

final class NewRelationOptionsSearchPresenter: ObservableObject {
    
    @Published var sections: [RelationOptionsSearchSectionModel] = []
    
    private var selectedOptionIds: [String] = []
    private var items: [RelationOptionSearchItem] = []

    private let interactor: NewRelationOptionsSearchInteractorInput
    
    init(interactor: NewRelationOptionsSearchInteractorInput) {
        self.interactor = interactor
    }
    
}

// MARK: - Internal functions

extension NewRelationOptionsSearchPresenter {
    
    func search(text: String) {
        interactor.obtainOptions(for: text) { [weak self] items in
            self?.handleObtainedOptionItems(items)
        }
    }
    
    func didSelectOption(with id: String) {
    }
    
}

// MARK: - Private extension

private extension NewRelationOptionsSearchPresenter {
    
    func handleObtainedOptionItems(_ items: [RelationOptionSearchItem]) {
        self.items = items
    }
    
}
