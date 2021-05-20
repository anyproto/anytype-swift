
import Foundation

/// Information of picked file
struct FilePickerResultInformation {
    
    /// document URL
    let documentUrl: URL
    
    /// String value of document URL
    var filePath: String { self.documentUrl.relativePath }
    
}
