// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
public enum Loc {
  public static let about = Loc.tr("Localizable", "About", fallback: "About")
  public static let access = Loc.tr("Localizable", "Access", fallback: "Key")
  public static let accessToKeyFromKeychain = Loc.tr("Localizable", "Access to key from keychain", fallback: "Access to key from keychain")
  public static let actionFocusedLayoutWithACheckbox = Loc.tr("Localizable", "Action-focused layout with a checkbox", fallback: "Action-focused layout with a checkbox")
  public static let actions = Loc.tr("Localizable", "Actions", fallback: "Actions")
  public static let add = Loc.tr("Localizable", "Add", fallback: "Add")
  public static let addADescription = Loc.tr("Localizable", "Add a description", fallback: "Add a description...")
  public static let addBelow = Loc.tr("Localizable", "Add below", fallback: "Add below")
  public static let addEmail = Loc.tr("Localizable", "Add email", fallback: "Add email")
  public static let addLink = Loc.tr("Localizable", "Add link", fallback: "Add link")
  public static let addPhone = Loc.tr("Localizable", "Add phone", fallback: "Add phone")
  public static let addProperty = Loc.tr("Localizable", "Add property", fallback: "Add property")
  public static let addToFavorite = Loc.tr("Localizable", "Add To Favorite", fallback: "Add To Favorite")
  public static func agreementDisclamer(_ p1: Any, _ p2: Any) -> String {
    return Loc.tr("Localizable", "Agreement Disclamer", String(describing: p1), String(describing: p2), fallback: "By continuing you agree to [Terms of Use](%@) and [Privacy Policy](%@)")
  }
  public static let alignCenter = Loc.tr("Localizable", "Align center", fallback: "Align center")
  public static let alignJustify = Loc.tr("Localizable", "Align justify", fallback: "Align justify")
  public static let alignLeft = Loc.tr("Localizable", "Align left", fallback: "Align left")
  public static let alignRight = Loc.tr("Localizable", "Align right", fallback: "Align right")
  public static let alignment = Loc.tr("Localizable", "Alignment", fallback: "Alignment")
  public static let all = Loc.tr("Localizable", "All", fallback: "All")
  public static let allObjects = Loc.tr("Localizable", "All objects", fallback: "All Objects")
  public static let amber = Loc.tr("Localizable", "Amber", fallback: "Amber")
  public static let amberBackground = Loc.tr("Localizable", "Amber background", fallback: "Amber background")
  public static let anytypeLibrary = Loc.tr("Localizable", "Anytype Library", fallback: "Anytype Library")
  public static let anytypeNetwork = Loc.tr("Localizable", "Anytype Network", fallback: "Anytype Network")
  public static let appearance = Loc.tr("Localizable", "Appearance", fallback: "Appearance")
  public static let applicationIcon = Loc.tr("Localizable", "Application icon", fallback: "Application icon")
  public static let apply = Loc.tr("Localizable", "Apply", fallback: "Apply")
  public static func areYouSureYouWantToDelete(_ p1: Int) -> String {
    return Loc.tr("Localizable", "Are you sure you want to delete", p1, fallback: "Are you sure you want to delete %#@object@?")
  }
  public static let areYouSure = Loc.tr("Localizable", "AreYouSure", fallback: "Are you sure?")
  public static func attachment(_ p1: Int) -> String {
    return Loc.tr("Localizable", "Attachment", p1, fallback: "Plural format key: Attachment")
  }
  public static func audio(_ p1: Int) -> String {
    return Loc.tr("Localizable", "Audio", p1, fallback: "Plural format key: Audio")
  }
  public static let back = Loc.tr("Localizable", "Back", fallback: "Back")
  public static let backUpKey = Loc.tr("Localizable", "Back up key", fallback: "Back up key")
  public static let backUpYourKey = Loc.tr("Localizable", "Back up your key", fallback: "Back up your key")
  public static let background = Loc.tr("Localizable", "Background", fallback: "Background")
  public static func backlinksCount(_ p1: Int) -> String {
    return Loc.tr("Localizable", "Backlinks count", p1, fallback: "Plural format key: Backlinks count")
  }
  public static let basic = Loc.tr("Localizable", "Basic", fallback: "Basic")
  public static let bin = Loc.tr("Localizable", "Bin", fallback: "Bin")
  public static let black = Loc.tr("Localizable", "Black", fallback: "Black")
  public static let blue = Loc.tr("Localizable", "Blue", fallback: "Blue")
  public static let blueBackground = Loc.tr("Localizable", "Blue background", fallback: "Blue background")
  public static let blurredIcon = Loc.tr("Localizable", "Blurred icon", fallback: "Blurred\n icon")
  public static func bookmark(_ p1: Int) -> String {
    return Loc.tr("Localizable", "Bookmark", p1, fallback: "Plural format key: Bookmark")
  }
  public static let bookmarkBlockSubtitle = Loc.tr("Localizable", "Bookmark block subtitle", fallback: "Save your favorite link with summary")
  public static let bookmarks = Loc.tr("Localizable", "Bookmarks", fallback: "Bookmarks")
  public static let callout = Loc.tr("Localizable", "Callout", fallback: "Callout")
  public static let camera = Loc.tr("Localizable", "Camera", fallback: "Camera")
  public static let cameraBlockSubtitle = Loc.tr("Localizable", "Camera block subtitle", fallback: "Capture a moment and enrich the page with it")
  public static let cameraBlockTitle = Loc.tr("Localizable", "Camera block title", fallback: "Take photo or video")
  public static let cancel = Loc.tr("Localizable", "Cancel", fallback: "Cancel")
  public static let cancelDeletion = Loc.tr("Localizable", "Cancel deletion", fallback: "Cancel deletion")
  public static let changeCover = Loc.tr("Localizable", "Change cover", fallback: "Change cover")
  public static let changeEmail = Loc.tr("Localizable", "Change email", fallback: "Change email")
  public static let changeIcon = Loc.tr("Localizable", "Change icon", fallback: "Change icon")
  public static let changeType = Loc.tr("Localizable", "Change type", fallback: "Change type")
  public static let changeWallpaper = Loc.tr("Localizable", "Change wallpaper", fallback: "Change wallpaper")
  public static let chat = Loc.tr("Localizable", "Chat", fallback: "Chat")
  public static let chooseDefaultObjectType = Loc.tr("Localizable", "Choose default object type", fallback: "Choose default object type")
  public static let chooseLayoutType = Loc.tr("Localizable", "Choose layout type", fallback: "Choose layout type")
  public static let clear = Loc.tr("Localizable", "Clear", fallback: "Clear")
  public static let close = Loc.tr("Localizable", "Close", fallback: "Close")
  public static let codeBlockSubtitle = Loc.tr("Localizable", "Code block subtitle", fallback: "Capture code snippet")
  public static let codeSnippet = Loc.tr("Localizable", "Code snippet", fallback: "Code snippet")
  public static let collaboration = Loc.tr("Localizable", "Collaboration", fallback: "Collaboration")
  public static let collection = Loc.tr("Localizable", "Collection", fallback: "Collection")
  public static let collectionOfObjects = Loc.tr("Localizable", "Collection of objects", fallback: "Collection of objects")
  public static let collections = Loc.tr("Localizable", "Collections", fallback: "Collections")
  public static let color = Loc.tr("Localizable", "Color", fallback: "Color")
  public static let companiesContactsFriendsAndFamily = Loc.tr("Localizable", "Companies, contacts, friends and family", fallback: "Companies, contacts, friends and family")
  public static let confirm = Loc.tr("Localizable", "Confirm", fallback: "Confirm")
  public static let connecting = Loc.tr("Localizable", "Connecting", fallback: "Connecting...")
  public static let contentModel = Loc.tr("Localizable", "Content Model", fallback: "Content Model")
  public static let `continue` = Loc.tr("Localizable", "Continue", fallback: "Continue")
  public static let copied = Loc.tr("Localizable", "Copied", fallback: "Copied")
  public static func copiedToClipboard(_ p1: Any) -> String {
    return Loc.tr("Localizable", "copied to clipboard", String(describing: p1), fallback: "%@ copied to clipboard")
  }
  public static let copy = Loc.tr("Localizable", "Copy", fallback: "Copy")
  public static let copyLink = Loc.tr("Localizable", "Copy link", fallback: "Copy link")
  public static let copySpaceInfo = Loc.tr("Localizable", "Copy space info", fallback: "Copy space info")
  public static let cover = Loc.tr("Localizable", "Cover", fallback: "Cover")
  public static let create = Loc.tr("Localizable", "Create", fallback: "Create")
  public static let createANewOneOrSearchForSomethingElse = Loc.tr("Localizable", "Create a new one or search for something else", fallback: "Create a new one or search for something else")
  public static let createNewObject = Loc.tr("Localizable", "Create new object", fallback: "Create new object")
  public static func createNewObjectWithName(_ p1: Any) -> String {
    return Loc.tr("Localizable", "Create new object with name", String(describing: p1), fallback: "Create new object \"%@\"")
  }
  public static let createNewType = Loc.tr("Localizable", "Create new type", fallback: "Create new type")
  public static let createObject = Loc.tr("Localizable", "Create object", fallback: "Create Object")
  public static let createObjectFromClipboard = Loc.tr("Localizable", "Create object from clipboard", fallback: "Create object from clipboard")
  public static func createOptionWith(_ p1: Any) -> String {
    return Loc.tr("Localizable", "Create option with", String(describing: p1), fallback: "Create option ‘%@’")
  }
  public static func createRelation(_ p1: Any) -> String {
    return Loc.tr("Localizable", "Create relation", String(describing: p1), fallback: "Create property ‘%@’")
  }
  public static let createSet = Loc.tr("Localizable", "Create Set", fallback: "Create Query")
  public static let createSpace = Loc.tr("Localizable", "Create Space", fallback: "Create Space")
  public static let createType = Loc.tr("Localizable", "Create type", fallback: "Create type")
  public static let current = Loc.tr("Localizable", "Current", fallback: "Current")
  public static let customizeURL = Loc.tr("Localizable", "Customize URL", fallback: "Customize URL")
  public static func date(_ p1: Int) -> String {
    return Loc.tr("Localizable", "Date", p1, fallback: "Plural format key: Date")
  }
  public static let dates = Loc.tr("Localizable", "Dates", fallback: "Dates")
  public static func daysToDeletionVault(_ p1: Int) -> String {
    return Loc.tr("Localizable", "Days to deletion vault", p1, fallback: "This vault will be deleted %#@days@")
  }
  public static let defaultBackground = Loc.tr("Localizable", "Default background", fallback: "Default background")
  public static let defaultObjectType = Loc.tr("Localizable", "Default object type", fallback: "Default object type")
  public static let delete = Loc.tr("Localizable", "Delete", fallback: "Delete")
  public static let deleteVault = Loc.tr("Localizable", "Delete vault", fallback: "Delete vault")
  public static let deleted = Loc.tr("Localizable", "Deleted", fallback: "Deleted")
  public static let deletionError = Loc.tr("Localizable", "Deletion error", fallback: "Deletion error")
  public static let description = Loc.tr("Localizable", "Description", fallback: "Description")
  public static let deselect = Loc.tr("Localizable", "Deselect", fallback: "Deselect")
  public static let deselectAll = Loc.tr("Localizable", "Deselect all", fallback: "Deselect all")
  public static let designedToCaptureThoughtsQuickly = Loc.tr("Localizable", "Designed to capture thoughts quickly", fallback: "Designed to capture thoughts quickly")
  public static func devicesConnected(_ p1: Int) -> String {
    return Loc.tr("Localizable", "Devices connected", p1, fallback: "%#@device@ connected")
  }
  public static let disabled = Loc.tr("Localizable", "Disabled", fallback: "Disabled")
  public static let documentScanFailed = Loc.tr("Localizable", "Document scan failed", fallback: "Document scan failed")
  public static let done = Loc.tr("Localizable", "Done", fallback: "Done")
  public static let download = Loc.tr("Localizable", "Download", fallback: "Download")
  public static let downloadingOrUploadingDataToSomeNode = Loc.tr("Localizable", "Downloading or uploading data to some node", fallback: "Downloading or uploading data to some node")
  public static let duplicate = Loc.tr("Localizable", "Duplicate", fallback: "Duplicate")
  public static let eMail = Loc.tr("Localizable", "E-mail", fallback: "E-mail")
  public static let edit = Loc.tr("Localizable", "Edit", fallback: "Edit")
  public static let editField = Loc.tr("Localizable", "Edit field", fallback: "Edit property")
  public static let editProfile = Loc.tr("Localizable", "Edit Profile", fallback: "Edit Profile")
  public static let editType = Loc.tr("Localizable", "Edit type", fallback: "Edit type")
  public static let egProject = Loc.tr("Localizable", "egProject", fallback: "e.g. Project")
  public static let egProjects = Loc.tr("Localizable", "egProjects", fallback: "e.g. Projects")
  public static let emailSuccessfullyValidated = Loc.tr("Localizable", "Email successfully validated", fallback: "Email successfully validated")
  public static let emoji = Loc.tr("Localizable", "Emoji", fallback: "Emoji")
  public static let empty = Loc.tr("Localizable", "Empty", fallback: "Empty")
  public static let enabled = Loc.tr("Localizable", "Enabled", fallback: "Enabled")
  public static let enterEmail = Loc.tr("Localizable", "Enter email", fallback: "Enter email")
  public static let enterNumber = Loc.tr("Localizable", "Enter number", fallback: "Enter number")
  public static let enterPhoneNumber = Loc.tr("Localizable", "Enter phone number", fallback: "Enter phone number")
  public static let enterText = Loc.tr("Localizable", "Enter text", fallback: "Enter text")
  public static let enterURL = Loc.tr("Localizable", "Enter URL", fallback: "Enter URL")
  public static let enterValue = Loc.tr("Localizable", "Enter value", fallback: "Enter value")
  public static let error = Loc.tr("Localizable", "Error", fallback: "Error")
  public static let errorCreatingWallet = Loc.tr("Localizable", "Error creating wallet", fallback: "Error creating wallet")
  public static let errorSelectVault = Loc.tr("Localizable", "Error select vault", fallback: "Error select vault")
  public static let errorWalletRecoverVault = Loc.tr("Localizable", "Error wallet recover vault", fallback: "Error wallet recover vault")
  public static let everywhere = Loc.tr("Localizable", "Everywhere", fallback: "Everywhere")
  public static let exactDay = Loc.tr("Localizable", "Exact day", fallback: "Exact day")
  public static let existingProperties = Loc.tr("Localizable", "Existing properties", fallback: "Existing properties")
  public static let export = Loc.tr("Localizable", "Export", fallback: "Export")
  public static let failedToSyncTryingAgain = Loc.tr("Localizable", "Failed to sync, trying again...", fallback: "Failed to sync, trying again...")
  public static let favorite = Loc.tr("Localizable", "Favorite", fallback: "Favorite")
  public static let favorites = Loc.tr("Localizable", "Favorites", fallback: "Favorites")
  public static let featuredRelations = Loc.tr("Localizable", "Featured relations", fallback: "Featured properties")
  public static let fields = Loc.tr("Localizable", "Fields", fallback: "Properties")
  public static func file(_ p1: Int) -> String {
    return Loc.tr("Localizable", "File", p1, fallback: "Plural format key: File")
  }
  public static let fileBlockSubtitle = Loc.tr("Localizable", "File block subtitle", fallback: "Store file in original state")
  public static let files = Loc.tr("Localizable", "Files", fallback: "Files")
  public static let filter = Loc.tr("Localizable", "Filter", fallback: "Filter")
  public static let forever = Loc.tr("Localizable", "Forever", fallback: "Forever")
  public static let foreverFree = Loc.tr("Localizable", "Forever free", fallback: "Forever free")
  public static let format = Loc.tr("Localizable", "Format", fallback: "Format")
  public static let gallery = Loc.tr("Localizable", "Gallery", fallback: "Gallery")
  public static let goBack = Loc.tr("Localizable", "Go back", fallback: "Go back")
  public static let gotIt = Loc.tr("Localizable", "Got it", fallback: "I got it!")
  public static let gradients = Loc.tr("Localizable", "Gradients", fallback: "Gradients")
  public static let green = Loc.tr("Localizable", "Green", fallback: "Green")
  public static let greenBackground = Loc.tr("Localizable", "Green background", fallback: "Green background")
  public static let grey = Loc.tr("Localizable", "Grey", fallback: "Grey")
  public static let greyBackground = Loc.tr("Localizable", "Grey background", fallback: "Grey background")
  public static let header = Loc.tr("Localizable", "Header", fallback: "Header")
  public static let hidden = Loc.tr("Localizable", "Hidden", fallback: "Hidden")
  public static let hide = Loc.tr("Localizable", "Hide", fallback: "Hide")
  public static let hideTypes = Loc.tr("Localizable", "Hide types", fallback: "Hide types")
  public static let highlight = Loc.tr("Localizable", "Highlight", fallback: "Highlight")
  public static let history = Loc.tr("Localizable", "History", fallback: "History")
  public static let home = Loc.tr("Localizable", "Home", fallback: "Home")
  public static let icon = Loc.tr("Localizable", "Icon", fallback: "Icon")
  public static func image(_ p1: Int) -> String {
    return Loc.tr("Localizable", "Image", p1, fallback: "Plural format key: Image")
  }
  public static let imageBlockSubtitle = Loc.tr("Localizable", "Image block subtitle", fallback: "Upload and enrich the page with image")
  public static let inThisObject = Loc.tr("Localizable", "In this object", fallback: "In this object")
  public static let incompatibleVersion = Loc.tr("Localizable", "Incompatible version", fallback: "Incompatible version")
  public static let initializingSync = Loc.tr("Localizable", "Initializing sync", fallback: "Initializing sync")
  public static let intoObject = Loc.tr("Localizable", "Into object", fallback: "Into object")
  public static let invite = Loc.tr("Localizable", "Invite", fallback: "Invite")
  public static func itemsSyncing(_ p1: Int) -> String {
    return Loc.tr("Localizable", "Items syncing", p1, fallback: "%#@item@ syncing...")
  }
  public static let join = Loc.tr("Localizable", "Join", fallback: "Join")
  public static let joinSpaceButton = Loc.tr("Localizable", "Join Space Button", fallback: "Join Space Button")
  public static let justEMail = Loc.tr("Localizable", "Just e-mail", fallback: "Just e-mail")
  public static let layout = Loc.tr("Localizable", "Layout", fallback: "Layout")
  public static let learnMore = Loc.tr("Localizable", "Learn more", fallback: "Learn more")
  public static let leaveASpace = Loc.tr("Localizable", "Leave a space", fallback: "Leave a space")
  public static let letsGo = Loc.tr("Localizable", "Lets Go", fallback: "Let’s Go")
  public static let limitObjectTypes = Loc.tr("Localizable", "Limit object types", fallback: "Limit object types")
  public static let link = Loc.tr("Localizable", "Link", fallback: "Link")
  public static let linkTo = Loc.tr("Localizable", "Link to", fallback: "Link to")
  public static func linksCount(_ p1: Int) -> String {
    return Loc.tr("Localizable", "Links count", p1, fallback: "Plural format key: Links count")
  }
  public static func list(_ p1: Int) -> String {
    return Loc.tr("Localizable", "List", p1, fallback: "Plural format key: List")
  }
  public static let lists = Loc.tr("Localizable", "Lists", fallback: "Lists")
  public static let loadingPleaseWait = Loc.tr("Localizable", "Loading, please wait", fallback: "Loading, please wait")
  public static let localOnly = Loc.tr("Localizable", "Local Only", fallback: "Local Only")
  public static let lock = Loc.tr("Localizable", "Lock", fallback: "Lock")
  public static let logOut = Loc.tr("Localizable", "Log out", fallback: "Log out")
  public static let logoutAndClearData = Loc.tr("Localizable", "Logout and clear data", fallback: "Logout and clear data")
  public static let managePayment = Loc.tr("Localizable", "Manage payment", fallback: "Manage payment")
  public static let media = Loc.tr("Localizable", "Media", fallback: "Media")
  public static let members = Loc.tr("Localizable", "Members", fallback: "Members")
  public static let membership = Loc.tr("Localizable", "Membership", fallback: "Membership")
  public static func membersPlural(_ p1: Int) -> String {
    return Loc.tr("Localizable", "membersPlural", p1, fallback: "Plural format key: membersPlural")
  }
  public static let mentions = Loc.tr("Localizable", "Mentions", fallback: "Mentions")
  public static func minXCharacters(_ p1: Any) -> String {
    return Loc.tr("Localizable", "Min X characters", String(describing: p1), fallback: "Min %@ characters")
  }
  public static let misc = Loc.tr("Localizable", "Misc", fallback: "Misc")
  public static let mode = Loc.tr("Localizable", "Mode", fallback: "Mode")
  public static let moreInfo = Loc.tr("Localizable", "MoreInfo", fallback: "More info")
  public static let move = Loc.tr("Localizable", "Move", fallback: "Move")
  public static let moveTo = Loc.tr("Localizable", "Move to", fallback: "Move to")
  public static let moveToBin = Loc.tr("Localizable", "Move To Bin", fallback: "Move To Bin")
  public static let mute = Loc.tr("Localizable", "Mute", fallback: "Mute")
  public static let myChannels = Loc.tr("Localizable", "My Channels", fallback: "My Channels")
  public static let myFirstSpace = Loc.tr("Localizable", "My First Space", fallback: "My First Space")
  public static let myProperties = Loc.tr("Localizable", "My Properties", fallback: "My Properties")
  public static let mySpaces = Loc.tr("Localizable", "My spaces", fallback: "My Spaces")
  public static let myself = Loc.tr("Localizable", "Myself", fallback: "Myself")
  public static let name = Loc.tr("Localizable", "Name", fallback: "Name")
  public static let new = Loc.tr("Localizable", "New", fallback: "New")
  public static let newField = Loc.tr("Localizable", "New field", fallback: "New property")
  public static let newSet = Loc.tr("Localizable", "New set", fallback: "New query")
  public static let newObject = Loc.tr("Localizable", "NewObject", fallback: "New Object")
  public static let newProperty = Loc.tr("Localizable", "NewProperty", fallback: "New Property")
  public static let next = Loc.tr("Localizable", "Next", fallback: "Next")
  public static let noConnection = Loc.tr("Localizable", "No connection", fallback: "No connection")
  public static let noDate = Loc.tr("Localizable", "No date", fallback: "No date")
  public static let noItemsMatchFilter = Loc.tr("Localizable", "No items match filter", fallback: "No items match filter")
  public static let noMatchesFound = Loc.tr("Localizable", "No matches found", fallback: "No matches found.\nTry a different keyword or check your spelling.")
  public static let noPropertiesYet = Loc.tr("Localizable", "No properties yet", fallback: "No properties yet. Add some to this type.")
  public static let noRelatedOptionsHere = Loc.tr("Localizable", "No related options here", fallback: "No related options here. You can add some")
  public static func noTypeFoundText(_ p1: Any) -> String {
    return Loc.tr("Localizable", "No type found text", String(describing: p1), fallback: "No type “%@” found. Change your request or create new type.")
  }
  public static let nodeIsNotConnected = Loc.tr("Localizable", "Node is not connected", fallback: "Node is not connected")
  public static let nonExistentObject = Loc.tr("Localizable", "Non-existent object", fallback: "Non-existent object")
  public static let `none` = Loc.tr("Localizable", "None", fallback: "None")
  public static let note = Loc.tr("Localizable", "Note", fallback: "Note")
  public static let nothingFound = Loc.tr("Localizable", "Nothing found", fallback: "Nothing found")
  public static let nothingToRedo = Loc.tr("Localizable", "Nothing to redo", fallback: "Nothing to redo")
  public static let nothingToUndo = Loc.tr("Localizable", "Nothing to undo", fallback: "Nothing to undo")
  public static let notifications = Loc.tr("Localizable", "Notifications", fallback: "Notifications")
  public static func object(_ p1: Int) -> String {
    return Loc.tr("Localizable", "Object", p1, fallback: "Plural format key: Object")
  }
  public static func objectSelected(_ p1: Int) -> String {
    return Loc.tr("Localizable", "Object selected", p1, fallback: "%#@object@ selected")
  }
  public static func objectType(_ p1: Int) -> String {
    return Loc.tr("Localizable", "Object type", p1, fallback: "Plural format key: Object type")
  }
  public static let objectTypes = Loc.tr("Localizable", "Object Types", fallback: "Object Types")
  public static let objects = Loc.tr("Localizable", "Objects", fallback: "Objects")
  public static let ok = Loc.tr("Localizable", "Ok", fallback: "Ok")
  public static let okay = Loc.tr("Localizable", "Okay", fallback: "Okay")
  public static let onAnalytics = Loc.tr("Localizable", "On analytics", fallback: "On analytics")
  public static let `open` = Loc.tr("Localizable", "Open", fallback: "Open")
  public static let openAsObject = Loc.tr("Localizable", "Open as Object", fallback: "Open as Object")
  public static let openFile = Loc.tr("Localizable", "Open file", fallback: "Open file")
  public static let openObject = Loc.tr("Localizable", "Open object", fallback: "Open object")
  public static let openSet = Loc.tr("Localizable", "Open Set", fallback: "Open Query")
  public static let openSource = Loc.tr("Localizable", "Open source", fallback: "Open source")
  public static func openTypeError(_ p1: Any) -> String {
    return Loc.tr("Localizable", "Open Type Error", String(describing: p1), fallback: "Not supported type \"%@\". You can open it via desktop.")
  }
  public static let openWebPage = Loc.tr("Localizable", "Open web page", fallback: "Open web page")
  public static let openSettings = Loc.tr("Localizable", "OpenSettings", fallback: "Open Settings")
  public static let other = Loc.tr("Localizable", "Other", fallback: "Other")
  public static let otherRelations = Loc.tr("Localizable", "Other relations", fallback: "Other properties")
  public static let p2PConnecting = Loc.tr("Localizable", "P2P Connecting", fallback: "P2P Connecting...")
  public static let p2PConnection = Loc.tr("Localizable", "P2P Connection", fallback: "P2P Connection")
  public static let pages = Loc.tr("Localizable", "Pages", fallback: "Pages")
  public static func paidBy(_ p1: Any) -> String {
    return Loc.tr("Localizable", "Paid by", String(describing: p1), fallback: "Paid by %@")
  }
  public static let paste = Loc.tr("Localizable", "Paste", fallback: "Paste")
  public static let pasteOrTypeURL = Loc.tr("Localizable", "Paste or type URL", fallback: "Paste or type URL")
  public static let pasteProcessing = Loc.tr("Localizable", "Paste processing...", fallback: "Paste processing...")
  public static let payByCard = Loc.tr("Localizable", "Pay by Card", fallback: "Pay by Card")
  public static func pdf(_ p1: Int) -> String {
    return Loc.tr("Localizable", "PDF", p1, fallback: "Plural format key: PDF")
  }
  public static let pending = Loc.tr("Localizable", "Pending", fallback: "Pending...")
  public static let pendingDeletionText = Loc.tr("Localizable", "Pending deletion text", fallback: "We're sorry to see you go. You have 30 days to cancel this request. After 30 days, your encrypted vault data will be permanently removed from the backup node.")
  public static let per = Loc.tr("Localizable", "per", fallback: "per")
  public static func perDay(_ p1: Int) -> String {
    return Loc.tr("Localizable", "Per Day", p1, fallback: "per %#@day@")
  }
  public static func perMonth(_ p1: Int) -> String {
    return Loc.tr("Localizable", "Per Month", p1, fallback: "per %#@month@")
  }
  public static func perWeek(_ p1: Int) -> String {
    return Loc.tr("Localizable", "Per Week", p1, fallback: "per %#@week@")
  }
  public static func perYear(_ p1: Int) -> String {
    return Loc.tr("Localizable", "Per Year", p1, fallback: "per %#@year@")
  }
  public static let personalization = Loc.tr("Localizable", "Personalization", fallback: "Personalization")
  public static let photo = Loc.tr("Localizable", "Photo", fallback: "Photo")
  public static let picture = Loc.tr("Localizable", "Picture", fallback: "Picture")
  public static let pin = Loc.tr("Localizable", "Pin", fallback: "Pin")
  public static func pinLimitReached(_ p1: Int) -> String {
    return Loc.tr("Localizable", "Pin limit reached", p1, fallback: "You've reached the limit of %d pinned spaces.")
  }
  public static let pinOnTop = Loc.tr("Localizable", "Pin on top", fallback: "Pin on top")
  public static let pink = Loc.tr("Localizable", "Pink", fallback: "Pink")
  public static let pinkBackground = Loc.tr("Localizable", "Pink background", fallback: "Pink background")
  public static let pinned = Loc.tr("Localizable", "Pinned", fallback: "Pinned")
  public static let preferences = Loc.tr("Localizable", "Preferences", fallback: "Preferences")
  public static let preview = Loc.tr("Localizable", "Preview", fallback: "Preview")
  public static let previewLayout = Loc.tr("Localizable", "Preview layout", fallback: "Preview layout")
  public static let profile = Loc.tr("Localizable", "Profile", fallback: "Profile")
  public static let progress = Loc.tr("Localizable", "Progress...", fallback: "Progress...")
  public static let properties = Loc.tr("Localizable", "Properties", fallback: "Properties")
  public static let propertiesFormats = Loc.tr("Localizable", "Properties formats", fallback: "Properties formats")
  public static let publish = Loc.tr("Localizable", "Publish", fallback: "Publish")
  public static let publishToWeb = Loc.tr("Localizable", "Publish to Web", fallback: "Publish to Web")
  public static let purple = Loc.tr("Localizable", "Purple", fallback: "Purple")
  public static let purpleBackground = Loc.tr("Localizable", "Purple background", fallback: "Purple background")
  public static let puzzle = Loc.tr("Localizable", "Puzzle", fallback: "Puzzle")
  public static let puzzles = Loc.tr("Localizable", "Puzzles", fallback: "Puzzles")
  public static let qrCode = Loc.tr("Localizable", "QR Code", fallback: "QR Code")
  public static let random = Loc.tr("Localizable", "Random", fallback: "Random")
  public static let recent = Loc.tr("Localizable", "Recent", fallback: "Recent")
  public static let red = Loc.tr("Localizable", "Red", fallback: "Red")
  public static let redBackground = Loc.tr("Localizable", "Red background", fallback: "Red background")
  public static let redo = Loc.tr("Localizable", "Redo", fallback: "Redo")
  public static func relation(_ p1: Int) -> String {
    return Loc.tr("Localizable", "Relation", p1, fallback: "Plural format key: Relation")
  }
  public static let remove = Loc.tr("Localizable", "Remove", fallback: "Remove")
  public static let removeFromFavorite = Loc.tr("Localizable", "Remove From Favorite", fallback: "Remove From Favorite")
  public static let removePhoto = Loc.tr("Localizable", "Remove photo", fallback: "Remove photo")
  public static let removingCache = Loc.tr("Localizable", "Removing cache", fallback: "Removing cache")
  public static let resend = Loc.tr("Localizable", "Resend", fallback: "Resend")
  public static func resendIn(_ p1: Any) -> String {
    return Loc.tr("Localizable", "Resend in", String(describing: p1), fallback: "Resend in %@ sec")
  }
  public static let resetToDefault = Loc.tr("Localizable", "Reset to default", fallback: "Reset to default")
  public static let resolveLayoutConflict = Loc.tr("Localizable", "Resolve layout conflict", fallback: "Resolve layout conflict")
  public static let restore = Loc.tr("Localizable", "Restore", fallback: "Restore")
  public static let restoreFromKeychain = Loc.tr("Localizable", "Restore from keychain", fallback: "Restore from keychain")
  public static let restoreKeyFromKeychain = Loc.tr("Localizable", "Restore key from keychain", fallback: "Restore Key from the keychain")
  public static let save = Loc.tr("Localizable", "Save", fallback: "Save")
  public static let scanDocuments = Loc.tr("Localizable", "Scan documents", fallback: "Scan documents")
  public static let scanDocumentsBlockSubtitle = Loc.tr("Localizable", "Scan documents block subtitle", fallback: "Capture and upload document image")
  public static let scanQRCode = Loc.tr("Localizable", "Scan QR code", fallback: "Scan QR code")
  public static let search = Loc.tr("Localizable", "Search", fallback: "Search...")
  public static let searchForLanguage = Loc.tr("Localizable", "Search for language", fallback: "Search for language")
  public static let searchOrCreateNew = Loc.tr("Localizable", "Search or create new", fallback: "Search or create new")
  public static let selectAll = Loc.tr("Localizable", "Select all", fallback: "Select all")
  public static let selectDate = Loc.tr("Localizable", "Select date", fallback: "Select date")
  public static let selectFile = Loc.tr("Localizable", "Select file", fallback: "Select file")
  public static let selectObject = Loc.tr("Localizable", "Select object", fallback: "Select object")
  public static let selectOption = Loc.tr("Localizable", "Select option", fallback: "Select option")
  public static let selectOptions = Loc.tr("Localizable", "Select options", fallback: "Select options")
  public static let selectRelationType = Loc.tr("Localizable", "Select relation type", fallback: "Select property format")
  public static let selectVaultError = Loc.tr("Localizable", "Select vault error", fallback: "Select vault error")
  public static func selectedBlocks(_ p1: Int) -> String {
    return Loc.tr("Localizable", "Selected blocks", p1, fallback: "Plural format key: Selected blocks")
  }
  public static let selfHost = Loc.tr("Localizable", "Self Host", fallback: "Self Host")
  public static let send = Loc.tr("Localizable", "Send", fallback: "Send")
  public static let `set` = Loc.tr("Localizable", "Set", fallback: "Query")
  public static let setAsDefault = Loc.tr("Localizable", "Set as default", fallback: "Set as default")
  public static func setOf(_ p1: Any) -> String {
    return Loc.tr("Localizable", "Set of", String(describing: p1), fallback: "Query of %@")
  }
  public static let sets = Loc.tr("Localizable", "Sets", fallback: "Queries")
  public static let settingUpEncryptedStoragePleaseWait = Loc.tr("Localizable", "Setting up encrypted storage\nPlease wait", fallback: "Setting up encrypted storage\nPlease wait")
  public static let settings = Loc.tr("Localizable", "Settings", fallback: "Settings")
  public static let share = Loc.tr("Localizable", "Share", fallback: "Share")
  public static let shared = Loc.tr("Localizable", "Shared", fallback: "Shared")
  public static let show = Loc.tr("Localizable", "Show", fallback: "Show")
  public static let showTypes = Loc.tr("Localizable", "Show types", fallback: "Show types")
  public static let skip = Loc.tr("Localizable", "Skip", fallback: "Skip")
  public static let sky = Loc.tr("Localizable", "Sky", fallback: "Sky")
  public static let skyBackground = Loc.tr("Localizable", "Sky background", fallback: "Sky background")
  public static let solidColors = Loc.tr("Localizable", "Solid colors", fallback: "Solid colors")
  public static let sort = Loc.tr("Localizable", "Sort", fallback: "Sort")
  public static let standardLayoutForCanvasBlocks = Loc.tr("Localizable", "Standard layout for canvas blocks", fallback: "Standard layout for canvas blocks")
  public static let start = Loc.tr("Localizable", "Start", fallback: "Start")
  public static let style = Loc.tr("Localizable", "Style", fallback: "Style")
  public static let submit = Loc.tr("Localizable", "Submit", fallback: "Submit")
  public static func successfullyDeleted(_ p1: Any) -> String {
    return Loc.tr("Localizable", "SuccessfullyDeleted ", String(describing: p1), fallback: "%@ deleted successfully")
  }
  public static let synced = Loc.tr("Localizable", "Synced", fallback: "Synced")
  public static let systemProperties = Loc.tr("Localizable", "System Properties", fallback: "System Properties")
  public static func tag(_ p1: Int) -> String {
    return Loc.tr("Localizable", "Tag", p1, fallback: "Plural format key: Tag")
  }
  public static let task = Loc.tr("Localizable", "Task", fallback: "Task")
  public static let teal = Loc.tr("Localizable", "Teal", fallback: "Teal")
  public static let tealBackground = Loc.tr("Localizable", "Teal background", fallback: "Teal background")
  public static let templates = Loc.tr("Localizable", "Templates", fallback: "Templates")
  public static let thereAreNoSpacesYet = Loc.tr("Localizable", "There are no spaces yet", fallback: "There are no spaces yet")
  public static let thereIsNoEmojiNamed = Loc.tr("Localizable", "There is no emoji named", fallback: "There is no emoji named")
  public static let thereIsNoIconNamed = Loc.tr("Localizable", "There is no icon named", fallback: "There is no icon named")
  public static func thereIsNoObjectNamed(_ p1: Any) -> String {
    return Loc.tr("Localizable", "There is no object named", String(describing: p1), fallback: "There is no object named %@")
  }
  public static func thereIsNoPropertyNamed(_ p1: Any) -> String {
    return Loc.tr("Localizable", "There is no property named", String(describing: p1), fallback: "There is no property named %@")
  }
  public static func thereIsNoTypeNamed(_ p1: Any) -> String {
    return Loc.tr("Localizable", "There is no type named", String(describing: p1), fallback: "There is no type named %@")
  }
  public static let theseObjectsWillBeDeletedIrrevocably = Loc.tr("Localizable", "These objects will be deleted irrevocably", fallback: "These objects will be deleted irrevocably. You can’t undo this action.")
  public static let thisObjectDoesnTExist = Loc.tr("Localizable", "This object doesn't exist", fallback: "This object doesn't exist")
  public static let toBin = Loc.tr("Localizable", "To Bin", fallback: "To Bin")
  public static let today = Loc.tr("Localizable", "Today", fallback: "Today")
  public static let tomorrow = Loc.tr("Localizable", "Tomorrow", fallback: "Tomorrow")
  public static let tryToFindANewOne = Loc.tr("Localizable", "Try to find a new one", fallback: "Try to find a new one")
  public static let tryToFindANewOneOrUploadYourImage = Loc.tr("Localizable", "Try to find a new one or upload your image", fallback: "Try to find a new one or upload your image")
  public static let tryAgain = Loc.tr("Localizable", "TryAgain", fallback: "Try again")
  public static let typeLabel = Loc.tr("Localizable", "Type Label", fallback: "Type")
  public static let typeName = Loc.tr("Localizable", "Type Name", fallback: "Type Name")
  public static let typePluralName = Loc.tr("Localizable", "Type Plural name", fallback: "Type Plural name")
  public static let types = Loc.tr("Localizable", "Types", fallback: "Types")
  public static let undo = Loc.tr("Localizable", "Undo", fallback: "Undo")
  public static let undoTyping = Loc.tr("Localizable", "Undo typing", fallback: "Undo typing")
  public static let undoRedo = Loc.tr("Localizable", "Undo/Redo", fallback: "Undo/Redo")
  public static let unfavorite = Loc.tr("Localizable", "Unfavorite", fallback: "Unfavorite")
  public static let unknown = Loc.tr("Localizable", "Unknown", fallback: "Unknown")
  public static let unknownError = Loc.tr("Localizable", "Unknown error", fallback: "Unknown error")
  public static let unlimited = Loc.tr("Localizable", "unlimited", fallback: "Unlimited")
  public static let unlock = Loc.tr("Localizable", "Unlock", fallback: "Unlock")
  public static let unmute = Loc.tr("Localizable", "Unmute", fallback: "Unmute")
  public static let unpin = Loc.tr("Localizable", "Unpin", fallback: "Unpin")
  public static let unpublish = Loc.tr("Localizable", "Unpublish", fallback: "Unpublish")
  public static let unread = Loc.tr("Localizable", "Unread", fallback: "Unread")
  public static let unselectAll = Loc.tr("Localizable", "Unselect all", fallback: "Unselect all")
  public static let unsetAsDefault = Loc.tr("Localizable", "Unset as default", fallback: "Unset as default")
  public static let unsetDefault = Loc.tr("Localizable", "Unset default", fallback: "Unset default")
  public static let unsplash = Loc.tr("Localizable", "Unsplash", fallback: "Unsplash")
  public static let unsupported = Loc.tr("Localizable", "Unsupported", fallback: "Unsupported")
  public static let unsupportedBlock = Loc.tr("Localizable", "Unsupported block", fallback: "Unsupported block")
  public static let unsupportedDeeplink = Loc.tr("Localizable", "Unsupported deeplink", fallback: "Unsupported deeplink")
  public static let unsupportedValue = Loc.tr("Localizable", "Unsupported value", fallback: "Unsupported value")
  public static let untitled = Loc.tr("Localizable", "Untitled", fallback: "Untitled")
  public static let update = Loc.tr("Localizable", "Update", fallback: "Update")
  public static let upgrade = Loc.tr("Localizable", "Upgrade", fallback: "Upgrade")
  public static let upload = Loc.tr("Localizable", "Upload", fallback: "Upload")
  public static let uploadPlayableAudio = Loc.tr("Localizable", "Upload playable audio", fallback: "Upload playable audio")
  public static let validUntil = Loc.tr("Localizable", "Valid until", fallback: "Valid until:")
  public static func validUntilDate(_ p1: Any) -> String {
    return Loc.tr("Localizable", "Valid until date", String(describing: p1), fallback: "Valid until %@")
  }
  public static let vault = Loc.tr("Localizable", "Vault", fallback: "Vault")
  public static let vaultDeleted = Loc.tr("Localizable", "Vault deleted", fallback: "Vault deleted")
  public static let vaultRecoverError = Loc.tr("Localizable", "Vault recover error", fallback: "Vault recover error, try again")
  public static let vaultRecoverErrorNoInternet = Loc.tr("Localizable", "Vault recover error no internet", fallback: "Vault recover error, probably no internet connection")
  public static func video(_ p1: Int) -> String {
    return Loc.tr("Localizable", "Video", p1, fallback: "Plural format key: Video")
  }
  public static let videoBlockSubtitle = Loc.tr("Localizable", "Video block subtitle", fallback: "Upload playable video")
  public static let view = Loc.tr("Localizable", "View", fallback: "View")
  public static let views = Loc.tr("Localizable", "Views", fallback: "Views")
  public static let wallpaper = Loc.tr("Localizable", "Wallpaper", fallback: "Wallpaper")
  public static let webPages = Loc.tr("Localizable", "Web pages", fallback: "Web pages")
  public static let whatSIncluded = Loc.tr("Localizable", "What’s included", fallback: "What’s included")
  public static let yellow = Loc.tr("Localizable", "Yellow", fallback: "Yellow")
  public static let yellowBackground = Loc.tr("Localizable", "Yellow background", fallback: "Yellow background")
  public static let yesterday = Loc.tr("Localizable", "Yesterday", fallback: "Yesterday")
  public static let yourCurrentStatus = Loc.tr("Localizable", "Your current status", fallback: "Your current status:")
  public enum AITool {
    public static let button = Loc.tr("Localizable", "AITool.button", fallback: "Generate")
    public static let placeholder = Loc.tr("Localizable", "AITool.placeholder", fallback: "For example, Summarise")
    public static let title = Loc.tr("Localizable", "AITool.title", fallback: "Ask AI")
  }
  public enum About {
    public static func analyticsId(_ p1: Any) -> String {
      return Loc.tr("Localizable", "About.analyticsId", String(describing: p1), fallback: "Analytics ID: %@")
    }
    public static let anytypeCommunity = Loc.tr("Localizable", "About.AnytypeCommunity", fallback: "Anytype Community")
    public static func anytypeId(_ p1: Any) -> String {
      return Loc.tr("Localizable", "About.anytypeId", String(describing: p1), fallback: "Anytype ID: %@")
    }
    public static func appVersion(_ p1: Any) -> String {
      return Loc.tr("Localizable", "About.AppVersion", String(describing: p1), fallback: "App version: %@")
    }
    public static func buildNumber(_ p1: Any) -> String {
      return Loc.tr("Localizable", "About.BuildNumber", String(describing: p1), fallback: "Build number: %@")
    }
    public static let contactUs = Loc.tr("Localizable", "About.ContactUs", fallback: "Contact Us")
    public static func device(_ p1: Any) -> String {
      return Loc.tr("Localizable", "About.Device", String(describing: p1), fallback: "Device: %@")
    }
    public static func deviceId(_ p1: Any) -> String {
      return Loc.tr("Localizable", "About.deviceId", String(describing: p1), fallback: "Device ID: %@")
    }
    public static let helpCommunity = Loc.tr("Localizable", "About.HelpCommunity", fallback: "Help & Community")
    public static let helpTutorials = Loc.tr("Localizable", "About.HelpTutorials", fallback: "Help & Tutorials")
    public static let legal = Loc.tr("Localizable", "About.Legal", fallback: "Legal")
    public static func library(_ p1: Any) -> String {
      return Loc.tr("Localizable", "About.Library", String(describing: p1), fallback: "Library version: %@")
    }
    public static func osVersion(_ p1: Any) -> String {
      return Loc.tr("Localizable", "About.OSVersion", String(describing: p1), fallback: "OS version: %@")
    }
    public static let privacyPolicy = Loc.tr("Localizable", "About.PrivacyPolicy", fallback: "Privacy Policy")
    public static let techInfo = Loc.tr("Localizable", "About.TechInfo", fallback: "Tech Info")
    public static let termsOfUse = Loc.tr("Localizable", "About.TermsOfUse", fallback: "Terms of Use")
    public static let whatsNew = Loc.tr("Localizable", "About.WhatsNew", fallback: "What’s New")
    public enum Mail {
      public static func body(_ p1: Any) -> String {
        return Loc.tr("Localizable", "About.Mail.Body", String(describing: p1), fallback: "\n\nTechnical information\n%@")
      }
      public static func subject(_ p1: Any) -> String {
        return Loc.tr("Localizable", "About.Mail.Subject", String(describing: p1), fallback: "Support request, Vault ID %@")
      }
    }
  }
  public enum Actions {
    public static let linkItself = Loc.tr("Localizable", "Actions.LinkItself", fallback: "Link to")
    public static let makeAsTemplate = Loc.tr("Localizable", "Actions.MakeAsTemplate", fallback: "Make template")
    public static let templateMakeDefault = Loc.tr("Localizable", "Actions.TemplateMakeDefault", fallback: "Make default")
    public enum CreateWidget {
      public static let success = Loc.tr("Localizable", "Actions.CreateWidget.Success", fallback: "New widget was created")
      public static let title = Loc.tr("Localizable", "Actions.CreateWidget.Title", fallback: "To widgets")
    }
  }
  public enum Alert {
    public enum CameraPermissions {
      public static let goToSettings = Loc.tr("Localizable", "Alert.CameraPermissions.GoToSettings", fallback: "Anytype needs access to your camera to scan QR codes.\n\nPlease, go to your device's Settings -> Anytype and set Camera to ON")
      public static let settings = Loc.tr("Localizable", "Alert.CameraPermissions.Settings", fallback: "Settings")
    }
  }
  public enum AllObjects {
    public enum Search {
      public enum Empty {
        public enum State {
          public static let subtitle = Loc.tr("Localizable", "AllObjects.Search.Empty.State.subtitle", fallback: "Try searching with different keywords.")
          public static let title = Loc.tr("Localizable", "AllObjects.Search.Empty.State.title", fallback: "No results found.")
        }
      }
    }
    public enum Settings {
      public static let viewBin = Loc.tr("Localizable", "AllObjects.Settings.ViewBin", fallback: "View Bin")
      public enum Sort {
        public static let title = Loc.tr("Localizable", "AllObjects.Settings.Sort.Title", fallback: "Sort by")
      }
      public enum Unlinked {
        public static let description = Loc.tr("Localizable", "AllObjects.Settings.Unlinked.Description", fallback: "Unlinked objects that do not have a direct link or backlink with other objects in the graph.")
        public static let title = Loc.tr("Localizable", "AllObjects.Settings.Unlinked.Title", fallback: "Only unlinked")
      }
    }
    public enum Sort {
      public static let dateCreated = Loc.tr("Localizable", "AllObjects.Sort.DateCreated", fallback: "Date created")
      public static let dateUpdated = Loc.tr("Localizable", "AllObjects.Sort.DateUpdated", fallback: "Date updated")
      public enum Date {
        public static let asc = Loc.tr("Localizable", "AllObjects.Sort.Date.Asc", fallback: "Oldest first")
        public static let desc = Loc.tr("Localizable", "AllObjects.Sort.Date.Desc", fallback: "Newest first")
      }
      public enum Name {
        public static let asc = Loc.tr("Localizable", "AllObjects.Sort.Name.Asc", fallback: "A → Z")
        public static let desc = Loc.tr("Localizable", "AllObjects.Sort.Name.Desc", fallback: "Z → A")
      }
    }
  }
  public enum AnyApp {
    public enum BetaAlert {
      public static let description = Loc.tr("Localizable", "AnyApp.BetaAlert.Description", fallback: "You’re ahead of the curve! Some features are still in development or not production-ready – stay tuned for updates.")
      public static let title = Loc.tr("Localizable", "AnyApp.BetaAlert.Title", fallback: "Welcome to the Alpha version")
    }
  }
  public enum Auth {
    public static let cameraPermissionTitle = Loc.tr("Localizable", "Auth.CameraPermissionTitle", fallback: "Please allow access")
    public static let logIn = Loc.tr("Localizable", "Auth.LogIn", fallback: "I already have the key")
    public static let next = Loc.tr("Localizable", "Auth.Next", fallback: "Next")
    public enum Button {
      public static let join = Loc.tr("Localizable", "Auth.Button.Join", fallback: "I am new here")
    }
    public enum JoinFlow {
      public enum Email {
        public static let description = Loc.tr("Localizable", "Auth.JoinFlow.Email.description", fallback: "We’d love to share tips, tricks and product updates with you. Your email is never linked to your identity. We won’t share your data. Ever.")
        public static let incorrectError = Loc.tr("Localizable", "Auth.JoinFlow.Email.incorrectError", fallback: "Incorrect email")
        public static let placeholder = Loc.tr("Localizable", "Auth.JoinFlow.Email.placeholder", fallback: "Enter your email")
        public static let title = Loc.tr("Localizable", "Auth.JoinFlow.Email.title", fallback: "Stay in the loop")
      }
      public enum Key {
        public static let description = Loc.tr("Localizable", "Auth.JoinFlow.Key.Description", fallback: "It replaces login and password. Keep it safe — you control your data. You can find this Key later in app settings.")
        public static let title = Loc.tr("Localizable", "Auth.JoinFlow.Key.Title", fallback: "This is your Key")
        public enum Button {
          public enum Copy {
            public static let title = Loc.tr("Localizable", "Auth.JoinFlow.Key.Button.Copy.Title", fallback: "Copy to clipboard")
          }
          public enum Info {
            public static let title = Loc.tr("Localizable", "Auth.JoinFlow.Key.Button.Info.Title", fallback: "Read more")
          }
          public enum Later {
            public static let title = Loc.tr("Localizable", "Auth.JoinFlow.Key.Button.Later.Title", fallback: "Not now")
          }
          public enum Saved {
            public static let title = Loc.tr("Localizable", "Auth.JoinFlow.Key.Button.Saved.Title", fallback: "Next")
          }
          public enum Show {
            public static let title = Loc.tr("Localizable", "Auth.JoinFlow.Key.Button.Show.Title", fallback: "Reveal and copy")
          }
        }
        public enum ReadMore {
          public static let title = Loc.tr("Localizable", "Auth.JoinFlow.Key.ReadMore.Title", fallback: "What is the Key?")
          public enum Instruction {
            public static let title = Loc.tr("Localizable", "Auth.JoinFlow.Key.ReadMore.Instruction.Title", fallback: "How to save my key?")
            public enum Option1 {
              public static let title = Loc.tr("Localizable", "Auth.JoinFlow.Key.ReadMore.Instruction.Option1.Title", fallback: "The easiest way to store your key is to save it in your password manager.")
            }
            public enum Option2 {
              public static let title = Loc.tr("Localizable", "Auth.JoinFlow.Key.ReadMore.Instruction.Option2.Title", fallback: "The most secure way is to write it down on paper and keep it offline, in a safe and secure place.")
            }
          }
          public enum Option1 {
            public static let title = Loc.tr("Localizable", "Auth.JoinFlow.Key.ReadMore.Option1.Title", fallback: "It is represented by a recovery phrase – 12 random words from which your vault is magically generated on this device.")
          }
          public enum Option2 {
            public static let title = Loc.tr("Localizable", "Auth.JoinFlow.Key.ReadMore.Option2.Title", fallback: "Whomever knows the combination of these words owns your vault. **Right now, you are the only person in the world who knows it.**")
          }
          public enum Option3 {
            public static let title = Loc.tr("Localizable", "Auth.JoinFlow.Key.ReadMore.Option3.Title", fallback: "All computational resources on Earth are not enough to break in. If you lose it, it cannot be recovered. So, store it somewhere safe!")
          }
        }
      }
      public enum Soul {
        public static let button = Loc.tr("Localizable", "Auth.JoinFlow.Soul.Button", fallback: "Done")
        public static let description = Loc.tr("Localizable", "Auth.JoinFlow.Soul.Description", fallback: "Only seen by people you share something with. There is no central registry of these names.")
        public static let title = Loc.tr("Localizable", "Auth.JoinFlow.Soul.Title", fallback: "Add Your Name")
      }
    }
    public enum LoginFlow {
      public static let or = Loc.tr("Localizable", "Auth.LoginFlow.Or", fallback: "OR")
      public enum Enter {
        public static let title = Loc.tr("Localizable", "Auth.LoginFlow.Enter.Title", fallback: "Enter my Vault")
      }
      public enum Entering {
        public enum Void {
          public static let title = Loc.tr("Localizable", "Auth.LoginFlow.Entering.Void.Title", fallback: "Entering the Void")
        }
      }
      public enum Textfield {
        public static let placeholder = Loc.tr("Localizable", "Auth.LoginFlow.Textfield.Placeholder", fallback: "Type your key")
      }
      public enum Use {
        public enum Keychain {
          public static let title = Loc.tr("Localizable", "Auth.LoginFlow.Use.Keychain.Title", fallback: "Use keychain")
        }
      }
    }
  }
  public enum BlockLink {
    public enum PreviewSettings {
      public enum IconSize {
        public static let medium = Loc.tr("Localizable", "BlockLink.PreviewSettings.IconSize.Medium", fallback: "Medium")
        public static let `none` = Loc.tr("Localizable", "BlockLink.PreviewSettings.IconSize.None", fallback: "None")
        public static let small = Loc.tr("Localizable", "BlockLink.PreviewSettings.IconSize.Small", fallback: "Small")
      }
      public enum Layout {
        public enum Card {
          public static let title = Loc.tr("Localizable", "BlockLink.PreviewSettings.Layout.Card.Title", fallback: "Card")
        }
        public enum Text {
          public static let title = Loc.tr("Localizable", "BlockLink.PreviewSettings.Layout.Text.Title", fallback: "Text")
        }
      }
    }
  }
  public enum BlockText {
    public enum ContentType {
      public enum Bulleted {
        public static let placeholder = Loc.tr("Localizable", "BlockText.ContentType.Bulleted.Placeholder", fallback: "Bulleted list item")
      }
      public enum Checkbox {
        public static let placeholder = Loc.tr("Localizable", "BlockText.ContentType.Checkbox.Placeholder", fallback: "Checkbox")
      }
      public enum Description {
        public static let placeholder = Loc.tr("Localizable", "BlockText.ContentType.Description.Placeholder", fallback: "Add a description")
      }
      public enum Header {
        public static let placeholder = Loc.tr("Localizable", "BlockText.ContentType.Header.Placeholder", fallback: "Title")
      }
      public enum Header2 {
        public static let placeholder = Loc.tr("Localizable", "BlockText.ContentType.Header2.Placeholder", fallback: "Heading")
      }
      public enum Header3 {
        public static let placeholder = Loc.tr("Localizable", "BlockText.ContentType.Header3.Placeholder", fallback: "Subheading")
      }
      public enum Numbered {
        public static let placeholder = Loc.tr("Localizable", "BlockText.ContentType.Numbered.Placeholder", fallback: "Numbered list item")
      }
      public enum Quote {
        public static let placeholder = Loc.tr("Localizable", "BlockText.ContentType.Quote.Placeholder", fallback: "Highlighted text")
      }
      public enum Title {
        public static let placeholder = Loc.tr("Localizable", "BlockText.ContentType.Title.Placeholder", fallback: "Untitled")
      }
      public enum Toggle {
        public static let placeholder = Loc.tr("Localizable", "BlockText.ContentType.Toggle.Placeholder", fallback: "Toggle block")
      }
    }
  }
  public enum Chat {
    public static let editMessage = Loc.tr("Localizable", "Chat.EditMessage", fallback: "Edit Message")
    public static let newMessages = Loc.tr("Localizable", "Chat.NewMessages", fallback: "New Messages")
    public static func replyTo(_ p1: Any) -> String {
      return Loc.tr("Localizable", "Chat.ReplyTo", String(describing: p1), fallback: "Reply to %@")
    }
    public enum Actions {
      public enum Menu {
        public static let camera = Loc.tr("Localizable", "Chat.Actions.Menu.Camera", fallback: "Camera")
        public static let files = Loc.tr("Localizable", "Chat.Actions.Menu.Files", fallback: "Files")
        public static let lists = Loc.tr("Localizable", "Chat.Actions.Menu.Lists", fallback: "Lists")
        public static let more = Loc.tr("Localizable", "Chat.Actions.Menu.More", fallback: "More")
        public static let pages = Loc.tr("Localizable", "Chat.Actions.Menu.Pages", fallback: "Pages")
        public static let photos = Loc.tr("Localizable", "Chat.Actions.Menu.Photos", fallback: "Photos")
      }
    }
    public enum Attach {
      public enum List {
        public static let title = Loc.tr("Localizable", "Chat.Attach.List.title", fallback: "Attach List")
      }
      public enum Page {
        public static let title = Loc.tr("Localizable", "Chat.Attach.Page.title", fallback: "Attach Page")
      }
    }
    public enum AttachedObject {
      public static let attach = Loc.tr("Localizable", "Chat.AttachedObject.Attach", fallback: "Attach")
    }
    public enum AttachmentsLimit {
      public static func alert(_ p1: Any) -> String {
        return Loc.tr("Localizable", "Chat.AttachmentsLimit.Alert", String(describing: p1), fallback: "You can upload only %@ attachments at a time")
      }
    }
    public enum CreateObject {
      public enum Dismiss {
        public static let message = Loc.tr("Localizable", "Chat.CreateObject.Dismiss.Message", fallback: "If you leave it, all your changes will be lost.")
        public static let ok = Loc.tr("Localizable", "Chat.CreateObject.Dismiss.Ok", fallback: "Yes, close")
        public static let title = Loc.tr("Localizable", "Chat.CreateObject.Dismiss.Title", fallback: "Are you sure you want to close this screen?")
      }
    }
    public enum DeleteMessage {
      public static let description = Loc.tr("Localizable", "Chat.DeleteMessage.Description", fallback: "It cannot be restored after confirmation")
      public static let title = Loc.tr("Localizable", "Chat.DeleteMessage.Title", fallback: "Delete this message?")
    }
    public enum Empty {
      public static let title = Loc.tr("Localizable", "Chat.Empty.Title", fallback: "No messages yet")
      public enum Button {
        public static let title = Loc.tr("Localizable", "Chat.Empty.Button.title", fallback: "Share invite link")
      }
      public enum Editor {
        public static let description = Loc.tr("Localizable", "Chat.Empty.Editor.Description", fallback: "Write the first one to spark it up!")
      }
      public enum Owner {
        public static let description = Loc.tr("Localizable", "Chat.Empty.Owner.Description", fallback: "Invite people and spark it up!")
      }
    }
    public enum FileSyncError {
      public enum IncompatibleVersion {
        public static let action = Loc.tr("Localizable", "Chat.FileSyncError.IncompatibleVersion.Action", fallback: "Update App")
        public static let description = Loc.tr("Localizable", "Chat.FileSyncError.IncompatibleVersion.Description", fallback: "This version doesn’t support sending files or images. Update the app to share media in chats.")
        public static let title = Loc.tr("Localizable", "Chat.FileSyncError.IncompatibleVersion.Title", fallback: "Incompatible Version")
      }
      public enum Network {
        public static let description = Loc.tr("Localizable", "Chat.FileSyncError.Network.description", fallback: "We couldn’t connect right now. This may be due to no internet or a temporary sync issue. We’ll keep trying in the background.")
        public static let done = Loc.tr("Localizable", "Chat.FileSyncError.Network.done", fallback: "Got it")
        public static let title = Loc.tr("Localizable", "Chat.FileSyncError.Network.title", fallback: "Network Error")
      }
    }
    public enum Participant {
      public static let badge = Loc.tr("Localizable", "Chat.Participant.Badge", fallback: "(You)")
    }
    public enum Reactions {
      public enum Empty {
        public static let subtitle = Loc.tr("Localizable", "Chat.Reactions.Empty.Subtitle", fallback: "Probably someone has just removed the reaction or technical issue happened")
        public static let title = Loc.tr("Localizable", "Chat.Reactions.Empty.Title", fallback: "No reactions yet")
      }
    }
    public enum Reply {
      public static func attachments(_ p1: Any) -> String {
        return Loc.tr("Localizable", "Chat.Reply.Attachments", String(describing: p1), fallback: "Attachments (%@)")
      }
      public static func files(_ p1: Any) -> String {
        return Loc.tr("Localizable", "Chat.Reply.Files", String(describing: p1), fallback: "Files (%@)")
      }
      public static func images(_ p1: Any) -> String {
        return Loc.tr("Localizable", "Chat.Reply.Images", String(describing: p1), fallback: "Images (%@)")
      }
    }
    public enum SendLimitAlert {
      public static let message = Loc.tr("Localizable", "Chat.SendLimitAlert.Message", fallback: "Looks like you're sending messages at lightning speed. Give it a sec before your next one.")
      public static let title = Loc.tr("Localizable", "Chat.SendLimitAlert.Title", fallback: "Hold up! Turbo typing detected!")
    }
  }
  public enum ClearCache {
    public static let error = Loc.tr("Localizable", "ClearCache.Error", fallback: "Error, try again later")
    public static let success = Loc.tr("Localizable", "ClearCache.Success", fallback: "Cache sucessfully cleared")
  }
  public enum ClearCacheAlert {
    public static let description = Loc.tr("Localizable", "ClearCacheAlert.Description", fallback: "All media files stored in Anytype will be deleted from your current device. They can be downloaded again from a backup node or another device.")
    public static let title = Loc.tr("Localizable", "ClearCacheAlert.Title", fallback: "Are you sure?")
  }
  public enum Collection {
    public enum View {
      public enum Empty {
        public static let subtitle = Loc.tr("Localizable", "Collection.View.Empty.Subtitle", fallback: "Create first object to continue")
        public static let title = Loc.tr("Localizable", "Collection.View.Empty.Title", fallback: "No objects")
        public enum Button {
          public static let title = Loc.tr("Localizable", "Collection.View.Empty.Button.Title", fallback: "Create object")
        }
      }
    }
  }
  public enum CommonOpenErrorView {
    public static let message = Loc.tr("Localizable", "CommonOpenErrorView.Message", fallback: "No data found")
  }
  public enum Content {
    public enum Audio {
      public static let upload = Loc.tr("Localizable", "Content.Audio.Upload", fallback: "Upload audio")
    }
    public enum Bookmark {
      public static let add = Loc.tr("Localizable", "Content.Bookmark.Add", fallback: "Add a web bookmark")
      public static let loading = Loc.tr("Localizable", "Content.Bookmark.Loading", fallback: "Loading, please wait...")
    }
    public enum Common {
      public static let error = Loc.tr("Localizable", "Content.Common.Error", fallback: "Something went wrong, try again")
      public static let uploading = Loc.tr("Localizable", "Content.Common.Uploading", fallback: "Uploading...")
    }
    public enum DataView {
      public enum InlineCollection {
        public static let subtitle = Loc.tr("Localizable", "Content.DataView.InlineCollection.Subtitle", fallback: "Inline collection")
        public static let untitled = Loc.tr("Localizable", "Content.DataView.InlineCollection.Untitled", fallback: "Untitled collection")
      }
      public enum InlineSet {
        public static let noData = Loc.tr("Localizable", "Content.DataView.InlineSet.NoData", fallback: "No data")
        public static let noSource = Loc.tr("Localizable", "Content.DataView.InlineSet.NoSource", fallback: "No source")
        public static let subtitle = Loc.tr("Localizable", "Content.DataView.InlineSet.Subtitle", fallback: "Inline query")
        public static let untitled = Loc.tr("Localizable", "Content.DataView.InlineSet.Untitled", fallback: "Untitled query")
        public enum Toast {
          public static let failure = Loc.tr("Localizable", "Content.DataView.InlineSet.Toast.Failure", fallback: "This inline query doesn’t have a source")
        }
      }
    }
    public enum File {
      public static let upload = Loc.tr("Localizable", "Content.File.Upload", fallback: "Upload a file")
    }
    public enum Picture {
      public static let upload = Loc.tr("Localizable", "Content.Picture.Upload", fallback: "Upload a picture")
    }
    public enum Video {
      public static let upload = Loc.tr("Localizable", "Content.Video.Upload", fallback: "Upload a video")
    }
  }
  public enum DataviewType {
    public static let calendar = Loc.tr("Localizable", "DataviewType.calendar", fallback: "Calendar")
    public static let gallery = Loc.tr("Localizable", "DataviewType.gallery", fallback: "Gallery")
    public static let graph = Loc.tr("Localizable", "DataviewType.graph", fallback: "Graph")
    public static let grid = Loc.tr("Localizable", "DataviewType.grid", fallback: "Grid")
    public static let kanban = Loc.tr("Localizable", "DataviewType.kanban", fallback: "Kanban")
    public static let list = Loc.tr("Localizable", "DataviewType.list", fallback: "List")
  }
  public enum Date {
    public enum Object {
      public enum Empty {
        public enum State {
          public static let title = Loc.tr("Localizable", "Date.Object.Empty.State.title", fallback: "There is nothing here for this date yet")
        }
      }
    }
    public enum Open {
      public enum Action {
        public static let title = Loc.tr("Localizable", "Date.Open.Action.title", fallback: "Open selected date")
      }
    }
  }
  public enum Debug {
    public static let info = Loc.tr("Localizable", "Debug.Info", fallback: "Debug Info")
    public static func mimeTypes(_ p1: Any) -> String {
      return Loc.tr("Localizable", "Debug.MimeTypes", String(describing: p1), fallback: "Mime Types - %@")
    }
  }
  public enum DebugMenu {
    public static func toggleAuthor(_ p1: Any, _ p2: Any) -> String {
      return Loc.tr("Localizable", "DebugMenu.ToggleAuthor", String(describing: p1), String(describing: p2), fallback: "Release: %@, %@")
    }
  }
  public enum DeletionAlert {
    public static let description = Loc.tr("Localizable", "DeletionAlert.description", fallback: "You will be logged out on all other devices. You'll have 30 days to recover your vault. Afterwards, it will be deleted permanently.")
    public static let title = Loc.tr("Localizable", "DeletionAlert.title", fallback: "Are you sure you want to delete your vault?")
  }
  public enum EditSet {
    public enum Popup {
      public enum Filter {
        public enum Condition {
          public enum Checkbox {
            public static let equal = Loc.tr("Localizable", "EditSet.Popup.Filter.Condition.Checkbox.Equal", fallback: "Is")
            public static let notEqual = Loc.tr("Localizable", "EditSet.Popup.Filter.Condition.Checkbox.NotEqual", fallback: "Is not")
          }
          public enum Date {
            public static let after = Loc.tr("Localizable", "EditSet.Popup.Filter.Condition.Date.After", fallback: "Is after")
            public static let before = Loc.tr("Localizable", "EditSet.Popup.Filter.Condition.Date.Before", fallback: "Is before")
            public static let equal = Loc.tr("Localizable", "EditSet.Popup.Filter.Condition.Date.Equal", fallback: "Is")
            public static let `in` = Loc.tr("Localizable", "EditSet.Popup.Filter.Condition.Date.In", fallback: "Is within")
            public static let onOrAfter = Loc.tr("Localizable", "EditSet.Popup.Filter.Condition.Date.OnOrAfter", fallback: "Is on or after")
            public static let onOrBefore = Loc.tr("Localizable", "EditSet.Popup.Filter.Condition.Date.OnOrBefore", fallback: "Is on or before")
          }
          public enum General {
            public static let empty = Loc.tr("Localizable", "EditSet.Popup.Filter.Condition.General.Empty", fallback: "Is empty")
            public static let `none` = Loc.tr("Localizable", "EditSet.Popup.Filter.Condition.General.None", fallback: "All")
            public static let notEmpty = Loc.tr("Localizable", "EditSet.Popup.Filter.Condition.General.NotEmpty", fallback: "Is not empty")
          }
          public enum Number {
            public static let equal = Loc.tr("Localizable", "EditSet.Popup.Filter.Condition.Number.Equal", fallback: "Is equal to")
            public static let greater = Loc.tr("Localizable", "EditSet.Popup.Filter.Condition.Number.Greater", fallback: "Is greater than")
            public static let greaterOrEqual = Loc.tr("Localizable", "EditSet.Popup.Filter.Condition.Number.GreaterOrEqual", fallback: "Is greater than or equal to")
            public static let less = Loc.tr("Localizable", "EditSet.Popup.Filter.Condition.Number.Less", fallback: "Is less than")
            public static let lessOrEqual = Loc.tr("Localizable", "EditSet.Popup.Filter.Condition.Number.LessOrEqual", fallback: "Is less than or equal to")
            public static let notEqual = Loc.tr("Localizable", "EditSet.Popup.Filter.Condition.Number.NotEqual", fallback: "Is not equal to")
          }
          public enum Selected {
            public static let allIn = Loc.tr("Localizable", "EditSet.Popup.Filter.Condition.Selected.AllIn", fallback: "Has all of")
            public static let equal = Loc.tr("Localizable", "EditSet.Popup.Filter.Condition.Selected.Equal", fallback: "Is exactly")
            public static let `in` = Loc.tr("Localizable", "EditSet.Popup.Filter.Condition.Selected.In", fallback: "Has any of")
            public static let notIn = Loc.tr("Localizable", "EditSet.Popup.Filter.Condition.Selected.NotIn", fallback: "Has none of")
          }
          public enum Text {
            public static let equal = Loc.tr("Localizable", "EditSet.Popup.Filter.Condition.Text.Equal", fallback: "Is")
            public static let like = Loc.tr("Localizable", "EditSet.Popup.Filter.Condition.Text.Like", fallback: "Contains")
            public static let notEqual = Loc.tr("Localizable", "EditSet.Popup.Filter.Condition.Text.NotEqual", fallback: "Is not")
            public static let notLike = Loc.tr("Localizable", "EditSet.Popup.Filter.Condition.Text.NotLike", fallback: "Doesn't contain")
          }
        }
        public enum Date {
          public enum Option {
            public static let currentMonth = Loc.tr("Localizable", "EditSet.Popup.Filter.Date.Option.CurrentMonth", fallback: "Current month")
            public static let currentWeek = Loc.tr("Localizable", "EditSet.Popup.Filter.Date.Option.CurrentWeek", fallback: "Current week")
            public static let currentYear = Loc.tr("Localizable", "EditSet.Popup.Filter.Date.Option.CurrentYear", fallback: "Current year")
            public static let exactDate = Loc.tr("Localizable", "EditSet.Popup.Filter.Date.Option.ExactDate", fallback: "Exact date")
            public static let lastMonth = Loc.tr("Localizable", "EditSet.Popup.Filter.Date.Option.LastMonth", fallback: "Last month")
            public static let lastWeek = Loc.tr("Localizable", "EditSet.Popup.Filter.Date.Option.LastWeek", fallback: "Last week")
            public static let lastYear = Loc.tr("Localizable", "EditSet.Popup.Filter.Date.Option.LastYear", fallback: "Last year")
            public static let nextMonth = Loc.tr("Localizable", "EditSet.Popup.Filter.Date.Option.NextMonth", fallback: "Next month")
            public static let nextWeek = Loc.tr("Localizable", "EditSet.Popup.Filter.Date.Option.NextWeek", fallback: "Next week")
            public static let nextYear = Loc.tr("Localizable", "EditSet.Popup.Filter.Date.Option.NextYear", fallback: "Next year")
            public static let numberOfDaysAgo = Loc.tr("Localizable", "EditSet.Popup.Filter.Date.Option.NumberOfDaysAgo", fallback: "Number of days ago")
            public static let numberOfDaysFromNow = Loc.tr("Localizable", "EditSet.Popup.Filter.Date.Option.NumberOfDaysFromNow", fallback: "Number of days from now")
            public static let today = Loc.tr("Localizable", "EditSet.Popup.Filter.Date.Option.Today", fallback: "Today")
            public static let tomorrow = Loc.tr("Localizable", "EditSet.Popup.Filter.Date.Option.Tomorrow", fallback: "Tomorrow")
            public static let yesterday = Loc.tr("Localizable", "EditSet.Popup.Filter.Date.Option.Yesterday", fallback: "Yesterday")
            public enum NumberOfDaysAgo {
              public static func short(_ p1: Any) -> String {
                return Loc.tr("Localizable", "EditSet.Popup.Filter.Date.Option.NumberOfDaysAgo.Short", String(describing: p1), fallback: "%@ days ago")
              }
            }
            public enum NumberOfDaysFromNow {
              public static func short(_ p1: Any) -> String {
                return Loc.tr("Localizable", "EditSet.Popup.Filter.Date.Option.NumberOfDaysFromNow.Short", String(describing: p1), fallback: "%@ days from now")
              }
            }
          }
        }
        public enum Value {
          public static let checked = Loc.tr("Localizable", "EditSet.Popup.Filter.Value.Checked", fallback: "Checked")
          public static let unchecked = Loc.tr("Localizable", "EditSet.Popup.Filter.Value.Unchecked", fallback: "Unchecked")
        }
      }
      public enum Filters {
        public enum EmptyView {
          public static let title = Loc.tr("Localizable", "EditSet.Popup.Filters.EmptyView.Title", fallback: "No filters here. You can add some")
        }
        public enum NavigationView {
          public static let title = Loc.tr("Localizable", "EditSet.Popup.Filters.NavigationView.Title", fallback: "Filters")
        }
        public enum TextView {
          public static let placeholder = Loc.tr("Localizable", "EditSet.Popup.Filters.TextView.Placeholder", fallback: "Value")
        }
      }
      public enum Sort {
        public enum Add {
          public static let searchPlaceholder = Loc.tr("Localizable", "EditSet.Popup.Sort.Add.SearchPlaceholder", fallback: "Сhoose a property to sort")
        }
        public enum EmptyTypes {
          public static let end = Loc.tr("Localizable", "EditSet.Popup.Sort.EmptyTypes.End", fallback: "On bottom")
          public static let start = Loc.tr("Localizable", "EditSet.Popup.Sort.EmptyTypes.Start", fallback: "On top")
          public enum Section {
            public static let title = Loc.tr("Localizable", "EditSet.Popup.Sort.EmptyTypes.Section.Title", fallback: "Show empty values")
          }
        }
        public enum Types {
          public static let ascending = Loc.tr("Localizable", "EditSet.Popup.Sort.Types.Ascending", fallback: "Ascending")
          public static let descending = Loc.tr("Localizable", "EditSet.Popup.Sort.Types.Descending", fallback: "Descending")
        }
      }
      public enum Sorts {
        public enum EmptyView {
          public static let title = Loc.tr("Localizable", "EditSet.Popup.Sorts.EmptyView.Title", fallback: "No sorts here. You can add some")
        }
        public enum NavigationView {
          public static let title = Loc.tr("Localizable", "EditSet.Popup.Sorts.NavigationView.Title", fallback: "Sorts")
        }
      }
    }
  }
  public enum Editor {
    public enum LinkToObject {
      public static let linkedTo = Loc.tr("Localizable", "Editor.LinkToObject.LinkedTo", fallback: "Linked to")
      public static let pasteFromClipboard = Loc.tr("Localizable", "Editor.LinkToObject.PasteFromClipboard", fallback: "Paste from clipboard")
      public static let removeLink = Loc.tr("Localizable", "Editor.LinkToObject.RemoveLink", fallback: "Remove link")
      public static let searchPlaceholder = Loc.tr("Localizable", "Editor.LinkToObject.SearchPlaceholder", fallback: "Paste link or search objects")
    }
    public enum MovingState {
      public static let scrollToSelectedPlace = Loc.tr("Localizable", "Editor.MovingState.ScrollToSelectedPlace", fallback: "Scroll to select a place")
    }
    public enum Toast {
      public static let linkedTo = Loc.tr("Localizable", "Editor.Toast.LinkedTo", fallback: "linked to")
      public static let movedTo = Loc.tr("Localizable", "Editor.Toast.MovedTo", fallback: "Block moved to")
    }
  }
  public enum EditorSet {
    public enum View {
      public enum Not {
        public enum Supported {
          public static let title = Loc.tr("Localizable", "EditorSet.View.Not.Supported.Title", fallback: "Unsupported")
        }
      }
    }
  }
  public enum Embed {
    public enum Block {
      public enum Content {
        public static func title(_ p1: Any) -> String {
          return Loc.tr("Localizable", "Embed.Block.Content.title", String(describing: p1), fallback: "%@ embed. This content is not available on mobile")
        }
        public enum Url {
          public static func title(_ p1: Any) -> String {
            return Loc.tr("Localizable", "Embed.Block.Content.Url.title", String(describing: p1), fallback: "%@ embed. Opens in external app or browser")
          }
        }
      }
      public enum Empty {
        public static func title(_ p1: Any) -> String {
          return Loc.tr("Localizable", "Embed.Block.Empty.title", String(describing: p1), fallback: "%@ embed is empty")
        }
      }
    }
  }
  public enum EmptyView {
    public enum Bin {
      public static let subtitle = Loc.tr("Localizable", "EmptyView.Bin.subtitle", fallback: "Looks like you’re all tidy and organized!")
      public static let title = Loc.tr("Localizable", "EmptyView.Bin.title", fallback: "Your bin is empty.")
    }
    public enum Default {
      public static let subtitle = Loc.tr("Localizable", "EmptyView.Default.subtitle", fallback: "Create your first objects to get started.")
      public static let title = Loc.tr("Localizable", "EmptyView.Default.title", fallback: "It’s empty here.")
    }
  }
  public enum Error {
    public static let unableToConnect = Loc.tr("Localizable", "Error.UnableToConnect", fallback: "Please connect to the internet")
    public enum AnytypeNeedsUpgrate {
      public static let confirm = Loc.tr("Localizable", "Error.AnytypeNeedsUpgrate.Confirm", fallback: "Update")
      public static let message = Loc.tr("Localizable", "Error.AnytypeNeedsUpgrate.Message", fallback: "This object was modified in a newer version of Anytype. Please update the app to open it on this device")
      public static let title = Loc.tr("Localizable", "Error.AnytypeNeedsUpgrate.Title", fallback: "Update Your App")
    }
    public enum Common {
      public static let message = Loc.tr("Localizable", "Error.Common.Message", fallback: "Please check your internet connection and try again or [post a report on forum](http://community.anytype.io/report-bug).")
      public static let title = Loc.tr("Localizable", "Error.Common.Title", fallback: "Oops!")
    }
  }
  public enum ErrorOccurred {
    public static let pleaseTryAgain = Loc.tr("Localizable", "Error occurred. Please try again", fallback: "Error occurred. Please try again")
  }
  public enum Fields {
    public static let addToType = Loc.tr("Localizable", "Fields.addToType", fallback: "Add to the current type")
    public static func created(_ p1: Any) -> String {
      return Loc.tr("Localizable", "Fields.Created", String(describing: p1), fallback: "Property ‘%@’ has been created")
    }
    public static let foundInObjects = Loc.tr("Localizable", "Fields.foundInObjects", fallback: "Found in objects")
    public static let local = Loc.tr("Localizable", "Fields.local", fallback: "Local")
    public static let menu = Loc.tr("Localizable", "Fields.menu", fallback: "Properties panel")
    public static let missingInfo = Loc.tr("Localizable", "Fields.missingInfo", fallback: "These properties exist in some objects but aren’t part of the Type. Add them to make them appear in all objects of this Type.")
    public static let removeFromObject = Loc.tr("Localizable", "Fields.removeFromObject", fallback: "Remove from the object")
    public static func updated(_ p1: Any) -> String {
      return Loc.tr("Localizable", "Fields.Updated", String(describing: p1), fallback: "Property ‘%@’ has been updated")
    }
  }
  public enum FileStorage {
    public static let cleanUpFiles = Loc.tr("Localizable", "FileStorage.CleanUpFiles", fallback: "Clean up files files")
    public static let limitError = Loc.tr("Localizable", "FileStorage.LimitError", fallback: "You exceeded file limit upload")
    public static let offloadTitle = Loc.tr("Localizable", "FileStorage.OffloadTitle", fallback: "Offload files")
    public static let title = Loc.tr("Localizable", "FileStorage.Title", fallback: "File storage")
    public enum LimitLegend {
      public static func current(_ p1: Any, _ p2: Any) -> String {
        return Loc.tr("Localizable", "FileStorage.LimitLegend.Current", String(describing: p1), String(describing: p2), fallback: "%@ | %@")
      }
      public static func free(_ p1: Any) -> String {
        return Loc.tr("Localizable", "FileStorage.LimitLegend.Free", String(describing: p1), fallback: "Free | %@")
      }
      public static func other(_ p1: Any) -> String {
        return Loc.tr("Localizable", "FileStorage.LimitLegend.Other", String(describing: p1), fallback: "Other spaces | %@")
      }
    }
    public enum Local {
      public static let instruction = Loc.tr("Localizable", "FileStorage.Local.Instruction", fallback: "In order to save space on your local device, you can offload all your files to our encrypted backup node. The files will be loaded back when you open them.")
      public static let title = Loc.tr("Localizable", "FileStorage.Local.Title", fallback: "Local storage")
      public static func used(_ p1: Any) -> String {
        return Loc.tr("Localizable", "FileStorage.Local.Used", String(describing: p1), fallback: "%@ used")
      }
    }
    public enum Space {
      public static let getMore = Loc.tr("Localizable", "FileStorage.Space.GetMore", fallback: "Get more space")
      public static func instruction(_ p1: Any) -> String {
        return Loc.tr("Localizable", "FileStorage.Space.Instruction", String(describing: p1), fallback: "You can store up to %@ of your files on our encrypted backup node for free. If you reach the limit, files will be stored only locally.")
      }
      public static let title = Loc.tr("Localizable", "FileStorage.Space.Title", fallback: "Remote storage")
      public static func used(_ p1: Any, _ p2: Any) -> String {
        return Loc.tr("Localizable", "FileStorage.Space.Used", String(describing: p1), String(describing: p2), fallback: "%@ of %@ used")
      }
    }
  }
  public enum FilesList {
    public static let title = Loc.tr("Localizable", "FilesList.Title", fallback: "Clean up files")
    public enum ForceDelete {
      public static let title = Loc.tr("Localizable", "FilesList.ForceDelete.Title", fallback: "Are you sure you want to permanently delete the files?")
    }
  }
  public enum Gallery {
    public static func author(_ p1: Any) -> String {
      return Loc.tr("Localizable", "Gallery.Author", String(describing: p1), fallback: "Made by @%@")
    }
    public static let install = Loc.tr("Localizable", "Gallery.Install", fallback: "Install")
    public static let installToNew = Loc.tr("Localizable", "Gallery.InstallToNew", fallback: "Install to new space")
    public enum Notification {
      public static let button = Loc.tr("Localizable", "Gallery.Notification.Button", fallback: "Go to space")
      public static func error(_ p1: Any) -> String {
        return Loc.tr("Localizable", "Gallery.Notification.Error", String(describing: p1), fallback: "Oops! \"%@\" wasn't installed. Please check your internet connection and try again or post a report on forum.")
      }
      public static func success(_ p1: Any) -> String {
        return Loc.tr("Localizable", "Gallery.Notification.Success", String(describing: p1), fallback: "Experience was successfully installed to the \"%@\" space. You can now open and start using it.")
      }
    }
  }
  public enum GlobalSearch {
    public enum EmptyFilteredState {
      public static let title = Loc.tr("Localizable", "GlobalSearch.EmptyFilteredState.title", fallback: "No related objects found")
    }
    public enum EmptyState {
      public static let subtitle = Loc.tr("Localizable", "GlobalSearch.EmptyState.subtitle", fallback: "Create new object or search for something else")
    }
    public enum Swipe {
      public enum Tip {
        public static let subtitle = Loc.tr("Localizable", "GlobalSearch.Swipe.Tip.subtitle", fallback: "Swipe left to see related objects. Note, it works only for objects that have related objects.")
        public static let title = Loc.tr("Localizable", "GlobalSearch.Swipe.Tip.title", fallback: "Related objects")
      }
    }
  }
  public enum Home {
    public enum Snackbar {
      public static let library = Loc.tr("Localizable", "Home.Snackbar.Library", fallback: "Library is available in desktop app")
    }
  }
  public enum Initial {
    public enum UnstableMiddle {
      public static let `continue` = Loc.tr("Localizable", "Initial.UnstableMiddle.Continue", fallback: "Continue with current vault")
      public static let logout = Loc.tr("Localizable", "Initial.UnstableMiddle.Logout", fallback: "Logout from current vault")
      public static let message = Loc.tr("Localizable", "Initial.UnstableMiddle.Message", fallback: "You launch app with a unstable middleware. Don't use your production vault. Your vault may be broken.")
      public static let title = Loc.tr("Localizable", "Initial.UnstableMiddle.Title", fallback: "Warning")
      public static let wontUseProd = Loc.tr("Localizable", "Initial.UnstableMiddle.WontUseProd", fallback: "I won't be using my production vault")
    }
  }
  public enum InterfaceStyle {
    public static let dark = Loc.tr("Localizable", "InterfaceStyle.dark", fallback: "Dark")
    public static let light = Loc.tr("Localizable", "InterfaceStyle.light", fallback: "Light")
    public static let system = Loc.tr("Localizable", "InterfaceStyle.system", fallback: "System")
  }
  public enum Keychain {
    public static let haveYouBackedUpYourKey = Loc.tr("Localizable", "Keychain.Have you backed up your key?", fallback: "Have you backed up your key?")
    public static let key = Loc.tr("Localizable", "Keychain.Key", fallback: "Key")
    public static let seedPhrasePlaceholder = Loc.tr("Localizable", "Keychain.SeedPhrasePlaceholder", fallback: "witch collapse practice feed shame open despair creek road again ice least lake tree young address brain despair")
    public static let showAndCopyKey = Loc.tr("Localizable", "Keychain.Show and copy key", fallback: "Show and copy key")
    public enum Error {
      public static let dataToStringConversionError = Loc.tr("Localizable", "Keychain.Error.Data to String conversion error", fallback: "Data to String conversion error")
      public static let stringToDataConversionError = Loc.tr("Localizable", "Keychain.Error.String to Data conversion error", fallback: "String to Data conversion error")
      public static let unknownKeychainError = Loc.tr("Localizable", "Keychain.Error.Unknown Keychain Error", fallback: "Unknown Keychain Error")
    }
    public enum Key {
      public static let description = Loc.tr("Localizable", "Keychain.Key.description", fallback: "You will need it to enter your vault. Keep it in a safe place. If you lose it, you can no longer enter your vault.")
      public enum Copy {
        public enum Toast {
          public static let title = Loc.tr("Localizable", "Keychain.Key.Copy.Toast.title", fallback: "Key copied")
        }
      }
    }
  }
  public enum LinkAppearance {
    public enum Description {
      public enum Content {
        public static let title = Loc.tr("Localizable", "LinkAppearance.Description.Content.Title", fallback: "Content preview")
      }
      public enum None {
        public static let title = Loc.tr("Localizable", "LinkAppearance.Description.None.Title", fallback: "None")
      }
      public enum Object {
        public static let title = Loc.tr("Localizable", "LinkAppearance.Description.Object.Title", fallback: "Object description")
      }
    }
    public enum ObjectType {
      public static let title = Loc.tr("Localizable", "LinkAppearance.ObjectType.Title", fallback: "Object type")
    }
  }
  public enum LinkPaste {
    public static let bookmark = Loc.tr("Localizable", "LinkPaste.bookmark", fallback: "Create bookmark")
    public static let link = Loc.tr("Localizable", "LinkPaste.link", fallback: "Paste as link")
    public static let text = Loc.tr("Localizable", "LinkPaste.text", fallback: "Paste as text")
  }
  public enum LongTapCreateTip {
    public static let message = Loc.tr("Localizable", "LongTapCreateTip.Message", fallback: "Long tap on Create Object button to open menu with types")
    public static let title = Loc.tr("Localizable", "LongTapCreateTip.Title", fallback: "Create Objects with specific Type")
  }
  public enum Membership {
    public static let emailValidation = Loc.tr("Localizable", "Membership.EmailValidation", fallback: "Enter the code sent to your email")
    public static let unavailable = Loc.tr("Localizable", "Membership.unavailable", fallback: "This tier is not available in the app. We know it's not ideal.")
    public enum Ad {
      public static let subtitle = Loc.tr("Localizable", "Membership.Ad.Subtitle", fallback: "Joining Anytype network means contributing to its story")
      public static let title = Loc.tr("Localizable", "Membership.Ad.Title", fallback: "Membership")
    }
    public enum Banner {
      public static let subtitle1 = Loc.tr("Localizable", "Membership.Banner.Subtitle1", fallback: "As a valued member your voice matters! Engage in exclusive events, shape strategic choices, and influence our roadmap.")
      public static let subtitle2 = Loc.tr("Localizable", "Membership.Banner.Subtitle2", fallback: "Members enjoy higher backup storage & sync limits, invitations for multiple guests to collaborate in shared spaces, and a unique identity on the Anytype Network.")
      public static let subtitle3 = Loc.tr("Localizable", "Membership.Banner.Subtitle3", fallback: "Your contribution supports our team and endorses our vision of a user-owned, secure, and collaborative digital network.")
      public static let subtitle4 = Loc.tr("Localizable", "Membership.Banner.Subtitle4", fallback: "Our network's value exceeds the sum of its parts. Your membership sustains the infrastructure for its growth which underpins this network.")
      public static let title1 = Loc.tr("Localizable", "Membership.Banner.Title1", fallback: "Build the Vision Together")
      public static let title2 = Loc.tr("Localizable", "Membership.Banner.Title2", fallback: "Unlock Member Benefits")
      public static let title3 = Loc.tr("Localizable", "Membership.Banner.Title3", fallback: "Support Digital Independence")
      public static let title4 = Loc.tr("Localizable", "Membership.Banner.Title4", fallback: "Invest in Connectivity")
    }
    public enum Email {
      public static let body = Loc.tr("Localizable", "Membership.Email.Body", fallback: "Hello Anytype team! I would like to extend my current membership for more (please choose an option):\n- Extra remote storage\n- More space editors\n- Additional shared spaces\nSpecifically,\nPlease provide specific details of your needs here.")
    }
    public enum EmailForm {
      public static let subtitle = Loc.tr("Localizable", "Membership.EmailForm.Subtitle", fallback: "It is not linked to your account in any way.")
      public static let title = Loc.tr("Localizable", "Membership.EmailForm.Title", fallback: "Get updates and enjoy free perks!")
    }
    public enum Feature {
      public static func invites(_ p1: Any) -> String {
        return Loc.tr("Localizable", "Membership.Feature.Invites", String(describing: p1), fallback: "%@ Invitations")
      }
      public static let localName = Loc.tr("Localizable", "Membership.Feature.LocalName", fallback: "Local, non-unique name")
      public static func sharedSpaces(_ p1: Any) -> String {
        return Loc.tr("Localizable", "Membership.Feature.SharedSpaces", String(describing: p1), fallback: "Up to %@ Shared spaces")
      }
      public static func spaceWriters(_ p1: Any) -> String {
        return Loc.tr("Localizable", "Membership.Feature.SpaceWriters", String(describing: p1), fallback: "%@ Editors per shared space")
      }
      public static func storageGB(_ p1: Any) -> String {
        return Loc.tr("Localizable", "Membership.Feature.StorageGB", String(describing: p1), fallback: "%@ GB of backup & sync space on the Anytype network")
      }
      public static func uniqueName(_ p1: Any) -> String {
        return Loc.tr("Localizable", "Membership.Feature.UniqueName", String(describing: p1), fallback: "Unique Network name (%@+ characters)")
      }
      public static let unlimitedViewers = Loc.tr("Localizable", "Membership.Feature.UnlimitedViewers", fallback: "Unlimited Viewers for shared spaces")
      public static func viewers(_ p1: Any) -> String {
        return Loc.tr("Localizable", "Membership.Feature.Viewers", String(describing: p1), fallback: "%@ Viewers for shared spaces")
      }
    }
    public enum Legal {
      public static let alreadyPurchasedTier = Loc.tr("Localizable", "Membership.Legal.AlreadyPurchasedTier", fallback: "Already purchased tier?")
      public static let details = Loc.tr("Localizable", "Membership.Legal.Details", fallback: "Membership plan details")
      public static let letUsKnow = Loc.tr("Localizable", "Membership.Legal.LetUsKnow", fallback: "Please let us know here.")
      public static let privacy = Loc.tr("Localizable", "Membership.Legal.Privacy", fallback: "Privacy policy")
      public static let restorePurchases = Loc.tr("Localizable", "Membership.Legal.RestorePurchases", fallback: "Restore purchases")
      public static let terms = Loc.tr("Localizable", "Membership.Legal.Terms", fallback: "Terms and conditions")
      public static let wouldYouLike = Loc.tr("Localizable", "Membership.Legal.WouldYouLike", fallback: "Would you like to use Anytype for business, education, etc.?")
    }
    public enum ManageTier {
      public static let android = Loc.tr("Localizable", "Membership.ManageTier.Android", fallback: "You can manage tier on Android platform")
      public static let appleId = Loc.tr("Localizable", "Membership.ManageTier.AppleId", fallback: "You can manage tier on another AppleId account")
      public static let desktop = Loc.tr("Localizable", "Membership.ManageTier.Desktop", fallback: "You can manage tier on Desktop platform")
    }
    public enum NameForm {
      public static let subtitle = Loc.tr("Localizable", "Membership.NameForm.Subtitle", fallback: "This is your unique name on the Anytype network, confirming your Membership. It acts as your personal domain and cannot be changed.")
      public static let title = Loc.tr("Localizable", "Membership.NameForm.Title", fallback: "Pick your unique name")
      public static let validated = Loc.tr("Localizable", "Membership.NameForm.Validated", fallback: "This name is up for grabs")
      public static let validating = Loc.tr("Localizable", "Membership.NameForm.Validating", fallback: "Wait a second...")
    }
    public enum Payment {
      public static let appleSubscription = Loc.tr("Localizable", "Membership.Payment.Apple subscription", fallback: "Apple subscription")
      public static let card = Loc.tr("Localizable", "Membership.Payment.Card", fallback: "Card")
      public static let crypto = Loc.tr("Localizable", "Membership.Payment.Crypto", fallback: "Crypto")
      public static let googleSubscription = Loc.tr("Localizable", "Membership.Payment.Google subscription", fallback: "Google subscription")
    }
    public enum Success {
      public static let curiosity = Loc.tr("Localizable", "Membership.Success.Curiosity", fallback: "Big cheers for your curiosity!")
      public static let support = Loc.tr("Localizable", "Membership.Success.Support", fallback: "Big cheers for your support!")
      public static func title(_ p1: Any) -> String {
        return Loc.tr("Localizable", "Membership.Success.Title", String(describing: p1), fallback: "Welcome to the network, %@")
      }
    }
    public enum Upgrade {
      public static let button = Loc.tr("Localizable", "Membership.Upgrade.Button", fallback: "Contact Anytype Team")
      public static let moreMembers = Loc.tr("Localizable", "Membership.Upgrade.MoreMembers", fallback: "Upgrade to add more members")
      public static let moreSpaces = Loc.tr("Localizable", "Membership.Upgrade.MoreSpaces", fallback: "Upgrade to add more spaces")
      public static let noMoreEditors = Loc.tr("Localizable", "Membership.Upgrade.NoMoreEditors", fallback: "You can’t add more editors")
      public static let noMoreMembers = Loc.tr("Localizable", "Membership.Upgrade.NoMoreMembers", fallback: "You can’t add more members")
      public static func spacesLimit(_ p1: Int) -> String {
        return Loc.tr("Localizable", "Membership.Upgrade.SpacesLimit", p1, fallback: "Plural format key: Membership.Upgrade.SpacesLimit")
      }
      public static let text = Loc.tr("Localizable", "Membership.Upgrade.Text", fallback: "Reach us for extra storage, space editors, or more shared spaces. Anytype team will provide details and conditions tailored to your needs.")
      public static let title = Loc.tr("Localizable", "Membership.Upgrade.Title", fallback: "Membership upgrade")
    }
  }
  public enum MembershipServiceError {
    public static let invalidBillingIdFormat = Loc.tr("Localizable", "MembershipServiceError.invalidBillingIdFormat", fallback: "Internal problem with billing format, we are working on this. Try again later or contact support.")
    public static let tierNotFound = Loc.tr("Localizable", "MembershipServiceError.tierNotFound", fallback: "Not found tier data, restart app and try again")
  }
  public enum Mention {
    public enum Subtitle {
      public static let placeholder = Loc.tr("Localizable", "Mention.Subtitle.Placeholder", fallback: "Object")
    }
  }
  public enum Message {
    public static let edited = Loc.tr("Localizable", "Message.edited", fallback: "edited")
    public enum Action {
      public static let addReaction = Loc.tr("Localizable", "Message.Action.AddReaction", fallback: "Add Reaction")
      public static let copyPlainText = Loc.tr("Localizable", "Message.Action.CopyPlainText", fallback: "Copy Plain Text")
      public static let reply = Loc.tr("Localizable", "Message.Action.Reply", fallback: "Reply")
      public static let unread = Loc.tr("Localizable", "Message.Action.Unread", fallback: "Mark Unread")
    }
    public enum ChatTitle {
      public static let placeholder = Loc.tr("Localizable", "Message.ChatTitle.Placeholder", fallback: "Untitled Chat")
    }
    public enum Input {
      public enum Chat {
        public static let emptyPlaceholder = Loc.tr("Localizable", "Message.Input.Chat.EmptyPlaceholder", fallback: "Write a message...")
      }
      public enum Stream {
        public static let emptyPlaceholder = Loc.tr("Localizable", "Message.Input.Stream.EmptyPlaceholder", fallback: "Broadcast")
      }
    }
  }
  public enum Migration {
    public enum Error {
      public enum NotEnoughtSpace {
        public static func message(_ p1: Any) -> String {
          return Loc.tr("Localizable", "Migration.Error.NotEnoughtSpace.message", String(describing: p1), fallback: "Please clear approximately %@ of space and run the process again.")
        }
        public static let title = Loc.tr("Localizable", "Migration.Error.NotEnoughtSpace.title", fallback: "Not enough space")
      }
    }
    public enum Initial {
      public static let readMore = Loc.tr("Localizable", "Migration.Initial.readMore", fallback: "Read More")
      public static let startUpdate = Loc.tr("Localizable", "Migration.Initial.startUpdate", fallback: "Start Update")
      public static let subtitle1 = Loc.tr("Localizable", "Migration.Initial.subtitle1", fallback: "We're laying the groundwork for our new chats. Including counters, notifications and other features needed for smooth chat experience.")
      public static let subtitle2 = Loc.tr("Localizable", "Migration.Initial.subtitle2", fallback: "It might take a little while, but don't worry, your data is safe.")
      public static let title = Loc.tr("Localizable", "Migration.Initial.title", fallback: "New Version Update")
    }
    public enum Progress {
      public static let subtitle = Loc.tr("Localizable", "Migration.Progress.subtitle", fallback: "This may take some time. Please don’t close the app until the process is complete.")
      public static let title = Loc.tr("Localizable", "Migration.Progress.title", fallback: "Update is in progress...")
    }
    public enum ReadMore {
      public static let description1 = Loc.tr("Localizable", "Migration.ReadMore.description1", fallback: "You'll see a loading screen during the update. Once finished, you can continue using the app normally.")
      public static let description2 = Loc.tr("Localizable", "Migration.ReadMore.description2", fallback: "During this update, your data remains fully secure. The update is performed directly on your device, and your synced data remains unaffected. We’ll just copy it to a new format, and a local backup will be created on your device, containing all your data in the previous format.")
      public static let description3 = Loc.tr("Localizable", "Migration.ReadMore.description3", fallback: "The reason we’re retaining this backup is to debug and assist you, in case of unforeseen.")
      public static let option1 = Loc.tr("Localizable", "Migration.ReadMore.option1", fallback: "What to Expect")
      public static let option2 = Loc.tr("Localizable", "Migration.ReadMore.option2", fallback: "Your Data Remains Safe")
    }
  }
  public enum Object {
    public enum Deleted {
      public static let placeholder = Loc.tr("Localizable", "Object.Deleted.Placeholder", fallback: "Deleted object")
    }
  }
  public enum ObjectSearchWithMeta {
    public enum Create {
      public static let collection = Loc.tr("Localizable", "ObjectSearchWithMeta.Create.Collection", fallback: "New Collection")
      public static let note = Loc.tr("Localizable", "ObjectSearchWithMeta.Create.Note", fallback: "New Note")
      public static let page = Loc.tr("Localizable", "ObjectSearchWithMeta.Create.Page", fallback: "New Page")
      public static let `set` = Loc.tr("Localizable", "ObjectSearchWithMeta.Create.Set", fallback: "New Query")
    }
  }
  public enum ObjectType {
    public static func addedToLibrary(_ p1: Any) -> String {
      return Loc.tr("Localizable", "ObjectType.AddedToLibrary", String(describing: p1), fallback: "Type ‘%@’ has been created")
    }
    public static let deletedName = Loc.tr("Localizable", "ObjectType.DeletedName", fallback: "Deleted type")
    public static let editingType = Loc.tr("Localizable", "ObjectType.editingType", fallback: "You're editing type")
    public static let fallbackDescription = Loc.tr("Localizable", "ObjectType.fallbackDescription", fallback: "Blank canvas with no title")
    public static let myTypes = Loc.tr("Localizable", "ObjectType.MyTypes", fallback: "My Types")
    public static let search = Loc.tr("Localizable", "ObjectType.Search", fallback: "Search for Type")
    public static let searchOrInstall = Loc.tr("Localizable", "ObjectType.SearchOrInstall", fallback: "Search or install a new type")
  }
  public enum ParticipantRemoveNotification {
    public static func text(_ p1: Any) -> String {
      return Loc.tr("Localizable", "ParticipantRemoveNotification.Text", String(describing: p1), fallback: "You were removed from **%@** space, or the space has been deleted by the owner.")
    }
  }
  public enum ParticipantRequestApprovedNotification {
    public static func text(_ p1: Any, _ p2: Any) -> String {
      return Loc.tr("Localizable", "ParticipantRequestApprovedNotification.Text", String(describing: p1), String(describing: p2), fallback: "Your request to join the **%@** space has been approved with **%@** access rights. The space will be available on your device soon.")
    }
  }
  public enum ParticipantRequestDeclineNotification {
    public static func text(_ p1: Any) -> String {
      return Loc.tr("Localizable", "ParticipantRequestDeclineNotification.Text", String(describing: p1), fallback: "Your request to join the **%@** space has been declined.")
    }
  }
  public enum PermissionChangeNotification {
    public static func text(_ p1: Any, _ p2: Any) -> String {
      return Loc.tr("Localizable", "PermissionChangeNotification.Text", String(describing: p1), String(describing: p2), fallback: "Your access rights were changed to **%@** in the **%@** space.")
    }
  }
  public enum Primitives {
    public enum LayoutConflict {
      public static let description = Loc.tr("Localizable", "Primitives.LayoutConflict.Description", fallback: "This layout differs from the type's default. Reset to match?")
    }
  }
  public enum Publishing {
    public enum Error {
      public static let noDomain = Loc.tr("Localizable", "Publishing.Error.NoDomain", fallback: "Failed to load your domain. Please try again.")
      public static let noObjectData = Loc.tr("Localizable", "Publishing.Error.NoObjectData", fallback: "Failed to load object data. Please try again.")
    }
    public enum Url {
      public static let placeholder = Loc.tr("Localizable", "Publishing.URL.placeholder", fallback: "insert-page-name-here")
    }
    public enum WebBanner {
      public static let liveOnWeb = Loc.tr("Localizable", "Publishing.WebBanner.LiveOnWeb", fallback: "This object is live on the web.")
      public static let viewSite = Loc.tr("Localizable", "Publishing.WebBanner.ViewSite", fallback: "View site ↗︎")
    }
  }
  public enum PublishingToWeb {
    public static let published = Loc.tr("Localizable", "PublishingToWeb.published", fallback: "Successfully published")
    public static let unpublished = Loc.tr("Localizable", "PublishingToWeb.unpublished", fallback: "Successfully unpublished")
    public static let updated = Loc.tr("Localizable", "PublishingToWeb.updated", fallback: "Successfully updated")
  }
  public enum PushNotifications {
    public enum DisabledAlert {
      public static let description = Loc.tr("Localizable", "PushNotifications.DisabledAlert.description", fallback: "It looks like you didn’t allow notifications. That means you won’t see new messages, mentions, or invites. Go to settings to turn them on.")
      public static let title = Loc.tr("Localizable", "PushNotifications.DisabledAlert.title", fallback: "Notifications are still turned off")
      public enum Skip {
        public static let button = Loc.tr("Localizable", "PushNotifications.DisabledAlert.Skip.button", fallback: "Skip for now")
      }
    }
    public enum Message {
      public enum Attachment {
        public static let title = Loc.tr("Localizable", "PushNotifications.Message.Attachment.title", fallback: "Attachment")
      }
    }
    public enum RequestAlert {
      public static let description = Loc.tr("Localizable", "PushNotifications.RequestAlert.Description", fallback: "Get notified instantly when someone messages or mentions you in your spaces.")
      public static let notificationTitle = Loc.tr("Localizable", "PushNotifications.RequestAlert.NotificationTitle", fallback: "New Message")
      public static let primaryButton = Loc.tr("Localizable", "PushNotifications.RequestAlert.PrimaryButton", fallback: "Enable notifications")
      public static let secondaryButton = Loc.tr("Localizable", "PushNotifications.RequestAlert.SecondaryButton", fallback: "Not now")
      public static let title = Loc.tr("Localizable", "PushNotifications.RequestAlert.Title", fallback: "Turn on push notifications")
    }
    public enum Settings {
      public enum DisabledAlert {
        public static let description = Loc.tr("Localizable", "PushNotifications.Settings.DisabledAlert.description", fallback: "Receive notifications about new messages by enabling them in your device settings.")
        public static let title = Loc.tr("Localizable", "PushNotifications.Settings.DisabledAlert.title", fallback: "Notifications are disabled")
      }
      public enum Status {
        public static let title = Loc.tr("Localizable", "PushNotifications.Settings.Status.title", fallback: "Message Notifications")
      }
    }
  }
  public enum Qr {
    public enum Join {
      public static let title = Loc.tr("Localizable", "QR.join.title", fallback: "Join via QR Code")
    }
    public enum Scan {
      public enum Error {
        public static let tryAgain = Loc.tr("Localizable", "QR.scan.error.tryAgain", fallback: "Try again")
        public enum Custom {
          public static let title = Loc.tr("Localizable", "QR.scan.error.custom.title", fallback: "Scanning error")
        }
        public enum InvalidFormat {
          public static let message = Loc.tr("Localizable", "QR.scan.error.invalidFormat.message", fallback: "The scanned QR code contains URL in invalid format")
        }
        public enum InvalidQR {
          public static let title = Loc.tr("Localizable", "QR.scan.error.invalidQR.title", fallback: "Invalid QR Code")
        }
        public enum NotUrl {
          public static let message = Loc.tr("Localizable", "QR.scan.error.notUrl.message", fallback: "The scanned QR code doesn't contain a valid URL")
        }
        public enum WrongLink {
          public static let message = Loc.tr("Localizable", "QR.scan.error.wrongLink.message", fallback: "The scanned QR code contains different action")
        }
      }
    }
  }
  public enum QuickAction {
    public static func create(_ p1: Any) -> String {
      return Loc.tr("Localizable", "QuickAction.create", String(describing: p1), fallback: "Create %@")
    }
  }
  public enum RedactedText {
    public static let pageTitle = Loc.tr("Localizable", "RedactedText.pageTitle", fallback: "Wake up, Neo")
    public static let pageType = Loc.tr("Localizable", "RedactedText.pageType", fallback: "Red pill")
  }
  public enum ReindexingWarningAlert {
    public static let description = Loc.tr("Localizable", "ReindexingWarningAlert.Description", fallback: "We've implemented a new search library for faster and more accurate results.\nReindexing may take a few minutes.")
    public static let title = Loc.tr("Localizable", "ReindexingWarningAlert.Title", fallback: "Upgrading your search experience")
  }
  public enum Relation {
    public static let deleted = Loc.tr("Localizable", "Relation.Deleted", fallback: "Deleted property")
    public static let myRelations = Loc.tr("Localizable", "Relation.MyRelations", fallback: "My properties")
    public enum Create {
      public enum Row {
        public static func title(_ p1: Any) -> String {
          return Loc.tr("Localizable", "Relation.Create.Row.title", String(describing: p1), fallback: "Create “%@”")
        }
      }
      public enum Textfield {
        public static let placeholder = Loc.tr("Localizable", "Relation.Create.Textfield.placeholder", fallback: "Enter name...")
      }
    }
    public enum Delete {
      public enum Alert {
        public static let description = Loc.tr("Localizable", "Relation.Delete.Alert.Description", fallback: "The option will be permanently removed from your space.")
        public static let title = Loc.tr("Localizable", "Relation.Delete.Alert.Title", fallback: "Are you sure?")
      }
    }
    public enum EmptyState {
      public static let description = Loc.tr("Localizable", "Relation.EmptyState.description", fallback: "Nothing found. Create first option to start.")
      public static let title = Loc.tr("Localizable", "Relation.EmptyState.title", fallback: "No options")
      public enum Blocked {
        public static let title = Loc.tr("Localizable", "Relation.EmptyState.Blocked.title", fallback: "The property is empty")
      }
    }
    public enum Format {
      public enum Checkbox {
        public static let title = Loc.tr("Localizable", "Relation.Format.Checkbox.Title", fallback: "Checkbox")
      }
      public enum Date {
        public static let title = Loc.tr("Localizable", "Relation.Format.Date.Title", fallback: "Date")
      }
      public enum Email {
        public static let title = Loc.tr("Localizable", "Relation.Format.Email.Title", fallback: "Email")
      }
      public enum FileMedia {
        public static let title = Loc.tr("Localizable", "Relation.Format.FileMedia.Title", fallback: "File & Media")
      }
      public enum Number {
        public static let title = Loc.tr("Localizable", "Relation.Format.Number.Title", fallback: "Number")
      }
      public enum Object {
        public static let title = Loc.tr("Localizable", "Relation.Format.Object.Title", fallback: "Relation object")
      }
      public enum Phone {
        public static let title = Loc.tr("Localizable", "Relation.Format.Phone.Title", fallback: "Phone number")
      }
      public enum Status {
        public static let title = Loc.tr("Localizable", "Relation.Format.Status.Title", fallback: "Select")
      }
      public enum Tag {
        public static let title = Loc.tr("Localizable", "Relation.Format.Tag.Title", fallback: "Multi-select")
      }
      public enum Text {
        public static let title = Loc.tr("Localizable", "Relation.Format.Text.Title", fallback: "Text")
      }
      public enum Url {
        public static let title = Loc.tr("Localizable", "Relation.Format.Url.Title", fallback: "URL")
      }
    }
    public enum From {
      public static func type(_ p1: Any) -> String {
        return Loc.tr("Localizable", "Relation.From.Type", String(describing: p1), fallback: "From type %@")
      }
    }
    public enum ImportType {
      public static let csv = Loc.tr("Localizable", "Relation.ImportType.Csv", fallback: "CSV")
      public static let html = Loc.tr("Localizable", "Relation.ImportType.Html", fallback: "HTML")
      public static let markdown = Loc.tr("Localizable", "Relation.ImportType.Markdown", fallback: "Markdown")
      public static let notion = Loc.tr("Localizable", "Relation.ImportType.Notion", fallback: "Notion")
      public static let obsidian = Loc.tr("Localizable", "Relation.ImportType.Obsidian", fallback: "Obsidian")
      public static let protobuf = Loc.tr("Localizable", "Relation.ImportType.Protobuf", fallback: "Any-Block")
      public static let text = Loc.tr("Localizable", "Relation.ImportType.Text", fallback: "TXT")
    }
    public enum Object {
      public enum Delete {
        public enum Alert {
          public static let description = Loc.tr("Localizable", "Relation.Object.Delete.Alert.Description", fallback: "The object will be moved to Bin.")
        }
      }
    }
    public enum ObjectType {
      public enum Header {
        public static let title = Loc.tr("Localizable", "Relation.ObjectType.Header.title", fallback: "Object type:")
      }
    }
    public enum ObjectTypes {
      public enum Header {
        public static let title = Loc.tr("Localizable", "Relation.ObjectTypes.Header.title", fallback: "Object types:")
      }
    }
    public enum Origin {
      public static let api = Loc.tr("Localizable", "Relation.Origin.API", fallback: "API")
      public static let bookmark = Loc.tr("Localizable", "Relation.Origin.Bookmark", fallback: "Bookmark")
      public static let builtin = Loc.tr("Localizable", "Relation.Origin.Builtin", fallback: "Library installed")
      public static let clipboard = Loc.tr("Localizable", "Relation.Origin.Clipboard", fallback: "Clipboard")
      public static let dragAndDrop = Loc.tr("Localizable", "Relation.Origin.DragAndDrop", fallback: "Drag'n'Drop")
      public static let `import` = Loc.tr("Localizable", "Relation.Origin.Import", fallback: "Imported object")
      public static let sharingExtension = Loc.tr("Localizable", "Relation.Origin.SharingExtension", fallback: "Mobile sharing extension")
      public static let useCase = Loc.tr("Localizable", "Relation.Origin.UseCase", fallback: "Use case")
      public static let webClipper = Loc.tr("Localizable", "Relation.Origin.WebClipper", fallback: "Web clipper")
    }
    public enum View {
      public enum Create {
        public static let title = Loc.tr("Localizable", "Relation.View.Create.title", fallback: "Create option")
      }
      public enum Edit {
        public static let title = Loc.tr("Localizable", "Relation.View.Edit.title", fallback: "Edit option")
      }
      public enum Hint {
        public static let empty = Loc.tr("Localizable", "Relation.View.Hint.Empty", fallback: "empty")
      }
    }
  }
  public enum RelationAction {
    public static let callPhone = Loc.tr("Localizable", "RelationAction.CallPhone", fallback: "Call phone numbler")
    public static let copied = Loc.tr("Localizable", "RelationAction.Copied", fallback: "Copied")
    public static let copyEmail = Loc.tr("Localizable", "RelationAction.CopyEmail", fallback: "Copy email")
    public static let copyPhone = Loc.tr("Localizable", "RelationAction.CopyPhone", fallback: "Copy phone number")
    public static let openLink = Loc.tr("Localizable", "RelationAction.OpenLink", fallback: "Open link")
    public static let reloadContent = Loc.tr("Localizable", "RelationAction.ReloadContent", fallback: "Reload object content")
    public static let reloadingContent = Loc.tr("Localizable", "RelationAction.ReloadingContent", fallback: "Reloading content")
    public static let sendEmail = Loc.tr("Localizable", "RelationAction.SendEmail", fallback: "Send email")
  }
  public enum RelativeFormatter {
    public static let days14 = Loc.tr("Localizable", "RelativeFormatter.days14", fallback: "Previous 14 days")
    public static let days7 = Loc.tr("Localizable", "RelativeFormatter.days7", fallback: "Previous 7 days")
  }
  public enum RequestToJoinNotification {
    public static let goToSpace = Loc.tr("Localizable", "RequestToJoinNotification.GoToSpace", fallback: "Go to Space")
    public static func text(_ p1: Any, _ p2: Any) -> String {
      return Loc.tr("Localizable", "RequestToJoinNotification.Text", String(describing: p1), String(describing: p2), fallback: "**%@** requested to join the **%@** space.")
    }
    public static let viewRequest = Loc.tr("Localizable", "RequestToJoinNotification.ViewRequest", fallback: "View request")
  }
  public enum RequestToLeaveNotification {
    public static func text(_ p1: Any, _ p2: Any) -> String {
      return Loc.tr("Localizable", "RequestToLeaveNotification.Text", String(describing: p1), String(describing: p2), fallback: "**%@** wants to leave the **%@** space.")
    }
  }
  public enum ReturnToWidgets {
    public enum Tip {
      public static let text = Loc.tr("Localizable", "ReturnToWidgets.Tip.Text", fallback: "Long press the back button to return to widgets instead of tapping it repeatedly.")
      public static let title = Loc.tr("Localizable", "ReturnToWidgets.Tip.Title", fallback: "Long Press to Return to Widgets")
    }
  }
  public enum Scanner {
    public enum Error {
      public static let scanningNotSupported = Loc.tr("Localizable", "Scanner.Error.Scanning not supported", fallback: "Scanning not supported")
    }
  }
  public enum Search {
    public enum Links {
      public enum Header {
        public static func title(_ p1: Any) -> String {
          return Loc.tr("Localizable", "Search.Links.Header.title", String(describing: p1), fallback: "Related to: %@")
        }
      }
      public enum Show {
        public static let title = Loc.tr("Localizable", "Search.Links.Show.title", fallback: "Show related objects")
      }
      public enum Swipe {
        public static let title = Loc.tr("Localizable", "Search.Links.Swipe.title", fallback: "Related to")
      }
    }
  }
  public enum SecureAlert {
    public static let message = Loc.tr("Localizable", "SecureAlert.message", fallback: "You phone doesn’t have a passcode or biometric authorization. It might make it easier to steal your data. Enable it in your app settings to secure your data.")
    public static let title = Loc.tr("Localizable", "SecureAlert.title", fallback: "Secure your phone")
    public enum Proceed {
      public static let button = Loc.tr("Localizable", "SecureAlert.Proceed.button", fallback: "Proceed anyway")
    }
  }
  public enum Server {
    public static let addButton = Loc.tr("Localizable", "Server.AddButton", fallback: "Add Self-hosted Network")
    public static let anytype = Loc.tr("Localizable", "Server.Anytype", fallback: "Anytype")
    public static let localOnly = Loc.tr("Localizable", "Server.LocalOnly", fallback: "Local-only")
    public static let network = Loc.tr("Localizable", "Server.Network", fallback: "Network")
    public static let networks = Loc.tr("Localizable", "Server.Networks", fallback: "Networks")
    public enum LocalOnly {
      public enum Alert {
        public static let message = Loc.tr("Localizable", "Server.LocalOnly.Alert.message", fallback: "Local-only mode is an experimental feature and does not provide security benefits. Please use it at your own risk, as data loss may occur.")
        public static let title = Loc.tr("Localizable", "Server.LocalOnly.Alert.title", fallback: "Are you sure?")
        public enum Action {
          public static let agree = Loc.tr("Localizable", "Server.LocalOnly.Alert.Action.agree", fallback: "Yes, I accept risks")
          public static let disagree = Loc.tr("Localizable", "Server.LocalOnly.Alert.Action.disagree", fallback: "No, don’t use it")
        }
      }
    }
  }
  public enum Set {
    public enum Bookmark {
      public enum Create {
        public static let placeholder = Loc.tr("Localizable", "Set.Bookmark.Create.Placeholder", fallback: "Paste link")
      }
      public enum Error {
        public static let message = Loc.tr("Localizable", "Set.Bookmark.Error.Message", fallback: "Oops - something went wrong. Please try again")
      }
    }
    public enum FeaturedRelations {
      public static let query = Loc.tr("Localizable", "Set.FeaturedRelations.Query", fallback: "Select query")
      public static let relation = Loc.tr("Localizable", "Set.FeaturedRelations.Relation", fallback: "Property:")
      public static let relationsList = Loc.tr("Localizable", "Set.FeaturedRelations.RelationsList", fallback: "Properties:")
      public static let type = Loc.tr("Localizable", "Set.FeaturedRelations.Type", fallback: "Type:")
    }
    public enum SourceType {
      public static let selectQuery = Loc.tr("Localizable", "Set.SourceType.SelectQuery", fallback: "Select query")
      public enum Cancel {
        public enum Toast {
          public static let title = Loc.tr("Localizable", "Set.SourceType.Cancel.Toast.Title", fallback: "This query can be changed on desktop only")
        }
      }
    }
    public enum TypeRelation {
      public enum ContextMenu {
        public static let changeQuery = Loc.tr("Localizable", "Set.TypeRelation.ContextMenu.ChangeQuery", fallback: "Change query")
        public static let turnIntoCollection = Loc.tr("Localizable", "Set.TypeRelation.ContextMenu.TurnIntoCollection", fallback: "Turn Query into Collection")
      }
    }
    public enum View {
      public static let unsupportedAlert = Loc.tr("Localizable", "Set.View.UnsupportedAlert", fallback: "View is unsupported on mobile")
      public enum Empty {
        public static let subtitle = Loc.tr("Localizable", "Set.View.Empty.Subtitle", fallback: "Add search query to aggregate objects with equal types and properties in a live mode")
        public static let title = Loc.tr("Localizable", "Set.View.Empty.Title", fallback: "No query selected")
      }
      public enum Kanban {
        public enum Column {
          public enum Paging {
            public enum Title {
              public static let showMore = Loc.tr("Localizable", "Set.View.Kanban.Column.Paging.Title.ShowMore", fallback: "Show more objects")
            }
          }
          public enum Settings {
            public enum Color {
              public static let title = Loc.tr("Localizable", "Set.View.Kanban.Column.Settings.Color.Title", fallback: "Column color")
            }
            public enum Hide {
              public enum Column {
                public static let title = Loc.tr("Localizable", "Set.View.Kanban.Column.Settings.Hide.Column.Title", fallback: "Hide column")
              }
            }
          }
          public enum Title {
            public static func checked(_ p1: Any) -> String {
              return Loc.tr("Localizable", "Set.View.Kanban.Column.Title.Checked", String(describing: p1), fallback: "%@ is checked")
            }
            public static let uncategorized = Loc.tr("Localizable", "Set.View.Kanban.Column.Title.Uncategorized", fallback: "Uncategorized")
            public static func unchecked(_ p1: Any) -> String {
              return Loc.tr("Localizable", "Set.View.Kanban.Column.Title.Unchecked", String(describing: p1), fallback: "%@ is unchecked")
            }
          }
        }
      }
      public enum Settings {
        public enum CardSize {
          public static let title = Loc.tr("Localizable", "Set.View.Settings.CardSize.Title", fallback: "Card size")
          public enum Large {
            public static let title = Loc.tr("Localizable", "Set.View.Settings.CardSize.Large.Title", fallback: "Large")
          }
          public enum Small {
            public static let title = Loc.tr("Localizable", "Set.View.Settings.CardSize.Small.Title", fallback: "Small")
          }
        }
        public enum GroupBackgroundColors {
          public static let title = Loc.tr("Localizable", "Set.View.Settings.GroupBackgroundColors.Title", fallback: "Color columns")
        }
        public enum GroupBy {
          public static let title = Loc.tr("Localizable", "Set.View.Settings.GroupBy.Title", fallback: "Group by")
        }
        public enum ImageFit {
          public static let title = Loc.tr("Localizable", "Set.View.Settings.ImageFit.Title", fallback: "Fit image")
        }
        public enum ImagePreview {
          public static let title = Loc.tr("Localizable", "Set.View.Settings.ImagePreview.Title", fallback: "Image preview")
        }
        public enum NoFilters {
          public static let placeholder = Loc.tr("Localizable", "Set.View.Settings.NoFilters.Placeholder", fallback: "No filters")
        }
        public enum NoRelations {
          public static let placeholder = Loc.tr("Localizable", "Set.View.Settings.NoRelations.Placeholder", fallback: "No properties")
        }
        public enum NoSorts {
          public static let placeholder = Loc.tr("Localizable", "Set.View.Settings.NoSorts.Placeholder", fallback: "No sorts")
        }
        public enum Objects {
          public enum Applied {
            public static func title(_ p1: Int) -> String {
              return Loc.tr("Localizable", "Set.View.Settings.Objects.Applied.Title", p1, fallback: "%d applied")
            }
          }
        }
      }
    }
  }
  public enum SetViewTypesPicker {
    public static let title = Loc.tr("Localizable", "SetViewTypesPicker.Title", fallback: "Edit view")
    public enum New {
      public static let title = Loc.tr("Localizable", "SetViewTypesPicker.New.Title", fallback: "New view")
    }
    public enum Section {
      public enum Types {
        public static let title = Loc.tr("Localizable", "SetViewTypesPicker.Section.Types.Title", fallback: "View as")
      }
    }
    public enum Settings {
      public enum Delete {
        public static let view = Loc.tr("Localizable", "SetViewTypesPicker.Settings.Delete.View", fallback: "Delete view")
      }
      public enum Duplicate {
        public static let view = Loc.tr("Localizable", "SetViewTypesPicker.Settings.Duplicate.View", fallback: "Duplicate")
      }
      public enum Textfield {
        public enum Placeholder {
          public static let untitled = Loc.tr("Localizable", "SetViewTypesPicker.Settings.Textfield.Placeholder.Untitled", fallback: "Untitled")
          public enum New {
            public static let view = Loc.tr("Localizable", "SetViewTypesPicker.Settings.Textfield.Placeholder.New.View", fallback: "New view")
          }
        }
      }
    }
  }
  public enum Settings {
    public static let autoCreateTypeWidgets = Loc.tr("Localizable", "Settings.AutoCreateTypeWidgets", fallback: "Auto Create Type Widgets")
    public static let chatDisabled = Loc.tr("Localizable", "Settings.ChatDisabled", fallback: "Chat is disabled")
    public static let chatEnabled = Loc.tr("Localizable", "Settings.ChatEnabled", fallback: "Chat is enabled")
    public static let dataManagement = Loc.tr("Localizable", "Settings.DataManagement", fallback: "Data Management")
    public static let editPicture = Loc.tr("Localizable", "Settings.Edit picture", fallback: "Edit picture")
    public static let spaceName = Loc.tr("Localizable", "Settings.SpaceName", fallback: "Space name")
    public static let spaceType = Loc.tr("Localizable", "Settings.SpaceType", fallback: "Space type")
    public static let title = Loc.tr("Localizable", "Settings.Title", fallback: "Settings")
    public static let updated = Loc.tr("Localizable", "Settings.Updated", fallback: "Space information updated")
    public static let vaultAndAccess = Loc.tr("Localizable", "Settings.VaultAndAccess", fallback: "Vault and key")
  }
  public enum Sharing {
    public static let addTo = Loc.tr("Localizable", "Sharing.AddTo", fallback: "Add to")
    public static let linkTo = Loc.tr("Localizable", "Sharing.LinkTo", fallback: "Link to")
    public static let saveAs = Loc.tr("Localizable", "Sharing.SaveAs", fallback: "SAVE AS")
    public static let selectSpace = Loc.tr("Localizable", "Sharing.SelectSpace", fallback: "Space")
    public static let title = Loc.tr("Localizable", "Sharing.Title", fallback: "Select Space")
    public enum `Any` {
      public static let block = Loc.tr("Localizable", "Sharing.Any.Block", fallback: "Blocks")
    }
    public enum File {
      public static func block(_ p1: Int) -> String {
        return Loc.tr("Localizable", "Sharing.File.Block", p1, fallback: "Plural format key: Sharing.File.Block")
      }
      public static func newObject(_ p1: Int) -> String {
        return Loc.tr("Localizable", "Sharing.File.NewObject", p1, fallback: "Plural format key: Sharing.File.NewObject")
      }
    }
    public enum Navigation {
      public static let title = Loc.tr("Localizable", "Sharing.Navigation.title", fallback: "Add to Anytype")
      public enum LeftButton {
        public static let title = Loc.tr("Localizable", "Sharing.Navigation.LeftButton.Title", fallback: "Cancel")
      }
      public enum RightButton {
        public static let title = Loc.tr("Localizable", "Sharing.Navigation.RightButton.Title", fallback: "Done")
      }
    }
    public enum Tab {
      public static let chat = Loc.tr("Localizable", "Sharing.Tab.Chat", fallback: "Send to chat")
      public static let object = Loc.tr("Localizable", "Sharing.Tab.Object", fallback: "Save as object")
    }
    public enum Text {
      public static let noteObject = Loc.tr("Localizable", "Sharing.Text.NoteObject", fallback: "Note object")
      public static let textBlock = Loc.tr("Localizable", "Sharing.Text.TextBlock", fallback: "Blocks")
    }
    public enum Tip {
      public static let title = Loc.tr("Localizable", "Sharing.Tip.Title", fallback: "Share Extension")
      public enum Button {
        public static let title = Loc.tr("Localizable", "Sharing.Tip.Button.title", fallback: "Show share menu")
      }
      public enum Steps {
        public static let _1 = Loc.tr("Localizable", "Sharing.Tip.Steps.1", fallback: "Tap the iOS sharing button")
        public static let _2 = Loc.tr("Localizable", "Sharing.Tip.Steps.2", fallback: "Scroll past the app and tap More")
        public static let _3 = Loc.tr("Localizable", "Sharing.Tip.Steps.3", fallback: "Tap Edit to find “Anytype” and tap")
      }
    }
    public enum Url {
      public static func block(_ p1: Int) -> String {
        return Loc.tr("Localizable", "Sharing.URL.Block", p1, fallback: "Plural format key: Sharing.URL.Block")
      }
      public static func newObject(_ p1: Int) -> String {
        return Loc.tr("Localizable", "Sharing.URL.NewObject", p1, fallback: "Plural format key: Sharing.URL.NewObject")
      }
    }
  }
  public enum SimpleTableMenu {
    public enum Item {
      public static let clearContents = Loc.tr("Localizable", "SimpleTableMenu.Item.clearContents", fallback: "Clear")
      public static let clearStyle = Loc.tr("Localizable", "SimpleTableMenu.Item.clearStyle", fallback: "Reset style")
      public static let color = Loc.tr("Localizable", "SimpleTableMenu.Item.color", fallback: "Color")
      public static let delete = Loc.tr("Localizable", "SimpleTableMenu.Item.Delete", fallback: "Delete")
      public static let duplicate = Loc.tr("Localizable", "SimpleTableMenu.Item.Duplicate", fallback: "Duplicate")
      public static let insertAbove = Loc.tr("Localizable", "SimpleTableMenu.Item.InsertAbove", fallback: "Insert above")
      public static let insertBelow = Loc.tr("Localizable", "SimpleTableMenu.Item.InsertBelow", fallback: "Insert below")
      public static let insertLeft = Loc.tr("Localizable", "SimpleTableMenu.Item.InsertLeft", fallback: "Insert left")
      public static let insertRight = Loc.tr("Localizable", "SimpleTableMenu.Item.InsertRight", fallback: "Insert right")
      public static let moveDown = Loc.tr("Localizable", "SimpleTableMenu.Item.MoveDown", fallback: "Move down")
      public static let moveLeft = Loc.tr("Localizable", "SimpleTableMenu.Item.MoveLeft", fallback: "Move left")
      public static let moveRight = Loc.tr("Localizable", "SimpleTableMenu.Item.MoveRight", fallback: "Move right")
      public static let moveUp = Loc.tr("Localizable", "SimpleTableMenu.Item.MoveUp", fallback: "Move up")
      public static let sort = Loc.tr("Localizable", "SimpleTableMenu.Item.Sort", fallback: "Sort")
      public static let style = Loc.tr("Localizable", "SimpleTableMenu.Item.style", fallback: "Style")
    }
  }
  public enum SlashMenu {
    public static let dotsDivider = Loc.tr("Localizable", "SlashMenu.DotsDivider", fallback: "Dots divider")
    public static let lineDivider = Loc.tr("Localizable", "SlashMenu.LineDivider", fallback: "Line divider")
    public static let table = Loc.tr("Localizable", "SlashMenu.Table", fallback: "Table")
    public static let tableOfContents = Loc.tr("Localizable", "SlashMenu.TableOfContents", fallback: "Table of contents")
    public enum LinkTo {
      public static let description = Loc.tr("Localizable", "SlashMenu.LinkTo.Description", fallback: "Create link to another object")
    }
  }
  public enum Space {
    public static func membersCount(_ p1: Int) -> String {
      return Loc.tr("Localizable", "Space.MembersCount", p1, fallback: "Plural format key: Space.MembersCount")
    }
    public enum Notifications {
      public enum Settings {
        public enum State {
          public static let all = Loc.tr("Localizable", "Space.Notifications.Settings.State.All", fallback: "All activity")
          public static let disabled = Loc.tr("Localizable", "Space.Notifications.Settings.State.Disabled", fallback: "Disable notifications")
          public static let mentions = Loc.tr("Localizable", "Space.Notifications.Settings.State.Mentions", fallback: "Mentions only")
        }
      }
    }
    public enum Status {
      public static let error = Loc.tr("Localizable", "Space.Status.Error", fallback: "Error")
      public static let loading = Loc.tr("Localizable", "Space.Status.Loading", fallback: "Loading")
      public static let missing = Loc.tr("Localizable", "Space.Status.Missing", fallback: "Missing")
      public static let ok = Loc.tr("Localizable", "Space.Status.Ok", fallback: "Ok")
      public static let remoteDeleted = Loc.tr("Localizable", "Space.Status.RemoteDeleted", fallback: "Remote Deleted")
      public static let remoteWaitingDeletion = Loc.tr("Localizable", "Space.Status.RemoteWaitingDeletion", fallback: "Waiting Deletion")
      public static let spaceActive = Loc.tr("Localizable", "Space.Status.SpaceActive", fallback: "Active")
      public static let spaceDeleted = Loc.tr("Localizable", "Space.Status.SpaceDeleted", fallback: "Deleted")
      public static let spaceJoining = Loc.tr("Localizable", "Space.Status.SpaceJoining", fallback: "Joining")
      public static let spaceRemoving = Loc.tr("Localizable", "Space.Status.SpaceRemoving", fallback: "Removing")
      public static let unknown = Loc.tr("Localizable", "Space.Status.Unknown", fallback: "Unknown")
    }
  }
  public enum SpaceCreate {
    public enum Chat {
      public static let title = Loc.tr("Localizable", "SpaceCreate.Chat.Title", fallback: "Create a chat")
    }
    public enum Space {
      public static let title = Loc.tr("Localizable", "SpaceCreate.Space.Title", fallback: "Create a space")
    }
    public enum Stream {
      public static let title = Loc.tr("Localizable", "SpaceCreate.Stream.Title", fallback: "Create a stream")
    }
  }
  public enum SpaceManager {
    public static let cancelRequest = Loc.tr("Localizable", "SpaceManager.CancelRequest", fallback: "Cancel Join Request")
    public static let doNotCancel = Loc.tr("Localizable", "SpaceManager.DoNotCancel", fallback: "Do Not Cancel")
    public enum CancelRequestAlert {
      public static let title = Loc.tr("Localizable", "SpaceManager.CancelRequestAlert.Title", fallback: "You will have to send request access again")
      public static let toast = Loc.tr("Localizable", "SpaceManager.CancelRequestAlert.Toast", fallback: "The request was canceled.")
    }
  }
  public enum SpaceSettings {
    public static let deleteButton = Loc.tr("Localizable", "SpaceSettings.DeleteButton", fallback: "Delete space")
    public static let info = Loc.tr("Localizable", "SpaceSettings.Info", fallback: "Space information")
    public static let leaveButton = Loc.tr("Localizable", "SpaceSettings.LeaveButton", fallback: "Leave")
    public static let networkId = Loc.tr("Localizable", "SpaceSettings.NetworkId", fallback: "Network ID")
    public static let remoteStorage = Loc.tr("Localizable", "SpaceSettings.RemoteStorage", fallback: "Remote storage")
    public static let share = Loc.tr("Localizable", "SpaceSettings.Share", fallback: "Share")
    public static let title = Loc.tr("Localizable", "SpaceSettings.Title", fallback: "Space settings")
    public enum DeleteAlert {
      public static let message = Loc.tr("Localizable", "SpaceSettings.DeleteAlert.Message", fallback: "This space will be deleted irrevocably. You can’t undo this action.")
      public static func title(_ p1: Any) -> String {
        return Loc.tr("Localizable", "SpaceSettings.DeleteAlert.Title", String(describing: p1), fallback: "Delete ‘%@’ space")
      }
    }
    public enum LeaveAlert {
      public static func message(_ p1: Any) -> String {
        return Loc.tr("Localizable", "SpaceSettings.LeaveAlert.Message", String(describing: p1), fallback: "%@ space will be removed from your devices and you will no longer have access to it")
      }
      public static func toast(_ p1: Any) -> String {
        return Loc.tr("Localizable", "SpaceSettings.LeaveAlert.Toast", String(describing: p1), fallback: "You left the %@.")
      }
    }
  }
  public enum SpaceShare {
    public static let accessChanged = Loc.tr("Localizable", "SpaceShare.AccessChanged", fallback: "Access rights have been changed.")
    public static func changePermissions(_ p1: Any, _ p2: Any) -> String {
      return Loc.tr("Localizable", "SpaceShare.ChangePermissions", String(describing: p1), String(describing: p2), fallback: "%@ access to the space would become %@.")
    }
    public static let joinRequest = Loc.tr("Localizable", "SpaceShare.JoinRequest", fallback: "Join request")
    public static let leaveRequest = Loc.tr("Localizable", "SpaceShare.LeaveRequest", fallback: "Leave request")
    public static let manage = Loc.tr("Localizable", "SpaceShare.Manage", fallback: "Manage")
    public static let manageSpaces = Loc.tr("Localizable", "SpaceShare.ManageSpaces", fallback: "Manage Spaces")
    public static let members = Loc.tr("Localizable", "SpaceShare.Members", fallback: "Members")
    public static func requestsCount(_ p1: Int) -> String {
      return Loc.tr("Localizable", "SpaceShare.RequestsCount", p1, fallback: "Plural format key: SpaceShare.RequestsCount")
    }
    public static let title = Loc.tr("Localizable", "SpaceShare.Title", fallback: "Sharing")
    public static func youSuffix(_ p1: Any) -> String {
      return Loc.tr("Localizable", "SpaceShare.YouSuffix", String(describing: p1), fallback: "%@ (you)")
    }
    public enum Action {
      public static let approve = Loc.tr("Localizable", "SpaceShare.Action.Approve", fallback: "Approve")
      public static let viewRequest = Loc.tr("Localizable", "SpaceShare.Action.ViewRequest", fallback: "View request")
    }
    public enum AlreadyJoin {
      public static let openSpace = Loc.tr("Localizable", "SpaceShare.AlreadyJoin.OpenSpace", fallback: "Open space")
      public static let title = Loc.tr("Localizable", "SpaceShare.AlreadyJoin.Title", fallback: "You are already a member of this space")
    }
    public enum Approve {
      public static func toast(_ p1: Any) -> String {
        return Loc.tr("Localizable", "SpaceShare.Approve.Toast", String(describing: p1), fallback: "You approved %@'s request.")
      }
    }
    public enum CopyInviteLink {
      public static let title = Loc.tr("Localizable", "SpaceShare.CopyInviteLink.Title", fallback: "Copy invite link")
    }
    public enum DeleteSharingLink {
      public static let message = Loc.tr("Localizable", "SpaceShare.DeleteSharingLink.Message", fallback: "New members won’t be able to join the space. You can generate a new link anytime")
      public static let title = Loc.tr("Localizable", "SpaceShare.DeleteSharingLink.Title", fallback: "Delete link")
    }
    public enum HowToShare {
      public static let step1 = Loc.tr("Localizable", "SpaceShare.HowToShare.Step1", fallback: "Please provide the link to the person you'd like to collaborate with.")
      public static let step2 = Loc.tr("Localizable", "SpaceShare.HowToShare.Step2", fallback: "By clicking the link, a person requests to join the space.")
      public static let step3 = Loc.tr("Localizable", "SpaceShare.HowToShare.Step3", fallback: "After approving the request, you can choose the access rights for that person.")
      public static let title = Loc.tr("Localizable", "SpaceShare.HowToShare.Title", fallback: "How to share a space?")
    }
    public enum Invite {
      public static let empty = Loc.tr("Localizable", "SpaceShare.Invite.Empty", fallback: "Create invite link to share space and add new members")
      public static let generate = Loc.tr("Localizable", "SpaceShare.Invite.Generate", fallback: "Generate invite link")
      public static func maxLimit(_ p1: Int) -> String {
        return Loc.tr("Localizable", "SpaceShare.Invite.MaxLimit", p1, fallback: "Plural format key: SpaceShare.Invite.MaxLimit")
      }
      public static let share = Loc.tr("Localizable", "SpaceShare.Invite.Share", fallback: "Share invite link")
      public static let title = Loc.tr("Localizable", "SpaceShare.Invite.Title", fallback: "Invite link")
      public enum Description {
        public static let part1 = Loc.tr("Localizable", "SpaceShare.Invite.Description.part1", fallback: "Share this invite link so that others can join your space")
        public static let part2 = Loc.tr("Localizable", "SpaceShare.Invite.Description.part2", fallback: "Once they click your link and request access, you can set their access rights.")
      }
      public enum Stream {
        public static let description = Loc.tr("Localizable", "SpaceShare.Invite.Stream.Description", fallback: "Share this link so that others can join your Stream.")
      }
    }
    public enum Join {
      public static let button = Loc.tr("Localizable", "SpaceShare.Join.Button", fallback: "Request to join")
      public static let commentPlaceholder = Loc.tr("Localizable", "SpaceShare.Join.CommentPlaceholder", fallback: "Leave a private comment for a space owner")
      public static let info = Loc.tr("Localizable", "SpaceShare.Join.Info", fallback: "Once the space owner approves your request, you'll join the space with the access rights owner determined.")
      public static func message(_ p1: Any, _ p2: Any) -> String {
        return Loc.tr("Localizable", "SpaceShare.Join.Message", String(describing: p1), String(describing: p2), fallback: "You’ve been invited to join **%@** space, created by **%@**. Send a request so space owner can let you in.")
      }
      public static let spaceDeleted = Loc.tr("Localizable", "SpaceShare.Join.SpaceDeleted", fallback: "The space you try to access has been deleted")
      public static let title = Loc.tr("Localizable", "SpaceShare.Join.Title", fallback: "Join a space")
      public enum InviteNotFound {
        public static let message = Loc.tr("Localizable", "SpaceShare.Join.InviteNotFound.Message", fallback: "The link you are using does not seem to work. Please ask the owner to share a new one with you.")
      }
      public enum LimitReached {
        public static let message = Loc.tr("Localizable", "SpaceShare.Join.LimitReached.Message", fallback: "To join as an editor, ask the owner to add more editor seats or send you a new link with view-only access.")
        public static let title = Loc.tr("Localizable", "SpaceShare.Join.LimitReached.Title", fallback: "This space has reached its limit")
      }
      public enum NoAccess {
        public static let title = Loc.tr("Localizable", "SpaceShare.Join.NoAccess.Title", fallback: "No access to this space")
      }
      public enum NoApprove {
        public static let button = Loc.tr("Localizable", "SpaceShare.Join.NoApprove.button", fallback: "Join Space")
        public static func message(_ p1: Any, _ p2: Any) -> String {
          return Loc.tr("Localizable", "SpaceShare.Join.NoApprove.Message", String(describing: p1), String(describing: p2), fallback: "You've been invited to join %@, created by %@")
        }
        public static func title(_ p1: Any) -> String {
          return Loc.tr("Localizable", "SpaceShare.Join.NoApprove.Title", String(describing: p1), fallback: "Join %@")
        }
      }
      public enum ObjectIsNotAvailable {
        public static let message = Loc.tr("Localizable", "SpaceShare.Join.ObjectIsNotAvailable.Message", fallback: "Ask the owner to share it with you.")
      }
    }
    public enum JoinConfirmation {
      public static let message = Loc.tr("Localizable", "SpaceShare.JoinConfirmation.Message", fallback: "You will receive a notification when the space owner will approve your request.")
      public static let title = Loc.tr("Localizable", "SpaceShare.JoinConfirmation.Title", fallback: "Request sent")
    }
    public enum Permissions {
      public static let owner = Loc.tr("Localizable", "SpaceShare.Permissions.Owner", fallback: "Owner")
      public static let reader = Loc.tr("Localizable", "SpaceShare.Permissions.Reader", fallback: "Viewer")
      public static let writer = Loc.tr("Localizable", "SpaceShare.Permissions.Writer", fallback: "Editor")
      public enum Grand {
        public static let edit = Loc.tr("Localizable", "SpaceShare.Permissions.Grand.Edit", fallback: "Edit")
        public static let view = Loc.tr("Localizable", "SpaceShare.Permissions.Grand.View", fallback: "View")
      }
    }
    public enum Qr {
      public static let button = Loc.tr("Localizable", "SpaceShare.QR.Button", fallback: "Show QR code")
      public static let title = Loc.tr("Localizable", "SpaceShare.QR.Title", fallback: "QR code for joining a Space")
    }
    public enum RemoveMember {
      public static func message(_ p1: Any) -> String {
        return Loc.tr("Localizable", "SpaceShare.RemoveMember.Message", String(describing: p1), fallback: "%@ will be removed from the space.")
      }
      public static let title = Loc.tr("Localizable", "SpaceShare.RemoveMember.Title", fallback: "Remove member")
    }
    public enum Share {
      public static let link = Loc.tr("Localizable", "SpaceShare.Share.link", fallback: "Share link")
    }
    public enum StopSharing {
      public static let action = Loc.tr("Localizable", "SpaceShare.StopSharing.Action", fallback: "Stop sharing")
      public static let message = Loc.tr("Localizable", "SpaceShare.StopSharing.Message", fallback: "Members will no longer sync to this space and the share link will be deactivated.")
      public static let title = Loc.tr("Localizable", "SpaceShare.StopSharing.Title", fallback: "Stop sharing the space")
      public static let toast = Loc.tr("Localizable", "SpaceShare.StopSharing.Toast", fallback: "The space is no longer shared")
    }
    public enum Tip {
      public static let title = Loc.tr("Localizable", "SpaceShare.Tip.Title", fallback: "Collaborate on spaces")
      public enum Steps {
        public static let _1 = Loc.tr("Localizable", "SpaceShare.Tip.Steps.1", fallback: "Tap the Space widget to access settings")
        public static let _2 = Loc.tr("Localizable", "SpaceShare.Tip.Steps.2", fallback: "Open Share section")
        public static let _3 = Loc.tr("Localizable", "SpaceShare.Tip.Steps.3", fallback: "Generate an invite link and share it")
      }
    }
    public enum ViewRequest {
      public static let editAccess = Loc.tr("Localizable", "SpaceShare.ViewRequest.EditAccess", fallback: "Add as editor")
      public static let reject = Loc.tr("Localizable", "SpaceShare.ViewRequest.Reject", fallback: "Reject")
      public static func title(_ p1: Any, _ p2: Any) -> String {
        return Loc.tr("Localizable", "SpaceShare.ViewRequest.Title", String(describing: p1), String(describing: p2), fallback: "%@ requested to join %@ space")
      }
      public static let viewAccess = Loc.tr("Localizable", "SpaceShare.ViewRequest.ViewAccess", fallback: "Add as viewer")
    }
  }
  public enum Spaces {
    public static let title = Loc.tr("Localizable", "Spaces.Title", fallback: "Spaces")
    public enum Accessibility {
      public static let personal = Loc.tr("Localizable", "Spaces.Accessibility.Personal", fallback: "Entry Space")
      public static let `private` = Loc.tr("Localizable", "Spaces.Accessibility.Private", fallback: "Private Space")
      public static let shared = Loc.tr("Localizable", "Spaces.Accessibility.Shared", fallback: "Shared Space")
    }
    public enum Info {
      public static let network = Loc.tr("Localizable", "Spaces.Info.Network", fallback: "Network:")
    }
    public enum Search {
      public static let title = Loc.tr("Localizable", "Spaces.Search.Title", fallback: "Search spaces")
    }
    public enum UxType {
      public enum Chat {
        public static let description = Loc.tr("Localizable", "Spaces.UxType.Chat.Description", fallback: "For real-time conversations")
        public static let title = Loc.tr("Localizable", "Spaces.UxType.Chat.Title", fallback: "Chat")
      }
      public enum Space {
        public static let description = Loc.tr("Localizable", "Spaces.UxType.Space.Description", fallback: "For organized content and data")
        public static let title = Loc.tr("Localizable", "Spaces.UxType.Space.Title", fallback: "Space")
      }
      public enum Stream {
        public static let description = Loc.tr("Localizable", "Spaces.UxType.Stream.Description", fallback: "For broadcasting your vibe")
        public static let title = Loc.tr("Localizable", "Spaces.UxType.Stream.Title", fallback: "Stream")
      }
    }
  }
  public enum StoreKitServiceError {
    public static let needUserAction = Loc.tr("Localizable", "StoreKitServiceError.needUserAction", fallback: "Payment unsuccessfull, User Actions on Apple side required to pay.")
    public static let userCancelled = Loc.tr("Localizable", "StoreKitServiceError.userCancelled", fallback: "Purchase cancelled")
  }
  public enum Stream {
    public enum Empty {
      public static let description = Loc.tr("Localizable", "Stream.Empty.Description", fallback: "Invite people and start sharing your vibe")
      public static let title = Loc.tr("Localizable", "Stream.Empty.Title", fallback: "This stream is empty")
    }
  }
  public enum StyleMenu {
    public enum Color {
      public enum TextColor {
        public static let placeholder = Loc.tr("Localizable", "StyleMenu.Color.TextColor.Placeholder", fallback: "A")
      }
    }
  }
  public enum Swipe {
    public enum Tip {
      public static let subtitle = Loc.tr("Localizable", "Swipe.Tip.Subtitle", fallback: "Create objects inside widgets by easily swiping them left.")
      public static let title = Loc.tr("Localizable", "Swipe.Tip.Title", fallback: "Swipe to Create Objects")
    }
  }
  public enum Sync {
    public enum Status {
      public enum Version {
        public enum Outdated {
          public static let description = Loc.tr("Localizable", "Sync.Status.Version.Outdated.Description", fallback: "Version outdated. Please update Anytype")
        }
      }
    }
  }
  public enum SyncStatus {
    public enum Error {
      public static let incompatibleVersion = Loc.tr("Localizable", "SyncStatus.Error.incompatibleVersion", fallback: "Incompatible version")
      public static let networkError = Loc.tr("Localizable", "SyncStatus.Error.networkError", fallback: "No access to the space")
      public static let storageLimitExceed = Loc.tr("Localizable", "SyncStatus.Error.storageLimitExceed", fallback: "Storage limit reached")
      public static let unrecognized = Loc.tr("Localizable", "SyncStatus.Error.UNRECOGNIZED", fallback: "Unrecognized error")
    }
    public enum Info {
      public static let anytypeNetwork = Loc.tr("Localizable", "SyncStatus.Info.AnytypeNetwork", fallback: "End-to-end encrypted")
      public static let localOnly = Loc.tr("Localizable", "SyncStatus.Info.localOnly", fallback: "Data backup is disabled")
      public static let networkNeedsUpdate = Loc.tr("Localizable", "SyncStatus.Info.NetworkNeedsUpdate", fallback: "Sync might be slow. Update the app.")
    }
    public enum P2P {
      public static let notConnected = Loc.tr("Localizable", "SyncStatus.P2P.NotConnected", fallback: "Not connected")
      public static let notPossible = Loc.tr("Localizable", "SyncStatus.P2P.NotPossible", fallback: "Connection not possible")
      public static let restricted = Loc.tr("Localizable", "SyncStatus.P2P.Restricted", fallback: "Restricted. Tap to open device settings.")
    }
  }
  public enum TalbeOfContents {
    public static let empty = Loc.tr("Localizable", "TalbeOfContents.Empty", fallback: "Add headings to create a table of contents")
  }
  public enum TemplateEditing {
    public static let title = Loc.tr("Localizable", "TemplateEditing.Title", fallback: "Edit template")
  }
  public enum TemplateOptions {
    public enum Alert {
      public static let delete = Loc.tr("Localizable", "TemplateOptions.Alert.Delete", fallback: "Delete")
      public static let duplicate = Loc.tr("Localizable", "TemplateOptions.Alert.Duplicate", fallback: "Duplicate")
      public static let editTemplate = Loc.tr("Localizable", "TemplateOptions.Alert.EditTemplate", fallback: "Edit template")
    }
  }
  public enum TemplatePicker {
    public static let chooseTemplate = Loc.tr("Localizable", "TemplatePicker.ChooseTemplate", fallback: "Choose template")
    public enum Buttons {
      public static let useTemplate = Loc.tr("Localizable", "TemplatePicker.Buttons.UseTemplate", fallback: "Use template")
    }
  }
  public enum TemplateSelection {
    public static let selectTemplate = Loc.tr("Localizable", "TemplateSelection.SelectTemplate", fallback: "Select template")
    public enum Available {
      public static func title(_ p1: Int) -> String {
        return Loc.tr("Localizable", "TemplateSelection.Available.Title", p1, fallback: "Plural format key: TemplateSelection.Available.Title")
      }
    }
    public enum ObjectType {
      public static let subtitle = Loc.tr("Localizable", "TemplateSelection.ObjectType.Subtitle", fallback: "Object type")
    }
    public enum Template {
      public static let subtitle = Loc.tr("Localizable", "TemplateSelection.Template.Subtitle", fallback: "Template")
    }
  }
  public enum Templates {
    public enum Popup {
      public static let `default` = Loc.tr("Localizable", "Templates.Popup.Default", fallback: "The template was set as default")
      public static let duplicated = Loc.tr("Localizable", "Templates.Popup.Duplicated", fallback: "The template was duplicated")
      public static let removed = Loc.tr("Localizable", "Templates.Popup.Removed", fallback: "The template was removed")
      public static let wasAddedTo = Loc.tr("Localizable", "Templates.Popup.WasAddedTo", fallback: "New template was added to the type")
      public enum WasAddedTo {
        public static func title(_ p1: Any) -> String {
          return Loc.tr("Localizable", "Templates.Popup.WasAddedTo.title", String(describing: p1), fallback: "New template was added to the type %@")
        }
      }
    }
  }
  public enum TextStyle {
    public enum Bold {
      public static let title = Loc.tr("Localizable", "TextStyle.Bold.Title", fallback: "Bold")
    }
    public enum Bulleted {
      public static let subtitle = Loc.tr("Localizable", "TextStyle.Bulleted.Subtitle", fallback: "Simple list")
      public static let title = Loc.tr("Localizable", "TextStyle.Bulleted.Title", fallback: "Bulleted")
    }
    public enum Callout {
      public static let subtitle = Loc.tr("Localizable", "TextStyle.Callout.Subtitle", fallback: "Bordered text with icon")
      public static let title = Loc.tr("Localizable", "TextStyle.Callout.Title", fallback: "Callout")
    }
    public enum Checkbox {
      public static let subtitle = Loc.tr("Localizable", "TextStyle.Checkbox.Subtitle", fallback: "Create and track task with to-do list")
      public static let title = Loc.tr("Localizable", "TextStyle.Checkbox.Title", fallback: "Checkbox")
    }
    public enum Code {
      public static let title = Loc.tr("Localizable", "TextStyle.Code.Title", fallback: "Code")
    }
    public enum Heading {
      public static let subtitle = Loc.tr("Localizable", "TextStyle.Heading.Subtitle", fallback: "Medium headline")
      public static let title = Loc.tr("Localizable", "TextStyle.Heading.Title", fallback: "Heading")
    }
    public enum Highlighted {
      public static let subtitle = Loc.tr("Localizable", "TextStyle.Highlighted.Subtitle", fallback: "Spotlight, that needs special attention")
      public static let title = Loc.tr("Localizable", "TextStyle.Highlighted.Title", fallback: "Highlighted")
    }
    public enum Italic {
      public static let title = Loc.tr("Localizable", "TextStyle.Italic.Title", fallback: "Italic")
    }
    public enum Link {
      public static let title = Loc.tr("Localizable", "TextStyle.Link.Title", fallback: "Link")
    }
    public enum Numbered {
      public static let subtitle = Loc.tr("Localizable", "TextStyle.Numbered.Subtitle", fallback: "Numbered list")
      public static let title = Loc.tr("Localizable", "TextStyle.Numbered.Title", fallback: "Numbered list")
    }
    public enum Strikethrough {
      public static let title = Loc.tr("Localizable", "TextStyle.Strikethrough.Title", fallback: "Strikethrough")
    }
    public enum Subheading {
      public static let subtitle = Loc.tr("Localizable", "TextStyle.Subheading.Subtitle", fallback: "Small headline")
      public static let title = Loc.tr("Localizable", "TextStyle.Subheading.Title", fallback: "Subheading")
    }
    public enum Text {
      public static let subtitle = Loc.tr("Localizable", "TextStyle.Text.Subtitle", fallback: "Just start writing with a plain text")
      public static let title = Loc.tr("Localizable", "TextStyle.Text.Title", fallback: "Text")
    }
    public enum Title {
      public static let subtitle = Loc.tr("Localizable", "TextStyle.Title.Subtitle", fallback: "Big section heading")
      public static let title = Loc.tr("Localizable", "TextStyle.Title.Title", fallback: "Title")
    }
    public enum Toggle {
      public static let subtitle = Loc.tr("Localizable", "TextStyle.Toggle.Subtitle", fallback: "Hide and show content inside")
      public static let title = Loc.tr("Localizable", "TextStyle.Toggle.Title", fallback: "Toggle")
    }
    public enum Underline {
      public static let title = Loc.tr("Localizable", "TextStyle.Underline.Title", fallback: "Underline")
    }
  }
  public enum ToggleEmpty {
    public static let tapToCreateBlock = Loc.tr("Localizable", "Toggle empty. Tap to create block.", fallback: "Toggle empty. Tap to create block.")
  }
  public enum Vault {
    public enum Select {
      public enum Incompatible {
        public enum Version {
          public enum Error {
            public static let text = Loc.tr("Localizable", "Vault.Select.Incompatible.Version.Error.Text", fallback: "We were unable to retrieve your vault data because your version is out-of-date. Please update Anytype to the latest version.")
          }
        }
      }
    }
  }
  public enum VersionHistory {
    public static let title = Loc.tr("Localizable", "VersionHistory.Title", fallback: "Version History")
    public enum Toast {
      public static func message(_ p1: Any) -> String {
        return Loc.tr("Localizable", "VersionHistory.Toast.message", String(describing: p1), fallback: "Version %@ was restored")
      }
    }
  }
  public enum Wallet {
    public enum Recovery {
      public enum Error {
        public static let description = Loc.tr("Localizable", "Wallet.Recovery.Error.description", fallback: "Invalid Key")
      }
    }
  }
  public enum WidgetExtension {
    public enum LockScreen {
      public static let description = Loc.tr("Localizable", "WidgetExtension.LockScreen.Description", fallback: "Create a new object on the fly")
      public static let title = Loc.tr("Localizable", "WidgetExtension.LockScreen.Title", fallback: "New object")
    }
  }
  public enum WidgetObjectList {
    public enum ForceDelete {
      public static let message = Loc.tr("Localizable", "WidgetObjectList.ForceDelete.Message", fallback: "You can’t undo this action.")
    }
  }
  public enum Widgets {
    public static let appUpdate = Loc.tr("Localizable", "Widgets.AppUpdate", fallback: "Anytype is ready to update")
    public static func autoAddedAlert(_ p1: Any) -> String {
      return Loc.tr("Localizable", "Widgets.AutoAddedAlert", String(describing: p1), fallback: "Widget %@ was added")
    }
    public static let sourceSearch = Loc.tr("Localizable", "Widgets.SourceSearch", fallback: "Widget source")
    public enum Actions {
      public static let addBelow = Loc.tr("Localizable", "Widgets.Actions.AddBelow", fallback: "Add Below")
      public static let addWidget = Loc.tr("Localizable", "Widgets.Actions.AddWidget", fallback: "Add Widget")
      public static func binConfirm(_ p1: Int) -> String {
        return Loc.tr("Localizable", "Widgets.Actions.BinConfirm", p1, fallback: "Plural format key: Widgets.Actions.BinConfirm")
      }
      public static let changeWidgetType = Loc.tr("Localizable", "Widgets.Actions.ChangeWidgetType", fallback: "Change Widget Type")
      public static let editWidgets = Loc.tr("Localizable", "Widgets.Actions.EditWidgets", fallback: "Edit Widgets")
      public static let emptyBin = Loc.tr("Localizable", "Widgets.Actions.EmptyBin", fallback: "Empty Bin")
      public static let newObject = Loc.tr("Localizable", "Widgets.Actions.NewObject", fallback: "New Object")
      public static let removeWidget = Loc.tr("Localizable", "Widgets.Actions.RemoveWidget", fallback: "Remove Widget")
      public static let seeAllObjects = Loc.tr("Localizable", "Widgets.Actions.SeeAllObjects", fallback: "See all objects")
    }
    public enum Empty {
      public static let createObject = Loc.tr("Localizable", "Widgets.Empty.CreateObject", fallback: "Create Object")
      public static let title = Loc.tr("Localizable", "Widgets.Empty.Title", fallback: "There are no objects here")
    }
    public enum Layout {
      public enum CompactList {
        public static let description = Loc.tr("Localizable", "Widgets.Layout.CompactList.Description", fallback: "Widget with a compact list view")
        public static let title = Loc.tr("Localizable", "Widgets.Layout.CompactList.Title", fallback: "Сompact list")
      }
      public enum Link {
        public static let description = Loc.tr("Localizable", "Widgets.Layout.Link.Description", fallback: "Compact widget view")
        public static let title = Loc.tr("Localizable", "Widgets.Layout.Link.Title", fallback: "Link")
      }
      public enum List {
        public static let description = Loc.tr("Localizable", "Widgets.Layout.List.Description", fallback: "Widget with a list view")
        public static let title = Loc.tr("Localizable", "Widgets.Layout.List.Title", fallback: "List")
      }
      public enum Screen {
        public static let title = Loc.tr("Localizable", "Widgets.Layout.Screen.Title", fallback: "Widget type")
      }
      public enum Tree {
        public static let description = Loc.tr("Localizable", "Widgets.Layout.Tree.Description", fallback: "Widget with a hierarchical structure")
        public static let title = Loc.tr("Localizable", "Widgets.Layout.Tree.Title", fallback: "Tree")
      }
      public enum View {
        public static let description = Loc.tr("Localizable", "Widgets.Layout.View.Description", fallback: "Widget with a Query or Collection layout")
        public static let title = Loc.tr("Localizable", "Widgets.Layout.View.Title", fallback: "View")
      }
    }
    public enum Library {
      public enum RecentlyEdited {
        public static let name = Loc.tr("Localizable", "Widgets.Library.RecentlyEdited.Name", fallback: "Recently edited")
      }
      public enum RecentlyOpened {
        public static let description = Loc.tr("Localizable", "Widgets.Library.RecentlyOpened.Description", fallback: "On this device")
        public static let name = Loc.tr("Localizable", "Widgets.Library.RecentlyOpened.Name", fallback: "Recently opened")
      }
    }
    public enum List {
      public static let empty = Loc.tr("Localizable", "Widgets.List.Empty", fallback: "No widgets yet")
    }
    public enum Source {
      public static let library = Loc.tr("Localizable", "Widgets.Source.Library", fallback: "System")
      public static let objects = Loc.tr("Localizable", "Widgets.Source.Objects", fallback: "Your objects")
      public static let suggested = Loc.tr("Localizable", "Widgets.Source.Suggested", fallback: "Suggested")
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension Loc {
  private static func tr(_ table: String, _ key: String, _ args: any CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
