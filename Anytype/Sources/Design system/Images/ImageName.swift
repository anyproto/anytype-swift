final class ImageName {
    static let ghost = "ghost"
    
    enum slashMenu {
        static let link_to = "slash_menu_link_to"

        enum relations {
            static let addRelation = "slash_menu_addRelation"
        }

        enum groups {
            static let actions = "slash_menu_group_actions"
            static let media = "slash_menu_group_media"
            static let objects = "slash_menu_group_objects"
            static let other = "slash_menu_group_other"
            static let relation = "slash_menu_group_relation"
            static let style = "slash_menu_group_style"
            static let alignment = "slash_menu_alignment_left"
        }
        
        enum style {
            static let bold = "slash_menu_style_bold"
            static let bulleted = "slash_menu_style_bulleted"
            static let checkbox = "slash_menu_style_checkbox"
            static let code = "slash_menu_style_code"
            static let heading = "slash_menu_style_heading"
            static let highlighted = "slash_menu_style_highlighted"
            static let callout = "slash_menu_style_callout"
            static let italic = "slash_menu_style_italic"
            static let link = "slash_menu_style_link"
            static let numbered = "slash_menu_style_numbered"
            static let strikethrough = "slash_menu_style_strikethrough"
            static let subheading = "slash_menu_style_subheading"
            static let text = "slash_menu_style_text"
            static let title = "slash_menu_style_title"
            static let toggle = "slash_menu_style_toggle"            
        }
        
        enum actions {
            static let clear = "slash_menu_action_clear"
            static let copy = "slash_menu_action_copy"
            static let delete = "delete"
            static let duplicate = "slash_menu_action_duplicate"
            static let move = "slash_menu_action_move"
            static let moveTo = "slash_menu_action_moveTo"
            static let paste = "slash_menu_action_paste"
        }
        
        enum alignment {
            static let center = "slash_menu_alignment_center"
            static let left = "slash_menu_alignment_left"
            static let right = "slash_menu_alignment_right"
        }
        
        enum media {
            static let bookmark = "slash_menu_media_bookmark"
            static let code = "slash_menu_media_code"
            static let file = "slash_menu_media_file"
            static let video = "slash_menu_media_video"
            static let audio = "slash_menu_media_audio"
            static let picture = "slash_menu_media_picture"
        }
        
        enum other {
            static let dots_divider = "slash_menu_dots_divider"
            static let line_divider = "slash_menu_line_divider"
            static let table_of_contents = "slash_menu_table_of_contents"
        }
    }

    enum ObjectPreview {
        static let card = "card"
        static let text = "text"
    }
}
