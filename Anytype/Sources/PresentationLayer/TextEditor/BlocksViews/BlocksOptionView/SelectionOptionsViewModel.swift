import Foundation
import Combine

struct SelectionOptionsItemViewModel: Identifiable, Hashable {
    let id: String
    let title: String
    let imageAsset: ImageAsset

    @EquatableNoop var action: () -> Void
}

protocol OptionsItemProvider: AnyObject {
    var optionsPublisher: AnyPublisher<[SelectionOptionsItemViewModel], Never> { get }
}

final class SelectionOptionsViewModel: ObservableObject {
    @Published var items = [SelectionOptionsItemViewModel]()
    
    private var cancellables = [AnyCancellable]()

    init(itemProvider: OptionsItemProvider?) {
        itemProvider?.optionsPublisher.sink { [weak self] types in
            self?.items = types
        }.store(in: &cancellables)
    }
}
