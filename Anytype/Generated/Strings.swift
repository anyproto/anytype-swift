// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum Loc {
  internal static let about = Loc.tr("Localizable", "About", fallback: "About")
  internal static let access = Loc.tr("Localizable", "Access", fallback: "Access")
  internal static let accessToKeyFromKeychain = Loc.tr("Localizable", "Access to key from keychain", fallback: "Access to key from keychain")
  internal static let actionFocusedLayoutWithACheckbox = Loc.tr("Localizable", "Action-focused layout with a checkbox", fallback: "Action-focused layout with a checkbox")
  internal static let actions = Loc.tr("Localizable", "Actions", fallback: "Actions")
  internal static let add = Loc.tr("Localizable", "Add", fallback: "Add")
  internal static let addBelow = Loc.tr("Localizable", "Add below", fallback: "Add below")
  internal static let addEmail = Loc.tr("Localizable", "Add email", fallback: "Add email")
  internal static let addLink = Loc.tr("Localizable", "Add link", fallback: "Add link")
  internal static let addPhone = Loc.tr("Localizable", "Add phone", fallback: "Add phone")
  internal static let addToFavorite = Loc.tr("Localizable", "Add To Favorite", fallback: "Add To Favorite")
  internal static func agreementDisclamer(_ p1: Any, _ p2: Any) -> String {
    return Loc.tr("Localizable", "Agreement Disclamer", String(describing: p1), String(describing: p2), fallback: "By continuing you agree to [Terms of Use](%@) and [Privacy Policy](%@)")
  }
  internal static let alignCenter = Loc.tr("Localizable", "Align center", fallback: "Align center")
  internal static let alignJustify = Loc.tr("Localizable", "Align justify", fallback: "Align justify")
  internal static let alignLeft = Loc.tr("Localizable", "Align left", fallback: "Align left")
  internal static let alignRight = Loc.tr("Localizable", "Align right", fallback: "Align right")
  internal static let alignment = Loc.tr("Localizable", "Alignment", fallback: "Alignment")
  internal static let all = Loc.tr("Localizable", "All", fallback: "All")
  internal static let allObjects = Loc.tr("Localizable", "All objects", fallback: "All Objects")
  internal static let amber = Loc.tr("Localizable", "Amber", fallback: "Amber")
  internal static let amberBackground = Loc.tr("Localizable", "Amber background", fallback: "Amber background")
  internal static let anytypeLibrary = Loc.tr("Localizable", "Anytype Library", fallback: "Anytype Library")
  internal static let anytypeNetwork = Loc.tr("Localizable", "Anytype Network", fallback: "Anytype Network")
  internal static let appearance = Loc.tr("Localizable", "Appearance", fallback: "Appearance")
  internal static let applicationIcon = Loc.tr("Localizable", "Application icon", fallback: "Application icon")
  internal static let apply = Loc.tr("Localizable", "Apply", fallback: "Apply")
  internal static func areYouSureYouWantToDelete(_ p1: Int) -> String {
    return Loc.tr("Localizable", "Are you sure you want to delete", p1, fallback: "Plural format key: \"Are you sure you want to delete %#@object@?\"")
  }
  internal static let areYouSure = Loc.tr("Localizable", "AreYouSure", fallback: "Are you sure?")
  internal static let audio = Loc.tr("Localizable", "Audio", fallback: "Audio")
  internal static let back = Loc.tr("Localizable", "Back", fallback: "Back")
  internal static let backUpKey = Loc.tr("Localizable", "Back up key", fallback: "Back up key")
  internal static let backUpYourKey = Loc.tr("Localizable", "Back up your key", fallback: "Back up your key")
  internal static let background = Loc.tr("Localizable", "Background", fallback: "Background")
  internal static func backlinksCount(_ p1: Int) -> String {
    return Loc.tr("Localizable", "Backlinks count", p1, fallback: "Plural format key: \"%#@object@\"")
  }
  internal static let basic = Loc.tr("Localizable", "Basic", fallback: "Basic")
  internal static let bin = Loc.tr("Localizable", "Bin", fallback: "Bin")
  internal static let black = Loc.tr("Localizable", "Black", fallback: "Black")
  internal static let blue = Loc.tr("Localizable", "Blue", fallback: "Blue")
  internal static let blueBackground = Loc.tr("Localizable", "Blue background", fallback: "Blue background")
  internal static let blurredIcon = Loc.tr("Localizable", "Blurred icon", fallback: "Blurred\n icon")
  internal static let bookmark = Loc.tr("Localizable", "Bookmark", fallback: "Bookmark")
  internal static let bookmarkBlockSubtitle = Loc.tr("Localizable", "Bookmark block subtitle", fallback: "Save your favorite link with summary")
  internal static let bookmarks = Loc.tr("Localizable", "Bookmarks", fallback: "Bookmarks")
  internal static let callout = Loc.tr("Localizable", "Callout", fallback: "Callout")
  internal static let cancel = Loc.tr("Localizable", "Cancel", fallback: "Cancel")
  internal static let cancelDeletion = Loc.tr("Localizable", "Cancel deletion", fallback: "Cancel deletion")
  internal static let changeCover = Loc.tr("Localizable", "Change cover", fallback: "Change cover")
  internal static let changeEmail = Loc.tr("Localizable", "Change email", fallback: "Change email")
  internal static let changeIcon = Loc.tr("Localizable", "Change icon", fallback: "Change icon")
  internal static let changeType = Loc.tr("Localizable", "Change type", fallback: "Change type")
  internal static let changeWallpaper = Loc.tr("Localizable", "Change wallpaper", fallback: "Change wallpaper")
  internal static let chooseDefaultObjectType = Loc.tr("Localizable", "Choose default object type", fallback: "Choose default object type")
  internal static let chooseLayoutType = Loc.tr("Localizable", "Choose layout type", fallback: "Choose layout type")
  internal static let clear = Loc.tr("Localizable", "Clear", fallback: "Clear")
  internal static let close = Loc.tr("Localizable", "Close", fallback: "Close")
  internal static let codeBlockSubtitle = Loc.tr("Localizable", "Code block subtitle", fallback: "Capture code snippet")
  internal static let codeSnippet = Loc.tr("Localizable", "Code snippet", fallback: "Code snippet")
  internal static let collaboration = Loc.tr("Localizable", "Collaboration", fallback: "Collaboration")
  internal static let collection = Loc.tr("Localizable", "Collection", fallback: "Collection")
  internal static let collectionOfObjects = Loc.tr("Localizable", "Collection of objects", fallback: "Collection of objects")
  internal static let collections = Loc.tr("Localizable", "Collections", fallback: "Collections")
  internal static let color = Loc.tr("Localizable", "Color", fallback: "Color")
  internal static let companiesContactsFriendsAndFamily = Loc.tr("Localizable", "Companies, contacts, friends and family", fallback: "Companies, contacts, friends and family")
  internal static let confirm = Loc.tr("Localizable", "Confirm", fallback: "Confirm")
  internal static let connecting = Loc.tr("Localizable", "Connecting", fallback: "Connecting...")
  internal static let contentModel = Loc.tr("Localizable", "Content Model", fallback: "Content Model")
  internal static let copied = Loc.tr("Localizable", "Copied", fallback: "Copied")
  internal static func copiedToClipboard(_ p1: Any) -> String {
    return Loc.tr("Localizable", "copied to clipboard", String(describing: p1), fallback: "%@ copied to clipboard")
  }
  internal static let copy = Loc.tr("Localizable", "Copy", fallback: "Copy")
  internal static let copySpaceInfo = Loc.tr("Localizable", "Copy space info", fallback: "Copy space info")
  internal static let cover = Loc.tr("Localizable", "Cover", fallback: "Cover")
  internal static let create = Loc.tr("Localizable", "Create", fallback: "Create")
  internal static let createANewOneOrSearchForSomethingElse = Loc.tr("Localizable", "Create a new one or search for something else", fallback: "Create a new one or search for something else")
  internal static let createNewObject = Loc.tr("Localizable", "Create new object", fallback: "Create new object")
  internal static func createNewObjectWithName(_ p1: Any) -> String {
    return Loc.tr("Localizable", "Create new object with name", String(describing: p1), fallback: "Create new object \"%@\"")
  }
  internal static let createObject = Loc.tr("Localizable", "Create object", fallback: "Create Object")
  internal static let createObjectFromClipboard = Loc.tr("Localizable", "Create object from clipboard", fallback: "Create object from clipboard")
  internal static func createOptionWith(_ p1: Any) -> String {
    return Loc.tr("Localizable", "Create option with", String(describing: p1), fallback: "Create option ‘%@’")
  }
  internal static func createRelation(_ p1: Any) -> String {
    return Loc.tr("Localizable", "Create relation", String(describing: p1), fallback: "Create property ‘%@’")
  }
  internal static let createSet = Loc.tr("Localizable", "Create Set", fallback: "Create Query")
  internal static let createType = Loc.tr("Localizable", "Create type", fallback: "Create type")
  internal static let current = Loc.tr("Localizable", "Current", fallback: "Current")
  internal static let dates = Loc.tr("Localizable", "Dates", fallback: "Dates")
  internal static func daysToDeletionVault(_ p1: Int) -> String {
    return Loc.tr("Localizable", "Days to deletion vault", p1, fallback: "Plural format key: \"This vault will be deleted %#@days@\"")
  }
  internal static let defaultBackground = Loc.tr("Localizable", "Default background", fallback: "Default background")
  internal static let defaultObjectType = Loc.tr("Localizable", "Default object type", fallback: "Default object type")
  internal static let delete = Loc.tr("Localizable", "Delete", fallback: "Delete")
  internal static let deleteVault = Loc.tr("Localizable", "Delete vault", fallback: "Delete vault")
  internal static let deleted = Loc.tr("Localizable", "Deleted", fallback: "Deleted")
  internal static let deletionError = Loc.tr("Localizable", "Deletion error", fallback: "Deletion error")
  internal static let description = Loc.tr("Localizable", "Description", fallback: "Description")
  internal static let deselect = Loc.tr("Localizable", "Deselect", fallback: "Deselect")
  internal static let deselectAll = Loc.tr("Localizable", "Deselect all", fallback: "Deselect all")
  internal static let designedToCaptureThoughtsQuickly = Loc.tr("Localizable", "Designed to capture thoughts quickly", fallback: "Designed to capture thoughts quickly")
  internal static func devicesConnected(_ p1: Int) -> String {
    return Loc.tr("Localizable", "Devices connected", p1, fallback: "Plural format key: \"%#@device@ connected\"")
  }
  internal static let done = Loc.tr("Localizable", "Done", fallback: "Done")
  internal static let download = Loc.tr("Localizable", "Download", fallback: "Download")
  internal static let downloadingOrUploadingDataToSomeNode = Loc.tr("Localizable", "Downloading or uploading data to some node", fallback: "Downloading or uploading data to some node")
  internal static let duplicate = Loc.tr("Localizable", "Duplicate", fallback: "Duplicate")
  internal static let eMail = Loc.tr("Localizable", "E-mail", fallback: "E-mail")
  internal static let edit = Loc.tr("Localizable", "Edit", fallback: "Edit")
  internal static let editField = Loc.tr("Localizable", "Edit field", fallback: "Edit property")
  internal static let editProfile = Loc.tr("Localizable", "Edit Profile", fallback: "Edit Profile")
  internal static let emailSuccessfullyValidated = Loc.tr("Localizable", "Email successfully validated", fallback: "Email successfully validated")
  internal static let emoji = Loc.tr("Localizable", "Emoji", fallback: "Emoji")
  internal static let empty = Loc.tr("Localizable", "Empty", fallback: "Empty")
  internal static let enterEmail = Loc.tr("Localizable", "Enter email", fallback: "Enter email")
  internal static let enterNumber = Loc.tr("Localizable", "Enter number", fallback: "Enter number")
  internal static let enterPhoneNumber = Loc.tr("Localizable", "Enter phone number", fallback: "Enter phone number")
  internal static let enterText = Loc.tr("Localizable", "Enter text", fallback: "Enter text")
  internal static let enterURL = Loc.tr("Localizable", "Enter URL", fallback: "Enter URL")
  internal static let enterValue = Loc.tr("Localizable", "Enter value", fallback: "Enter value")
  internal static let error = Loc.tr("Localizable", "Error", fallback: "Error")
  internal static let errorCreatingWallet = Loc.tr("Localizable", "Error creating wallet", fallback: "Error creating wallet")
  internal static let errorSelectVault = Loc.tr("Localizable", "Error select vault", fallback: "Error select vault")
  internal static let errorWalletRecoverVault = Loc.tr("Localizable", "Error wallet recover vault", fallback: "Error wallet recover vault")
  internal static let everywhere = Loc.tr("Localizable", "Everywhere", fallback: "Everywhere")
  internal static let exactDay = Loc.tr("Localizable", "Exact day", fallback: "Exact day")
  internal static let export = Loc.tr("Localizable", "Export", fallback: "Export")
  internal static let failedToSyncTryingAgain = Loc.tr("Localizable", "Failed to sync, trying again...", fallback: "Failed to sync, trying again...")
  internal static let favorite = Loc.tr("Localizable", "Favorite", fallback: "Favorite")
  internal static let favorites = Loc.tr("Localizable", "Favorites", fallback: "Favorites")
  internal static let featuredRelations = Loc.tr("Localizable", "Featured relations", fallback: "Featured properties")
  internal static let fields = Loc.tr("Localizable", "Fields", fallback: "Properties")
  internal static let file = Loc.tr("Localizable", "File", fallback: "File")
  internal static let fileBlockSubtitle = Loc.tr("Localizable", "File block subtitle", fallback: "Store file in original state")
  internal static let files = Loc.tr("Localizable", "Files", fallback: "Files")
  internal static let filter = Loc.tr("Localizable", "Filter", fallback: "Filter")
  internal static let forever = Loc.tr("Localizable", "Forever", fallback: "Forever")
  internal static let foreverFree = Loc.tr("Localizable", "Forever free", fallback: "Forever free")
  internal static let gallery = Loc.tr("Localizable", "Gallery", fallback: "Gallery")
  internal static let goBack = Loc.tr("Localizable", "Go back", fallback: "Go back")
  internal static let gotIt = Loc.tr("Localizable", "Got it", fallback: "I got it!")
  internal static let gradients = Loc.tr("Localizable", "Gradients", fallback: "Gradients")
  internal static let green = Loc.tr("Localizable", "Green", fallback: "Green")
  internal static let greenBackground = Loc.tr("Localizable", "Green background", fallback: "Green background")
  internal static let grey = Loc.tr("Localizable", "Grey", fallback: "Grey")
  internal static let greyBackground = Loc.tr("Localizable", "Grey background", fallback: "Grey background")
  internal static let header = Loc.tr("Localizable", "Header", fallback: "Header")
  internal static let hidden = Loc.tr("Localizable", "Hidden", fallback: "Hidden")
  internal static let hide = Loc.tr("Localizable", "Hide", fallback: "Hide")
  internal static let hideTypes = Loc.tr("Localizable", "Hide types", fallback: "Hide types")
  internal static let highlight = Loc.tr("Localizable", "Highlight", fallback: "Highlight")
  internal static let history = Loc.tr("Localizable", "History", fallback: "History")
  internal static let home = Loc.tr("Localizable", "Home", fallback: "Home")
  internal static let icon = Loc.tr("Localizable", "Icon", fallback: "Icon")
  internal static let image = Loc.tr("Localizable", "Image", fallback: "Image")
  internal static let imageBlockSubtitle = Loc.tr("Localizable", "Image block subtitle", fallback: "Upload and enrich the page with image")
  internal static let inThisObject = Loc.tr("Localizable", "In this object", fallback: "In this object")
  internal static let incompatibleVersion = Loc.tr("Localizable", "Incompatible version", fallback: "Incompatible version")
  internal static let initializingSync = Loc.tr("Localizable", "Initializing sync", fallback: "Initializing sync")
  internal static let intoObject = Loc.tr("Localizable", "Into object", fallback: "Into object")
  internal static let invite = Loc.tr("Localizable", "Invite", fallback: "Invite")
  internal static func itemsSyncing(_ p1: Int) -> String {
    return Loc.tr("Localizable", "Items syncing", p1, fallback: "Plural format key: \"%#@item@ syncing...\"")
  }
  internal static let join = Loc.tr("Localizable", "Join", fallback: "Join")
  internal static let justEMail = Loc.tr("Localizable", "Just e-mail", fallback: "Just e-mail")
  internal static let layout = Loc.tr("Localizable", "Layout", fallback: "Layout")
  internal static let learnMore = Loc.tr("Localizable", "Learn more", fallback: "Learn more")
  internal static let leaveASpace = Loc.tr("Localizable", "Leave a space", fallback: "Leave a space")
  internal static let letsGo = Loc.tr("Localizable", "Lets Go", fallback: "Let’s Go")
  internal static let limitObjectTypes = Loc.tr("Localizable", "Limit object types", fallback: "Limit object types")
  internal static let linkTo = Loc.tr("Localizable", "Link to", fallback: "Link to")
  internal static func linksCount(_ p1: Int) -> String {
    return Loc.tr("Localizable", "Links count", p1, fallback: "Plural format key: \"%#@object@\"")
  }
  internal static let lists = Loc.tr("Localizable", "Lists", fallback: "Lists")
  internal static let loadingPleaseWait = Loc.tr("Localizable", "Loading, please wait", fallback: "Loading, please wait")
  internal static let localOnly = Loc.tr("Localizable", "Local Only", fallback: "Local Only")
  internal static let lock = Loc.tr("Localizable", "Lock", fallback: "Lock")
  internal static let logOut = Loc.tr("Localizable", "Log out", fallback: "Log out")
  internal static let logoutAndClearData = Loc.tr("Localizable", "Logout and clear data", fallback: "Logout and clear data")
  internal static let managePayment = Loc.tr("Localizable", "Manage payment", fallback: "Manage payment")
  internal static let media = Loc.tr("Localizable", "Media", fallback: "Media")
  internal static let members = Loc.tr("Localizable", "Members", fallback: "Members")
  internal static let membership = Loc.tr("Localizable", "Membership", fallback: "Membership")
  internal static func minXCharacters(_ p1: Any) -> String {
    return Loc.tr("Localizable", "Min X characters", String(describing: p1), fallback: "Min %@ characters")
  }
  internal static let misc = Loc.tr("Localizable", "Misc", fallback: "Misc")
  internal static let mode = Loc.tr("Localizable", "Mode", fallback: "Mode")
  internal static let moreInfo = Loc.tr("Localizable", "MoreInfo", fallback: "More info")
  internal static let move = Loc.tr("Localizable", "Move", fallback: "Move")
  internal static let moveTo = Loc.tr("Localizable", "Move to", fallback: "Move to")
  internal static let moveToBin = Loc.tr("Localizable", "Move To Bin", fallback: "Move To Bin")
  internal static let myChannels = Loc.tr("Localizable", "My Channels", fallback: "My Channels")
  internal static let myFirstSpace = Loc.tr("Localizable", "My First Space", fallback: "My First Space")
  internal static let myself = Loc.tr("Localizable", "Myself", fallback: "Myself")
  internal static let name = Loc.tr("Localizable", "Name", fallback: "Name")
  internal static let new = Loc.tr("Localizable", "New", fallback: "New")
  internal static let newField = Loc.tr("Localizable", "New field", fallback: "New property")
  internal static let newSet = Loc.tr("Localizable", "New set", fallback: "New query")
  internal static let next = Loc.tr("Localizable", "Next", fallback: "Next")
  internal static let noConnection = Loc.tr("Localizable", "No connection", fallback: "No connection")
  internal static let noDate = Loc.tr("Localizable", "No date", fallback: "No date")
  internal static let noItemsMatchFilter = Loc.tr("Localizable", "No items match filter", fallback: "No items match filter")
  internal static let noName = Loc.tr("Localizable", "No name", fallback: "No name")
  internal static let noRelatedOptionsHere = Loc.tr("Localizable", "No related options here", fallback: "No related options here. You can add some")
  internal static func noTypeFoundText(_ p1: Any) -> String {
    return Loc.tr("Localizable", "No type found text", String(describing: p1), fallback: "No type “%@” found. Change your request or create new type.")
  }
  internal static let nodeIsNotConnected = Loc.tr("Localizable", "Node is not connected", fallback: "Node is not connected")
  internal static let nonExistentObject = Loc.tr("Localizable", "Non-existent object", fallback: "Non-existent object")
  internal static let `none` = Loc.tr("Localizable", "None", fallback: "None")
  internal static let note = Loc.tr("Localizable", "Note", fallback: "Note")
  internal static let nothingFound = Loc.tr("Localizable", "Nothing found", fallback: "Nothing found")
  internal static let nothingToRedo = Loc.tr("Localizable", "Nothing to redo", fallback: "Nothing to redo")
  internal static let nothingToUndo = Loc.tr("Localizable", "Nothing to undo", fallback: "Nothing to undo")
  internal static func objectSelected(_ p1: Int) -> String {
    return Loc.tr("Localizable", "Object selected", p1, fallback: "Plural format key: \"%#@object@ selected\"")
  }
  internal static let objectTypes = Loc.tr("Localizable", "Object Types", fallback: "Object Types")
  internal static let objects = Loc.tr("Localizable", "Objects", fallback: "Objects")
  internal static let ok = Loc.tr("Localizable", "Ok", fallback: "Ok")
  internal static let okay = Loc.tr("Localizable", "Okay", fallback: "Okay")
  internal static let onAnalytics = Loc.tr("Localizable", "On analytics", fallback: "On analytics")
  internal static let openAsObject = Loc.tr("Localizable", "Open as Object", fallback: "Open as Object")
  internal static let openFile = Loc.tr("Localizable", "Open file", fallback: "Open file")
  internal static let openObject = Loc.tr("Localizable", "Open object", fallback: "Open object")
  internal static let openSet = Loc.tr("Localizable", "Open Set", fallback: "Open Query")
  internal static let openSource = Loc.tr("Localizable", "Open source", fallback: "Open source")
  internal static func openTypeError(_ p1: Any) -> String {
    return Loc.tr("Localizable", "Open Type Error", String(describing: p1), fallback: "Not supported type \"%@\". You can open it via desktop.")
  }
  internal static let other = Loc.tr("Localizable", "Other", fallback: "Other")
  internal static let otherRelations = Loc.tr("Localizable", "Other relations", fallback: "Other properties")
  internal static let p2PConnecting = Loc.tr("Localizable", "P2P Connecting", fallback: "P2P Connecting...")
  internal static let p2PConnection = Loc.tr("Localizable", "P2P Connection", fallback: "P2P Connection")
  internal static let pages = Loc.tr("Localizable", "Pages", fallback: "Pages")
  internal static func paidBy(_ p1: Any) -> String {
    return Loc.tr("Localizable", "Paid by", String(describing: p1), fallback: "Paid by %@")
  }
  internal static let paste = Loc.tr("Localizable", "Paste", fallback: "Paste")
  internal static let pasteOrTypeURL = Loc.tr("Localizable", "Paste or type URL", fallback: "Paste or type URL")
  internal static let pasteProcessing = Loc.tr("Localizable", "Paste processing...", fallback: "Paste processing...")
  internal static let payByCard = Loc.tr("Localizable", "Pay by Card", fallback: "Pay by Card")
  internal static let pending = Loc.tr("Localizable", "Pending", fallback: "Pending...")
  internal static let pendingDeletionText = Loc.tr("Localizable", "Pending deletion text", fallback: "We're sorry to see you go. You have 30 days to cancel this request. After 30 days, your encrypted vault data will be permanently removed from the backup node.")
  internal static let per = Loc.tr("Localizable", "per", fallback: "per")
  internal static func perDay(_ p1: Int) -> String {
    return Loc.tr("Localizable", "Per Day", p1, fallback: "Plural format key: \"per %#@day@\"")
  }
  internal static func perMonth(_ p1: Int) -> String {
    return Loc.tr("Localizable", "Per Month", p1, fallback: "Plural format key: \"per %#@month@\"")
  }
  internal static func perWeek(_ p1: Int) -> String {
    return Loc.tr("Localizable", "Per Week", p1, fallback: "Plural format key: \"per %#@week@\"")
  }
  internal static func perYear(_ p1: Int) -> String {
    return Loc.tr("Localizable", "Per Year", p1, fallback: "Plural format key: \"per %#@year@\"")
  }
  internal static let personalization = Loc.tr("Localizable", "Personalization", fallback: "Personalization")
  internal static let picture = Loc.tr("Localizable", "Picture", fallback: "Picture")
  internal static let pin = Loc.tr("Localizable", "Pin", fallback: "Pin")
  internal static let pinOnTop = Loc.tr("Localizable", "Pin on top", fallback: "Pin on top")
  internal static let pink = Loc.tr("Localizable", "Pink", fallback: "Pink")
  internal static let pinkBackground = Loc.tr("Localizable", "Pink background", fallback: "Pink background")
  internal static let pinned = Loc.tr("Localizable", "Pinned", fallback: "Pinned")
  internal static let preferences = Loc.tr("Localizable", "Preferences", fallback: "Preferences")
  internal static let preview = Loc.tr("Localizable", "Preview", fallback: "Preview")
  internal static let previewLayout = Loc.tr("Localizable", "Preview layout", fallback: "Preview layout")
  internal static let profile = Loc.tr("Localizable", "Profile", fallback: "Profile")
  internal static let progress = Loc.tr("Localizable", "Progress...", fallback: "Progress...")
  internal static let purple = Loc.tr("Localizable", "Purple", fallback: "Purple")
  internal static let purpleBackground = Loc.tr("Localizable", "Purple background", fallback: "Purple background")
  internal static let qrCode = Loc.tr("Localizable", "QR Code", fallback: "QR Code")
  internal static let random = Loc.tr("Localizable", "Random", fallback: "Random")
  internal static let recent = Loc.tr("Localizable", "Recent", fallback: "Recent")
  internal static let red = Loc.tr("Localizable", "Red", fallback: "Red")
  internal static let redBackground = Loc.tr("Localizable", "Red background", fallback: "Red background")
  internal static let redo = Loc.tr("Localizable", "Redo", fallback: "Redo")
  internal static let remove = Loc.tr("Localizable", "Remove", fallback: "Remove")
  internal static let removeFromFavorite = Loc.tr("Localizable", "Remove From Favorite", fallback: "Remove From Favorite")
  internal static let removePhoto = Loc.tr("Localizable", "Remove photo", fallback: "Remove photo")
  internal static let removingCache = Loc.tr("Localizable", "Removing cache", fallback: "Removing cache")
  internal static let resend = Loc.tr("Localizable", "Resend", fallback: "Resend")
  internal static func resendIn(_ p1: Any) -> String {
    return Loc.tr("Localizable", "Resend in", String(describing: p1), fallback: "Resend in %@ sec")
  }
  internal static let resetToDefault = Loc.tr("Localizable", "Reset to default", fallback: "Reset to default")
  internal static let resolveLayoutConflict = Loc.tr("Localizable", "Resolve layout conflict", fallback: "Resolve layout conflict")
  internal static let restore = Loc.tr("Localizable", "Restore", fallback: "Restore")
  internal static let restoreFromKeychain = Loc.tr("Localizable", "Restore from keychain", fallback: "Restore from keychain")
  internal static let restoreKeyFromKeychain = Loc.tr("Localizable", "Restore key from keychain", fallback: "Restore Key from the keychain")
  internal static let save = Loc.tr("Localizable", "Save", fallback: "Save")
  internal static let scanQRCode = Loc.tr("Localizable", "Scan QR code", fallback: "Scan QR code")
  internal static let search = Loc.tr("Localizable", "Search", fallback: "Search")
  internal static let searchForLanguage = Loc.tr("Localizable", "Search for language", fallback: "Search for language")
  internal static let selectAll = Loc.tr("Localizable", "Select all", fallback: "Select all")
  internal static let selectDate = Loc.tr("Localizable", "Select date", fallback: "Select date")
  internal static let selectFile = Loc.tr("Localizable", "Select file", fallback: "Select file")
  internal static let selectObject = Loc.tr("Localizable", "Select object", fallback: "Select object")
  internal static let selectOption = Loc.tr("Localizable", "Select option", fallback: "Select option")
  internal static let selectOptions = Loc.tr("Localizable", "Select options", fallback: "Select options")
  internal static let selectRelationType = Loc.tr("Localizable", "Select relation type", fallback: "Select property type")
  internal static let selectVaultError = Loc.tr("Localizable", "Select vault error", fallback: "Select vault error")
  internal static func selectedBlocks(_ p1: Int) -> String {
    return Loc.tr("Localizable", "Selected blocks", p1, fallback: "Plural format key: \"%#@object@\"")
  }
  internal static let selfHost = Loc.tr("Localizable", "Self Host", fallback: "Self Host")
  internal static let `set` = Loc.tr("Localizable", "Set", fallback: "Query")
  internal static let setAsDefault = Loc.tr("Localizable", "Set as default", fallback: "Set as default")
  internal static func setOf(_ p1: Any) -> String {
    return Loc.tr("Localizable", "Set of", String(describing: p1), fallback: "Query of %@")
  }
  internal static let sets = Loc.tr("Localizable", "Sets", fallback: "Queries")
  internal static let settingUpEncryptedStoragePleaseWait = Loc.tr("Localizable", "Setting up encrypted storage\nPlease wait", fallback: "Setting up encrypted storage\nPlease wait")
  internal static let settings = Loc.tr("Localizable", "Settings", fallback: "Settings")
  internal static let share = Loc.tr("Localizable", "Share", fallback: "Share")
  internal static let shared = Loc.tr("Localizable", "Shared", fallback: "Shared")
  internal static let show = Loc.tr("Localizable", "Show", fallback: "Show")
  internal static let showTypes = Loc.tr("Localizable", "Show types", fallback: "Show types")
  internal static let sky = Loc.tr("Localizable", "Sky", fallback: "Sky")
  internal static let skyBackground = Loc.tr("Localizable", "Sky background", fallback: "Sky background")
  internal static let solidColors = Loc.tr("Localizable", "Solid colors", fallback: "Solid colors")
  internal static let sort = Loc.tr("Localizable", "Sort", fallback: "Sort")
  internal static let standardLayoutForCanvasBlocks = Loc.tr("Localizable", "Standard layout for canvas blocks", fallback: "Standard layout for canvas blocks")
  internal static let start = Loc.tr("Localizable", "Start", fallback: "Start")
  internal static let style = Loc.tr("Localizable", "Style", fallback: "Style")
  internal static let submit = Loc.tr("Localizable", "Submit", fallback: "Submit")
  internal static let synced = Loc.tr("Localizable", "Synced", fallback: "Synced")
  internal static let task = Loc.tr("Localizable", "Task", fallback: "Task")
  internal static let teal = Loc.tr("Localizable", "Teal", fallback: "Teal")
  internal static let tealBackground = Loc.tr("Localizable", "Teal background", fallback: "Teal background")
  internal static let templates = Loc.tr("Localizable", "Templates", fallback: "Templates")
  internal static let thereIsNoEmojiNamed = Loc.tr("Localizable", "There is no emoji named", fallback: "There is no emoji named")
  internal static let thereIsNoIconNamed = Loc.tr("Localizable", "There is no icon named", fallback: "There is no icon named")
  internal static func thereIsNoObjectNamed(_ p1: Any) -> String {
    return Loc.tr("Localizable", "There is no object named", String(describing: p1), fallback: "There is no object named %@")
  }
  internal static func thereIsNoTypeNamed(_ p1: Any) -> String {
    return Loc.tr("Localizable", "There is no type named", String(describing: p1), fallback: "There is no type named %@")
  }
  internal static let theseObjectsWillBeDeletedIrrevocably = Loc.tr("Localizable", "These objects will be deleted irrevocably", fallback: "These objects will be deleted irrevocably. You can’t undo this action.")
  internal static let thisObjectDoesnTExist = Loc.tr("Localizable", "This object doesn't exist", fallback: "This object doesn't exist")
  internal static let toBin = Loc.tr("Localizable", "To Bin", fallback: "To Bin")
  internal static let today = Loc.tr("Localizable", "Today", fallback: "Today")
  internal static let tomorrow = Loc.tr("Localizable", "Tomorrow", fallback: "Tomorrow")
  internal static let tryToFindANewOne = Loc.tr("Localizable", "Try to find a new one", fallback: "Try to find a new one")
  internal static let tryToFindANewOneOrUploadYourImage = Loc.tr("Localizable", "Try to find a new one or upload your image", fallback: "Try to find a new one or upload your image")
  internal static let type = Loc.tr("Localizable", "Type", fallback: "Type")
  internal static let types = Loc.tr("Localizable", "Types", fallback: "Types")
  internal static let undo = Loc.tr("Localizable", "Undo", fallback: "Undo")
  internal static let undoTyping = Loc.tr("Localizable", "Undo typing", fallback: "Undo typing")
  internal static let undoRedo = Loc.tr("Localizable", "Undo/Redo", fallback: "Undo/Redo")
  internal static let unfavorite = Loc.tr("Localizable", "Unfavorite", fallback: "Unfavorite")
  internal static let unknown = Loc.tr("Localizable", "Unknown", fallback: "Unknown")
  internal static let unknownError = Loc.tr("Localizable", "Unknown error", fallback: "Unknown error")
  internal static let unlimited = Loc.tr("Localizable", "unlimited", fallback: "Unlimited")
  internal static let unlock = Loc.tr("Localizable", "Unlock", fallback: "Unlock")
  internal static let unpin = Loc.tr("Localizable", "Unpin", fallback: "Unpin")
  internal static let unselectAll = Loc.tr("Localizable", "Unselect all", fallback: "Unselect all")
  internal static let unsplash = Loc.tr("Localizable", "Unsplash", fallback: "Unsplash")
  internal static let unsupported = Loc.tr("Localizable", "Unsupported", fallback: "Unsupported")
  internal static let unsupportedBlock = Loc.tr("Localizable", "Unsupported block", fallback: "Unsupported block")
  internal static let unsupportedDeeplink = Loc.tr("Localizable", "Unsupported deeplink", fallback: "Unsupported deeplink")
  internal static let unsupportedValue = Loc.tr("Localizable", "Unsupported value", fallback: "Unsupported value")
  internal static let untitled = Loc.tr("Localizable", "Untitled", fallback: "Untitled")
  internal static let upgrade = Loc.tr("Localizable", "Upgrade", fallback: "Upgrade")
  internal static let upload = Loc.tr("Localizable", "Upload", fallback: "Upload")
  internal static let uploadPlayableAudio = Loc.tr("Localizable", "Upload playable audio", fallback: "Upload playable audio")
  internal static let validUntil = Loc.tr("Localizable", "Valid until", fallback: "Valid until:")
  internal static func validUntilDate(_ p1: Any) -> String {
    return Loc.tr("Localizable", "Valid until date", String(describing: p1), fallback: "Valid until %@")
  }
  internal static let vault = Loc.tr("Localizable", "Vault", fallback: "Vault")
  internal static let vaultDeleted = Loc.tr("Localizable", "Vault deleted", fallback: "Vault deleted")
  internal static let vaultRecoverError = Loc.tr("Localizable", "Vault recover error", fallback: "Vault recover error, try again")
  internal static let vaultRecoverErrorNoInternet = Loc.tr("Localizable", "Vault recover error no internet", fallback: "Vault recover error, probably no internet connection")
  internal static let video = Loc.tr("Localizable", "Video", fallback: "Video")
  internal static let videoBlockSubtitle = Loc.tr("Localizable", "Video block subtitle", fallback: "Upload playable video")
  internal static let view = Loc.tr("Localizable", "View", fallback: "View")
  internal static let views = Loc.tr("Localizable", "Views", fallback: "Views")
  internal static let wallpaper = Loc.tr("Localizable", "Wallpaper", fallback: "Wallpaper")
  internal static let webPages = Loc.tr("Localizable", "Web pages", fallback: "Web pages")
  internal static let whatSIncluded = Loc.tr("Localizable", "What’s included", fallback: "What’s included")
  internal static let yellow = Loc.tr("Localizable", "Yellow", fallback: "Yellow")
  internal static let yellowBackground = Loc.tr("Localizable", "Yellow background", fallback: "Yellow background")
  internal static let yesterday = Loc.tr("Localizable", "Yesterday", fallback: "Yesterday")
  internal static let yourCurrentStatus = Loc.tr("Localizable", "Your current status", fallback: "Your current status:")
  internal enum About {
    internal static func analyticsId(_ p1: Any) -> String {
      return Loc.tr("Localizable", "About.analyticsId", String(describing: p1), fallback: "Analytics ID: %@")
    }
    internal static let anytypeCommunity = Loc.tr("Localizable", "About.AnytypeCommunity", fallback: "Anytype Community")
    internal static func anytypeId(_ p1: Any) -> String {
      return Loc.tr("Localizable", "About.anytypeId", String(describing: p1), fallback: "Anytype ID: %@")
    }
    internal static func appVersion(_ p1: Any) -> String {
      return Loc.tr("Localizable", "About.AppVersion", String(describing: p1), fallback: "App version: %@")
    }
    internal static func buildNumber(_ p1: Any) -> String {
      return Loc.tr("Localizable", "About.BuildNumber", String(describing: p1), fallback: "Build number: %@")
    }
    internal static let contactUs = Loc.tr("Localizable", "About.ContactUs", fallback: "Contact Us")
    internal static func device(_ p1: Any) -> String {
      return Loc.tr("Localizable", "About.Device", String(describing: p1), fallback: "Device: %@")
    }
    internal static func deviceId(_ p1: Any) -> String {
      return Loc.tr("Localizable", "About.deviceId", String(describing: p1), fallback: "Device ID: %@")
    }
    internal static let helpCommunity = Loc.tr("Localizable", "About.HelpCommunity", fallback: "Help & Community")
    internal static let helpTutorials = Loc.tr("Localizable", "About.HelpTutorials", fallback: "Help & Tutorials")
    internal static let legal = Loc.tr("Localizable", "About.Legal", fallback: "Legal")
    internal static func library(_ p1: Any) -> String {
      return Loc.tr("Localizable", "About.Library", String(describing: p1), fallback: "Library version: %@")
    }
    internal static func osVersion(_ p1: Any) -> String {
      return Loc.tr("Localizable", "About.OSVersion", String(describing: p1), fallback: "OS version: %@")
    }
    internal static let privacyPolicy = Loc.tr("Localizable", "About.PrivacyPolicy", fallback: "Privacy Policy")
    internal static let techInfo = Loc.tr("Localizable", "About.TechInfo", fallback: "Tech Info")
    internal static let termsOfUse = Loc.tr("Localizable", "About.TermsOfUse", fallback: "Terms of Use")
    internal static let whatsNew = Loc.tr("Localizable", "About.WhatsNew", fallback: "What’s New")
    internal enum Mail {
      internal static func body(_ p1: Any) -> String {
        return Loc.tr("Localizable", "About.Mail.Body", String(describing: p1), fallback: "\n\nTechnical information\n%@")
      }
      internal static func subject(_ p1: Any) -> String {
        return Loc.tr("Localizable", "About.Mail.Subject", String(describing: p1), fallback: "Support request, Vault ID %@")
      }
    }
  }
  internal enum Actions {
    internal static let copyLink = Loc.tr("Localizable", "Actions.CopyLink", fallback: "Copy link")
    internal static let linkItself = Loc.tr("Localizable", "Actions.LinkItself", fallback: "Link to")
    internal static let makeAsTemplate = Loc.tr("Localizable", "Actions.MakeAsTemplate", fallback: "Make template")
    internal static let templateMakeDefault = Loc.tr("Localizable", "Actions.TemplateMakeDefault", fallback: "Make default")
    internal enum CreateWidget {
      internal static let success = Loc.tr("Localizable", "Actions.CreateWidget.Success", fallback: "New widget was created")
      internal static let title = Loc.tr("Localizable", "Actions.CreateWidget.Title", fallback: "To widgets")
    }
  }
  internal enum Alert {
    internal enum CameraPermissions {
      internal static let goToSettings = Loc.tr("Localizable", "Alert.CameraPermissions.GoToSettings", fallback: "Anytype needs access to your camera to scan QR codes.\n\nPlease, go to your device's Settings -> Anytype and set Camera to ON")
      internal static let settings = Loc.tr("Localizable", "Alert.CameraPermissions.Settings", fallback: "Settings")
    }
  }
  internal enum AllContent {
    internal enum Search {
      internal enum Empty {
        internal enum State {
          internal static let subtitle = Loc.tr("Localizable", "AllContent.Search.Empty.State.subtitle", fallback: "Try searching with different keywords.")
          internal static let title = Loc.tr("Localizable", "AllContent.Search.Empty.State.title", fallback: "No results found.")
        }
      }
    }
    internal enum Settings {
      internal static let viewBin = Loc.tr("Localizable", "AllContent.Settings.ViewBin", fallback: "View Bin")
      internal enum Sort {
        internal static let title = Loc.tr("Localizable", "AllContent.Settings.Sort.Title", fallback: "Sort by")
      }
      internal enum Unlinked {
        internal static let description = Loc.tr("Localizable", "AllContent.Settings.Unlinked.Description", fallback: "Unlinked objects that do not have a direct link or backlink with other objects in the graph.")
        internal static let title = Loc.tr("Localizable", "AllContent.Settings.Unlinked.Title", fallback: "Only unlinked")
      }
    }
    internal enum Sort {
      internal static let dateCreated = Loc.tr("Localizable", "AllContent.Sort.DateCreated", fallback: "Date created")
      internal static let dateUpdated = Loc.tr("Localizable", "AllContent.Sort.DateUpdated", fallback: "Date updated")
      internal enum Date {
        internal static let asc = Loc.tr("Localizable", "AllContent.Sort.Date.Asc", fallback: "Oldest first")
        internal static let desc = Loc.tr("Localizable", "AllContent.Sort.Date.Desc", fallback: "Newest first")
      }
      internal enum Name {
        internal static let asc = Loc.tr("Localizable", "AllContent.Sort.Name.Asc", fallback: "A → Z")
        internal static let desc = Loc.tr("Localizable", "AllContent.Sort.Name.Desc", fallback: "Z → A")
      }
    }
  }
  internal enum AnyApp {
    internal enum BetaAlert {
      internal static let description = Loc.tr("Localizable", "AnyApp.BetaAlert.Description", fallback: "You’re ahead of the curve! Some features are still in development or not production-ready – stay tuned for updates.")
      internal static let title = Loc.tr("Localizable", "AnyApp.BetaAlert.Title", fallback: "Welcome to the Alpha version")
    }
  }
  internal enum Auth {
    internal static let cameraPermissionTitle = Loc.tr("Localizable", "Auth.CameraPermissionTitle", fallback: "Please allow access")
    internal static let logIn = Loc.tr("Localizable", "Auth.LogIn", fallback: "I already have the key")
    internal static let next = Loc.tr("Localizable", "Auth.Next", fallback: "Next")
    internal enum Button {
      internal static let join = Loc.tr("Localizable", "Auth.Button.Join", fallback: "I am new here")
    }
    internal enum JoinFlow {
      internal enum Key {
        internal static let description = Loc.tr("Localizable", "Auth.JoinFlow.Key.Description", fallback: "It gives you full ownership over your data and conversations. You can find this key later in app settings.")
        internal static let title = Loc.tr("Localizable", "Auth.JoinFlow.Key.Title", fallback: "This is your Key")
        internal enum Button {
          internal enum Copy {
            internal static let title = Loc.tr("Localizable", "Auth.JoinFlow.Key.Button.Copy.Title", fallback: "Copy to clipboard")
          }
          internal enum Info {
            internal static let title = Loc.tr("Localizable", "Auth.JoinFlow.Key.Button.Info.Title", fallback: "Read more about Key")
          }
          internal enum Later {
            internal static let title = Loc.tr("Localizable", "Auth.JoinFlow.Key.Button.Later.Title", fallback: "Not now")
          }
          internal enum Saved {
            internal static let title = Loc.tr("Localizable", "Auth.JoinFlow.Key.Button.Saved.Title", fallback: "Next")
          }
          internal enum Show {
            internal static let title = Loc.tr("Localizable", "Auth.JoinFlow.Key.Button.Show.Title", fallback: "Tap to Reveal")
          }
        }
        internal enum ReadMore {
          internal static let title = Loc.tr("Localizable", "Auth.JoinFlow.Key.ReadMore.Title", fallback: "What is the Key?")
          internal enum Instruction {
            internal static let title = Loc.tr("Localizable", "Auth.JoinFlow.Key.ReadMore.Instruction.Title", fallback: "How to save my key?")
            internal enum Option1 {
              internal static let title = Loc.tr("Localizable", "Auth.JoinFlow.Key.ReadMore.Instruction.Option1.Title", fallback: "The easiest way to store your key is to save it in your password manager.")
            }
            internal enum Option2 {
              internal static let title = Loc.tr("Localizable", "Auth.JoinFlow.Key.ReadMore.Instruction.Option2.Title", fallback: "The most secure way is to write it down on paper and keep it offline, in a safe and secure place.")
            }
          }
          internal enum Option1 {
            internal static let title = Loc.tr("Localizable", "Auth.JoinFlow.Key.ReadMore.Option1.Title", fallback: "It is represented by a recovery phrase – 12 random words from which your vault is magically generated on this device.")
          }
          internal enum Option2 {
            internal static let title = Loc.tr("Localizable", "Auth.JoinFlow.Key.ReadMore.Option2.Title", fallback: "Whomever knows the combination of these words owns your vault. **Right now, you are the only person in the world who knows it.**")
          }
          internal enum Option3 {
            internal static let title = Loc.tr("Localizable", "Auth.JoinFlow.Key.ReadMore.Option3.Title", fallback: "All computational resources on Earth are not enough to break in. If you lose it, it cannot be recovered. So, store it somewhere safe!")
          }
        }
      }
      internal enum Soul {
        internal static let button = Loc.tr("Localizable", "Auth.JoinFlow.Soul.Button", fallback: "Done")
        internal static let description = Loc.tr("Localizable", "Auth.JoinFlow.Soul.Description", fallback: "Only seen by people you share something with. There is no central registry of these names.")
        internal static let placeholder = Loc.tr("Localizable", "Auth.JoinFlow.Soul.Placeholder", fallback: "Name")
        internal static let title = Loc.tr("Localizable", "Auth.JoinFlow.Soul.Title", fallback: "Set your name")
      }
    }
    internal enum LoginFlow {
      internal static let or = Loc.tr("Localizable", "Auth.LoginFlow.Or", fallback: "OR")
      internal enum Enter {
        internal static let title = Loc.tr("Localizable", "Auth.LoginFlow.Enter.Title", fallback: "Enter my Vault")
      }
      internal enum Entering {
        internal enum Void {
          internal static let title = Loc.tr("Localizable", "Auth.LoginFlow.Entering.Void.Title", fallback: "Entering the Void")
        }
      }
      internal enum Textfield {
        internal static let placeholder = Loc.tr("Localizable", "Auth.LoginFlow.Textfield.Placeholder", fallback: "Type your key")
      }
      internal enum Use {
        internal enum Keychain {
          internal static let title = Loc.tr("Localizable", "Auth.LoginFlow.Use.Keychain.Title", fallback: "Use keychain")
        }
      }
    }
    internal enum Welcome {
      internal static func subtitle(_ p1: Any) -> String {
        return Loc.tr("Localizable", "Auth.Welcome.Subtitle", String(describing: p1), fallback: "Create & collaborate in spaces you own. Encrypted, offline & [open](%@).")
      }
    }
  }
  internal enum BlockLink {
    internal enum PreviewSettings {
      internal enum IconSize {
        internal static let medium = Loc.tr("Localizable", "BlockLink.PreviewSettings.IconSize.Medium", fallback: "Medium")
        internal static let `none` = Loc.tr("Localizable", "BlockLink.PreviewSettings.IconSize.None", fallback: "None")
        internal static let small = Loc.tr("Localizable", "BlockLink.PreviewSettings.IconSize.Small", fallback: "Small")
      }
      internal enum Layout {
        internal enum Card {
          internal static let title = Loc.tr("Localizable", "BlockLink.PreviewSettings.Layout.Card.Title", fallback: "Card")
        }
        internal enum Text {
          internal static let title = Loc.tr("Localizable", "BlockLink.PreviewSettings.Layout.Text.Title", fallback: "Text")
        }
      }
    }
  }
  internal enum BlockText {
    internal enum ContentType {
      internal enum Bulleted {
        internal static let placeholder = Loc.tr("Localizable", "BlockText.ContentType.Bulleted.Placeholder", fallback: "Bulleted list item")
      }
      internal enum Checkbox {
        internal static let placeholder = Loc.tr("Localizable", "BlockText.ContentType.Checkbox.Placeholder", fallback: "Checkbox")
      }
      internal enum Description {
        internal static let placeholder = Loc.tr("Localizable", "BlockText.ContentType.Description.Placeholder", fallback: "Add a description")
      }
      internal enum Header {
        internal static let placeholder = Loc.tr("Localizable", "BlockText.ContentType.Header.Placeholder", fallback: "Title")
      }
      internal enum Header2 {
        internal static let placeholder = Loc.tr("Localizable", "BlockText.ContentType.Header2.Placeholder", fallback: "Heading")
      }
      internal enum Header3 {
        internal static let placeholder = Loc.tr("Localizable", "BlockText.ContentType.Header3.Placeholder", fallback: "Subheading")
      }
      internal enum Numbered {
        internal static let placeholder = Loc.tr("Localizable", "BlockText.ContentType.Numbered.Placeholder", fallback: "Numbered list item")
      }
      internal enum Quote {
        internal static let placeholder = Loc.tr("Localizable", "BlockText.ContentType.Quote.Placeholder", fallback: "Highlighted text")
      }
      internal enum Title {
        internal static let placeholder = Loc.tr("Localizable", "BlockText.ContentType.Title.Placeholder", fallback: "Untitled")
      }
      internal enum Toggle {
        internal static let placeholder = Loc.tr("Localizable", "BlockText.ContentType.Toggle.Placeholder", fallback: "Toggle block")
      }
    }
  }
  internal enum Chat {
    internal static let editMessage = Loc.tr("Localizable", "Chat.EditMessage", fallback: "Edit Message")
    internal static let newMessages = Loc.tr("Localizable", "Chat.NewMessages", fallback: "New messages")
    internal static func replyTo(_ p1: Any) -> String {
      return Loc.tr("Localizable", "Chat.ReplyTo", String(describing: p1), fallback: "Reply to %@")
    }
    internal enum Actions {
      internal enum Menu {
        internal static let camera = Loc.tr("Localizable", "Chat.Actions.Menu.Camera", fallback: "Camera")
        internal static let files = Loc.tr("Localizable", "Chat.Actions.Menu.Files", fallback: "Files")
        internal static let lists = Loc.tr("Localizable", "Chat.Actions.Menu.Lists", fallback: "Lists")
        internal static let more = Loc.tr("Localizable", "Chat.Actions.Menu.More", fallback: "More")
        internal static let pages = Loc.tr("Localizable", "Chat.Actions.Menu.Pages", fallback: "Pages")
        internal static let photos = Loc.tr("Localizable", "Chat.Actions.Menu.Photos", fallback: "Photos")
      }
    }
    internal enum Attach {
      internal enum List {
        internal static let title = Loc.tr("Localizable", "Chat.Attach.List.title", fallback: "Attach List")
      }
      internal enum Page {
        internal static let title = Loc.tr("Localizable", "Chat.Attach.Page.title", fallback: "Attach Page")
      }
    }
    internal enum AttachedObject {
      internal static let attach = Loc.tr("Localizable", "Chat.AttachedObject.Attach", fallback: "Attach")
    }
    internal enum AttachmentsLimit {
      internal static func alert(_ p1: Any) -> String {
        return Loc.tr("Localizable", "Chat.AttachmentsLimit.Alert", String(describing: p1), fallback: "You can upload only %@ attachments at a time")
      }
    }
    internal enum CreateObject {
      internal enum Dismiss {
        internal static let message = Loc.tr("Localizable", "Chat.CreateObject.Dismiss.Message", fallback: "If you leave it, all your changes will be lost.")
        internal static let ok = Loc.tr("Localizable", "Chat.CreateObject.Dismiss.Ok", fallback: "Yes, close")
        internal static let title = Loc.tr("Localizable", "Chat.CreateObject.Dismiss.Title", fallback: "Are you sure you want to close this screen?")
      }
    }
    internal enum DeleteMessage {
      internal static let description = Loc.tr("Localizable", "Chat.DeleteMessage.Description", fallback: "It cannot be restored after confirmation")
      internal static let title = Loc.tr("Localizable", "Chat.DeleteMessage.Title", fallback: "Delete this message?")
    }
    internal enum Empty {
      internal static let description = Loc.tr("Localizable", "Chat.Empty.Description", fallback: "Write a first one to start a conversation")
      internal static let title = Loc.tr("Localizable", "Chat.Empty.Title", fallback: "No messages here yet...")
    }
    internal enum Participant {
      internal static let badge = Loc.tr("Localizable", "Chat.Participant.Badge", fallback: "(You)")
    }
    internal enum Reactions {
      internal enum Empty {
        internal static let subtitle = Loc.tr("Localizable", "Chat.Reactions.Empty.Subtitle", fallback: "Probably someone has just removed the reaction or technical issue happened")
        internal static let title = Loc.tr("Localizable", "Chat.Reactions.Empty.Title", fallback: "No reactions yet")
      }
    }
    internal enum Reply {
      internal static func attachments(_ p1: Any) -> String {
        return Loc.tr("Localizable", "Chat.Reply.Attachments", String(describing: p1), fallback: "Attachments (%@)")
      }
      internal static func files(_ p1: Any) -> String {
        return Loc.tr("Localizable", "Chat.Reply.Files", String(describing: p1), fallback: "Files (%@)")
      }
      internal static func images(_ p1: Any) -> String {
        return Loc.tr("Localizable", "Chat.Reply.Images", String(describing: p1), fallback: "Images (%@)")
      }
    }
    internal enum SendLimitAlert {
      internal static let message = Loc.tr("Localizable", "Chat.SendLimitAlert.Message", fallback: "Looks like you're sending messages at lightning speed. Give it a sec before your next one.")
      internal static let title = Loc.tr("Localizable", "Chat.SendLimitAlert.Title", fallback: "Hold up! Turbo typing detected!")
    }
  }
  internal enum ClearCache {
    internal static let error = Loc.tr("Localizable", "ClearCache.Error", fallback: "Error, try again later")
    internal static let success = Loc.tr("Localizable", "ClearCache.Success", fallback: "Cache sucessfully cleared")
  }
  internal enum ClearCacheAlert {
    internal static let description = Loc.tr("Localizable", "ClearCacheAlert.Description", fallback: "All media files stored in Anytype will be deleted from your current device. They can be downloaded again from a backup node or another device.")
    internal static let title = Loc.tr("Localizable", "ClearCacheAlert.Title", fallback: "Are you sure?")
  }
  internal enum Collection {
    internal enum View {
      internal enum Empty {
        internal static let subtitle = Loc.tr("Localizable", "Collection.View.Empty.Subtitle", fallback: "Create first object to continue")
        internal static let title = Loc.tr("Localizable", "Collection.View.Empty.Title", fallback: "No objects")
        internal enum Button {
          internal static let title = Loc.tr("Localizable", "Collection.View.Empty.Button.Title", fallback: "Create object")
        }
      }
    }
  }
  internal enum CommonOpenErrorView {
    internal static let message = Loc.tr("Localizable", "CommonOpenErrorView.Message", fallback: "No data found")
  }
  internal enum Content {
    internal enum Audio {
      internal static let upload = Loc.tr("Localizable", "Content.Audio.Upload", fallback: "Upload audio")
    }
    internal enum Bookmark {
      internal static let add = Loc.tr("Localizable", "Content.Bookmark.Add", fallback: "Add a web bookmark")
      internal static let loading = Loc.tr("Localizable", "Content.Bookmark.Loading", fallback: "Loading, please wait...")
    }
    internal enum Common {
      internal static let error = Loc.tr("Localizable", "Content.Common.Error", fallback: "Something went wrong, try again")
      internal static let uploading = Loc.tr("Localizable", "Content.Common.Uploading", fallback: "Uploading...")
    }
    internal enum DataView {
      internal enum InlineCollection {
        internal static let subtitle = Loc.tr("Localizable", "Content.DataView.InlineCollection.Subtitle", fallback: "Inline collection")
        internal static let untitled = Loc.tr("Localizable", "Content.DataView.InlineCollection.Untitled", fallback: "Untitled collection")
      }
      internal enum InlineSet {
        internal static let noData = Loc.tr("Localizable", "Content.DataView.InlineSet.NoData", fallback: "No data")
        internal static let noSource = Loc.tr("Localizable", "Content.DataView.InlineSet.NoSource", fallback: "No source")
        internal static let subtitle = Loc.tr("Localizable", "Content.DataView.InlineSet.Subtitle", fallback: "Inline query")
        internal static let untitled = Loc.tr("Localizable", "Content.DataView.InlineSet.Untitled", fallback: "Untitled query")
        internal enum Toast {
          internal static let failure = Loc.tr("Localizable", "Content.DataView.InlineSet.Toast.Failure", fallback: "This inline query doesn’t have a source")
        }
      }
    }
    internal enum File {
      internal static let upload = Loc.tr("Localizable", "Content.File.Upload", fallback: "Upload a file")
    }
    internal enum Picture {
      internal static let upload = Loc.tr("Localizable", "Content.Picture.Upload", fallback: "Upload a picture")
    }
    internal enum Video {
      internal static let upload = Loc.tr("Localizable", "Content.Video.Upload", fallback: "Upload a video")
    }
  }
  internal enum DataviewType {
    internal static let calendar = Loc.tr("Localizable", "DataviewType.calendar", fallback: "Calendar")
    internal static let gallery = Loc.tr("Localizable", "DataviewType.gallery", fallback: "Gallery")
    internal static let graph = Loc.tr("Localizable", "DataviewType.graph", fallback: "Graph")
    internal static let grid = Loc.tr("Localizable", "DataviewType.grid", fallback: "Grid")
    internal static let kanban = Loc.tr("Localizable", "DataviewType.kanban", fallback: "Kanban")
    internal static let list = Loc.tr("Localizable", "DataviewType.list", fallback: "List")
  }
  internal enum Date {
    internal enum Object {
      internal enum Empty {
        internal enum State {
          internal static let title = Loc.tr("Localizable", "Date.Object.Empty.State.title", fallback: "There is nothing here for this date yet")
        }
      }
    }
    internal enum Open {
      internal enum Action {
        internal static let title = Loc.tr("Localizable", "Date.Open.Action.title", fallback: "Open selected date")
      }
    }
  }
  internal enum Debug {
    internal static let info = Loc.tr("Localizable", "Debug.Info", fallback: "Debug Info")
    internal static func mimeTypes(_ p1: Any) -> String {
      return Loc.tr("Localizable", "Debug.MimeTypes", String(describing: p1), fallback: "Mime Types - %@")
    }
  }
  internal enum DebugMenu {
    internal static func toggleAuthor(_ p1: Any, _ p2: Any) -> String {
      return Loc.tr("Localizable", "DebugMenu.ToggleAuthor", String(describing: p1), String(describing: p2), fallback: "Release: %@, %@")
    }
  }
  internal enum DeletionAlert {
    internal static let description = Loc.tr("Localizable", "DeletionAlert.description", fallback: "You will be logged out on all other devices. You'll have 30 days to recover your vault. Afterwards, it will be deleted permanently.")
    internal static let title = Loc.tr("Localizable", "DeletionAlert.title", fallback: "Are you sure you want to delete your vault?")
  }
  internal enum EditSet {
    internal enum Popup {
      internal enum Filter {
        internal enum Condition {
          internal enum Checkbox {
            internal static let equal = Loc.tr("Localizable", "EditSet.Popup.Filter.Condition.Checkbox.Equal", fallback: "Is")
            internal static let notEqual = Loc.tr("Localizable", "EditSet.Popup.Filter.Condition.Checkbox.NotEqual", fallback: "Is not")
          }
          internal enum Date {
            internal static let after = Loc.tr("Localizable", "EditSet.Popup.Filter.Condition.Date.After", fallback: "Is after")
            internal static let before = Loc.tr("Localizable", "EditSet.Popup.Filter.Condition.Date.Before", fallback: "Is before")
            internal static let equal = Loc.tr("Localizable", "EditSet.Popup.Filter.Condition.Date.Equal", fallback: "Is")
            internal static let `in` = Loc.tr("Localizable", "EditSet.Popup.Filter.Condition.Date.In", fallback: "Is within")
            internal static let onOrAfter = Loc.tr("Localizable", "EditSet.Popup.Filter.Condition.Date.OnOrAfter", fallback: "Is on or after")
            internal static let onOrBefore = Loc.tr("Localizable", "EditSet.Popup.Filter.Condition.Date.OnOrBefore", fallback: "Is on or before")
          }
          internal enum General {
            internal static let empty = Loc.tr("Localizable", "EditSet.Popup.Filter.Condition.General.Empty", fallback: "Is empty")
            internal static let `none` = Loc.tr("Localizable", "EditSet.Popup.Filter.Condition.General.None", fallback: "All")
            internal static let notEmpty = Loc.tr("Localizable", "EditSet.Popup.Filter.Condition.General.NotEmpty", fallback: "Is not empty")
          }
          internal enum Number {
            internal static let equal = Loc.tr("Localizable", "EditSet.Popup.Filter.Condition.Number.Equal", fallback: "Is equal to")
            internal static let greater = Loc.tr("Localizable", "EditSet.Popup.Filter.Condition.Number.Greater", fallback: "Is greater than")
            internal static let greaterOrEqual = Loc.tr("Localizable", "EditSet.Popup.Filter.Condition.Number.GreaterOrEqual", fallback: "Is greater than or equal to")
            internal static let less = Loc.tr("Localizable", "EditSet.Popup.Filter.Condition.Number.Less", fallback: "Is less than")
            internal static let lessOrEqual = Loc.tr("Localizable", "EditSet.Popup.Filter.Condition.Number.LessOrEqual", fallback: "Is less than or equal to")
            internal static let notEqual = Loc.tr("Localizable", "EditSet.Popup.Filter.Condition.Number.NotEqual", fallback: "Is not equal to")
          }
          internal enum Selected {
            internal static let allIn = Loc.tr("Localizable", "EditSet.Popup.Filter.Condition.Selected.AllIn", fallback: "Has all of")
            internal static let equal = Loc.tr("Localizable", "EditSet.Popup.Filter.Condition.Selected.Equal", fallback: "Is exactly")
            internal static let `in` = Loc.tr("Localizable", "EditSet.Popup.Filter.Condition.Selected.In", fallback: "Has any of")
            internal static let notIn = Loc.tr("Localizable", "EditSet.Popup.Filter.Condition.Selected.NotIn", fallback: "Has none of")
          }
          internal enum Text {
            internal static let equal = Loc.tr("Localizable", "EditSet.Popup.Filter.Condition.Text.Equal", fallback: "Is")
            internal static let like = Loc.tr("Localizable", "EditSet.Popup.Filter.Condition.Text.Like", fallback: "Contains")
            internal static let notEqual = Loc.tr("Localizable", "EditSet.Popup.Filter.Condition.Text.NotEqual", fallback: "Is not")
            internal static let notLike = Loc.tr("Localizable", "EditSet.Popup.Filter.Condition.Text.NotLike", fallback: "Doesn't contain")
          }
        }
        internal enum Date {
          internal enum Option {
            internal static let currentMonth = Loc.tr("Localizable", "EditSet.Popup.Filter.Date.Option.CurrentMonth", fallback: "Current month")
            internal static let currentWeek = Loc.tr("Localizable", "EditSet.Popup.Filter.Date.Option.CurrentWeek", fallback: "Current week")
            internal static let exactDate = Loc.tr("Localizable", "EditSet.Popup.Filter.Date.Option.ExactDate", fallback: "Exact date")
            internal static let lastMonth = Loc.tr("Localizable", "EditSet.Popup.Filter.Date.Option.LastMonth", fallback: "Last month")
            internal static let lastWeek = Loc.tr("Localizable", "EditSet.Popup.Filter.Date.Option.LastWeek", fallback: "Last week")
            internal static let nextMonth = Loc.tr("Localizable", "EditSet.Popup.Filter.Date.Option.NextMonth", fallback: "Next month")
            internal static let nextWeek = Loc.tr("Localizable", "EditSet.Popup.Filter.Date.Option.NextWeek", fallback: "Next week")
            internal static let numberOfDaysAgo = Loc.tr("Localizable", "EditSet.Popup.Filter.Date.Option.NumberOfDaysAgo", fallback: "Number of days ago")
            internal static let numberOfDaysFromNow = Loc.tr("Localizable", "EditSet.Popup.Filter.Date.Option.NumberOfDaysFromNow", fallback: "Number of days from now")
            internal static let today = Loc.tr("Localizable", "EditSet.Popup.Filter.Date.Option.Today", fallback: "Today")
            internal static let tomorrow = Loc.tr("Localizable", "EditSet.Popup.Filter.Date.Option.Tomorrow", fallback: "Tomorrow")
            internal static let yesterday = Loc.tr("Localizable", "EditSet.Popup.Filter.Date.Option.Yesterday", fallback: "Yesterday")
            internal enum NumberOfDaysAgo {
              internal static func short(_ p1: Any) -> String {
                return Loc.tr("Localizable", "EditSet.Popup.Filter.Date.Option.NumberOfDaysAgo.Short", String(describing: p1), fallback: "%@ days ago")
              }
            }
            internal enum NumberOfDaysFromNow {
              internal static func short(_ p1: Any) -> String {
                return Loc.tr("Localizable", "EditSet.Popup.Filter.Date.Option.NumberOfDaysFromNow.Short", String(describing: p1), fallback: "%@ days from now")
              }
            }
          }
        }
        internal enum Value {
          internal static let checked = Loc.tr("Localizable", "EditSet.Popup.Filter.Value.Checked", fallback: "Checked")
          internal static let unchecked = Loc.tr("Localizable", "EditSet.Popup.Filter.Value.Unchecked", fallback: "Unchecked")
        }
      }
      internal enum Filters {
        internal enum EmptyView {
          internal static let title = Loc.tr("Localizable", "EditSet.Popup.Filters.EmptyView.Title", fallback: "No filters here. You can add some")
        }
        internal enum NavigationView {
          internal static let title = Loc.tr("Localizable", "EditSet.Popup.Filters.NavigationView.Title", fallback: "Filters")
        }
        internal enum TextView {
          internal static let placeholder = Loc.tr("Localizable", "EditSet.Popup.Filters.TextView.Placeholder", fallback: "Value")
        }
      }
      internal enum Sort {
        internal enum Add {
          internal static let searchPlaceholder = Loc.tr("Localizable", "EditSet.Popup.Sort.Add.SearchPlaceholder", fallback: "Сhoose a property to sort")
        }
        internal enum EmptyTypes {
          internal static let end = Loc.tr("Localizable", "EditSet.Popup.Sort.EmptyTypes.End", fallback: "On bottom")
          internal static let start = Loc.tr("Localizable", "EditSet.Popup.Sort.EmptyTypes.Start", fallback: "On top")
          internal enum Section {
            internal static let title = Loc.tr("Localizable", "EditSet.Popup.Sort.EmptyTypes.Section.Title", fallback: "Show empty values")
          }
        }
        internal enum Types {
          internal static let ascending = Loc.tr("Localizable", "EditSet.Popup.Sort.Types.Ascending", fallback: "Ascending")
          internal static let descending = Loc.tr("Localizable", "EditSet.Popup.Sort.Types.Descending", fallback: "Descending")
        }
      }
      internal enum Sorts {
        internal enum EmptyView {
          internal static let title = Loc.tr("Localizable", "EditSet.Popup.Sorts.EmptyView.Title", fallback: "No sorts here. You can add some")
        }
        internal enum NavigationView {
          internal static let title = Loc.tr("Localizable", "EditSet.Popup.Sorts.NavigationView.Title", fallback: "Sorts")
        }
      }
    }
  }
  internal enum Editor {
    internal enum LinkToObject {
      internal static let copyLink = Loc.tr("Localizable", "Editor.LinkToObject.CopyLink", fallback: "Copy link")
      internal static let linkedTo = Loc.tr("Localizable", "Editor.LinkToObject.LinkedTo", fallback: "Linked to")
      internal static let pasteFromClipboard = Loc.tr("Localizable", "Editor.LinkToObject.PasteFromClipboard", fallback: "Paste from clipboard")
      internal static let removeLink = Loc.tr("Localizable", "Editor.LinkToObject.RemoveLink", fallback: "Remove link")
      internal static let searchPlaceholder = Loc.tr("Localizable", "Editor.LinkToObject.SearchPlaceholder", fallback: "Paste link or search objects")
    }
    internal enum MovingState {
      internal static let scrollToSelectedPlace = Loc.tr("Localizable", "Editor.MovingState.ScrollToSelectedPlace", fallback: "Scroll to select a place")
    }
    internal enum Toast {
      internal static let linkedTo = Loc.tr("Localizable", "Editor.Toast.LinkedTo", fallback: "linked to")
      internal static let movedTo = Loc.tr("Localizable", "Editor.Toast.MovedTo", fallback: "Block moved to")
    }
  }
  internal enum EditorSet {
    internal enum View {
      internal enum Not {
        internal enum Supported {
          internal static let title = Loc.tr("Localizable", "EditorSet.View.Not.Supported.Title", fallback: "Unsupported")
        }
      }
    }
  }
  internal enum EmptyView {
    internal enum Bin {
      internal static let subtitle = Loc.tr("Localizable", "EmptyView.Bin.subtitle", fallback: "Looks like you’re all tidy and organized!")
      internal static let title = Loc.tr("Localizable", "EmptyView.Bin.title", fallback: "Your bin is empty.")
    }
    internal enum Default {
      internal static let subtitle = Loc.tr("Localizable", "EmptyView.Default.subtitle", fallback: "Create your first objects to get started.")
      internal static let title = Loc.tr("Localizable", "EmptyView.Default.title", fallback: "It’s empty here.")
    }
  }
  internal enum Error {
    internal static let unableToConnect = Loc.tr("Localizable", "Error.UnableToConnect", fallback: "Please connect to the internet")
    internal enum AnytypeNeedsUpgrate {
      internal static let confirm = Loc.tr("Localizable", "Error.AnytypeNeedsUpgrate.Confirm", fallback: "Update")
      internal static let message = Loc.tr("Localizable", "Error.AnytypeNeedsUpgrate.Message", fallback: "This object was modified in a newer version of Anytype. Please update the app to open it on this device")
      internal static let title = Loc.tr("Localizable", "Error.AnytypeNeedsUpgrate.Title", fallback: "Update Your App")
    }
    internal enum Common {
      internal static let message = Loc.tr("Localizable", "Error.Common.Message", fallback: "Please check your internet connection and try again or [post a report on forum](http://community.anytype.io/report-bug).")
      internal static let title = Loc.tr("Localizable", "Error.Common.Title", fallback: "Oops!")
      internal static let tryAgain = Loc.tr("Localizable", "Error.Common.TryAgain", fallback: "Try again")
    }
  }
  internal enum ErrorOccurred {
    internal static let pleaseTryAgain = Loc.tr("Localizable", "Error occurred. Please try again", fallback: "Error occurred. Please try again")
  }
  internal enum Fields {
    internal static let addToType = Loc.tr("Localizable", "Fields.addToType", fallback: "Add to the current type")
    internal static func created(_ p1: Any) -> String {
      return Loc.tr("Localizable", "Fields.Created", String(describing: p1), fallback: "Property ‘%@’ has been created")
    }
    internal static let local = Loc.tr("Localizable", "Fields.local", fallback: "Local properties")
    internal static let menu = Loc.tr("Localizable", "Fields.menu", fallback: "Properties menu")
    internal static let missingInfo = Loc.tr("Localizable", "Fields.missingInfo", fallback: "Some properties are not included in the object type. Please add them if you want to see them in all objects of this type, or remove them.")
    internal static let removeFromObject = Loc.tr("Localizable", "Fields.removeFromObject", fallback: "Remove from the object")
    internal static func updated(_ p1: Any) -> String {
      return Loc.tr("Localizable", "Fields.Updated", String(describing: p1), fallback: "Property ‘%@’ has been updated")
    }
  }
  internal enum FileStorage {
    internal static let cleanUpFiles = Loc.tr("Localizable", "FileStorage.CleanUpFiles", fallback: "Clean up files files")
    internal static let limitError = Loc.tr("Localizable", "FileStorage.LimitError", fallback: "You exceeded file limit upload")
    internal static let offloadTitle = Loc.tr("Localizable", "FileStorage.OffloadTitle", fallback: "Offload files")
    internal static let title = Loc.tr("Localizable", "FileStorage.Title", fallback: "File storage")
    internal enum LimitLegend {
      internal static func current(_ p1: Any, _ p2: Any) -> String {
        return Loc.tr("Localizable", "FileStorage.LimitLegend.Current", String(describing: p1), String(describing: p2), fallback: "%@ | %@")
      }
      internal static func free(_ p1: Any) -> String {
        return Loc.tr("Localizable", "FileStorage.LimitLegend.Free", String(describing: p1), fallback: "Free | %@")
      }
      internal static func other(_ p1: Any) -> String {
        return Loc.tr("Localizable", "FileStorage.LimitLegend.Other", String(describing: p1), fallback: "Other spaces | %@")
      }
    }
    internal enum Local {
      internal static let instruction = Loc.tr("Localizable", "FileStorage.Local.Instruction", fallback: "In order to save space on your local device, you can offload all your files to our encrypted backup node. The files will be loaded back when you open them.")
      internal static let title = Loc.tr("Localizable", "FileStorage.Local.Title", fallback: "Local storage")
      internal static func used(_ p1: Any) -> String {
        return Loc.tr("Localizable", "FileStorage.Local.Used", String(describing: p1), fallback: "%@ used")
      }
    }
    internal enum Space {
      internal static let getMore = Loc.tr("Localizable", "FileStorage.Space.GetMore", fallback: "Get more space")
      internal static func instruction(_ p1: Any) -> String {
        return Loc.tr("Localizable", "FileStorage.Space.Instruction", String(describing: p1), fallback: "You can store up to %@ of your files on our encrypted backup node for free. If you reach the limit, files will be stored only locally.")
      }
      internal static let title = Loc.tr("Localizable", "FileStorage.Space.Title", fallback: "Remote storage")
      internal static func used(_ p1: Any, _ p2: Any) -> String {
        return Loc.tr("Localizable", "FileStorage.Space.Used", String(describing: p1), String(describing: p2), fallback: "%@ of %@ used")
      }
    }
  }
  internal enum FilesList {
    internal static let title = Loc.tr("Localizable", "FilesList.Title", fallback: "Clean up files")
    internal enum ForceDelete {
      internal static let title = Loc.tr("Localizable", "FilesList.ForceDelete.Title", fallback: "Are you sure you want to permanently delete the files?")
    }
  }
  internal enum Gallery {
    internal static func author(_ p1: Any) -> String {
      return Loc.tr("Localizable", "Gallery.Author", String(describing: p1), fallback: "Made by @%@")
    }
    internal static let install = Loc.tr("Localizable", "Gallery.Install", fallback: "Install")
    internal static let installToNew = Loc.tr("Localizable", "Gallery.InstallToNew", fallback: "Install to new space")
    internal enum Notification {
      internal static let button = Loc.tr("Localizable", "Gallery.Notification.Button", fallback: "Go to space")
      internal static func error(_ p1: Any) -> String {
        return Loc.tr("Localizable", "Gallery.Notification.Error", String(describing: p1), fallback: "Oops! \"%@\" wasn't installed. Please check your internet connection and try again or post a report on forum.")
      }
      internal static func success(_ p1: Any) -> String {
        return Loc.tr("Localizable", "Gallery.Notification.Success", String(describing: p1), fallback: "Experience was successfully installed to the \"%@\" space. You can now open and start using it.")
      }
    }
  }
  internal enum GlobalSearch {
    internal enum EmptyFilteredState {
      internal static let title = Loc.tr("Localizable", "GlobalSearch.EmptyFilteredState.title", fallback: "No related objects found")
    }
    internal enum EmptyState {
      internal static let subtitle = Loc.tr("Localizable", "GlobalSearch.EmptyState.subtitle", fallback: "Create new object or search for something else")
    }
    internal enum Swipe {
      internal enum Tip {
        internal static let subtitle = Loc.tr("Localizable", "GlobalSearch.Swipe.Tip.subtitle", fallback: "Swipe left to see related objects. Note, it works only for objects that have related objects.")
        internal static let title = Loc.tr("Localizable", "GlobalSearch.Swipe.Tip.title", fallback: "Related objects")
      }
    }
  }
  internal enum Home {
    internal enum Snackbar {
      internal static let library = Loc.tr("Localizable", "Home.Snackbar.Library", fallback: "Library is available in desktop app")
    }
  }
  internal enum Initial {
    internal enum UnstableMiddle {
      internal static let `continue` = Loc.tr("Localizable", "Initial.UnstableMiddle.Continue", fallback: "Continue with current vault")
      internal static let logout = Loc.tr("Localizable", "Initial.UnstableMiddle.Logout", fallback: "Logout from current vault")
      internal static let message = Loc.tr("Localizable", "Initial.UnstableMiddle.Message", fallback: "You launch app with a unstable middleware. Don't use your production vault. Your vault may be broken.")
      internal static let title = Loc.tr("Localizable", "Initial.UnstableMiddle.Title", fallback: "Warning")
      internal static let wontUseProd = Loc.tr("Localizable", "Initial.UnstableMiddle.WontUseProd", fallback: "I won't be using my production vault")
    }
  }
  internal enum InterfaceStyle {
    internal static let dark = Loc.tr("Localizable", "InterfaceStyle.dark", fallback: "Dark")
    internal static let light = Loc.tr("Localizable", "InterfaceStyle.light", fallback: "Light")
    internal static let system = Loc.tr("Localizable", "InterfaceStyle.system", fallback: "System")
  }
  internal enum Keychain {
    internal static let haveYouBackedUpYourKey = Loc.tr("Localizable", "Keychain.Have you backed up your key?", fallback: "Have you backed up your key?")
    internal static let key = Loc.tr("Localizable", "Keychain.Key", fallback: "Key")
    internal static let seedPhrasePlaceholder = Loc.tr("Localizable", "Keychain.SeedPhrasePlaceholder", fallback: "witch collapse practice feed shame open despair creek road again ice least lake tree young address brain despair")
    internal static let showAndCopyKey = Loc.tr("Localizable", "Keychain.Show and copy key", fallback: "Show and copy key")
    internal enum Error {
      internal static let dataToStringConversionError = Loc.tr("Localizable", "Keychain.Error.Data to String conversion error", fallback: "Data to String conversion error")
      internal static let stringToDataConversionError = Loc.tr("Localizable", "Keychain.Error.String to Data conversion error", fallback: "String to Data conversion error")
      internal static let unknownKeychainError = Loc.tr("Localizable", "Keychain.Error.Unknown Keychain Error", fallback: "Unknown Keychain Error")
    }
    internal enum Key {
      internal static let description = Loc.tr("Localizable", "Keychain.Key.description", fallback: "You will need it to enter your vault. Keep it in a safe place. If you lose it, you can no longer enter your vault.")
      internal enum Copy {
        internal enum Toast {
          internal static let title = Loc.tr("Localizable", "Keychain.Key.Copy.Toast.title", fallback: "Key copied")
        }
      }
    }
  }
  internal enum LinkAppearance {
    internal enum Description {
      internal enum Content {
        internal static let title = Loc.tr("Localizable", "LinkAppearance.Description.Content.Title", fallback: "Content preview")
      }
      internal enum None {
        internal static let title = Loc.tr("Localizable", "LinkAppearance.Description.None.Title", fallback: "None")
      }
      internal enum Object {
        internal static let title = Loc.tr("Localizable", "LinkAppearance.Description.Object.Title", fallback: "Object description")
      }
    }
    internal enum ObjectType {
      internal static let title = Loc.tr("Localizable", "LinkAppearance.ObjectType.Title", fallback: "Object type")
    }
  }
  internal enum LinkPaste {
    internal static let bookmark = Loc.tr("Localizable", "LinkPaste.bookmark", fallback: "Create bookmark")
    internal static let link = Loc.tr("Localizable", "LinkPaste.link", fallback: "Paste as link")
    internal static let text = Loc.tr("Localizable", "LinkPaste.text", fallback: "Paste as text")
  }
  internal enum LongTapCreateTip {
    internal static let message = Loc.tr("Localizable", "LongTapCreateTip.Message", fallback: "Long tap on Create Object button to open menu with types")
    internal static let title = Loc.tr("Localizable", "LongTapCreateTip.Title", fallback: "Create Objects with specific Type")
  }
  internal enum Membership {
    internal static let emailValidation = Loc.tr("Localizable", "Membership.EmailValidation", fallback: "Enter the code sent to your email")
    internal enum Ad {
      internal static let subtitle = Loc.tr("Localizable", "Membership.Ad.Subtitle", fallback: "Joining Anytype network means contributing to its story")
      internal static let title = Loc.tr("Localizable", "Membership.Ad.Title", fallback: "Membership")
    }
    internal enum Banner {
      internal static let subtitle1 = Loc.tr("Localizable", "Membership.Banner.Subtitle1", fallback: "As a valued member your voice matters! Engage in exclusive events, shape strategic choices, and influence our roadmap.")
      internal static let subtitle2 = Loc.tr("Localizable", "Membership.Banner.Subtitle2", fallback: "Members enjoy higher backup storage & sync limits, invitations for multiple guests to collaborate in shared spaces, and a unique identity on the Anytype Network.")
      internal static let subtitle3 = Loc.tr("Localizable", "Membership.Banner.Subtitle3", fallback: "Your contribution supports our team and endorses our vision of a user-owned, secure, and collaborative digital network.")
      internal static let subtitle4 = Loc.tr("Localizable", "Membership.Banner.Subtitle4", fallback: "Our network's value exceeds the sum of its parts. Your membership sustains the infrastructure for its growth which underpins this network.")
      internal static let title1 = Loc.tr("Localizable", "Membership.Banner.Title1", fallback: "Build the Vision Together")
      internal static let title2 = Loc.tr("Localizable", "Membership.Banner.Title2", fallback: "Unlock Member Benefits")
      internal static let title3 = Loc.tr("Localizable", "Membership.Banner.Title3", fallback: "Support Digital Independence")
      internal static let title4 = Loc.tr("Localizable", "Membership.Banner.Title4", fallback: "Invest in Connectivity")
    }
    internal enum Builder {
      internal static let subtitle = Loc.tr("Localizable", "Membership.Builder.Subtitle", fallback: "Unlock multiparty collaboration and extend your network storage.")
    }
    internal enum CoCreator {
      internal static let subtitle = Loc.tr("Localizable", "Membership.CoCreator.Subtitle", fallback: "Support our adventure and unlock exclusive access and perks.")
    }
    internal enum Custom {
      internal static let subtitle = Loc.tr("Localizable", "Membership.Custom.Subtitle", fallback: "Custom conditions of Membership. If you have any questions, please contact support.")
    }
    internal enum Email {
      internal static let body = Loc.tr("Localizable", "Membership.Email.Body", fallback: "Hello Anytype team! I would like to extend my current membership for more (please choose an option):\n- Extra remote storage\n- More space editors\n- Additional shared spaces\nSpecifically,\nPlease provide specific details of your needs here.")
    }
    internal enum EmailForm {
      internal static let subtitle = Loc.tr("Localizable", "Membership.EmailForm.Subtitle", fallback: "It is not linked to your account in any way.")
      internal static let title = Loc.tr("Localizable", "Membership.EmailForm.Title", fallback: "Get updates and enjoy free perks!")
    }
    internal enum Explorer {
      internal static let subtitle = Loc.tr("Localizable", "Membership.Explorer.Subtitle", fallback: "Sync your devices, get backup storage, and engage in collaboration.")
    }
    internal enum Feature {
      internal static func invites(_ p1: Any) -> String {
        return Loc.tr("Localizable", "Membership.Feature.Invites", String(describing: p1), fallback: "%@ Invitations")
      }
      internal static let localName = Loc.tr("Localizable", "Membership.Feature.LocalName", fallback: "Local, non-unique name")
      internal static func sharedSpaces(_ p1: Any) -> String {
        return Loc.tr("Localizable", "Membership.Feature.SharedSpaces", String(describing: p1), fallback: "Up to %@ Shared spaces")
      }
      internal static func spaceWriters(_ p1: Any) -> String {
        return Loc.tr("Localizable", "Membership.Feature.SpaceWriters", String(describing: p1), fallback: "%@ Editors per shared space")
      }
      internal static func storageGB(_ p1: Any) -> String {
        return Loc.tr("Localizable", "Membership.Feature.StorageGB", String(describing: p1), fallback: "%@ GB of backup & sync space on the Anytype network")
      }
      internal static func uniqueName(_ p1: Any) -> String {
        return Loc.tr("Localizable", "Membership.Feature.UniqueName", String(describing: p1), fallback: "Unique Network name (%@+ characters)")
      }
      internal static let unlimitedViewers = Loc.tr("Localizable", "Membership.Feature.UnlimitedViewers", fallback: "Unlimited Viewers for shared spaces")
      internal static func viewers(_ p1: Any) -> String {
        return Loc.tr("Localizable", "Membership.Feature.Viewers", String(describing: p1), fallback: "%@ Viewers for shared spaces")
      }
    }
    internal enum Legal {
      internal static let alreadyPurchasedTier = Loc.tr("Localizable", "Membership.Legal.AlreadyPurchasedTier", fallback: "Already purchased tier?")
      internal static let details = Loc.tr("Localizable", "Membership.Legal.Details", fallback: "Membership plan details")
      internal static let letUsKnow = Loc.tr("Localizable", "Membership.Legal.LetUsKnow", fallback: "Please let us know here.")
      internal static let privacy = Loc.tr("Localizable", "Membership.Legal.Privacy", fallback: "Privacy policy")
      internal static let restorePurchases = Loc.tr("Localizable", "Membership.Legal.RestorePurchases", fallback: "Restore purchases")
      internal static let terms = Loc.tr("Localizable", "Membership.Legal.Terms", fallback: "Terms and conditions")
      internal static let wouldYouLike = Loc.tr("Localizable", "Membership.Legal.WouldYouLike", fallback: "Would you like to use Anytype for business, education, etc.?")
    }
    internal enum ManageTier {
      internal static let android = Loc.tr("Localizable", "Membership.ManageTier.Android", fallback: "You can manage tier on Android platform")
      internal static let appleId = Loc.tr("Localizable", "Membership.ManageTier.AppleId", fallback: "You can manage tier on another AppleId account")
      internal static let desktop = Loc.tr("Localizable", "Membership.ManageTier.Desktop", fallback: "You can manage tier on Desktop platform")
    }
    internal enum NameForm {
      internal static let subtitle = Loc.tr("Localizable", "Membership.NameForm.Subtitle", fallback: "This is your unique name on the Anytype network, confirming your Membership. It acts as your personal domain and cannot be changed.")
      internal static let title = Loc.tr("Localizable", "Membership.NameForm.Title", fallback: "Pick your unique name")
      internal static let validated = Loc.tr("Localizable", "Membership.NameForm.Validated", fallback: "This name is up for grabs")
      internal static let validating = Loc.tr("Localizable", "Membership.NameForm.Validating", fallback: "Wait a second...")
    }
    internal enum Payment {
      internal static let appleSubscription = Loc.tr("Localizable", "Membership.Payment.Apple subscription", fallback: "Apple subscription")
      internal static let card = Loc.tr("Localizable", "Membership.Payment.Card", fallback: "Card")
      internal static let crypto = Loc.tr("Localizable", "Membership.Payment.Crypto", fallback: "Crypto")
      internal static let googleSubscription = Loc.tr("Localizable", "Membership.Payment.Google subscription", fallback: "Google subscription")
    }
    internal enum Success {
      internal static let curiosity = Loc.tr("Localizable", "Membership.Success.Curiosity", fallback: "Big cheers for your curiosity!")
      internal static let support = Loc.tr("Localizable", "Membership.Success.Support", fallback: "Big cheers for your support!")
      internal static func title(_ p1: Any) -> String {
        return Loc.tr("Localizable", "Membership.Success.Title", String(describing: p1), fallback: "Welcome to the network, %@")
      }
    }
    internal enum Upgrade {
      internal static let button = Loc.tr("Localizable", "Membership.Upgrade.Button", fallback: "Contact Anytype Team")
      internal static let moreMembers = Loc.tr("Localizable", "Membership.Upgrade.MoreMembers", fallback: "Upgrade to add more members")
      internal static let moreSpaces = Loc.tr("Localizable", "Membership.Upgrade.MoreSpaces", fallback: "Upgrade to add more spaces")
      internal static let noMoreEditors = Loc.tr("Localizable", "Membership.Upgrade.NoMoreEditors", fallback: "You can’t add more editors")
      internal static let noMoreMembers = Loc.tr("Localizable", "Membership.Upgrade.NoMoreMembers", fallback: "You can’t add more members")
      internal static func spacesLimit(_ p1: Int) -> String {
        return Loc.tr("Localizable", "Membership.Upgrade.SpacesLimit", p1, fallback: "Plural format key: \"%#@object@\"")
      }
      internal static let text = Loc.tr("Localizable", "Membership.Upgrade.Text", fallback: "Reach us for extra storage, space editors, or more shared spaces. Anytype team will provide details and conditions tailored to your needs.")
      internal static let title = Loc.tr("Localizable", "Membership.Upgrade.Title", fallback: "Membership upgrade")
    }
  }
  internal enum MembershipServiceError {
    internal static let invalidBillingIdFormat = Loc.tr("Localizable", "MembershipServiceError.invalidBillingIdFormat", fallback: "Internal problem with billing format, we are working on this. Try again later or contact support.")
    internal static let tierNotFound = Loc.tr("Localizable", "MembershipServiceError.tierNotFound", fallback: "Not found tier data, restart app and try again")
  }
  internal enum Mention {
    internal enum Subtitle {
      internal static let placeholder = Loc.tr("Localizable", "Mention.Subtitle.Placeholder", fallback: "Object")
    }
  }
  internal enum Message {
    internal enum Action {
      internal static let addReaction = Loc.tr("Localizable", "Message.Action.AddReaction", fallback: "Add Reaction")
      internal static let copyPlainText = Loc.tr("Localizable", "Message.Action.CopyPlainText", fallback: "Copy Plain Text")
      internal static let reply = Loc.tr("Localizable", "Message.Action.Reply", fallback: "Reply")
      internal static let unread = Loc.tr("Localizable", "Message.Action.Unread", fallback: "Mark Unread")
    }
    internal enum ChatTitle {
      internal static let placeholder = Loc.tr("Localizable", "Message.ChatTitle.Placeholder", fallback: "Untitled Chat")
    }
    internal enum Input {
      internal static let emptyPlaceholder = Loc.tr("Localizable", "Message.Input.EmptyPlaceholder", fallback: "Write a message...")
    }
  }
  internal enum Migration {
    internal static let subtitle = Loc.tr("Localizable", "Migration.subtitle", fallback: "This may take some time. Please don’t close the app until the process is complete.")
    internal static let title = Loc.tr("Localizable", "Migration.title", fallback: "Migration is in progress...")
    internal enum Error {
      internal enum NotEnoughtSpace {
        internal static let message = Loc.tr("Localizable", "Migration.Error.NotEnoughtSpace.message", fallback: "Please free up space and run the process again.")
        internal static let title = Loc.tr("Localizable", "Migration.Error.NotEnoughtSpace.title", fallback: "Not enough space")
      }
    }
  }
  internal enum Object {
    internal enum Deleted {
      internal static let placeholder = Loc.tr("Localizable", "Object.Deleted.Placeholder", fallback: "Deleted object")
    }
  }
  internal enum ObjectSearchWithMeta {
    internal enum Create {
      internal static let collection = Loc.tr("Localizable", "ObjectSearchWithMeta.Create.Collection", fallback: "New Collection")
      internal static let note = Loc.tr("Localizable", "ObjectSearchWithMeta.Create.Note", fallback: "New Note")
      internal static let page = Loc.tr("Localizable", "ObjectSearchWithMeta.Create.Page", fallback: "New Page")
      internal static let `set` = Loc.tr("Localizable", "ObjectSearchWithMeta.Create.Set", fallback: "New Query")
    }
  }
  internal enum ObjectType {
    internal static func addedToLibrary(_ p1: Any) -> String {
      return Loc.tr("Localizable", "ObjectType.AddedToLibrary", String(describing: p1), fallback: "Type ‘%@’ has been created")
    }
    internal static let deletedName = Loc.tr("Localizable", "ObjectType.DeletedName", fallback: "Deleted type")
    internal static let editingType = Loc.tr("Localizable", "ObjectType.editingType", fallback: "You're editing type")
    internal static let fallbackDescription = Loc.tr("Localizable", "ObjectType.fallbackDescription", fallback: "Blank canvas with no title")
    internal static let myTypes = Loc.tr("Localizable", "ObjectType.MyTypes", fallback: "My Types")
    internal static let search = Loc.tr("Localizable", "ObjectType.Search", fallback: "Search for Type")
    internal static let searchOrInstall = Loc.tr("Localizable", "ObjectType.SearchOrInstall", fallback: "Search or install a new type")
  }
  internal enum ParticipantRemoveNotification {
    internal static func text(_ p1: Any) -> String {
      return Loc.tr("Localizable", "ParticipantRemoveNotification.Text", String(describing: p1), fallback: "You were removed from **%@** space, or the space has been deleted by the owner.")
    }
  }
  internal enum ParticipantRequestApprovedNotification {
    internal static func text(_ p1: Any, _ p2: Any) -> String {
      return Loc.tr("Localizable", "ParticipantRequestApprovedNotification.Text", String(describing: p1), String(describing: p2), fallback: "Your request to join the **%@** space has been approved with **%@** access rights. The space will be available on your device soon.")
    }
  }
  internal enum ParticipantRequestDeclineNotification {
    internal static func text(_ p1: Any) -> String {
      return Loc.tr("Localizable", "ParticipantRequestDeclineNotification.Text", String(describing: p1), fallback: "Your request to join the **%@** space has been declined.")
    }
  }
  internal enum PermissionChangeNotification {
    internal static func text(_ p1: Any, _ p2: Any) -> String {
      return Loc.tr("Localizable", "PermissionChangeNotification.Text", String(describing: p1), String(describing: p2), fallback: "Your access rights were changed to **%@** in the **%@** space.")
    }
  }
  internal enum Primitives {
    internal enum LayoutConflict {
      internal static let description = Loc.tr("Localizable", "Primitives.LayoutConflict.Description", fallback: "This layout differs from the type's default. Reset to match?")
    }
  }
  internal enum QuickAction {
    internal static func create(_ p1: Any) -> String {
      return Loc.tr("Localizable", "QuickAction.create", String(describing: p1), fallback: "Create %@")
    }
  }
  internal enum RedactedText {
    internal static let pageTitle = Loc.tr("Localizable", "RedactedText.pageTitle", fallback: "Wake up, Neo")
    internal static let pageType = Loc.tr("Localizable", "RedactedText.pageType", fallback: "Red pill")
  }
  internal enum ReindexingWarningAlert {
    internal static let description = Loc.tr("Localizable", "ReindexingWarningAlert.Description", fallback: "We've implemented a new search library for faster and more accurate results.\nReindexing may take a few minutes.")
    internal static let title = Loc.tr("Localizable", "ReindexingWarningAlert.Title", fallback: "Upgrading your search experience")
  }
  internal enum Relation {
    internal static let deleted = Loc.tr("Localizable", "Relation.Deleted", fallback: "Deleted property")
    internal static let myRelations = Loc.tr("Localizable", "Relation.MyRelations", fallback: "My properties")
    internal enum Create {
      internal enum Row {
        internal static func title(_ p1: Any) -> String {
          return Loc.tr("Localizable", "Relation.Create.Row.title", String(describing: p1), fallback: "Create “%@”")
        }
      }
      internal enum Textfield {
        internal static let placeholder = Loc.tr("Localizable", "Relation.Create.Textfield.placeholder", fallback: "Enter name...")
      }
    }
    internal enum Delete {
      internal enum Alert {
        internal static let description = Loc.tr("Localizable", "Relation.Delete.Alert.Description", fallback: "The option will be permanently removed from your space.")
        internal static let title = Loc.tr("Localizable", "Relation.Delete.Alert.Title", fallback: "Are you sure?")
      }
    }
    internal enum EmptyState {
      internal static let description = Loc.tr("Localizable", "Relation.EmptyState.description", fallback: "Nothing found. Create first option to start.")
      internal static let title = Loc.tr("Localizable", "Relation.EmptyState.title", fallback: "No options")
      internal enum Blocked {
        internal static let title = Loc.tr("Localizable", "Relation.EmptyState.Blocked.title", fallback: "The property is empty")
      }
    }
    internal enum Format {
      internal enum Checkbox {
        internal static let title = Loc.tr("Localizable", "Relation.Format.Checkbox.Title", fallback: "Checkbox")
      }
      internal enum Date {
        internal static let title = Loc.tr("Localizable", "Relation.Format.Date.Title", fallback: "Date")
      }
      internal enum Email {
        internal static let title = Loc.tr("Localizable", "Relation.Format.Email.Title", fallback: "Email")
      }
      internal enum FileMedia {
        internal static let title = Loc.tr("Localizable", "Relation.Format.FileMedia.Title", fallback: "File & Media")
      }
      internal enum Number {
        internal static let title = Loc.tr("Localizable", "Relation.Format.Number.Title", fallback: "Number")
      }
      internal enum Object {
        internal static let title = Loc.tr("Localizable", "Relation.Format.Object.Title", fallback: "Object")
      }
      internal enum Phone {
        internal static let title = Loc.tr("Localizable", "Relation.Format.Phone.Title", fallback: "Phone number")
      }
      internal enum Status {
        internal static let title = Loc.tr("Localizable", "Relation.Format.Status.Title", fallback: "Select")
      }
      internal enum Tag {
        internal static let title = Loc.tr("Localizable", "Relation.Format.Tag.Title", fallback: "Multi-select")
      }
      internal enum Text {
        internal static let title = Loc.tr("Localizable", "Relation.Format.Text.Title", fallback: "Text")
      }
      internal enum Url {
        internal static let title = Loc.tr("Localizable", "Relation.Format.Url.Title", fallback: "URL")
      }
    }
    internal enum From {
      internal static func type(_ p1: Any) -> String {
        return Loc.tr("Localizable", "Relation.From.Type", String(describing: p1), fallback: "From type %@")
      }
    }
    internal enum ImportType {
      internal static let csv = Loc.tr("Localizable", "Relation.ImportType.Csv", fallback: "CSV")
      internal static let html = Loc.tr("Localizable", "Relation.ImportType.Html", fallback: "HTML")
      internal static let markdown = Loc.tr("Localizable", "Relation.ImportType.Markdown", fallback: "Markdown")
      internal static let notion = Loc.tr("Localizable", "Relation.ImportType.Notion", fallback: "Notion")
      internal static let protobuf = Loc.tr("Localizable", "Relation.ImportType.Protobuf", fallback: "Any-Block")
      internal static let text = Loc.tr("Localizable", "Relation.ImportType.Text", fallback: "TXT")
    }
    internal enum Object {
      internal enum Delete {
        internal enum Alert {
          internal static let description = Loc.tr("Localizable", "Relation.Object.Delete.Alert.Description", fallback: "The object will be moved to Bin.")
        }
      }
    }
    internal enum ObjectType {
      internal enum Header {
        internal static let title = Loc.tr("Localizable", "Relation.ObjectType.Header.title", fallback: "Object type:")
      }
    }
    internal enum ObjectTypes {
      internal enum Header {
        internal static let title = Loc.tr("Localizable", "Relation.ObjectTypes.Header.title", fallback: "Object types:")
      }
    }
    internal enum Origin {
      internal static let api = Loc.tr("Localizable", "Relation.Origin.API", fallback: "API")
      internal static let bookmark = Loc.tr("Localizable", "Relation.Origin.Bookmark", fallback: "Bookmark")
      internal static let builtin = Loc.tr("Localizable", "Relation.Origin.Builtin", fallback: "Library installed")
      internal static let clipboard = Loc.tr("Localizable", "Relation.Origin.Clipboard", fallback: "Clipboard")
      internal static let dragAndDrop = Loc.tr("Localizable", "Relation.Origin.DragAndDrop", fallback: "Drag'n'Drop")
      internal static let `import` = Loc.tr("Localizable", "Relation.Origin.Import", fallback: "Imported object")
      internal static let sharingExtension = Loc.tr("Localizable", "Relation.Origin.SharingExtension", fallback: "Mobile sharing extension")
      internal static let useCase = Loc.tr("Localizable", "Relation.Origin.UseCase", fallback: "Use case")
      internal static let webClipper = Loc.tr("Localizable", "Relation.Origin.WebClipper", fallback: "Web clipper")
    }
    internal enum Search {
      internal enum View {
        internal static let placeholder = Loc.tr("Localizable", "Relation.Search.View.Placeholder", fallback: "Search or create a new property")
      }
    }
    internal enum View {
      internal enum Create {
        internal static let title = Loc.tr("Localizable", "Relation.View.Create.title", fallback: "Create option")
      }
      internal enum Edit {
        internal static let title = Loc.tr("Localizable", "Relation.View.Edit.title", fallback: "Edit option")
      }
      internal enum Hint {
        internal static let empty = Loc.tr("Localizable", "Relation.View.Hint.Empty", fallback: "empty")
      }
    }
  }
  internal enum RelationAction {
    internal static let callPhone = Loc.tr("Localizable", "RelationAction.CallPhone", fallback: "Call phone numbler")
    internal static let copied = Loc.tr("Localizable", "RelationAction.Copied", fallback: "Copied")
    internal static let copyEmail = Loc.tr("Localizable", "RelationAction.CopyEmail", fallback: "Copy email")
    internal static let copyLink = Loc.tr("Localizable", "RelationAction.CopyLink", fallback: "Copy link")
    internal static let copyPhone = Loc.tr("Localizable", "RelationAction.CopyPhone", fallback: "Copy phone number")
    internal static let openLink = Loc.tr("Localizable", "RelationAction.OpenLink", fallback: "Open link")
    internal static let reloadContent = Loc.tr("Localizable", "RelationAction.ReloadContent", fallback: "Reload object content")
    internal static let reloadingContent = Loc.tr("Localizable", "RelationAction.ReloadingContent", fallback: "Reloading content")
    internal static let sendEmail = Loc.tr("Localizable", "RelationAction.SendEmail", fallback: "Send email")
  }
  internal enum RelativeFormatter {
    internal static let days14 = Loc.tr("Localizable", "RelativeFormatter.days14", fallback: "Previous 14 days")
    internal static let days7 = Loc.tr("Localizable", "RelativeFormatter.days7", fallback: "Previous 7 days")
  }
  internal enum RequestToJoinNotification {
    internal static let goToSpace = Loc.tr("Localizable", "RequestToJoinNotification.GoToSpace", fallback: "Go to Space")
    internal static func text(_ p1: Any, _ p2: Any) -> String {
      return Loc.tr("Localizable", "RequestToJoinNotification.Text", String(describing: p1), String(describing: p2), fallback: "**%@** requested to join the **%@** space.")
    }
    internal static let viewRequest = Loc.tr("Localizable", "RequestToJoinNotification.ViewRequest", fallback: "View request")
  }
  internal enum RequestToLeaveNotification {
    internal static func text(_ p1: Any, _ p2: Any) -> String {
      return Loc.tr("Localizable", "RequestToLeaveNotification.Text", String(describing: p1), String(describing: p2), fallback: "**%@** wants to leave the **%@** space.")
    }
  }
  internal enum ReturnToWidgets {
    internal enum Tip {
      internal static let text = Loc.tr("Localizable", "ReturnToWidgets.Tip.Text", fallback: "Long press the back button to return to widgets instead of tapping it repeatedly.")
      internal static let title = Loc.tr("Localizable", "ReturnToWidgets.Tip.Title", fallback: "Long Press to Return to Widgets")
    }
  }
  internal enum Scanner {
    internal enum Error {
      internal static let scanningNotSupported = Loc.tr("Localizable", "Scanner.Error.Scanning not supported", fallback: "Scanning not supported")
    }
  }
  internal enum Search {
    internal enum Links {
      internal enum Header {
        internal static func title(_ p1: Any) -> String {
          return Loc.tr("Localizable", "Search.Links.Header.title", String(describing: p1), fallback: "Related to: %@")
        }
      }
      internal enum Show {
        internal static let title = Loc.tr("Localizable", "Search.Links.Show.title", fallback: "Show related objects")
      }
      internal enum Swipe {
        internal static let title = Loc.tr("Localizable", "Search.Links.Swipe.title", fallback: "Related to")
      }
    }
  }
  internal enum Server {
    internal static let addButton = Loc.tr("Localizable", "Server.AddButton", fallback: "Add Self-hosted Network")
    internal static let anytype = Loc.tr("Localizable", "Server.Anytype", fallback: "Anytype")
    internal static let localOnly = Loc.tr("Localizable", "Server.LocalOnly", fallback: "Local-only")
    internal static let network = Loc.tr("Localizable", "Server.Network", fallback: "Network")
    internal static let networks = Loc.tr("Localizable", "Server.Networks", fallback: "Networks")
    internal enum LocalOnly {
      internal enum Alert {
        internal static let message = Loc.tr("Localizable", "Server.LocalOnly.Alert.message", fallback: "Local-only mode is an experimental feature and does not provide security benefits. Please use it at your own risk, as data loss may occur.")
        internal static let title = Loc.tr("Localizable", "Server.LocalOnly.Alert.title", fallback: "Are you sure?")
        internal enum Action {
          internal static let agree = Loc.tr("Localizable", "Server.LocalOnly.Alert.Action.agree", fallback: "Yes, I accept risks")
          internal static let disagree = Loc.tr("Localizable", "Server.LocalOnly.Alert.Action.disagree", fallback: "No, don’t use it")
        }
      }
    }
  }
  internal enum Set {
    internal enum Bookmark {
      internal enum Create {
        internal static let placeholder = Loc.tr("Localizable", "Set.Bookmark.Create.Placeholder", fallback: "Paste link")
      }
      internal enum Error {
        internal static let message = Loc.tr("Localizable", "Set.Bookmark.Error.Message", fallback: "Oops - something went wrong. Please try again")
      }
    }
    internal enum FeaturedRelations {
      internal static let query = Loc.tr("Localizable", "Set.FeaturedRelations.Query", fallback: "Select query")
      internal static let relation = Loc.tr("Localizable", "Set.FeaturedRelations.Relation", fallback: "Property:")
      internal static let relationsList = Loc.tr("Localizable", "Set.FeaturedRelations.RelationsList", fallback: "Properties:")
      internal static let type = Loc.tr("Localizable", "Set.FeaturedRelations.Type", fallback: "Type:")
    }
    internal enum SourceType {
      internal static let selectQuery = Loc.tr("Localizable", "Set.SourceType.SelectQuery", fallback: "Select query")
      internal enum Cancel {
        internal enum Toast {
          internal static let title = Loc.tr("Localizable", "Set.SourceType.Cancel.Toast.Title", fallback: "This query can be changed on desktop only")
        }
      }
    }
    internal enum TypeRelation {
      internal enum ContextMenu {
        internal static let changeQuery = Loc.tr("Localizable", "Set.TypeRelation.ContextMenu.ChangeQuery", fallback: "Change query")
        internal static let turnIntoCollection = Loc.tr("Localizable", "Set.TypeRelation.ContextMenu.TurnIntoCollection", fallback: "Turn Query into Collection")
      }
    }
    internal enum View {
      internal static let unsupportedAlert = Loc.tr("Localizable", "Set.View.UnsupportedAlert", fallback: "View is unsupported on mobile")
      internal enum Empty {
        internal static let subtitle = Loc.tr("Localizable", "Set.View.Empty.Subtitle", fallback: "Add search query to aggregate objects with equal types and properties in a live mode")
        internal static let title = Loc.tr("Localizable", "Set.View.Empty.Title", fallback: "No query selected")
      }
      internal enum Kanban {
        internal enum Column {
          internal enum Paging {
            internal enum Title {
              internal static let showMore = Loc.tr("Localizable", "Set.View.Kanban.Column.Paging.Title.ShowMore", fallback: "Show more objects")
            }
          }
          internal enum Settings {
            internal enum Color {
              internal static let title = Loc.tr("Localizable", "Set.View.Kanban.Column.Settings.Color.Title", fallback: "Column color")
            }
            internal enum Hide {
              internal enum Column {
                internal static let title = Loc.tr("Localizable", "Set.View.Kanban.Column.Settings.Hide.Column.Title", fallback: "Hide column")
              }
            }
          }
          internal enum Title {
            internal static func checked(_ p1: Any) -> String {
              return Loc.tr("Localizable", "Set.View.Kanban.Column.Title.Checked", String(describing: p1), fallback: "%@ is checked")
            }
            internal static let uncategorized = Loc.tr("Localizable", "Set.View.Kanban.Column.Title.Uncategorized", fallback: "Uncategorized")
            internal static func unchecked(_ p1: Any) -> String {
              return Loc.tr("Localizable", "Set.View.Kanban.Column.Title.Unchecked", String(describing: p1), fallback: "%@ is unchecked")
            }
          }
        }
      }
      internal enum Settings {
        internal enum CardSize {
          internal static let title = Loc.tr("Localizable", "Set.View.Settings.CardSize.Title", fallback: "Card size")
          internal enum Large {
            internal static let title = Loc.tr("Localizable", "Set.View.Settings.CardSize.Large.Title", fallback: "Large")
          }
          internal enum Small {
            internal static let title = Loc.tr("Localizable", "Set.View.Settings.CardSize.Small.Title", fallback: "Small")
          }
        }
        internal enum GroupBackgroundColors {
          internal static let title = Loc.tr("Localizable", "Set.View.Settings.GroupBackgroundColors.Title", fallback: "Color columns")
        }
        internal enum GroupBy {
          internal static let title = Loc.tr("Localizable", "Set.View.Settings.GroupBy.Title", fallback: "Group by")
        }
        internal enum ImageFit {
          internal static let title = Loc.tr("Localizable", "Set.View.Settings.ImageFit.Title", fallback: "Fit image")
        }
        internal enum ImagePreview {
          internal static let title = Loc.tr("Localizable", "Set.View.Settings.ImagePreview.Title", fallback: "Image preview")
        }
        internal enum NoFilters {
          internal static let placeholder = Loc.tr("Localizable", "Set.View.Settings.NoFilters.Placeholder", fallback: "No filters")
        }
        internal enum NoRelations {
          internal static let placeholder = Loc.tr("Localizable", "Set.View.Settings.NoRelations.Placeholder", fallback: "No properties")
        }
        internal enum NoSorts {
          internal static let placeholder = Loc.tr("Localizable", "Set.View.Settings.NoSorts.Placeholder", fallback: "No sorts")
        }
        internal enum Objects {
          internal enum Applied {
            internal static func title(_ p1: Int) -> String {
              return Loc.tr("Localizable", "Set.View.Settings.Objects.Applied.Title", p1, fallback: "%d applied")
            }
          }
        }
      }
    }
  }
  internal enum SetViewTypesPicker {
    internal static let title = Loc.tr("Localizable", "SetViewTypesPicker.Title", fallback: "Edit view")
    internal enum New {
      internal static let title = Loc.tr("Localizable", "SetViewTypesPicker.New.Title", fallback: "New view")
    }
    internal enum Section {
      internal enum Types {
        internal static let title = Loc.tr("Localizable", "SetViewTypesPicker.Section.Types.Title", fallback: "View as")
      }
    }
    internal enum Settings {
      internal enum Delete {
        internal static let view = Loc.tr("Localizable", "SetViewTypesPicker.Settings.Delete.View", fallback: "Delete view")
      }
      internal enum Duplicate {
        internal static let view = Loc.tr("Localizable", "SetViewTypesPicker.Settings.Duplicate.View", fallback: "Duplicate")
      }
      internal enum Textfield {
        internal enum Placeholder {
          internal static let untitled = Loc.tr("Localizable", "SetViewTypesPicker.Settings.Textfield.Placeholder.Untitled", fallback: "Untitled")
          internal enum New {
            internal static let view = Loc.tr("Localizable", "SetViewTypesPicker.Settings.Textfield.Placeholder.New.View", fallback: "New view")
          }
        }
      }
    }
  }
  internal enum Settings {
    internal static let dataManagement = Loc.tr("Localizable", "Settings.DataManagement", fallback: "Data Management")
    internal static let editPicture = Loc.tr("Localizable", "Settings.Edit picture", fallback: "Edit picture")
    internal static let spaceName = Loc.tr("Localizable", "Settings.SpaceName", fallback: "Space name")
    internal static let spaceType = Loc.tr("Localizable", "Settings.SpaceType", fallback: "Space type")
    internal static let title = Loc.tr("Localizable", "Settings.Title", fallback: "Settings")
    internal static let updated = Loc.tr("Localizable", "Settings.Updated", fallback: "Space information updated")
    internal static let vaultAndAccess = Loc.tr("Localizable", "Settings.VaultAndAccess", fallback: "Vault and access")
  }
  internal enum Sharing {
    internal static let addTo = Loc.tr("Localizable", "Sharing.AddTo", fallback: "Add to")
    internal static let linkTo = Loc.tr("Localizable", "Sharing.LinkTo", fallback: "Link to")
    internal static let saveAs = Loc.tr("Localizable", "Sharing.SaveAs", fallback: "SAVE AS")
    internal static let selectSpace = Loc.tr("Localizable", "Sharing.SelectSpace", fallback: "Space")
    internal enum `Any` {
      internal static let block = Loc.tr("Localizable", "Sharing.Any.Block", fallback: "Blocks")
    }
    internal enum File {
      internal static func block(_ p1: Int) -> String {
        return Loc.tr("Localizable", "Sharing.File.Block", p1, fallback: "Plural format key: \"%#@object@\"")
      }
      internal static func newObject(_ p1: Int) -> String {
        return Loc.tr("Localizable", "Sharing.File.NewObject", p1, fallback: "Plural format key: \"%#@object@\"")
      }
    }
    internal enum Navigation {
      internal static let title = Loc.tr("Localizable", "Sharing.Navigation.title", fallback: "Add to Anytype")
      internal enum LeftButton {
        internal static let title = Loc.tr("Localizable", "Sharing.Navigation.LeftButton.Title", fallback: "Cancel")
      }
      internal enum RightButton {
        internal static let title = Loc.tr("Localizable", "Sharing.Navigation.RightButton.Title", fallback: "Done")
      }
    }
    internal enum Text {
      internal static let noteObject = Loc.tr("Localizable", "Sharing.Text.NoteObject", fallback: "Note object")
      internal static let textBlock = Loc.tr("Localizable", "Sharing.Text.TextBlock", fallback: "Blocks")
    }
    internal enum Tip {
      internal static let title = Loc.tr("Localizable", "Sharing.Tip.Title", fallback: "Share Extension")
      internal enum Button {
        internal static let title = Loc.tr("Localizable", "Sharing.Tip.Button.title", fallback: "Show share menu")
      }
      internal enum Steps {
        internal static let _1 = Loc.tr("Localizable", "Sharing.Tip.Steps.1", fallback: "Tap the iOS sharing button")
        internal static let _2 = Loc.tr("Localizable", "Sharing.Tip.Steps.2", fallback: "Scroll past the app and tap More")
        internal static let _3 = Loc.tr("Localizable", "Sharing.Tip.Steps.3", fallback: "Tap Edit to find “Anytype” and tap")
      }
    }
    internal enum Url {
      internal static func block(_ p1: Int) -> String {
        return Loc.tr("Localizable", "Sharing.URL.Block", p1, fallback: "Plural format key: \"%#@object@\"")
      }
      internal static func newObject(_ p1: Int) -> String {
        return Loc.tr("Localizable", "Sharing.URL.NewObject", p1, fallback: "Plural format key: \"%#@object@\"")
      }
    }
  }
  internal enum SimpleTableMenu {
    internal enum Item {
      internal static let clearContents = Loc.tr("Localizable", "SimpleTableMenu.Item.clearContents", fallback: "Clear")
      internal static let clearStyle = Loc.tr("Localizable", "SimpleTableMenu.Item.clearStyle", fallback: "Reset style")
      internal static let color = Loc.tr("Localizable", "SimpleTableMenu.Item.color", fallback: "Color")
      internal static let delete = Loc.tr("Localizable", "SimpleTableMenu.Item.Delete", fallback: "Delete")
      internal static let duplicate = Loc.tr("Localizable", "SimpleTableMenu.Item.Duplicate", fallback: "Duplicate")
      internal static let insertAbove = Loc.tr("Localizable", "SimpleTableMenu.Item.InsertAbove", fallback: "Insert above")
      internal static let insertBelow = Loc.tr("Localizable", "SimpleTableMenu.Item.InsertBelow", fallback: "Insert below")
      internal static let insertLeft = Loc.tr("Localizable", "SimpleTableMenu.Item.InsertLeft", fallback: "Insert left")
      internal static let insertRight = Loc.tr("Localizable", "SimpleTableMenu.Item.InsertRight", fallback: "Insert right")
      internal static let moveDown = Loc.tr("Localizable", "SimpleTableMenu.Item.MoveDown", fallback: "Move down")
      internal static let moveLeft = Loc.tr("Localizable", "SimpleTableMenu.Item.MoveLeft", fallback: "Move left")
      internal static let moveRight = Loc.tr("Localizable", "SimpleTableMenu.Item.MoveRight", fallback: "Move right")
      internal static let moveUp = Loc.tr("Localizable", "SimpleTableMenu.Item.MoveUp", fallback: "Move up")
      internal static let sort = Loc.tr("Localizable", "SimpleTableMenu.Item.Sort", fallback: "Sort")
      internal static let style = Loc.tr("Localizable", "SimpleTableMenu.Item.style", fallback: "Style")
    }
  }
  internal enum SlashMenu {
    internal static let dotsDivider = Loc.tr("Localizable", "SlashMenu.DotsDivider", fallback: "Dots divider")
    internal static let lineDivider = Loc.tr("Localizable", "SlashMenu.LineDivider", fallback: "Line divider")
    internal static let table = Loc.tr("Localizable", "SlashMenu.Table", fallback: "Table")
    internal static let tableOfContents = Loc.tr("Localizable", "SlashMenu.TableOfContents", fallback: "Table of contents")
    internal enum LinkTo {
      internal static let description = Loc.tr("Localizable", "SlashMenu.LinkTo.Description", fallback: "Create link to another object")
    }
  }
  internal enum Space {
    internal static func membersCount(_ p1: Int) -> String {
      return Loc.tr("Localizable", "Space.MembersCount", p1, fallback: "Plural format key: \"%#@object@\"")
    }
    internal enum Status {
      internal static let error = Loc.tr("Localizable", "Space.Status.Error", fallback: "Error")
      internal static let loading = Loc.tr("Localizable", "Space.Status.Loading", fallback: "Loading")
      internal static let missing = Loc.tr("Localizable", "Space.Status.Missing", fallback: "Missing")
      internal static let ok = Loc.tr("Localizable", "Space.Status.Ok", fallback: "Ok")
      internal static let remoteDeleted = Loc.tr("Localizable", "Space.Status.RemoteDeleted", fallback: "Remote Deleted")
      internal static let remoteWaitingDeletion = Loc.tr("Localizable", "Space.Status.RemoteWaitingDeletion", fallback: "Waiting Deletion")
      internal static let spaceActive = Loc.tr("Localizable", "Space.Status.SpaceActive", fallback: "Active")
      internal static let spaceDeleted = Loc.tr("Localizable", "Space.Status.SpaceDeleted", fallback: "Deleted")
      internal static let spaceJoining = Loc.tr("Localizable", "Space.Status.SpaceJoining", fallback: "Joining")
      internal static let spaceRemoving = Loc.tr("Localizable", "Space.Status.SpaceRemoving", fallback: "Removing")
      internal static let unknown = Loc.tr("Localizable", "Space.Status.Unknown", fallback: "Unknown")
    }
  }
  internal enum SpaceCreate {
    internal static let title = Loc.tr("Localizable", "SpaceCreate.Title", fallback: "Create a space")
  }
  internal enum SpaceManager {
    internal static let cancelRequest = Loc.tr("Localizable", "SpaceManager.CancelRequest", fallback: "Cancel Join Request")
    internal static let doNotCancel = Loc.tr("Localizable", "SpaceManager.DoNotCancel", fallback: "Do Not Cancel")
    internal enum CancelRequestAlert {
      internal static let title = Loc.tr("Localizable", "SpaceManager.CancelRequestAlert.Title", fallback: "You will have to send request access again")
      internal static let toast = Loc.tr("Localizable", "SpaceManager.CancelRequestAlert.Toast", fallback: "The request was canceled.")
    }
  }
  internal enum SpaceSettings {
    internal static let deleteButton = Loc.tr("Localizable", "SpaceSettings.DeleteButton", fallback: "Delete space")
    internal static let info = Loc.tr("Localizable", "SpaceSettings.Info", fallback: "Space information")
    internal static let leaveButton = Loc.tr("Localizable", "SpaceSettings.LeaveButton", fallback: "Leave")
    internal static let networkId = Loc.tr("Localizable", "SpaceSettings.NetworkId", fallback: "Network ID")
    internal static let remoteStorage = Loc.tr("Localizable", "SpaceSettings.RemoteStorage", fallback: "Remote storage")
    internal static let share = Loc.tr("Localizable", "SpaceSettings.Share", fallback: "Share")
    internal static let title = Loc.tr("Localizable", "SpaceSettings.Title", fallback: "Space settings")
    internal enum DeleteAlert {
      internal static let message = Loc.tr("Localizable", "SpaceSettings.DeleteAlert.Message", fallback: "This space will be deleted irrevocably. You can’t undo this action.")
      internal static func title(_ p1: Any) -> String {
        return Loc.tr("Localizable", "SpaceSettings.DeleteAlert.Title", String(describing: p1), fallback: "Delete ‘%@’ space")
      }
    }
    internal enum LeaveAlert {
      internal static func message(_ p1: Any) -> String {
        return Loc.tr("Localizable", "SpaceSettings.LeaveAlert.Message", String(describing: p1), fallback: "%@ space will be removed from your devices and you will no longer have access to it")
      }
      internal static func toast(_ p1: Any) -> String {
        return Loc.tr("Localizable", "SpaceSettings.LeaveAlert.Toast", String(describing: p1), fallback: "You left the %@.")
      }
    }
  }
  internal enum SpaceShare {
    internal static let accessChanged = Loc.tr("Localizable", "SpaceShare.AccessChanged", fallback: "Access rights have been changed.")
    internal static func changePermissions(_ p1: Any, _ p2: Any) -> String {
      return Loc.tr("Localizable", "SpaceShare.ChangePermissions", String(describing: p1), String(describing: p2), fallback: "%@ access to the space would become %@.")
    }
    internal static let joinRequest = Loc.tr("Localizable", "SpaceShare.JoinRequest", fallback: "Join request")
    internal static let leaveRequest = Loc.tr("Localizable", "SpaceShare.LeaveRequest", fallback: "Leave request")
    internal static let manage = Loc.tr("Localizable", "SpaceShare.Manage", fallback: "Manage")
    internal static let manageSpaces = Loc.tr("Localizable", "SpaceShare.ManageSpaces", fallback: "Manage Spaces")
    internal static let members = Loc.tr("Localizable", "SpaceShare.Members", fallback: "Members")
    internal static func requestsCount(_ p1: Int) -> String {
      return Loc.tr("Localizable", "SpaceShare.RequestsCount", p1, fallback: "Plural format key: \"%#@object@\"")
    }
    internal static let title = Loc.tr("Localizable", "SpaceShare.Title", fallback: "Sharing")
    internal static func youSuffix(_ p1: Any) -> String {
      return Loc.tr("Localizable", "SpaceShare.YouSuffix", String(describing: p1), fallback: "%@ (you)")
    }
    internal enum Action {
      internal static let approve = Loc.tr("Localizable", "SpaceShare.Action.Approve", fallback: "Approve")
      internal static let viewRequest = Loc.tr("Localizable", "SpaceShare.Action.ViewRequest", fallback: "View request")
    }
    internal enum AlreadyJoin {
      internal static let openSpace = Loc.tr("Localizable", "SpaceShare.AlreadyJoin.OpenSpace", fallback: "Open space")
      internal static let title = Loc.tr("Localizable", "SpaceShare.AlreadyJoin.Title", fallback: "You are already a member of this space")
    }
    internal enum Approve {
      internal static func toast(_ p1: Any) -> String {
        return Loc.tr("Localizable", "SpaceShare.Approve.Toast", String(describing: p1), fallback: "You approved %@'s request.")
      }
    }
    internal enum DeleteSharingLink {
      internal static let message = Loc.tr("Localizable", "SpaceShare.DeleteSharingLink.Message", fallback: "New members won’t be able to join the space. You can generate a new link anytime")
      internal static let title = Loc.tr("Localizable", "SpaceShare.DeleteSharingLink.Title", fallback: "Delete link")
    }
    internal enum HowToShare {
      internal static let step1 = Loc.tr("Localizable", "SpaceShare.HowToShare.Step1", fallback: "Please provide the link to the person you'd like to collaborate with.")
      internal static let step2 = Loc.tr("Localizable", "SpaceShare.HowToShare.Step2", fallback: "By clicking the link, a person requests to join the space.")
      internal static let step3 = Loc.tr("Localizable", "SpaceShare.HowToShare.Step3", fallback: "After approving the request, you can choose the access rights for that person.")
      internal static let title = Loc.tr("Localizable", "SpaceShare.HowToShare.Title", fallback: "How to share a space?")
    }
    internal enum Invite {
      internal static let description = Loc.tr("Localizable", "SpaceShare.Invite.Description", fallback: "Share this invite link so that others can join your Space. Once they click your link and request access, you can set their access rights.")
      internal static let empty = Loc.tr("Localizable", "SpaceShare.Invite.Empty", fallback: "Create invite link to share space and add new members")
      internal static let generate = Loc.tr("Localizable", "SpaceShare.Invite.Generate", fallback: "Generate invite link")
      internal static func maxLimit(_ p1: Int) -> String {
        return Loc.tr("Localizable", "SpaceShare.Invite.MaxLimit", p1, fallback: "Plural format key: \"%#@object@\"")
      }
      internal static let share = Loc.tr("Localizable", "SpaceShare.Invite.Share", fallback: "Share invite link")
      internal static let title = Loc.tr("Localizable", "SpaceShare.Invite.Title", fallback: "Invite link")
    }
    internal enum Join {
      internal static let button = Loc.tr("Localizable", "SpaceShare.Join.Button", fallback: "Request to join")
      internal static let commentPlaceholder = Loc.tr("Localizable", "SpaceShare.Join.CommentPlaceholder", fallback: "Leave a private comment for a space owner")
      internal static let info = Loc.tr("Localizable", "SpaceShare.Join.Info", fallback: "Once the space owner approves your request, you'll join the space with the access rights owner determined.")
      internal static let inviteNotFound = Loc.tr("Localizable", "SpaceShare.Join.InviteNotFound", fallback: "This link doesn’t seem to work")
      internal static func message(_ p1: Any, _ p2: Any) -> String {
        return Loc.tr("Localizable", "SpaceShare.Join.Message", String(describing: p1), String(describing: p2), fallback: "You’ve been invited to join **%@** space, created by **%@**. Send a request so space owner can let you in.")
      }
      internal static let objectIsNotAvailable = Loc.tr("Localizable", "SpaceShare.Join.ObjectIsNotAvailable", fallback: "Object is not available. Ask the owner to share it.")
      internal static let spaceDeleted = Loc.tr("Localizable", "SpaceShare.Join.SpaceDeleted", fallback: "The space you try to access has been deleted")
      internal static let title = Loc.tr("Localizable", "SpaceShare.Join.Title", fallback: "Join a space")
    }
    internal enum JoinConfirmation {
      internal static let message = Loc.tr("Localizable", "SpaceShare.JoinConfirmation.Message", fallback: "You will receive a notification when the space owner will approve your request.")
      internal static let title = Loc.tr("Localizable", "SpaceShare.JoinConfirmation.Title", fallback: "Request sent")
    }
    internal enum Permissions {
      internal static let owner = Loc.tr("Localizable", "SpaceShare.Permissions.Owner", fallback: "Owner")
      internal static let reader = Loc.tr("Localizable", "SpaceShare.Permissions.Reader", fallback: "Viewer")
      internal static let writer = Loc.tr("Localizable", "SpaceShare.Permissions.Writer", fallback: "Editor")
      internal enum Grand {
        internal static let edit = Loc.tr("Localizable", "SpaceShare.Permissions.Grand.Edit", fallback: "Edit")
        internal static let view = Loc.tr("Localizable", "SpaceShare.Permissions.Grand.View", fallback: "View")
      }
    }
    internal enum Qr {
      internal static let button = Loc.tr("Localizable", "SpaceShare.QR.Button", fallback: "Show QR code")
      internal static let title = Loc.tr("Localizable", "SpaceShare.QR.Title", fallback: "QR code for joining a Space")
    }
    internal enum RemoveMember {
      internal static func message(_ p1: Any) -> String {
        return Loc.tr("Localizable", "SpaceShare.RemoveMember.Message", String(describing: p1), fallback: "%@ will be removed from the space.")
      }
      internal static let title = Loc.tr("Localizable", "SpaceShare.RemoveMember.Title", fallback: "Remove member")
    }
    internal enum StopSharing {
      internal static let action = Loc.tr("Localizable", "SpaceShare.StopSharing.Action", fallback: "Stop sharing")
      internal static let message = Loc.tr("Localizable", "SpaceShare.StopSharing.Message", fallback: "Members will no longer sync to this space and the share link will be deactivated.")
      internal static let title = Loc.tr("Localizable", "SpaceShare.StopSharing.Title", fallback: "Stop sharing the space")
      internal static let toast = Loc.tr("Localizable", "SpaceShare.StopSharing.Toast", fallback: "The space is no longer shared")
    }
    internal enum Tip {
      internal static let title = Loc.tr("Localizable", "SpaceShare.Tip.Title", fallback: "Collaborate on spaces")
      internal enum Steps {
        internal static let _1 = Loc.tr("Localizable", "SpaceShare.Tip.Steps.1", fallback: "Tap the Space widget to access settings")
        internal static let _2 = Loc.tr("Localizable", "SpaceShare.Tip.Steps.2", fallback: "Open Share section")
        internal static let _3 = Loc.tr("Localizable", "SpaceShare.Tip.Steps.3", fallback: "Generate an invite link and share it")
      }
    }
    internal enum ViewRequest {
      internal static let editAccess = Loc.tr("Localizable", "SpaceShare.ViewRequest.EditAccess", fallback: "Add as editor")
      internal static let reject = Loc.tr("Localizable", "SpaceShare.ViewRequest.Reject", fallback: "Reject")
      internal static func title(_ p1: Any, _ p2: Any) -> String {
        return Loc.tr("Localizable", "SpaceShare.ViewRequest.Title", String(describing: p1), String(describing: p2), fallback: "%@ requested to join %@ space")
      }
      internal static let viewAccess = Loc.tr("Localizable", "SpaceShare.ViewRequest.ViewAccess", fallback: "Add as viewer")
    }
  }
  internal enum Spaces {
    internal static let title = Loc.tr("Localizable", "Spaces.Title", fallback: "Spaces")
    internal enum Accessibility {
      internal static let personal = Loc.tr("Localizable", "Spaces.Accessibility.Personal", fallback: "Entry Space")
      internal static let `private` = Loc.tr("Localizable", "Spaces.Accessibility.Private", fallback: "Private Space")
      internal static let shared = Loc.tr("Localizable", "Spaces.Accessibility.Shared", fallback: "Shared Space")
    }
    internal enum Info {
      internal static let network = Loc.tr("Localizable", "Spaces.Info.Network", fallback: "Network:")
    }
    internal enum Search {
      internal static let title = Loc.tr("Localizable", "Spaces.Search.Title", fallback: "Search spaces")
    }
  }
  internal enum StoreKitServiceError {
    internal static let needUserAction = Loc.tr("Localizable", "StoreKitServiceError.needUserAction", fallback: "Payment unsuccessfull, User Actions on Apple side required to pay.")
    internal static let userCancelled = Loc.tr("Localizable", "StoreKitServiceError.userCancelled", fallback: "Purchase cancelled")
  }
  internal enum StyleMenu {
    internal enum Color {
      internal enum TextColor {
        internal static let placeholder = Loc.tr("Localizable", "StyleMenu.Color.TextColor.Placeholder", fallback: "A")
      }
    }
  }
  internal enum Swipe {
    internal enum Tip {
      internal static let subtitle = Loc.tr("Localizable", "Swipe.Tip.Subtitle", fallback: "Create objects inside widgets by easily swiping them left.")
      internal static let title = Loc.tr("Localizable", "Swipe.Tip.Title", fallback: "Swipe to Create Objects")
    }
  }
  internal enum Sync {
    internal enum Status {
      internal enum Version {
        internal enum Outdated {
          internal static let description = Loc.tr("Localizable", "Sync.Status.Version.Outdated.Description", fallback: "Version outdated. Please update Anytype")
        }
      }
    }
  }
  internal enum SyncStatus {
    internal enum Error {
      internal static let incompatibleVersion = Loc.tr("Localizable", "SyncStatus.Error.incompatibleVersion", fallback: "Incompatible version")
      internal static let networkError = Loc.tr("Localizable", "SyncStatus.Error.networkError", fallback: "No access to the space")
      internal static let storageLimitExceed = Loc.tr("Localizable", "SyncStatus.Error.storageLimitExceed", fallback: "Storage limit reached")
      internal static let unrecognized = Loc.tr("Localizable", "SyncStatus.Error.UNRECOGNIZED", fallback: "Unrecognized error")
    }
    internal enum Info {
      internal static let anytypeNetwork = Loc.tr("Localizable", "SyncStatus.Info.AnytypeNetwork", fallback: "End-to-end encrypted")
      internal static let localOnly = Loc.tr("Localizable", "SyncStatus.Info.localOnly", fallback: "Data backup is disabled")
      internal static let networkNeedsUpdate = Loc.tr("Localizable", "SyncStatus.Info.NetworkNeedsUpdate", fallback: "Sync might be slow. Update the app.")
    }
    internal enum P2P {
      internal static let notConnected = Loc.tr("Localizable", "SyncStatus.P2P.NotConnected", fallback: "Not connected")
      internal static let notPossible = Loc.tr("Localizable", "SyncStatus.P2P.NotPossible", fallback: "Connection not possible")
      internal static let restricted = Loc.tr("Localizable", "SyncStatus.P2P.Restricted", fallback: "Restricted. Tap to open device settings.")
    }
  }
  internal enum TalbeOfContents {
    internal static let empty = Loc.tr("Localizable", "TalbeOfContents.Empty", fallback: "Add headings to create a table of contents")
  }
  internal enum TemplateEditing {
    internal static let title = Loc.tr("Localizable", "TemplateEditing.Title", fallback: "Edit template")
  }
  internal enum TemplateOptions {
    internal enum Alert {
      internal static let delete = Loc.tr("Localizable", "TemplateOptions.Alert.Delete", fallback: "Delete")
      internal static let duplicate = Loc.tr("Localizable", "TemplateOptions.Alert.Duplicate", fallback: "Duplicate")
      internal static let editTemplate = Loc.tr("Localizable", "TemplateOptions.Alert.EditTemplate", fallback: "Edit template")
    }
  }
  internal enum TemplatePicker {
    internal static let chooseTemplate = Loc.tr("Localizable", "TemplatePicker.ChooseTemplate", fallback: "Choose template")
    internal enum Buttons {
      internal static let useTemplate = Loc.tr("Localizable", "TemplatePicker.Buttons.UseTemplate", fallback: "Use template")
    }
  }
  internal enum TemplateSelection {
    internal static let selectTemplate = Loc.tr("Localizable", "TemplateSelection.SelectTemplate", fallback: "Select template")
    internal enum Available {
      internal static func title(_ p1: Int) -> String {
        return Loc.tr("Localizable", "TemplateSelection.Available.Title", p1, fallback: "Plural format key: \"%#@object@\"")
      }
    }
    internal enum ObjectType {
      internal static let subtitle = Loc.tr("Localizable", "TemplateSelection.ObjectType.Subtitle", fallback: "Object type")
    }
    internal enum Template {
      internal static let subtitle = Loc.tr("Localizable", "TemplateSelection.Template.Subtitle", fallback: "Template")
    }
  }
  internal enum Templates {
    internal enum Popup {
      internal static let `default` = Loc.tr("Localizable", "Templates.Popup.Default", fallback: "The template was set as default")
      internal static let duplicated = Loc.tr("Localizable", "Templates.Popup.Duplicated", fallback: "The template was duplicated")
      internal static let removed = Loc.tr("Localizable", "Templates.Popup.Removed", fallback: "The template was removed")
      internal static let wasAddedTo = Loc.tr("Localizable", "Templates.Popup.WasAddedTo", fallback: "New template was added to the type")
      internal enum WasAddedTo {
        internal static func title(_ p1: Any) -> String {
          return Loc.tr("Localizable", "Templates.Popup.WasAddedTo.title", String(describing: p1), fallback: "New template was added to the type %@")
        }
      }
    }
  }
  internal enum TextStyle {
    internal enum Bold {
      internal static let title = Loc.tr("Localizable", "TextStyle.Bold.Title", fallback: "Bold")
    }
    internal enum Bulleted {
      internal static let subtitle = Loc.tr("Localizable", "TextStyle.Bulleted.Subtitle", fallback: "Simple list")
      internal static let title = Loc.tr("Localizable", "TextStyle.Bulleted.Title", fallback: "Bulleted")
    }
    internal enum Callout {
      internal static let subtitle = Loc.tr("Localizable", "TextStyle.Callout.Subtitle", fallback: "Bordered text with icon")
      internal static let title = Loc.tr("Localizable", "TextStyle.Callout.Title", fallback: "Callout")
    }
    internal enum Checkbox {
      internal static let subtitle = Loc.tr("Localizable", "TextStyle.Checkbox.Subtitle", fallback: "Create and track task with to-do list")
      internal static let title = Loc.tr("Localizable", "TextStyle.Checkbox.Title", fallback: "Checkbox")
    }
    internal enum Code {
      internal static let title = Loc.tr("Localizable", "TextStyle.Code.Title", fallback: "Code")
    }
    internal enum Heading {
      internal static let subtitle = Loc.tr("Localizable", "TextStyle.Heading.Subtitle", fallback: "Medium headline")
      internal static let title = Loc.tr("Localizable", "TextStyle.Heading.Title", fallback: "Heading")
    }
    internal enum Highlighted {
      internal static let subtitle = Loc.tr("Localizable", "TextStyle.Highlighted.Subtitle", fallback: "Spotlight, that needs special attention")
      internal static let title = Loc.tr("Localizable", "TextStyle.Highlighted.Title", fallback: "Highlighted")
    }
    internal enum Italic {
      internal static let title = Loc.tr("Localizable", "TextStyle.Italic.Title", fallback: "Italic")
    }
    internal enum Link {
      internal static let title = Loc.tr("Localizable", "TextStyle.Link.Title", fallback: "Link")
    }
    internal enum Numbered {
      internal static let subtitle = Loc.tr("Localizable", "TextStyle.Numbered.Subtitle", fallback: "Numbered list")
      internal static let title = Loc.tr("Localizable", "TextStyle.Numbered.Title", fallback: "Numbered list")
    }
    internal enum Strikethrough {
      internal static let title = Loc.tr("Localizable", "TextStyle.Strikethrough.Title", fallback: "Strikethrough")
    }
    internal enum Subheading {
      internal static let subtitle = Loc.tr("Localizable", "TextStyle.Subheading.Subtitle", fallback: "Small headline")
      internal static let title = Loc.tr("Localizable", "TextStyle.Subheading.Title", fallback: "Subheading")
    }
    internal enum Text {
      internal static let subtitle = Loc.tr("Localizable", "TextStyle.Text.Subtitle", fallback: "Just start writing with a plain text")
      internal static let title = Loc.tr("Localizable", "TextStyle.Text.Title", fallback: "Text")
    }
    internal enum Title {
      internal static let subtitle = Loc.tr("Localizable", "TextStyle.Title.Subtitle", fallback: "Big section heading")
      internal static let title = Loc.tr("Localizable", "TextStyle.Title.Title", fallback: "Title")
    }
    internal enum Toggle {
      internal static let subtitle = Loc.tr("Localizable", "TextStyle.Toggle.Subtitle", fallback: "Hide and show content inside")
      internal static let title = Loc.tr("Localizable", "TextStyle.Toggle.Title", fallback: "Toggle")
    }
    internal enum Underline {
      internal static let title = Loc.tr("Localizable", "TextStyle.Underline.Title", fallback: "Underline")
    }
  }
  internal enum ToggleEmpty {
    internal static let tapToCreateBlock = Loc.tr("Localizable", "Toggle empty. Tap to create block.", fallback: "Toggle empty. Tap to create block.")
  }
  internal enum Vault {
    internal enum Select {
      internal enum Incompatible {
        internal enum Version {
          internal enum Error {
            internal static let text = Loc.tr("Localizable", "Vault.Select.Incompatible.Version.Error.Text", fallback: "We were unable to retrieve your vault data because your version is out-of-date. Please update Anytype to the latest version.")
          }
        }
      }
    }
  }
  internal enum VersionHistory {
    internal static let title = Loc.tr("Localizable", "VersionHistory.Title", fallback: "Version History")
    internal enum Toast {
      internal static func message(_ p1: Any) -> String {
        return Loc.tr("Localizable", "VersionHistory.Toast.message", String(describing: p1), fallback: "Version %@ was restored")
      }
    }
  }
  internal enum Wallet {
    internal enum Recovery {
      internal enum Error {
        internal static let description = Loc.tr("Localizable", "Wallet.Recovery.Error.description", fallback: "Invalid Key")
      }
    }
  }
  internal enum WidgetObjectList {
    internal enum ForceDelete {
      internal static let message = Loc.tr("Localizable", "WidgetObjectList.ForceDelete.Message", fallback: "You can’t undo this action.")
    }
  }
  internal enum Widgets {
    internal static let appUpdate = Loc.tr("Localizable", "Widgets.AppUpdate", fallback: "Anytype is ready to update")
    internal static let sourceSearch = Loc.tr("Localizable", "Widgets.SourceSearch", fallback: "Widget source")
    internal enum Actions {
      internal static let addBelow = Loc.tr("Localizable", "Widgets.Actions.AddBelow", fallback: "Add Below")
      internal static let addWidget = Loc.tr("Localizable", "Widgets.Actions.AddWidget", fallback: "Add Widget")
      internal static func binConfirm(_ p1: Int) -> String {
        return Loc.tr("Localizable", "Widgets.Actions.BinConfirm", p1, fallback: "Plural format key: \"%#@object@\"")
      }
      internal static let changeSource = Loc.tr("Localizable", "Widgets.Actions.ChangeSource", fallback: "Change Source")
      internal static let changeWidgetType = Loc.tr("Localizable", "Widgets.Actions.ChangeWidgetType", fallback: "Change Widget Type")
      internal static let editWidgets = Loc.tr("Localizable", "Widgets.Actions.EditWidgets", fallback: "Edit Widgets")
      internal static let emptyBin = Loc.tr("Localizable", "Widgets.Actions.EmptyBin", fallback: "Empty Bin")
      internal static let newObject = Loc.tr("Localizable", "Widgets.Actions.NewObject", fallback: "New Object")
      internal static let removeWidget = Loc.tr("Localizable", "Widgets.Actions.RemoveWidget", fallback: "Remove Widget")
      internal static let seeAllObjects = Loc.tr("Localizable", "Widgets.Actions.SeeAllObjects", fallback: "See all objects")
    }
    internal enum Empty {
      internal static let createObject = Loc.tr("Localizable", "Widgets.Empty.CreateObject", fallback: "Create Object")
      internal static let title = Loc.tr("Localizable", "Widgets.Empty.Title", fallback: "There are no objects here")
    }
    internal enum Layout {
      internal enum CompactList {
        internal static let description = Loc.tr("Localizable", "Widgets.Layout.CompactList.Description", fallback: "Widget with a compact list view")
        internal static let title = Loc.tr("Localizable", "Widgets.Layout.CompactList.Title", fallback: "Сompact list")
      }
      internal enum Link {
        internal static let description = Loc.tr("Localizable", "Widgets.Layout.Link.Description", fallback: "Compact widget view")
        internal static let title = Loc.tr("Localizable", "Widgets.Layout.Link.Title", fallback: "Link")
      }
      internal enum List {
        internal static let description = Loc.tr("Localizable", "Widgets.Layout.List.Description", fallback: "Widget with a list view")
        internal static let title = Loc.tr("Localizable", "Widgets.Layout.List.Title", fallback: "List")
      }
      internal enum Screen {
        internal static let title = Loc.tr("Localizable", "Widgets.Layout.Screen.Title", fallback: "Widget type")
      }
      internal enum Tree {
        internal static let description = Loc.tr("Localizable", "Widgets.Layout.Tree.Description", fallback: "Widget with a hierarchical structure")
        internal static let title = Loc.tr("Localizable", "Widgets.Layout.Tree.Title", fallback: "Tree")
      }
      internal enum View {
        internal static let description = Loc.tr("Localizable", "Widgets.Layout.View.Description", fallback: "Widget with a Query or Collection layout")
        internal static let title = Loc.tr("Localizable", "Widgets.Layout.View.Title", fallback: "View")
      }
    }
    internal enum Library {
      internal enum RecentlyEdited {
        internal static let name = Loc.tr("Localizable", "Widgets.Library.RecentlyEdited.Name", fallback: "Recently edited")
      }
      internal enum RecentlyOpened {
        internal static let description = Loc.tr("Localizable", "Widgets.Library.RecentlyOpened.Description", fallback: "On this device")
        internal static let name = Loc.tr("Localizable", "Widgets.Library.RecentlyOpened.Name", fallback: "Recently opened")
      }
    }
    internal enum Source {
      internal static let library = Loc.tr("Localizable", "Widgets.Source.Library", fallback: "Default sets")
      internal static let objects = Loc.tr("Localizable", "Widgets.Source.Objects", fallback: "Your objects")
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
