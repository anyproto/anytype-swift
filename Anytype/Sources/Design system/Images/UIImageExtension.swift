import UIKit
import AnytypeCore

extension UIImage {
//    static let backArrow = createImage("backArrow")
//    static let slashMenuBackArrow = createImage("slash_back_arrow")
//    static let searchIcon = createImage("searchTextFieldIcon")
//    static let more = createImage("more")
    
//    static let ghost = createImage(ImageName.ghost)
}

extension UIImage {
//    enum action {
//        static let openToEdit = createImage("open_to_edit")
//    }
    
    enum editor {
//        enum BlockOption {
//            static let addBelow = createImage("TextEditor/BlocksOption/add_below")
//            static let delete = createImage("TextEditor/BlocksOption/delete")
//            static let duplicate = createImage("TextEditor/BlocksOption/duplicate")
//            static let moveTo = createImage("TextEditor/BlocksOption/move_to")
//            static let move = createImage("TextEditor/BlocksOption/move")
//            static let turnInto = createImage("TextEditor/BlocksOption/turn_into_object")
//            static let download = createImage("TextEditor/BlocksOption/download")
//            static let paste = createImage("TextEditor/BlocksOption/paste")
//            static let copy = createImage("TextEditor/BlocksOption/copy")
//            static let preview = createImage("TextEditor/BlocksOption/view")
//
//            // Simple table
//            static let cellMenuClear = createImage("TextEditor/BlocksOption/cell_menu_clear")
//            static let cellMenuColor = createImage("TextEditor/BlocksOption/cell_menu_color")
//            
//            static let columnInsertLeft = createImage("TextEditor/BlocksOption/column_insert_left")
//            static let columnInsertRight = createImage("TextEditor/BlocksOption/column_insert_right")
//            static let columnMoveLeft = createImage("TextEditor/BlocksOption/column_move_left")
//            static let columnMoveRight = createImage("TextEditor/BlocksOption/column_move_right")
//            static let columnSort = createImage("TextEditor/BlocksOption/column_sort")
//
//            static let rowMoveDown = createImage("TextEditor/BlocksOption/row_move_down")
//            static let rowMoveUp = createImage("TextEditor/BlocksOption/row_move_up")
//            static let rowInsertAbove = createImage("TextEditor/BlocksOption/row_insert_above")
//            static let rowInsertBelow = createImage("TextEditor/BlocksOption/row_insert_below")
//        }

//        enum UndoRedo {
//            static let undo = createImage("undo")
//            static let redo = createImage("redo")
//        }

//        static let bigGhost = createImage("TextEditor/bigGhost")
    }
    
//    enum editorNavigation {
//        static let home = createImage("TextEditor/home")
//        static let draft = createImage("draft")
//        static let backArrow = createImage("TextEditor/backArrow")
//        static let forwardArrow = createImage("TextEditor/forwardArrow")
//        static let lockedObject = createImage("TextEditor/locked_object")
//    }
    
    enum edititngToolbar {
        enum ChangeType {
//            static let search = createImage("search")
        }

//        static let addNew = createImage("EditingToolbar/add_new")
//        static let style = createImage("EditingToolbar/style")
//        static let move = createImage("EditingToolbar/move")
//        static let mention = createImage("EditingToolbar/mention")
//        static let actions = createImage("EditingToolbar/actions")
    }
    
//    enum divider {
//        static let dots = createImage("TextEditor/Divider/Dots")
//    }
    
//    enum ObjectIcon {
//        static let checkbox = createImage("todo_checkbox")
//        static let checkmark = createImage("todo_checkmark")
//    }
    
//    enum codeBlock {
//        static let arrow = createImage("TextEditor/turn_into_arrow")
//    }
    
//    enum textAttributes {
//        static let code = createImage("TextAttributes/code")
//        static let url = createImage("TextAttributes/url")
//        static let bold = createImage("TextAttributes/bold")
//        static let italic = createImage("TextAttributes/italic")
//        static let strikethrough = createImage("TextAttributes/strikethrough")
//        static let alignLeft = createImage("TextAttributes/align_left")
//        static let alignRight = createImage("TextAttributes/align_right")
//        static let alignCenter = createImage("TextAttributes/align_center")
//        static let color = createImage("StyleBottomSheet/color")
//    }
    
//    enum Relations {
//        enum Icons {
//            static let phone = createImage("relation_small_phone_icon")
//            static let email = createImage("relation_small_email_icon")
//            static let goToURL = createImage("relation_small_go_to_url_icon")
//            static let locked = createImage("relation_locked")
//        }
//        static let checkboxChecked = createImage("relation_checkbox_checked")
//        static let checkboxUnchecked = createImage("relation_checkbox_unchecked")
//    }
    
    static func createImage(_ name: String) -> UIImage {
        guard let image = UIImage(named: name) else {
            anytypeAssertionFailure("No image named: \(name)", domain: .imageCreation)
            return UIImage()
        }
        
        return image
    }
}
