import Foundation

extension GalleryWidgetRowModel {
    
    init(details: SetContentViewItemConfiguration) {
        self = GalleryWidgetRowModel(
            objectId: details.id,
            title: details.title,
            icon: details.showIcon ? details.icon : nil,
            coverFit: details.coverFit,
            cover: details.coverType,
            onTap: details.onItemTap
        )
    }
}
