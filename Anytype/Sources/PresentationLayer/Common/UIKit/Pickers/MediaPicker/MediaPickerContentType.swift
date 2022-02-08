import PhotosUI
import BlocksModels

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
    
    var supportedTypeIdentifiers: [String] {
        switch self {
        case .images:
            return [
                UTType.image,
                UTType.ico,
                UTType.icns,
                UTType.png,
                UTType.jpeg,
                UTType.webP,
                UTType.tiff,
                UTType.bmp,
                UTType.svg,
                UTType.rawImage
            ].map { $0.identifier }
        case .videos:
            return [
                UTType.movie,
                UTType.video,
                UTType.quickTimeMovie,
                UTType.mpeg,
                UTType.mpeg2Video,
                UTType.mpeg2TransportStream,
                UTType.mpeg4Movie,
                UTType.appleProtectedMPEG4Video,
                UTType.avi
            ].map { $0.identifier }
        case .audio:
            return [UTType.audio].map(\.identifier)
        }
    }
    
}
