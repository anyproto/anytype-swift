import UIKit.UIColor

struct ObjectHeaderCover: Hashable {
    let coverType: ObjectHeaderCoverType
    
    let onTap: () -> Void
    
}

enum ObjectHeaderCoverType: Hashable {
    case cover(DocumentCover)
    case preview(ObjectHeaderCoverPreviewType)
}

enum ObjectHeaderCoverPreviewType: Hashable {
    case remote(URL)
    case image(UIImage?)
}

extension ObjectHeaderCover {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(coverType)
    }
    
    static func == (lhs: ObjectHeaderCover, rhs: ObjectHeaderCover) -> Bool {
        lhs.coverType == rhs.coverType
    }
    
}
