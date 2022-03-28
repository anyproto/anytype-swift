import Foundation
import BlocksModels
import AnytypeCore

enum ObjectHeaderImageUsecase {
    case icon
    case cover
    
    func localEvent(path: String) -> LocalEvent {
        switch self {
        case .icon:
            return .header(.iconUploading(path))
        case .cover:
            return .header(.coverUploading(.bundleImagePath(path)))
        }
    }
    
    func updatedDetails(with imageHash: Hash) -> [BundledDetails] {
        switch self {
        case .icon:
            return [.iconEmoji(""), .iconImageHash(imageHash)]
        case .cover:
            return [.coverType(CoverType.uploadedImage), .coverId(imageHash.value)]

        }
    }
    
}
