import Foundation

/// File loading state
///
/// - loading: File loading prrocess is running and you can access how much are loaded
/// - loaded: File loaded and you can access it by URL
enum FileLoadingState {
    case loading(bytesLoaded: Int64, totalBytesCount: Int64)
    case loaded(URL)
    
    /// Convenience getter for percents complete
    var percentComplete: Float {
        switch self {
        case let .loading(bytesLoaded, totalBytesCount):
            if totalBytesCount > 0 {
                return Float(bytesLoaded) / Float(totalBytesCount)
            }
            return 0
        case .loaded:
            return 1
        }
    }
    
    /// Convenience getter for file URL
    var fileURL: URL? {
        switch self {
        case let .loaded(url):
            return url
        case .loading:
            return nil
        }
    }
}
