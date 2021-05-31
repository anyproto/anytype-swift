import UIKit
import SwiftUI


struct ProfileModel {
    private let localRepoService = ServiceLocator.shared.localRepoService()
    
    let profiles: [ProfileModel]
    
    enum Avatar {
        case imagePath(String)
    }
    
    struct Profile: Identifiable {
        var id: String
        var name: String
        var avatar: Avatar
        var peers: String? = nil
        var uploaded: Bool
    }
}
