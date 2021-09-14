import UIKit

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let documentsDirectory = paths[0]
    
    return documentsDirectory
}

var windowHolder: WindowHolder? {
    let sceneDeleage = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
    
    return sceneDeleage?.windowHolder
}
