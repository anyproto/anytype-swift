import UIKit


var windowHolder: WindowHolder? {
    let sceneDeleage = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
    
    return sceneDeleage?.windowHolder
}

enum Constants {
    static let numberOfRowsPerPageInSubscriptions: Int64 = 50
}
