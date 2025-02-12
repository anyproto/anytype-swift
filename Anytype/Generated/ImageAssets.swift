// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen


// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal extension ImageAsset {
  enum AppIconsPreview {
    static let appIcon = ImageAsset.bundle(name: "AppIconsPreview/AppIcon")
    static let appIconClassic = ImageAsset.bundle(name: "AppIconsPreview/AppIconClassic")
    static let appIconOldSchool = ImageAsset.bundle(name: "AppIconsPreview/AppIconOldSchool")
    static let appIconSmile = ImageAsset.bundle(name: "AppIconsPreview/AppIconSmile")
  }
  static let authPhotoIcon = ImageAsset.bundle(name: "auth_photo_icon")
  static let localInternet = ImageAsset.bundle(name: "local-internet")
  enum BottomAlert {
    static let error = ImageAsset.bundle(name: "BottomAlert/error")
    static let exclamation = ImageAsset.bundle(name: "BottomAlert/exclamation")
    static let mail = ImageAsset.bundle(name: "BottomAlert/mail")
    static let question = ImageAsset.bundle(name: "BottomAlert/question")
    static let sadMail = ImageAsset.bundle(name: "BottomAlert/sadMail")
    static let update = ImageAsset.bundle(name: "BottomAlert/update")
  }
  static let arrowDown = ImageAsset.bundle(name: "arrowDown")
  static let arrowForward = ImageAsset.bundle(name: "arrowForward")
  static let backArrow = ImageAsset.bundle(name: "backArrow")
  static let ghost = ImageAsset.bundle(name: "ghost")
  static let logo = ImageAsset.bundle(name: "logo")
  static let noImage = ImageAsset.bundle(name: "no_image")
  enum Channel {
    static let chat = ImageAsset.bundle(name: "Channel/Chat")
    static let space = ImageAsset.bundle(name: "Channel/Space")
    static let stream = ImageAsset.bundle(name: "Channel/Stream")
  }
  enum Chat {
    enum SendMessage {
      static let active = ImageAsset.bundle(name: "Chat/SendMessage/active")
      static let inactive = ImageAsset.bundle(name: "Chat/SendMessage/inactive")
    }
  }
  enum EmptyIcon {
    static let bookmark = ImageAsset.bundle(name: "EmptyIcon/bookmark")
    static let chat = ImageAsset.bundle(name: "EmptyIcon/chat")
    static let date = ImageAsset.bundle(name: "EmptyIcon/date")
    static let list = ImageAsset.bundle(name: "EmptyIcon/list")
    static let objectType = ImageAsset.bundle(name: "EmptyIcon/objectType")
    static let page = ImageAsset.bundle(name: "EmptyIcon/page")
    static let tag = ImageAsset.bundle(name: "EmptyIcon/tag")
  }
  enum FileTypes {
    static let archive = ImageAsset.bundle(name: "FileTypes/Archive")
    static let audio = ImageAsset.bundle(name: "FileTypes/Audio")
    static let image = ImageAsset.bundle(name: "FileTypes/Image")
    static let other = ImageAsset.bundle(name: "FileTypes/Other")
    static let pdf = ImageAsset.bundle(name: "FileTypes/PDF")
    static let presentation = ImageAsset.bundle(name: "FileTypes/Presentation")
    static let table = ImageAsset.bundle(name: "FileTypes/Table")
    static let text = ImageAsset.bundle(name: "FileTypes/Text")
    static let video = ImageAsset.bundle(name: "FileTypes/Video")
  }
  enum Layout {
    static let basic = ImageAsset.bundle(name: "Layout/Basic")
    static let note = ImageAsset.bundle(name: "Layout/Note")
    static let profile = ImageAsset.bundle(name: "Layout/Profile")
    static let task = ImageAsset.bundle(name: "Layout/Task")
  }
  enum NavigationBase {
    static let add = ImageAsset.bundle(name: "NavigationBase/Add")
    static let empty = ImageAsset.bundle(name: "NavigationBase/Empty")
    static let search = ImageAsset.bundle(name: "NavigationBase/Search")
    static let settings = ImageAsset.bundle(name: "NavigationBase/Settings")
    static let sharedSpace = ImageAsset.bundle(name: "NavigationBase/Shared Space")
  }
  enum ObjectSettings {
    static let cover = ImageAsset.bundle(name: "ObjectSettings/Cover")
    static let description = ImageAsset.bundle(name: "ObjectSettings/Description")
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
  enum QrCode {
    static let smile = ImageAsset.bundle(name: "QrCode/Smile")
  }
  enum Settings {
    static let about = ImageAsset.bundle(name: "Settings/About")
    static let appearance = ImageAsset.bundle(name: "Settings/Appearance")
    static let debug = ImageAsset.bundle(name: "Settings/Debug")
    static let fileStorage = ImageAsset.bundle(name: "Settings/FileStorage")
    static let keychainPhrase = ImageAsset.bundle(name: "Settings/KeychainPhrase")
    static let membership = ImageAsset.bundle(name: "Settings/Membership")
    static let personalization = ImageAsset.bundle(name: "Settings/Personalization")
    static let pinCode = ImageAsset.bundle(name: "Settings/PinCode")
    static let spaces = ImageAsset.bundle(name: "Settings/Spaces")
  }
  enum System {
    static let checkboxChecked = ImageAsset.bundle(name: "System/Checkbox checked")
    static let checkboxUnchecked = ImageAsset.bundle(name: "System/Checkbox unchecked")
    static let textCheckMark = ImageAsset.bundle(name: "System/Text check mark")
  }
  enum TaskLayout {
    static let done = ImageAsset.bundle(name: "TaskLayout/Done")
    static let empty = ImageAsset.bundle(name: "TaskLayout/Empty")
  }
  enum TextStyles {
    enum Align {
      static let center = ImageAsset.bundle(name: "TextStyles/Align/Center")
      static let justify = ImageAsset.bundle(name: "TextStyles/Align/Justify")
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
    static let delete = ImageAsset.bundle(name: "x18/Delete")
    enum Disclosure {
      static let down = ImageAsset.bundle(name: "x18/Disclosure/Down")
      static let `left` = ImageAsset.bundle(name: "x18/Disclosure/Left")
      static let `right` = ImageAsset.bundle(name: "x18/Disclosure/Right")
      static let up = ImageAsset.bundle(name: "x18/Disclosure/Up")
    }
    static let help = ImageAsset.bundle(name: "x18/Help")
    static let listArrow = ImageAsset.bundle(name: "x18/List Arrow")
    static let list = ImageAsset.bundle(name: "x18/List")
    static let lock = ImageAsset.bundle(name: "x18/Lock")
    static let objectWithoutIcon = ImageAsset.bundle(name: "x18/Object Without Icon")
    static let search = ImageAsset.bundle(name: "x18/Search")
    static let slashMenuArrow = ImageAsset.bundle(name: "x18/Slash Menu Arrow")
    static let updateApp = ImageAsset.bundle(name: "x18/Update App")
    static let webLink = ImageAsset.bundle(name: "x18/Web link")
  }
  enum X19 {
    static let more = ImageAsset.bundle(name: "x19/more")
    static let plus = ImageAsset.bundle(name: "x19/plus")
    static let share = ImageAsset.bundle(name: "x19/share")
  }
  enum X22 {
    static let close = ImageAsset.bundle(name: "x22/close")
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
    static let back = ImageAsset.bundle(name: "x24/Back")
    static let blur = ImageAsset.bundle(name: "x24/Blur")
    static let burger = ImageAsset.bundle(name: "x24/Burger")
    static let calendar = ImageAsset.bundle(name: "x24/Calendar")
    static let checkbox = ImageAsset.bundle(name: "x24/Checkbox")
    static let clipboard = ImageAsset.bundle(name: "x24/Clipboard")
    static let close = ImageAsset.bundle(name: "x24/Close")
    static let copy = ImageAsset.bundle(name: "x24/Copy")
    static let database = ImageAsset.bundle(name: "x24/Database")
    static let date = ImageAsset.bundle(name: "x24/Date")
    static let edit = ImageAsset.bundle(name: "x24/Edit")
    static let email = ImageAsset.bundle(name: "x24/Email")
    static let embed = ImageAsset.bundle(name: "x24/Embed")
    static let empty = ImageAsset.bundle(name: "x24/Empty")
    enum Favorite {
      static let favorite = ImageAsset.bundle(name: "x24/Favorite/Favorite")
      static let unfavorite = ImageAsset.bundle(name: "x24/Favorite/Unfavorite")
    }
    static let folder = ImageAsset.bundle(name: "x24/Folder")
    static let member = ImageAsset.bundle(name: "x24/Member")
    static let mention = ImageAsset.bundle(name: "x24/Mention")
    static let more = ImageAsset.bundle(name: "x24/More")
    static let multiselect = ImageAsset.bundle(name: "x24/Multiselect")
    static let name = ImageAsset.bundle(name: "x24/Name")
    static let number = ImageAsset.bundle(name: "x24/Number")
    static let object = ImageAsset.bundle(name: "x24/Object")
    static let openToEdit = ImageAsset.bundle(name: "x24/Open to Edit")
    static let `open` = ImageAsset.bundle(name: "x24/Open")
    static let phoneNumber = ImageAsset.bundle(name: "x24/Phone Number")
    static let pin = ImageAsset.bundle(name: "x24/Pin")
    static let plus = ImageAsset.bundle(name: "x24/Plus")
    static let privateSpace = ImageAsset.bundle(name: "x24/Private Space")
    static let reaction = ImageAsset.bundle(name: "x24/Reaction")
    static let relations = ImageAsset.bundle(name: "x24/Relations")
    static let removeRed = ImageAsset.bundle(name: "x24/Remove Red")
    static let replace = ImageAsset.bundle(name: "x24/Replace")
    static let search = ImageAsset.bundle(name: "x24/Search")
    static let select = ImageAsset.bundle(name: "x24/Select")
    static let settings = ImageAsset.bundle(name: "x24/Settings")
    static let sharing = ImageAsset.bundle(name: "x24/Sharing")
    static let spaceSettings = ImageAsset.bundle(name: "x24/Space settings")
    static let status = ImageAsset.bundle(name: "x24/Status")
    static let storage = ImageAsset.bundle(name: "x24/Storage")
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
  enum X28 {
    static let sort = ImageAsset.bundle(name: "x28/Sort")
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
      static let justify = ImageAsset.bundle(name: "x32/Align/Justify")
      static let `left` = ImageAsset.bundle(name: "x32/Align/Left")
      static let `right` = ImageAsset.bundle(name: "x32/Align/Right")
    }
    enum Arrow {
      static let down = ImageAsset.bundle(name: "x32/Arrow/Down")
      static let `left` = ImageAsset.bundle(name: "x32/Arrow/Left")
      static let `right` = ImageAsset.bundle(name: "x32/Arrow/Right")
      static let up = ImageAsset.bundle(name: "x32/Arrow/Up")
    }
    static let attachment = ImageAsset.bundle(name: "x32/Attachment")
    static let audo = ImageAsset.bundle(name: "x32/Audo")
    static let bookmark = ImageAsset.bundle(name: "x32/Bookmark")
    static let chat = ImageAsset.bundle(name: "x32/Chat")
    static let clear = ImageAsset.bundle(name: "x32/Clear")
    static let color = ImageAsset.bundle(name: "x32/Color")
    static let copy = ImageAsset.bundle(name: "x32/Copy")
    static let dashboard = ImageAsset.bundle(name: "x32/Dashboard")
    static let dashboardOld = ImageAsset.bundle(name: "x32/Dashboard_old")
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
    enum Island {
      static let discuss = ImageAsset.bundle(name: "x32/Island/Discuss")
      static let vault = ImageAsset.bundle(name: "x32/Island/Vault")
      static let addMember = ImageAsset.bundle(name: "x32/Island/add member")
      static let addObject = ImageAsset.bundle(name: "x32/Island/add object")
      static let add = ImageAsset.bundle(name: "x32/Island/add")
      static let back = ImageAsset.bundle(name: "x32/Island/back")
      static let members = ImageAsset.bundle(name: "x32/Island/members")
      static let search = ImageAsset.bundle(name: "x32/Island/search")
    }
    static let linkTo = ImageAsset.bundle(name: "x32/Link to")
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
    static let qrCode = ImageAsset.bundle(name: "x32/QRCode")
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
    static let widgets = ImageAsset.bundle(name: "x32/Widgets")
  }
  enum X40 {
    static let actions = ImageAsset.bundle(name: "x40/Actions")
    static let attachment = ImageAsset.bundle(name: "x40/Attachment")
    static let audio = ImageAsset.bundle(name: "x40/Audio")
    static let bold = ImageAsset.bundle(name: "x40/Bold")
    static let bookmark = ImageAsset.bundle(name: "x40/Bookmark")
    static let bulleted = ImageAsset.bundle(name: "x40/Bulleted")
    static let callout = ImageAsset.bundle(name: "x40/Callout")
    static let checkbox = ImageAsset.bundle(name: "x40/Checkbox")
    static let codeSnippet = ImageAsset.bundle(name: "x40/Code Snippet")
    static let code = ImageAsset.bundle(name: "x40/Code")
    enum Divider {
      static let dots = ImageAsset.bundle(name: "x40/Divider/Dots")
      static let line = ImageAsset.bundle(name: "x40/Divider/Line")
    }
    static let heading = ImageAsset.bundle(name: "x40/Heading")
    static let highlighted = ImageAsset.bundle(name: "x40/Highlighted")
    static let italic = ImageAsset.bundle(name: "x40/Italic")
    static let linkToExistingObject = ImageAsset.bundle(name: "x40/Link to Existing Object")
    static let link = ImageAsset.bundle(name: "x40/Link")
    static let media = ImageAsset.bundle(name: "x40/Media")
    static let numbered = ImageAsset.bundle(name: "x40/Numbered")
    static let objects = ImageAsset.bundle(name: "x40/Objects")
    static let other = ImageAsset.bundle(name: "x40/Other")
    static let picture = ImageAsset.bundle(name: "x40/Picture")
    static let relations = ImageAsset.bundle(name: "x40/Relations")
    static let simpleTables = ImageAsset.bundle(name: "x40/Simple Tables")
    static let sorts = ImageAsset.bundle(name: "x40/Sorts")
    static let strikethrough = ImageAsset.bundle(name: "x40/Strikethrough")
    enum Style {
      static let bullet = ImageAsset.bundle(name: "x40/Style/Bullet")
      static let checkbox = ImageAsset.bundle(name: "x40/Style/Checkbox")
      static let numbered = ImageAsset.bundle(name: "x40/Style/Numbered")
      static let toggle = ImageAsset.bundle(name: "x40/Style/Toggle")
    }
    static let style = ImageAsset.bundle(name: "x40/Style")
    static let subheading = ImageAsset.bundle(name: "x40/Subheading")
    static let text = ImageAsset.bundle(name: "x40/Text")
    static let title = ImageAsset.bundle(name: "x40/Title")
    static let toggle = ImageAsset.bundle(name: "x40/Toggle")
    static let underline = ImageAsset.bundle(name: "x40/Underline")
    static let video = ImageAsset.bundle(name: "x40/Video")
  }
  enum X54 {
    enum View {
      static let gallerySelected = ImageAsset.bundle(name: "x54/View/Gallery.Selected")
      static let gallery = ImageAsset.bundle(name: "x54/View/Gallery")
      static let gridSelected = ImageAsset.bundle(name: "x54/View/Grid.Selected")
      static let grid = ImageAsset.bundle(name: "x54/View/Grid")
      static let kanbanSelected = ImageAsset.bundle(name: "x54/View/Kanban.Selected")
      static let kanban = ImageAsset.bundle(name: "x54/View/Kanban")
      static let listSelected = ImageAsset.bundle(name: "x54/View/List.Selected")
      static let list = ImageAsset.bundle(name: "x54/View/List")
    }
  }
  enum Emoji {
    }
  enum Membership {
    static let banner1 = ImageAsset.bundle(name: "Membership/banner_1")
    static let banner2 = ImageAsset.bundle(name: "Membership/banner_2")
    static let banner3 = ImageAsset.bundle(name: "Membership/banner_3")
    static let banner4 = ImageAsset.bundle(name: "Membership/banner_4")
    static let tierBuilderMedium = ImageAsset.bundle(name: "Membership/tier_builder_medium")
    static let tierBuilderSmall = ImageAsset.bundle(name: "Membership/tier_builder_small")
    static let tierCocreatorMedium = ImageAsset.bundle(name: "Membership/tier_cocreator_medium")
    static let tierCocreatorSmall = ImageAsset.bundle(name: "Membership/tier_cocreator_small")
    static let tierCustomMedium = ImageAsset.bundle(name: "Membership/tier_custom_medium")
    static let tierCustomSmall = ImageAsset.bundle(name: "Membership/tier_custom_small")
    static let tierExplorerMedium = ImageAsset.bundle(name: "Membership/tier_explorer_medium")
    static let tierExplorerSmall = ImageAsset.bundle(name: "Membership/tier_explorer_small")
  }
  static let createNewObject = ImageAsset.bundle(name: "createNewObject")
  static let makeAsTemplate = ImageAsset.bundle(name: "make_as_template")
  static let templateMakeDefault = ImageAsset.bundle(name: "template_make_default")
  static let relationAddToFeatured = ImageAsset.bundle(name: "relation_add_to_featured")
  static let relationCheckboxChecked = ImageAsset.bundle(name: "relation_checkbox_checked")
  static let relationCheckboxUnchecked = ImageAsset.bundle(name: "relation_checkbox_unchecked")
  static let relationLocked = ImageAsset.bundle(name: "relation_locked")
  static let relationLockedSmall = ImageAsset.bundle(name: "relation_locked_small")
  static let relationNew = ImageAsset.bundle(name: "relation_new")
  static let relationRemoveFromFeatured = ImageAsset.bundle(name: "relation_remove_from_featured")
  static let handPointLeft = ImageAsset.bundle(name: "HandPointLeft")
  static let webPage = ImageAsset.bundle(name: "web_page")
  static let setImagePlaceholder = ImageAsset.bundle(name: "set_image_placeholder")
  static let setOpenToEdit = ImageAsset.bundle(name: "set_open_to_edit")
  enum SettingsOld {
    enum Theme {
      static let dark = ImageAsset.bundle(name: "SettingsOld/Theme/dark")
      static let light = ImageAsset.bundle(name: "SettingsOld/Theme/light")
      static let system = ImageAsset.bundle(name: "SettingsOld/Theme/system")
    }
  }
  enum Format {
    static let unknown = ImageAsset.bundle(name: "format/unknown")
  }
  enum StyleBottomSheet {
    static let bullet = ImageAsset.bundle(name: "StyleBottomSheet/bullet")
    static let checkbox = ImageAsset.bundle(name: "StyleBottomSheet/checkbox")
    static let color = ImageAsset.bundle(name: "StyleBottomSheet/color")
    static let numbered = ImageAsset.bundle(name: "StyleBottomSheet/numbered")
    static let toggle = ImageAsset.bundle(name: "StyleBottomSheet/toggle")
  }
  enum SyncStatus {
    static let syncAnytypenetworkConnected = ImageAsset.bundle(name: "SyncStatus/sync_anytypenetwork_connected")
    static let syncAnytypenetworkError = ImageAsset.bundle(name: "SyncStatus/sync_anytypenetwork_error")
    static let syncInProgress = ImageAsset.bundle(name: "SyncStatus/sync_in_progress")
    static let syncLocalonlyDefault = ImageAsset.bundle(name: "SyncStatus/sync_localonly_default")
    static let syncOffline = ImageAsset.bundle(name: "SyncStatus/sync_offline")
    static let syncP2p = ImageAsset.bundle(name: "SyncStatus/sync_p2p")
    static let syncSelfhost = ImageAsset.bundle(name: "SyncStatus/sync_selfhost")
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
    static let search = ImageAsset.bundle(name: "TextEditor/search")
    static let shimmering = ImageAsset.bundle(name: "TextEditor/shimmering")
    enum Text {
      static let checked = ImageAsset.bundle(name: "TextEditor/Text/checked")
      static let folded = ImageAsset.bundle(name: "TextEditor/Text/folded")
      static let unchecked = ImageAsset.bundle(name: "TextEditor/Text/unchecked")
    }
    static let bigGhost = ImageAsset.bundle(name: "TextEditor/bigGhost")
  }
  enum SharingTip {
    static let step1 = ImageAsset.bundle(name: "SharingTip/step1")
    static let step2 = ImageAsset.bundle(name: "SharingTip/step2")
    static let step3 = ImageAsset.bundle(name: "SharingTip/step3")
  }
  enum SpaceHubTip {
    static let backgroundsDark = ImageAsset.bundle(name: "SpaceHubTip/backgrounds_dark")
    static let backgroundsLight = ImageAsset.bundle(name: "SpaceHubTip/backgrounds_light")
    static let vaultImmersive = ImageAsset.bundle(name: "SpaceHubTip/vault_immersive")
    static let vaultMove = ImageAsset.bundle(name: "SpaceHubTip/vault_move")
  }
  static let toastFailure = ImageAsset.bundle(name: "toast_failure")
  static let toastTick = ImageAsset.bundle(name: "toast_tick")
  enum Widget {
    enum Preview {
      static let compactList = ImageAsset.bundle(name: "Widget/Preview/compact list")
      static let link = ImageAsset.bundle(name: "Widget/Preview/link")
      static let list = ImageAsset.bundle(name: "Widget/Preview/list")
      static let tree = ImageAsset.bundle(name: "Widget/Preview/tree")
    }
    static let addTop = ImageAsset.bundle(name: "Widget/add_top")
    static let allContent = ImageAsset.bundle(name: "Widget/allContent")
    static let bin = ImageAsset.bundle(name: "Widget/bin")
    static let settings = ImageAsset.bundle(name: "Widget/settings")
    static let tick = ImageAsset.bundle(name: "Widget/tick")
  }
  static let launchDot = ImageAsset.bundle(name: "launch_dot")
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal enum ImageAsset: Hashable {
  case bundle(name: String)
  case system(name: String)
}
