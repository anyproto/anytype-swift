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

extension NewRelationOptionsSearchPresenter {
    
    func search(text: String) {
        interactor.obtainOptions(for: text) { [weak self] items in
            self?.handleObtainedOptionItems(items)
        }
    }
    
    func didSelectOption(with id: String) {
        if selectedOptionIds.contains(id) {
            selectedOptionIds.removeAll { $0 == id }
        } else {
            selectedOptionIds.append(id)
        }
    }
    
}

private extension NewRelationOptionsSearchPresenter {
    
    func handleObtainedOptionItems(_ items: [RelationOptionSearchItem]) {
        self.items = items
    }
    
}
