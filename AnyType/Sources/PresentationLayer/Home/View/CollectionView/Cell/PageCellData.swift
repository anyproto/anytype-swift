import Foundation

extension PageCellData {
    enum PageCellDataIcon {
        case emoji(String)
        case pic(String)
        case none
    }
}

struct PageCellData: Identifiable {
    let icon: PageCellDataIcon
    let title: String
    let type: String
    let id = UUID()
}
