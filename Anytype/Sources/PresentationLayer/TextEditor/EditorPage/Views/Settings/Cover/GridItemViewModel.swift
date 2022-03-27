import SwiftUI

enum SearchAvaliability {
    case none
    case search(placeholder: String)
}

protocol GridItemViewModelProtocol: ObservableObject {
    associatedtype Item: GridItemViewModel

    var searchAvailability: SearchAvaliability { get }

    var isLoading: Bool { get }
    var sections: [GridItemSection<Item>] { get }
    var searchValue: String { get set }

    func onAppear()

    func didSelectItem(item: Item)
}

extension GridItemViewModelProtocol {
    var isLoading: Bool { false }
    var searchValue: String {
        get { "" }
        set { _ = newValue }
    }
    
    func didChangeSearchQuery(query: String) { }
}

struct GridItemSection<Item: GridItemViewModel>: Identifiable {
    var id: String { "\(title ?? "") \(items.map { String($0.id.hashValue) }.joined(separator: ""))" }
    let title: String?
    let items: [Item]
}

protocol GridItemViewModel: Identifiable, GridItemViewRepresentable {}

protocol GridItemViewRepresentable {
    var view: AnyView { get }
}

extension GridItemViewModelProtocol {
    func onAppear() { }
}
