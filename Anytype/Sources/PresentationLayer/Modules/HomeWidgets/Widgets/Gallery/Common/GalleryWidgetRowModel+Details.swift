import Foundation

extension GalleryWidgetRowModel {
    
    init(details: SetContentViewItemConfiguration) {
        self = GalleryWidgetRowModel(
            objectId: details.id,
            title: details.showTitle ? details.title : nil,
            icon: details.showIcon ? details.icon : nil,
            cover: details.coverType,
            onTap: details.onItemTap
        )
    }
}
