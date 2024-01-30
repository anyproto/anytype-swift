import SwiftUI
import Services

extension ObjectTypeSearchViewModel {
    enum State {
        case showTypes([ObjectType])
        case emptyScreen
    }
}

@MainActor
final class ObjectTypeSearchViewModel: ObservableObject {
    @Published var state = State.showTypes([])
    
    private let onSelect: (_ type: ObjectType) -> Void
    
    private let interactor: ObjectTypeSearchInteractor
    
    nonisolated init(
        onSelect: @escaping (_ type: ObjectType) -> Void,
        interactor: ObjectTypeSearchInteractor
    ) {
        self.onSelect = onSelect
        self.interactor = interactor
    }
    
    func search(text: String) {
        Task {
            let objectTypes = await interactor.search(text: text)
            if objectTypes.isNotEmpty {
                state = .showTypes(objectTypes)
            } else {
                state = .emptyScreen
            }
        }
    }
    
    func didSelectType(_ type: ObjectType) {
        onSelect(type)
    }
}
