// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen


// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal extension ImageAsset {
  static let authPhotoIcon = ImageAsset.bundle(name: "auth_photo_icon")
  static let arrowDown = ImageAsset.bundle(name: "arrowDown")
  static let arrowForward = ImageAsset.bundle(name: "arrowForward")
  static let backArrow = ImageAsset.bundle(name: "backArrow")
  static let ghost = ImageAsset.bundle(name: "ghost")
  static let logo = ImageAsset.bundle(name: "logo")
  static let noImage = ImageAsset.bundle(name: "no_image")
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
  enum Layout {
    static let basic = ImageAsset.bundle(name: "Layout/Basic")
    static let note = ImageAsset.bundle(name: "Layout/Note")
    static let profile = ImageAsset.bundle(name: "Layout/Profile")
    static let task = ImageAsset.bundle(name: "Layout/Task")
  }
  enum ObjectSettings {
    static let cover = ImageAsset.bundle(name: "ObjectSettings/Cover")
    static let history = ImageAsset.bundle(name: "ObjectSettings/History")
    static let icon = ImageAsset.bundle(name: "ObjectSettings/Icon")
    static let layout = ImageAsset.bundle(name: "ObjectSettings/Layout")
    static let relations = ImageAsset.bundle(name: "ObjectSettings/Relations")
  }
  enum PageBlock {
    enum Checkbox {
      static let empty = ImageAsset.bundle(name: "PageBlock/Checkbox/Empty")
      static let marked = ImageAsset.bundle(name: "PageBlock/Checkbox/Marked")
    }
  }
  enum Preview {
    static let card = ImageAsset.bundle(name: "Preview/Card")
    static let inline = ImageAsset.bundle(name: "Preview/Inline")
    static let text = ImageAsset.bundle(name: "Preview/Text")
  }
  enum Settings {
    static let about = ImageAsset.bundle(name: "Settings/About")
    static let appearance = ImageAsset.bundle(name: "Settings/Appearance")
    static let debug = ImageAsset.bundle(name: "Settings/Debug")
    static let fileStorage = ImageAsset.bundle(name: "Settings/FileStorage")
    static let keychainPhrase = ImageAsset.bundle(name: "Settings/KeychainPhrase")
    static let personalization = ImageAsset.bundle(name: "Settings/Personalization")
    static let pinCode = ImageAsset.bundle(name: "Settings/PinCode")
  }
  enum TextStyles {
    enum Align {
      static let center = ImageAsset.bundle(name: "TextStyles/Align/Center")
      static let `left` = ImageAsset.bundle(name: "TextStyles/Align/Left")
      static let `right` = ImageAsset.bundle(name: "TextStyles/Align/Right")
    }
    static let bold = ImageAsset.bundle(name: "TextStyles/Bold")
    static let code = ImageAsset.bundle(name: "TextStyles/Code")
    static let embed = ImageAsset.bundle(name: "TextStyles/Embed")
    static let italic = ImageAsset.bundle(name: "TextStyles/Italic")
    static let strikethrough = ImageAsset.bundle(name: "TextStyles/Strikethrough")
    static let underline = ImageAsset.bundle(name: "TextStyles/Underline")
  }
  enum X18 {
    static let attention = ImageAsset.bundle(name: "x18/Attention")
    static let clear = ImageAsset.bundle(name: "x18/Clear")
    enum Disclosure {
      static let down = ImageAsset.bundle(name: "x18/Disclosure/Down")
      static let `left` = ImageAsset.bundle(name: "x18/Disclosure/Left")
      static let `right` = ImageAsset.bundle(name: "x18/Disclosure/Right")
      static let up = ImageAsset.bundle(name: "x18/Disclosure/Up")
    }
    static let help = ImageAsset.bundle(name: "x18/Help")
    static let listArrow = ImageAsset.bundle(name: "x18/List Arrow")
    static let lock = ImageAsset.bundle(name: "x18/Lock")
    static let search = ImageAsset.bundle(name: "x18/Search")
    static let slashMenuArrow = ImageAsset.bundle(name: "x18/Slash Menu Arrow")
  }
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
  enum Emoji {
    }
  static let createNewObject = ImageAsset.bundle(name: "createNewObject")
  enum Migration {
    static let close = ImageAsset.bundle(name: "Migration/Close")
  }
  static let taskChecked = ImageAsset.bundle(name: "task_checked")
  static let taskUnchecked = ImageAsset.bundle(name: "task_unchecked")
  static let todoCheckbox = ImageAsset.bundle(name: "todo_checkbox")
  static let todoCheckmark = ImageAsset.bundle(name: "todo_checkmark")
  static let delete = ImageAsset.bundle(name: "delete")
  static let linkToItself = ImageAsset.bundle(name: "link_to_itself")
  static let relationAddToFeatured = ImageAsset.bundle(name: "relation_add_to_featured")
  static let relationCheckboxChecked = ImageAsset.bundle(name: "relation_checkbox_checked")
  static let relationCheckboxUnchecked = ImageAsset.bundle(name: "relation_checkbox_unchecked")
  static let relationLocked = ImageAsset.bundle(name: "relation_locked")
  static let relationLockedSmall = ImageAsset.bundle(name: "relation_locked_small")
  static let relationNew = ImageAsset.bundle(name: "relation_new")
  static let relationRemoveFromFeatured = ImageAsset.bundle(name: "relation_remove_from_featured")
  static let webPage = ImageAsset.bundle(name: "web_page")
  static let setImagePlaceholder = ImageAsset.bundle(name: "set_image_placeholder")
  static let setOpenToEdit = ImageAsset.bundle(name: "set_open_to_edit")
  static let setPenEdit = ImageAsset.bundle(name: "set_pen_edit")
  enum SettingsOld {
    enum Theme {
      static let dark = ImageAsset.bundle(name: "SettingsOld/Theme/dark")
      static let light = ImageAsset.bundle(name: "SettingsOld/Theme/light")
      static let system = ImageAsset.bundle(name: "SettingsOld/Theme/system")
    }
    static let accountAndData = ImageAsset.bundle(name: "SettingsOld/account_and_data")
    static let setWallpaper = ImageAsset.bundle(name: "SettingsOld/set_wallpaper")
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
    static let unknown = ImageAsset.bundle(name: "format/unknown")
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
  enum TextEditor {
    enum BlocksOption {
      static let copy = ImageAsset.bundle(name: "TextEditor/BlocksOption/copy")
      static let delete = ImageAsset.bundle(name: "TextEditor/BlocksOption/delete")
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
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal enum ImageAsset: Hashable {
  case bundle(name: String)
  case system(name: String)
}
