import Foundation
import UIKit
import Combine

enum PageCellIcon {
    case emoji(String)
    case image(UIImage?)
}

enum PageCellIconData {
    case emoji(String)
    case imageId(String)
}

final class PageCellData: Identifiable {
    let id: String
    @Published private(set) var icon: PageCellIcon?
    @Published private(set) var title: String
    @Published private(set) var type: String
    
    private var imageSubscription: AnyCancellable?
    private var imageProperty: ImageProperty?
    
    init(id: String, iconData: PageCellIconData?, title: String, type: String) {
        self.id = id
        self.title = title
        self.type = type
        setUpIcon(iconData)        
    }
    
    private func setUpIcon(_ iconData: PageCellIconData?) {
        guard let iconData = iconData else {
            self.icon = nil
            return
        }
        
        switch iconData {
        case let .imageId(imageId):
            let imageProperty = ImageProperty(imageId: imageId, ImageParameters(width: .thumbnail))
            
            self.imageProperty = imageProperty
            self.icon = .image(imageProperty.property)
            
            self.imageSubscription = imageProperty.stream.sink { [weak self] image in
                guard let self = self, let image = image else {
                    return
                }
                
                self.icon = .image(image)
            }
        case let .emoji(emoji):
            self.icon = .emoji(emoji)
            break
        }
    }
}
