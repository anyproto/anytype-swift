import SwiftUI

enum SearchAvailability {
    case unavailable
    case available(placeholder: String)
}

@MainActor
protocol GridItemViewModelProtocol: ObservableObject {
    associatedtype Item: GridItemViewModel

    var searchAvailability: SearchAvailability { get }

    var isLoading: Bool { get }
    var sections: [GridItemSection<Item>] { get }

    func onAppear()
    func didSelectItem(item: Item)
    func didChangeSearchQuery(query: String)
}

extension GridItemViewModelProtocol {
    var isLoading: Bool { false }

    func didChangeSearchQuery(query: String) { }
}

struct GridItemSection<Item: GridItemViewModel>: Identifiable {
    var id: String { "\(title ?? "") \(items.map { String($0.id.hashValue) }.joined(separator: ""))" }
    let title: String?
    let items: [Item]
}

protocol GridItemViewModel: Identifiable, GridItemViewRepresentable {}

protocol GridItemViewRepresentable {
    @MainActor
    var view: AnyView { get }
}

extension GridItemViewModelProtocol {
    func onAppear() { }
}
