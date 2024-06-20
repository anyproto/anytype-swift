import Foundation

enum SetObjectViewWidgetRows {
    case list(rows: [ListWidgetRowModel]?, id: String)
    case gallery(rows: [GalleryWidgetRowModel]?, id: String)
}
