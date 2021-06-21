import SwiftUI

class BlockToolbarAddBlockCellViewModel: ObservableObject, Identifiable {
    @Published var indexPath: IndexPath?
    let section: Int
    let index: Int
    let title: String
    let subtitle: String
    let imageResource: String // path to image
    
    func pressed() {
        self.indexPath = .init(item: self.index, section: self.section)
    }
    
    func configured(indexPathStream: Published<IndexPath?>) -> Self {
        self._indexPath = indexPathStream
        return self
    }
            
    internal init(section: Int, index: Int, title: String, subtitle: String, imageResource: String) {
        self.section = section
        self.index = index
        self.title = title
        self.subtitle = subtitle
        self.imageResource = imageResource
    }
    
    // MARK: - Identifiable
    var id: IndexPath {
        .init(row: self.index, section: self.section)
    }
}
