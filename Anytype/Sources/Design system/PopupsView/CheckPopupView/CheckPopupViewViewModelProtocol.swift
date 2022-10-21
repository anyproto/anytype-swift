import SwiftUI

protocol CheckPopupViewViewModelProtocol: ObservableObject {
    var title: String { get }

    var items: [CheckPopupItem] { get }
}
