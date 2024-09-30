import Foundation

enum SetObjectViewWidgetRows {
    case compactList(rows: [ListWidgetRowModel]?, id: String)
    case list(rows: [ListWidgetRowModel]?, id: String)
    case gallery(rows: [GalleryWidgetRowModel]?, id: String)
}

extension SetObjectViewWidgetRows {
    var rowsIsNil: Bool {
        switch self {
        case .compactList(let rows, _):
            rows.isNil
        case .list(let rows, _):
            rows.isNil
        case .gallery(let rows, _):
            rows.isNil
        }
    }
}
