import Foundation

final class SelectionOptionsViewModel: ObservableObject {
    @Published var options = [HorizontalListItem]()
}
