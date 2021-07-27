import UIKit

extension UIImage {
    static let back = UIImage(named: "TextEditor/Toolbar/Blocks/Back")
    static let more = UIImage(named: "TextEditor/More")
}

extension UIImage {
    enum edititngToolbar {
        static let addNew = createImage("EditingToolbar/add_new")
        static let style = createImage("EditingToolbar/style")
        static let move = createImage("EditingToolbar/move")
        static let mention = createImage("EditingToolbar/mention")
    }
    
    enum divider {
        static let dots = createImage("TextEditor/Style/Other/Divider/Dots")
    }
    
    enum blockFile {
        static let noImage = createImage("TextEditor/no_image")
        
        enum empty {
            static let image = createImage("TextEditor/BlockFile/Empty/Image")
            static let video = createImage("TextEditor/BlockFile/Empty/Video")
            static let file = createImage("TextEditor/BlockFile/Empty/File")
            static let bookmark = createImage("TextEditor/BlockFile/Empty/Bookmark")
        }
        
        enum content {
            static let text = createImage("TextEditor/BlockFile/Content/Text")
            static let spreadsheet = createImage("TextEditor/BlockFile/Content/Spreadsheet")
            static let presentation = createImage("TextEditor/BlockFile/Content/Presentation")
            static let pdf = createImage("TextEditor/BlockFile/Content/PDF")
            static let image = createImage("TextEditor/BlockFile/Content/Image")
            static let audio = createImage("TextEditor/BlockFile/Content/Audio")
            static let video = createImage("TextEditor/BlockFile/Content/Video")
            static let archive = createImage("TextEditor/BlockFile/Content/Archive")
            static let other = createImage("TextEditor/BlockFile/Content/Other")
        }
    }
    
    enum Title {
        enum TodoLayout {
            static let checkbox = createImage("title_todo_checkbox")
            static let checkmark = createImage("title_todo_checkmark")
        }
    }
    
    enum codeBlock {
        static let arrow = createImage("TextEditor/Toolbar/turn_into_arrow")
    }
    
    private static func createImage(_ name: String) -> UIImage {
        guard let image = UIImage(named: name) else {
            assertionFailure("No image named: \(name)")
            return UIImage()
        }
        
        return image
    }
}
