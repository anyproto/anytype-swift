import PhotosUI
import Services

/// Content type to display in picker from gallery
///
/// - images: Images
/// - videos: Videos
enum MediaPickerContentType {
    case images
    case videos
    case audio
    
    /// Filter for system picker
    var filter: PHPickerFilter {
        switch self {
        case .images:
            return .images
        case .videos:
            return .videos
        case .audio:
            return .videos
        }
    }

    var asFileBlockContentType: FileContentType {
        switch self {
        case .images:
            return .image
        case .videos:
            return .video
        case .audio:
            return .audio
        }
    }
}
