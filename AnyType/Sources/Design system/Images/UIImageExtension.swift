import UIKit

extension UIImage {
    static let back = UIImage(named: "TextEditor/Toolbar/Blocks/Back")
    static let more = UIImage(named: "TextEditor/More")
}


extension UIImage {
    enum edititngToolbar {
        static let addNew = UIImage(named: "EditingToolbar/add_new")
        static let style = UIImage(named: "EditingToolbar/style")
        static let move = UIImage(named: "EditingToolbar/move")
        static let mention = UIImage(named: "EditingToolbar/mention")
    }
    
    enum divider {
        static let dots = UIImage(named: "TextEditor/Style/Other/Divider/Dots")
    }
}
