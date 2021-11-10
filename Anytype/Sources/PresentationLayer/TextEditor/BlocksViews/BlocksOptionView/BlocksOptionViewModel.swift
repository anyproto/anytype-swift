import Foundation

final class BlocksOptionViewModel: ObservableObject {
    @Published var options = BlocksOptionItem.allCases

    var tapHandler: ((BlocksOptionItem) -> Void)?
}
