import Foundation

struct InfoSelectionOption: Identifiable, Hashable {
    let icon: ImageAsset
    let title: String
    
    var id: Int { hashValue }
}
