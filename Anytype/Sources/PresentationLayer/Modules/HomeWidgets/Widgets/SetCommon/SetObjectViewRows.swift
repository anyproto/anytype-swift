import Foundation

enum SetObjectViewWidgetRows {
    case compactList(rows: [ListWidgetRowModel]?, id: String)
    case list(rows: [ListWidgetRowModel]?, id: String)
    case gallery(rows: [GalleryWidgetRowModel]?, id: String)
}
