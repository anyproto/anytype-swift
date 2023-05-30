// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen


// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal extension ImageAsset {
  static let play = ImageAsset.bundle(name: "play")
  static let authPhotoIcon = ImageAsset.bundle(name: "auth_photo_icon")
  static let arrowDown = ImageAsset.bundle(name: "arrowDown")
  static let arrowForward = ImageAsset.bundle(name: "arrowForward")
  static let backArrow = ImageAsset.bundle(name: "backArrow")
  static let ghost = ImageAsset.bundle(name: "ghost")
  static let logo = ImageAsset.bundle(name: "logo")
  static let more = ImageAsset.bundle(name: "more")
  static let noImage = ImageAsset.bundle(name: "no_image")
  static let optionChecked = ImageAsset.bundle(name: "option_checked")
  static let plus = ImageAsset.bundle(name: "plus")
  enum EditingToolbar {
    static let move = ImageAsset.bundle(name: "EditingToolbar/move")
    static let style = ImageAsset.bundle(name: "EditingToolbar/style")
  }
  enum Emoji {
    }
  enum FileTypes {
    static let archive = ImageAsset.bundle(name: "FileTypes/Archive")
    static let audio = ImageAsset.bundle(name: "FileTypes/Audio")
    static let image = ImageAsset.bundle(name: "FileTypes/Image")
    static let other = ImageAsset.bundle(name: "FileTypes/Other")
    static let pdf = ImageAsset.bundle(name: "FileTypes/PDF")
    static let presentation = ImageAsset.bundle(name: "FileTypes/Presentation")
    static let spreadsheet = ImageAsset.bundle(name: "FileTypes/Spreadsheet")
    static let text = ImageAsset.bundle(name: "FileTypes/Text")
    static let video = ImageAsset.bundle(name: "FileTypes/Video")
  }
  static let createNewObject = ImageAsset.bundle(name: "createNewObject")
  enum Migration {
    static let close = ImageAsset.bundle(name: "Migration/Close")
  }
  static let taskChecked = ImageAsset.bundle(name: "task_checked")
  static let taskUnchecked = ImageAsset.bundle(name: "task_unchecked")
  static let todoCheckbox = ImageAsset.bundle(name: "todo_checkbox")
  static let todoCheckmark = ImageAsset.bundle(name: "todo_checkmark")
  static let card = ImageAsset.bundle(name: "card")
  static let text = ImageAsset.bundle(name: "text")
  static let addNew = ImageAsset.bundle(name: "addNew")
  static let addToFavorites = ImageAsset.bundle(name: "addToFavorites")
  static let delete = ImageAsset.bundle(name: "delete")
  static let duplicate = ImageAsset.bundle(name: "duplicate")
  static let linkToItself = ImageAsset.bundle(name: "link_to_itself")
  static let lock = ImageAsset.bundle(name: "lock")
  static let moveTo = ImageAsset.bundle(name: "moveTo")
  static let restore = ImageAsset.bundle(name: "restore")
  static let search = ImageAsset.bundle(name: "search")
  static let undoredo = ImageAsset.bundle(name: "undoredo")
  static let unfavorite = ImageAsset.bundle(name: "unfavorite")
  static let unlock = ImageAsset.bundle(name: "unlock")
  static let layoutSettingsBasic = ImageAsset.bundle(name: "layout_settings_basic")
  static let layoutSettingsNote = ImageAsset.bundle(name: "layout_settings_note")
  static let layoutSettingsProfile = ImageAsset.bundle(name: "layout_settings_profile")
  static let layoutSettingsTodo = ImageAsset.bundle(name: "layout_settings_todo")
  static let relationSmallCopy = ImageAsset.bundle(name: "relation_small_copy")
  static let relationSmallEmailIcon = ImageAsset.bundle(name: "relation_small_email_icon")
  static let relationSmallOpenLink = ImageAsset.bundle(name: "relation_small_open_link")
  static let relationSmallPhoneIcon = ImageAsset.bundle(name: "relation_small_phone_icon")
  static let relationSmallReload = ImageAsset.bundle(name: "relation_small_reload")
  static let relationAddToFeatured = ImageAsset.bundle(name: "relation_add_to_featured")
  static let relationCheckboxChecked = ImageAsset.bundle(name: "relation_checkbox_checked")
  static let relationCheckboxUnchecked = ImageAsset.bundle(name: "relation_checkbox_unchecked")
  static let relationLocked = ImageAsset.bundle(name: "relation_locked")
  static let relationLockedSmall = ImageAsset.bundle(name: "relation_locked_small")
  static let relationNew = ImageAsset.bundle(name: "relation_new")
  static let relationRemoveFromFeatured = ImageAsset.bundle(name: "relation_remove_from_featured")
  static let redo = ImageAsset.bundle(name: "redo")
  static let undo = ImageAsset.bundle(name: "undo")
  static let objectSettingsCover = ImageAsset.bundle(name: "object_settings_cover")
  static let objectSettingsIcon = ImageAsset.bundle(name: "object_settings_icon")
  static let objectSettingsLayout = ImageAsset.bundle(name: "object_settings_layout")
  static let objectSettingsRelations = ImageAsset.bundle(name: "object_settings_relations")
  enum PageBlock {
    static let checkboxChecked = ImageAsset.bundle(name: "PageBlock/checkbox_checked")
    static let checkboxUnchecked = ImageAsset.bundle(name: "PageBlock/checkbox_unchecked")
  }
  static let webPage = ImageAsset.bundle(name: "web_page")
  static let searchTextFieldIcon = ImageAsset.bundle(name: "searchTextFieldIcon")
  static let setGalleryView = ImageAsset.bundle(name: "set_gallery_view")
  static let setGridView = ImageAsset.bundle(name: "set_grid_view")
  static let setImagePlaceholder = ImageAsset.bundle(name: "set_image_placeholder")
  static let setKanbanView = ImageAsset.bundle(name: "set_kanban_view")
  static let setListView = ImageAsset.bundle(name: "set_list_view")
  static let setOpenToEdit = ImageAsset.bundle(name: "set_open_to_edit")
  static let setPaginationArrowBackward = ImageAsset.bundle(name: "set_pagination_arrow_backward")
  static let setPaginationArrowForward = ImageAsset.bundle(name: "set_pagination_arrow_forward")
  static let setPenEdit = ImageAsset.bundle(name: "set_pen_edit")
  static let setSettings = ImageAsset.bundle(name: "set_settings")
  static let setSettingsSettings = ImageAsset.bundle(name: "set_settings_settings")
  static let setSettinsFilter = ImageAsset.bundle(name: "set_settins_filter")
  static let setSettinsGroup = ImageAsset.bundle(name: "set_settins_group")
  static let setSettinsSort = ImageAsset.bundle(name: "set_settins_sort")
  static let setSettinsView = ImageAsset.bundle(name: "set_settins_view")
  enum Settings {
    enum Theme {
      static let dark = ImageAsset.bundle(name: "Settings/Theme/dark")
      static let light = ImageAsset.bundle(name: "Settings/Theme/light")
      static let system = ImageAsset.bundle(name: "Settings/Theme/system")
    }
    static let about = ImageAsset.bundle(name: "Settings/about")
    static let accountAndData = ImageAsset.bundle(name: "Settings/account_and_data")
    static let appearance = ImageAsset.bundle(name: "Settings/appearance")
    static let debug = ImageAsset.bundle(name: "Settings/debug")
    static let fileStorage = ImageAsset.bundle(name: "Settings/fileStorage")
    static let personalization = ImageAsset.bundle(name: "Settings/personalization")
    static let setKeychainPhrase = ImageAsset.bundle(name: "Settings/set_keychain_phrase")
    static let setPinCode = ImageAsset.bundle(name: "Settings/set_pin_code")
    static let setWallpaper = ImageAsset.bundle(name: "Settings/set_wallpaper")
  }
  static let slashMenuActionClear = ImageAsset.bundle(name: "slash_menu_action_clear")
  static let slashMenuActionCopy = ImageAsset.bundle(name: "slash_menu_action_copy")
  static let slashMenuActionDuplicate = ImageAsset.bundle(name: "slash_menu_action_duplicate")
  static let slashMenuActionMove = ImageAsset.bundle(name: "slash_menu_action_move")
  static let slashMenuActionMoveTo = ImageAsset.bundle(name: "slash_menu_action_moveTo")
  static let slashMenuActionPaste = ImageAsset.bundle(name: "slash_menu_action_paste")
  static let slashMenuAlignmentCenter = ImageAsset.bundle(name: "slash_menu_alignment_center")
  static let slashMenuAlignmentLeft = ImageAsset.bundle(name: "slash_menu_alignment_left")
  static let slashMenuAlignmentRight = ImageAsset.bundle(name: "slash_menu_alignment_right")
  static let slashMenuMediaAudio = ImageAsset.bundle(name: "slash_menu_media_audio")
  static let slashMenuMediaBookmark = ImageAsset.bundle(name: "slash_menu_media_bookmark")
  static let slashMenuMediaCode = ImageAsset.bundle(name: "slash_menu_media_code")
  static let slashMenuMediaFile = ImageAsset.bundle(name: "slash_menu_media_file")
  static let slashMenuMediaPicture = ImageAsset.bundle(name: "slash_menu_media_picture")
  static let slashMenuMediaVideo = ImageAsset.bundle(name: "slash_menu_media_video")
  static let slashMenuDotsDivider = ImageAsset.bundle(name: "slash_menu_dots_divider")
  static let slashMenuLineDivider = ImageAsset.bundle(name: "slash_menu_line_divider")
  static let slashMenuTable = ImageAsset.bundle(name: "slash_menu_table")
  static let slashMenuTableOfContents = ImageAsset.bundle(name: "slash_menu_table_of_contents")
  static let slashMenuStyleBold = ImageAsset.bundle(name: "slash_menu_style_bold")
  static let slashMenuStyleBulleted = ImageAsset.bundle(name: "slash_menu_style_bulleted")
  static let slashMenuStyleCallout = ImageAsset.bundle(name: "slash_menu_style_callout")
  static let slashMenuStyleCheckbox = ImageAsset.bundle(name: "slash_menu_style_checkbox")
  static let slashMenuStyleCode = ImageAsset.bundle(name: "slash_menu_style_code")
  static let slashMenuStyleHeading = ImageAsset.bundle(name: "slash_menu_style_heading")
  static let slashMenuStyleHighlighted = ImageAsset.bundle(name: "slash_menu_style_highlighted")
  static let slashMenuStyleItalic = ImageAsset.bundle(name: "slash_menu_style_italic")
  static let slashMenuStyleLink = ImageAsset.bundle(name: "slash_menu_style_link")
  static let slashMenuStyleNumbered = ImageAsset.bundle(name: "slash_menu_style_numbered")
  static let slashMenuStyleStrikethrough = ImageAsset.bundle(name: "slash_menu_style_strikethrough")
  static let slashMenuStyleSubheading = ImageAsset.bundle(name: "slash_menu_style_subheading")
  static let slashMenuStyleText = ImageAsset.bundle(name: "slash_menu_style_text")
  static let slashMenuStyleTitle = ImageAsset.bundle(name: "slash_menu_style_title")
  static let slashMenuStyleToggle = ImageAsset.bundle(name: "slash_menu_style_toggle")
  static let slashMenuGroupActions = ImageAsset.bundle(name: "slash_menu_group_actions")
  static let slashMenuGroupMedia = ImageAsset.bundle(name: "slash_menu_group_media")
  static let slashMenuGroupObjects = ImageAsset.bundle(name: "slash_menu_group_objects")
  static let slashMenuGroupOther = ImageAsset.bundle(name: "slash_menu_group_other")
  static let slashMenuGroupRelation = ImageAsset.bundle(name: "slash_menu_group_relation")
  static let slashMenuGroupStyle = ImageAsset.bundle(name: "slash_menu_group_style")
  enum Format {
    static let attachment = ImageAsset.bundle(name: "format/attachment")
    static let checkbox = ImageAsset.bundle(name: "format/checkbox")
    static let date = ImageAsset.bundle(name: "format/date")
    static let email = ImageAsset.bundle(name: "format/email")
    static let name = ImageAsset.bundle(name: "format/name")
    static let number = ImageAsset.bundle(name: "format/number")
    static let object = ImageAsset.bundle(name: "format/object")
    static let phone = ImageAsset.bundle(name: "format/phone")
    static let status = ImageAsset.bundle(name: "format/status")
    static let tag = ImageAsset.bundle(name: "format/tag")
    static let text = ImageAsset.bundle(name: "format/text")
    static let unknown = ImageAsset.bundle(name: "format/unknown")
    static let url = ImageAsset.bundle(name: "format/url")
  }
  static let slashMenuAddRelation = ImageAsset.bundle(name: "slash_menu_addRelation")
  static let slashBackArrow = ImageAsset.bundle(name: "slash_back_arrow")
  static let slashMenuLinkTo = ImageAsset.bundle(name: "slash_menu_link_to")
  enum StyleBottomSheet {
    static let bullet = ImageAsset.bundle(name: "StyleBottomSheet/bullet")
    static let checkbox = ImageAsset.bundle(name: "StyleBottomSheet/checkbox")
    static let color = ImageAsset.bundle(name: "StyleBottomSheet/color")
    static let numbered = ImageAsset.bundle(name: "StyleBottomSheet/numbered")
    static let toggle = ImageAsset.bundle(name: "StyleBottomSheet/toggle")
  }
  enum TextStyles {
    enum Align {
      static let center = ImageAsset.bundle(name: "Text Styles/Align/Center")
      static let `left` = ImageAsset.bundle(name: "Text Styles/Align/Left")
      static let `right` = ImageAsset.bundle(name: "Text Styles/Align/Right")
    }
    static let bold = ImageAsset.bundle(name: "Text Styles/Bold")
    static let code = ImageAsset.bundle(name: "Text Styles/Code")
    static let embed = ImageAsset.bundle(name: "Text Styles/Embed")
    static let italic = ImageAsset.bundle(name: "Text Styles/Italic")
    static let strikethrough = ImageAsset.bundle(name: "Text Styles/Strikethrough")
    static let underline = ImageAsset.bundle(name: "Text Styles/Underline")
  }
  enum TextEditor {
    enum BlockFile {
      enum Empty {
        static let bookmark = ImageAsset.bundle(name: "TextEditor/BlockFile/Empty/Bookmark")
        static let file = ImageAsset.bundle(name: "TextEditor/BlockFile/Empty/File")
        static let image = ImageAsset.bundle(name: "TextEditor/BlockFile/Empty/Image")
        static let video = ImageAsset.bundle(name: "TextEditor/BlockFile/Empty/Video")
      }
    }
    enum BlocksOption {
      static let addBelow = ImageAsset.bundle(name: "TextEditor/BlocksOption/add_below")
      static let cellMenuClearContents = ImageAsset.bundle(name: "TextEditor/BlocksOption/cell_menu_clear_contents")
      static let cellMenuClearStyle = ImageAsset.bundle(name: "TextEditor/BlocksOption/cell_menu_clear_style")
      static let cellMenuColor = ImageAsset.bundle(name: "TextEditor/BlocksOption/cell_menu_color")
      static let columnInsertLeft = ImageAsset.bundle(name: "TextEditor/BlocksOption/column_insert_left")
      static let columnInsertRight = ImageAsset.bundle(name: "TextEditor/BlocksOption/column_insert_right")
      static let columnMoveLeft = ImageAsset.bundle(name: "TextEditor/BlocksOption/column_move_left")
      static let columnMoveRight = ImageAsset.bundle(name: "TextEditor/BlocksOption/column_move_right")
      static let columnSort = ImageAsset.bundle(name: "TextEditor/BlocksOption/column_sort")
      static let copy = ImageAsset.bundle(name: "TextEditor/BlocksOption/copy")
      static let delete = ImageAsset.bundle(name: "TextEditor/BlocksOption/delete")
      static let download = ImageAsset.bundle(name: "TextEditor/BlocksOption/download")
      static let duplicate = ImageAsset.bundle(name: "TextEditor/BlocksOption/duplicate")
      static let move = ImageAsset.bundle(name: "TextEditor/BlocksOption/move")
      static let moveTo = ImageAsset.bundle(name: "TextEditor/BlocksOption/move_to")
      static let openToEdit = ImageAsset.bundle(name: "TextEditor/BlocksOption/open_to_edit")
      static let paste = ImageAsset.bundle(name: "TextEditor/BlocksOption/paste")
      static let rowInsertAbove = ImageAsset.bundle(name: "TextEditor/BlocksOption/row_insert_above")
      static let rowInsertBelow = ImageAsset.bundle(name: "TextEditor/BlocksOption/row_insert_below")
      static let rowMoveDown = ImageAsset.bundle(name: "TextEditor/BlocksOption/row_move_down")
      static let rowMoveUp = ImageAsset.bundle(name: "TextEditor/BlocksOption/row_move_up")
      static let turnIntoObject = ImageAsset.bundle(name: "TextEditor/BlocksOption/turn_into_object")
      static let view = ImageAsset.bundle(name: "TextEditor/BlocksOption/view")
    }
    static let turnIntoArrow = ImageAsset.bundle(name: "TextEditor/turn_into_arrow")
    enum Divider {
      static let dots = ImageAsset.bundle(name: "TextEditor/Divider/Dots")
    }
    static let lockedObject = ImageAsset.bundle(name: "TextEditor/locked_object")
    static let search = ImageAsset.bundle(name: "TextEditor/search")
    static let shimmering = ImageAsset.bundle(name: "TextEditor/shimmering")
    enum Text {
      static let checked = ImageAsset.bundle(name: "TextEditor/Text/checked")
      static let folded = ImageAsset.bundle(name: "TextEditor/Text/folded")
      static let unchecked = ImageAsset.bundle(name: "TextEditor/Text/unchecked")
    }
    static let bigGhost = ImageAsset.bundle(name: "TextEditor/bigGhost")
    static let questionMark = ImageAsset.bundle(name: "TextEditor/questionMark")
  }
  static let toastFailure = ImageAsset.bundle(name: "toast_failure")
  static let toastTick = ImageAsset.bundle(name: "toast_tick")
  enum Widget {
    enum Preview {
      static let link = ImageAsset.bundle(name: "Widget/Preview/link")
      static let list = ImageAsset.bundle(name: "Widget/Preview/list")
      static let tree = ImageAsset.bundle(name: "Widget/Preview/tree")
    }
    static let add = ImageAsset.bundle(name: "Widget/add")
    static let bin = ImageAsset.bundle(name: "Widget/bin")
    static let collapse = ImageAsset.bundle(name: "Widget/collapse")
    static let collection = ImageAsset.bundle(name: "Widget/collection")
    static let dot = ImageAsset.bundle(name: "Widget/dot")
    static let search = ImageAsset.bundle(name: "Widget/search")
    static let `set` = ImageAsset.bundle(name: "Widget/set")
    static let settings = ImageAsset.bundle(name: "Widget/settings")
    static let tick = ImageAsset.bundle(name: "Widget/tick")
  }
  static let splashLogo = ImageAsset.bundle(name: "splash_logo")
  enum X24 {
    static let add = ImageAsset.bundle(name: "x24/Add")
    enum Arrow {
      static let down = ImageAsset.bundle(name: "x24/Arrow/Down")
      static let `left` = ImageAsset.bundle(name: "x24/Arrow/Left")
      static let `right` = ImageAsset.bundle(name: "x24/Arrow/Right")
      static let up = ImageAsset.bundle(name: "x24/Arrow/Up")
    }
    static let attachment = ImageAsset.bundle(name: "x24/Attachment")
    static let checkbox = ImageAsset.bundle(name: "x24/Checkbox")
    static let close = ImageAsset.bundle(name: "x24/Close")
    static let copy = ImageAsset.bundle(name: "x24/Copy")
    static let customizeView = ImageAsset.bundle(name: "x24/Customize View")
    static let database = ImageAsset.bundle(name: "x24/Database")
    static let date = ImageAsset.bundle(name: "x24/Date")
    static let email = ImageAsset.bundle(name: "x24/Email")
    static let embed = ImageAsset.bundle(name: "x24/Embed")
    static let empty = ImageAsset.bundle(name: "x24/Empty")
    enum Favorite {
      static let favorite = ImageAsset.bundle(name: "x24/Favorite/Favorite")
      static let unfavorite = ImageAsset.bundle(name: "x24/Favorite/Unfavorite")
    }
    static let folder = ImageAsset.bundle(name: "x24/Folder")
    static let more = ImageAsset.bundle(name: "x24/More")
    static let name = ImageAsset.bundle(name: "x24/Name")
    static let number = ImageAsset.bundle(name: "x24/Number")
    static let object = ImageAsset.bundle(name: "x24/Object")
    static let openToEdit = ImageAsset.bundle(name: "x24/Open to Edit")
    static let `open` = ImageAsset.bundle(name: "x24/Open")
    static let phoneNumber = ImageAsset.bundle(name: "x24/Phone Number")
    static let plus = ImageAsset.bundle(name: "x24/Plus")
    static let relations = ImageAsset.bundle(name: "x24/Relations")
    static let removeRed = ImageAsset.bundle(name: "x24/Remove Red")
    static let replace = ImageAsset.bundle(name: "x24/Replace")
    static let simpleTables = ImageAsset.bundle(name: "x24/Simple Tables")
    static let status = ImageAsset.bundle(name: "x24/Status")
    static let tag = ImageAsset.bundle(name: "x24/Tag")
    static let text = ImageAsset.bundle(name: "x24/Text")
    static let tick = ImageAsset.bundle(name: "x24/Tick")
    static let url = ImageAsset.bundle(name: "x24/Url")
    enum View {
      static let gallery = ImageAsset.bundle(name: "x24/View/Gallery")
      static let kanban = ImageAsset.bundle(name: "x24/View/Kanban")
      static let list = ImageAsset.bundle(name: "x24/View/List")
      static let table = ImageAsset.bundle(name: "x24/View/Table")
    }
  }
  enum X32 {
    static let actions = ImageAsset.bundle(name: "x32/Actions")
    static let actions2 = ImageAsset.bundle(name: "x32/Actions2")
    static let addBelow = ImageAsset.bundle(name: "x32/Add Below")
    enum AddColumn {
      static let above = ImageAsset.bundle(name: "x32/Add Column/Above")
      static let below = ImageAsset.bundle(name: "x32/Add Column/Below")
      static let `left` = ImageAsset.bundle(name: "x32/Add Column/Left")
      static let `right` = ImageAsset.bundle(name: "x32/Add Column/Right")
    }
    static let addNew = ImageAsset.bundle(name: "x32/Add New")
    enum Align {
      static let center = ImageAsset.bundle(name: "x32/Align/Center")
      static let `left` = ImageAsset.bundle(name: "x32/Align/Left")
      static let `right` = ImageAsset.bundle(name: "x32/Align/Right")
    }
    enum Arrow {
      static let down = ImageAsset.bundle(name: "x32/Arrow/Down")
      static let `left` = ImageAsset.bundle(name: "x32/Arrow/Left")
      static let `right` = ImageAsset.bundle(name: "x32/Arrow/Right")
      static let up = ImageAsset.bundle(name: "x32/Arrow/Up")
    }
    static let audo = ImageAsset.bundle(name: "x32/Audo")
    static let bookmark = ImageAsset.bundle(name: "x32/Bookmark")
    static let clear = ImageAsset.bundle(name: "x32/Clear")
    static let color = ImageAsset.bundle(name: "x32/Color")
    static let copy = ImageAsset.bundle(name: "x32/Copy")
    static let dashboard = ImageAsset.bundle(name: "x32/Dashboard")
    static let delete = ImageAsset.bundle(name: "x32/Delete")
    static let download = ImageAsset.bundle(name: "x32/Download")
    static let dragDrop = ImageAsset.bundle(name: "x32/Drag & Drop")
    static let duplicate = ImageAsset.bundle(name: "x32/Duplicate")
    static let edit = ImageAsset.bundle(name: "x32/Edit")
    static let empty = ImageAsset.bundle(name: "x32/Empty")
    static let export = ImageAsset.bundle(name: "x32/Export")
    enum Favorite {
      static let favorite = ImageAsset.bundle(name: "x32/Favorite/Favorite")
      static let unfavorite = ImageAsset.bundle(name: "x32/Favorite/Unfavorite")
    }
    static let file = ImageAsset.bundle(name: "x32/File")
    static let filter = ImageAsset.bundle(name: "x32/Filter")
    static let group = ImageAsset.bundle(name: "x32/Group")
    static let image = ImageAsset.bundle(name: "x32/Image")
    enum Insert {
      static let `left` = ImageAsset.bundle(name: "x32/Insert/Left")
      static let `right` = ImageAsset.bundle(name: "x32/Insert/Right")
    }
    enum Lock {
      static let lock = ImageAsset.bundle(name: "x32/Lock/Lock")
      static let unlock = ImageAsset.bundle(name: "x32/Lock/Unlock")
    }
    static let mention = ImageAsset.bundle(name: "x32/Mention")
    enum MoveColumn {
      static let down = ImageAsset.bundle(name: "x32/Move Column/Down")
      static let `left` = ImageAsset.bundle(name: "x32/Move Column/Left")
      static let `right` = ImageAsset.bundle(name: "x32/Move Column/Right")
      static let up = ImageAsset.bundle(name: "x32/Move Column/Up")
    }
    static let moveTo = ImageAsset.bundle(name: "x32/Move To")
    static let move = ImageAsset.bundle(name: "x32/Move")
    static let navigation = ImageAsset.bundle(name: "x32/Navigation")
    static let openAsObject = ImageAsset.bundle(name: "x32/Open as Object")
    static let paste = ImageAsset.bundle(name: "x32/Paste")
    static let plus = ImageAsset.bundle(name: "x32/Plus")
    static let properties = ImageAsset.bundle(name: "x32/Properties")
    static let remove = ImageAsset.bundle(name: "x32/Remove")
    static let rename = ImageAsset.bundle(name: "x32/Rename")
    static let replace = ImageAsset.bundle(name: "x32/Replace")
    static let restore = ImageAsset.bundle(name: "x32/Restore")
    static let search = ImageAsset.bundle(name: "x32/Search")
    static let slashMenu = ImageAsset.bundle(name: "x32/Slash Menu")
    static let sort = ImageAsset.bundle(name: "x32/Sort")
    static let style = ImageAsset.bundle(name: "x32/Style")
    static let tableOfContents = ImageAsset.bundle(name: "x32/Table of Contents")
    static let turnIntoObject = ImageAsset.bundle(name: "x32/Turn Into Object")
    enum Undo {
      static let redo = ImageAsset.bundle(name: "x32/Undo/Redo")
      static let undo = ImageAsset.bundle(name: "x32/Undo/Undo")
    }
    static let undoRedo = ImageAsset.bundle(name: "x32/UndoRedo")
    static let video = ImageAsset.bundle(name: "x32/Video")
    enum View {
      static let hide = ImageAsset.bundle(name: "x32/View/Hide")
      static let view = ImageAsset.bundle(name: "x32/View/View")
    }
    static let view = ImageAsset.bundle(name: "x32/View")
  }
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal enum ImageAsset: Hashable {
  case bundle(name: String)
  case system(name: String)
}
