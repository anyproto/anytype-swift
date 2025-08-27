import Foundation

struct InfoSelectionOption: Identifiable, Hashable {
    let icon: ImageAsset
    let title: String
    let analyticsValue: String
    
    var id: Int { hashValue }
}
