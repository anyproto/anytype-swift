import Foundation

struct AttributedStringChange {
    
    let changeAttributes: [NSAttributedString.Key: Any]
    let deletedKeys: [NSAttributedString.Key]
    
    init(
        changeAttributes: [NSAttributedString.Key: Any] = [:],
        deletedKeys: [NSAttributedString.Key] = []
    ) {
        self.changeAttributes = changeAttributes
        self.deletedKeys = deletedKeys
    }
    
}
