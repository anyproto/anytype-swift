import SwiftUI

@MainActor
protocol CheckPopupViewViewModelProtocol: ObservableObject {
    var title: String { get }

    var items: [CheckPopupItem] { get }
}
