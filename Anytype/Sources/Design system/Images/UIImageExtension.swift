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
    
    enum blockFile {
        enum empty {
            static let image = UIImage(named: "TextEditor/BlockFile/Empty/Image")
            static let video = UIImage(named: "TextEditor/BlockFile/Empty/Video")
            static let file = UIImage(named: "TextEditor/BlockFile/Empty/File")
            static let bookmark = UIImage(named: "TextEditor/BlockFile/Empty/Bookmark")
        }
        
        enum content {
            static let text = UIImage(named: "TextEditor/BlockFile/Content/Text")
            static let spreadsheet = UIImage(named: "TextEditor/BlockFile/Content/Spreadsheet")
            static let presentation = UIImage(named: "TextEditor/BlockFile/Content/Presentation")
            static let pdf = UIImage(named: "TextEditor/BlockFile/Content/PDF")
            static let image = UIImage(named: "TextEditor/BlockFile/Content/Image")
            static let audio = UIImage(named: "TextEditor/BlockFile/Content/Audio")
            static let video = UIImage(named: "TextEditor/BlockFile/Content/Video")
            static let archive = UIImage(named: "TextEditor/BlockFile/Content/Archive")
            static let other = UIImage(named: "TextEditor/BlockFile/Content/Other")
        }
    }
}
