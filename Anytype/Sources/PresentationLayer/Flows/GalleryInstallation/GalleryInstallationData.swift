import Foundation

struct GalleryInstallationData: Identifiable, Hashable {
    let type: String
    let source: String
    
    var id: Int { hashValue }
}
