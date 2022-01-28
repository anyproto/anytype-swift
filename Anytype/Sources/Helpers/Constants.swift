import UIKit


var windowHolder: WindowHolder? {
    let sceneDeleage = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
    
    return sceneDeleage?.windowHolder
}
