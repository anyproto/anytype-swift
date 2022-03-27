import SwiftUI

protocol GridItemViewModelProtocol: ObservableObject {
    associatedtype Item: GridItemViewModel

    var sections: [GridItemSection<Item>] { get }

    func didSelectItem(item: Item)
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

