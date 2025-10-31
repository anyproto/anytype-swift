import Foundation

enum ObjectTypeWidgetRowType {
    case compactList(rows: [ListWidgetRowModel], availableMoreObjects: Bool)
    case gallery(rows: [GalleryWidgetRowModel], availableMoreObjects: Bool)
}
