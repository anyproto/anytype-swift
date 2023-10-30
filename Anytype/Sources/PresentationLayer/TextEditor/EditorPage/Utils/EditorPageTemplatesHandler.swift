import Services

protocol EditorPageTemplatesHandlerProtocol {
    func shouldRestartSubscription(objectType: String) -> Bool
}

final class EditorPageTemplatesHandler: EditorPageTemplatesHandlerProtocol {
    private var currentType: String?
    
    func shouldRestartSubscription(objectType: String) -> Bool {
        guard currentType != objectType else { return false }
        currentType = objectType
        return true
    }
}
