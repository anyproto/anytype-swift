// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum Loc {
  /// About
  internal static let about = Loc.tr("Localizable", "About", fallback: "About")
  /// Access
  internal static let access = Loc.tr("Localizable", "Access", fallback: "Access")
  /// Access to secret phrase from keychain
  internal static let accessToSecretPhraseFromKeychain = Loc.tr("Localizable", "Access to secret phrase from keychain", fallback: "Access to secret phrase from keychain")
  /// Account
  internal static let account = Loc.tr("Localizable", "Account", fallback: "Account")
  /// Account deleted
  internal static let accountDeleted = Loc.tr("Localizable", "Account deleted", fallback: "Account deleted")
  /// Account is deleted
  internal static let accountIsDeleted = Loc.tr("Localizable", "Account is deleted", fallback: "Account is deleted")
  /// Account recover error, try again
  internal static let accountRecoverError = Loc.tr("Localizable", "Account recover error", fallback: "Account recover error, try again")
  /// Account recover error, probably no internet connection
  internal static let accountRecoverErrorNoInternet = Loc.tr("Localizable", "Account recover error no internet", fallback: "Account recover error, probably no internet connection")
  /// Action-focused layout with a checkbox
  internal static let actionFocusedLayoutWithACheckbox = Loc.tr("Localizable", "Action-focused layout with a checkbox", fallback: "Action-focused layout with a checkbox")
  /// Actions
  internal static let actions = Loc.tr("Localizable", "Actions", fallback: "Actions")
  /// Add
  internal static let add = Loc.tr("Localizable", "Add", fallback: "Add")
  /// Add below
  internal static let addBelow = Loc.tr("Localizable", "Add below", fallback: "Add below")
  /// Add email
  internal static let addEmail = Loc.tr("Localizable", "Add email", fallback: "Add email")
  /// Add link
  internal static let addLink = Loc.tr("Localizable", "Add link", fallback: "Add link")
  /// Add number
  internal static let addNumber = Loc.tr("Localizable", "Add number", fallback: "Add number")
  /// Add phone
  internal static let addPhone = Loc.tr("Localizable", "Add phone", fallback: "Add phone")
  /// Add phone number
  internal static let addPhoneNumber = Loc.tr("Localizable", "Add phone number", fallback: "Add phone number")
  /// Add text
  internal static let addText = Loc.tr("Localizable", "Add text", fallback: "Add text")
  /// Add To Favorite
  internal static let addToFavorite = Loc.tr("Localizable", "Add To Favorite", fallback: "Add To Favorite")
  /// Add URL
  internal static let addURL = Loc.tr("Localizable", "Add URL", fallback: "Add URL")
  /// Align center
  internal static let alignCenter = Loc.tr("Localizable", "Align center", fallback: "Align center")
  /// Align left
  internal static let alignLeft = Loc.tr("Localizable", "Align left", fallback: "Align left")
  /// Align right
  internal static let alignRight = Loc.tr("Localizable", "Align right", fallback: "Align right")
  /// Alignment
  internal static let alignment = Loc.tr("Localizable", "Alignment", fallback: "Alignment")
  /// Amber
  internal static let amber = Loc.tr("Localizable", "Amber", fallback: "Amber")
  /// Amber background
  internal static let amberBackground = Loc.tr("Localizable", "Amber background", fallback: "Amber background")
  /// Anytype Library
  internal static let anytypeLibrary = Loc.tr("Localizable", "Anytype Library", fallback: "Anytype Library")
  /// Appearance
  internal static let appearance = Loc.tr("Localizable", "Appearance", fallback: "Appearance")
  /// Application icon
  internal static let applicationIcon = Loc.tr("Localizable", "Application icon", fallback: "Application icon")
  /// Plural format key: "Are you sure you want to delete %#@object@?"
  internal static func areYouSureYouWantToDelete(_ p1: Int) -> String {
    return Loc.tr("Localizable", "Are you sure you want to delete", p1, fallback: "Plural format key: \"Are you sure you want to delete %#@object@?\"")
  }
  /// Arrangement of objects on a canvas
  internal static let arrangementOfObjectsOnACanvas = Loc.tr("Localizable", "Arrangement of objects on a canvas", fallback: "Arrangement of objects on a canvas")
  /// Audio
  internal static let audio = Loc.tr("Localizable", "Audio", fallback: "Audio")
  /// Back
  internal static let back = Loc.tr("Localizable", "Back", fallback: "Back")
  /// Back up phrase
  internal static let backUpPhrase = Loc.tr("Localizable", "Back up phrase", fallback: "Back up phrase")
  /// Back up your recovery phrase
  internal static let backUpYourRecoveryPhrase = Loc.tr("Localizable", "Back up your recovery phrase", fallback: "Back up your recovery phrase")
  /// Background
  internal static let background = Loc.tr("Localizable", "Background", fallback: "Background")
  /// Background picture
  internal static let backgroundPicture = Loc.tr("Localizable", "Background picture", fallback: "Background picture")
  /// Basic
  internal static let basic = Loc.tr("Localizable", "Basic", fallback: "Basic")
  /// Bin
  internal static let bin = Loc.tr("Localizable", "Bin", fallback: "Bin")
  /// Black
  internal static let black = Loc.tr("Localizable", "Black", fallback: "Black")
  /// Blue
  internal static let blue = Loc.tr("Localizable", "Blue", fallback: "Blue")
  /// Blue background
  internal static let blueBackground = Loc.tr("Localizable", "Blue background", fallback: "Blue background")
  /// Bookmark
  internal static let bookmark = Loc.tr("Localizable", "Bookmark", fallback: "Bookmark")
  /// Save your favorite link with summary
  internal static let bookmarkBlockSubtitle = Loc.tr("Localizable", "Bookmark block subtitle", fallback: "Save your favorite link with summary")
  /// Callout
  internal static let callout = Loc.tr("Localizable", "Callout", fallback: "Callout")
  /// Cancel
  internal static let cancel = Loc.tr("Localizable", "Cancel", fallback: "Cancel")
  /// Cancel deletion
  internal static let cancelDeletion = Loc.tr("Localizable", "Cancel deletion", fallback: "Cancel deletion")
  /// Change cover
  internal static let changeCover = Loc.tr("Localizable", "Change cover", fallback: "Change cover")
  /// Change icon
  internal static let changeIcon = Loc.tr("Localizable", "Change icon", fallback: "Change icon")
  /// Change type
  internal static let changeType = Loc.tr("Localizable", "Change type", fallback: "Change type")
  /// Change wallpaper
  internal static let changeWallpaper = Loc.tr("Localizable", "Change wallpaper", fallback: "Change wallpaper")
  /// Choose default object type
  internal static let chooseDefaultObjectType = Loc.tr("Localizable", "Choose default object type", fallback: "Choose default object type")
  /// Choose layout type
  internal static let chooseLayoutType = Loc.tr("Localizable", "Choose layout type", fallback: "Choose layout type")
  /// Clear
  internal static let clear = Loc.tr("Localizable", "Clear", fallback: "Clear")
  /// Close
  internal static let close = Loc.tr("Localizable", "Close", fallback: "Close")
  /// Capture code snippet
  internal static let codeBlockSubtitle = Loc.tr("Localizable", "Code block subtitle", fallback: "Capture code snippet")
  /// Code snippet
  internal static let codeSnippet = Loc.tr("Localizable", "Code snippet", fallback: "Code snippet")
  /// Collection
  internal static let collection = Loc.tr("Localizable", "Collection", fallback: "Collection")
  /// Collection of objects
  internal static let collectionOfObjects = Loc.tr("Localizable", "Collection of objects", fallback: "Collection of objects")
  /// Collections
  internal static let collections = Loc.tr("Localizable", "Collections", fallback: "Collections")
  /// Color
  internal static let color = Loc.tr("Localizable", "Color", fallback: "Color")
  /// Companies, contacts, friends and family
  internal static let companiesContactsFriendsAndFamily = Loc.tr("Localizable", "Companies, contacts, friends and family", fallback: "Companies, contacts, friends and family")
  /// Copied
  internal static let copied = Loc.tr("Localizable", "Copied", fallback: "Copied")
  /// %@ copied to clipboard
  internal static func copiedToClipboard(_ p1: Any) -> String {
    return Loc.tr("Localizable", "copied to clipboard", String(describing: p1), fallback: "%@ copied to clipboard")
  }
  /// Copy
  internal static let copy = Loc.tr("Localizable", "Copy", fallback: "Copy")
  /// Cover
  internal static let cover = Loc.tr("Localizable", "Cover", fallback: "Cover")
  /// Create
  internal static let create = Loc.tr("Localizable", "Create", fallback: "Create")
  /// Create a new one or search for something else
  internal static let createANewOneOrSearchForSomethingElse = Loc.tr("Localizable", "Create a new one or search for something else", fallback: "Create a new one or search for something else")
  /// Create new object
  internal static let createNewObject = Loc.tr("Localizable", "Create new object", fallback: "Create new object")
  /// Create object
  internal static let createObject = Loc.tr("Localizable", "Create object", fallback: "Create object")
  /// Create option ‘%@’
  internal static func createOption(_ p1: Any) -> String {
    return Loc.tr("Localizable", "Create option", String(describing: p1), fallback: "Create option ‘%@’")
  }
  /// Create relation ‘%@’
  internal static func createRelation(_ p1: Any) -> String {
    return Loc.tr("Localizable", "Create relation", String(describing: p1), fallback: "Create relation ‘%@’")
  }
  /// Plural format key: "This account will be deleted %#@days@"
  internal static func daysToDeletionAccount(_ p1: Int) -> String {
    return Loc.tr("Localizable", "Days to deletion account", p1, fallback: "Plural format key: \"This account will be deleted %#@days@\"")
  }
  /// Default background
  internal static let defaultBackground = Loc.tr("Localizable", "Default background", fallback: "Default background")
  /// Default object type
  internal static let defaultObjectType = Loc.tr("Localizable", "Default object type", fallback: "Default object type")
  /// Delete
  internal static let delete = Loc.tr("Localizable", "Delete", fallback: "Delete")
  /// Delete account
  internal static let deleteAccount = Loc.tr("Localizable", "Delete account", fallback: "Delete account")
  /// Deleted
  internal static let deleted = Loc.tr("Localizable", "Deleted", fallback: "Deleted")
  /// Deletion error
  internal static let deletionError = Loc.tr("Localizable", "Deletion error", fallback: "Deletion error")
  /// Description
  internal static let description = Loc.tr("Localizable", "Description", fallback: "Description")
  /// Deselect all
  internal static let deselectAll = Loc.tr("Localizable", "Deselect all", fallback: "Deselect all")
  /// Designed to capture thoughts quickly
  internal static let designedToCaptureThoughtsQuickly = Loc.tr("Localizable", "Designed to capture thoughts quickly", fallback: "Designed to capture thoughts quickly")
  /// Done
  internal static let done = Loc.tr("Localizable", "Done", fallback: "Done")
  /// Download
  internal static let download = Loc.tr("Localizable", "Download", fallback: "Download")
  /// Downloading or uploading data to some node
  internal static let downloadingOrUploadingDataToSomeNode = Loc.tr("Localizable", "Downloading or uploading data to some node", fallback: "Downloading or uploading data to some node")
  /// Duplicate
  internal static let duplicate = Loc.tr("Localizable", "Duplicate", fallback: "Duplicate")
  /// Edit
  internal static let edit = Loc.tr("Localizable", "Edit", fallback: "Edit")
  /// Emoji
  internal static let emoji = Loc.tr("Localizable", "Emoji", fallback: "Emoji")
  /// Emoji or image for object
  internal static let emojiOrImageForObject = Loc.tr("Localizable", "Emoji or image for object", fallback: "Emoji or image for object")
  /// Empty
  internal static let empty = Loc.tr("Localizable", "Empty", fallback: "Empty")
  /// Enter number
  internal static let enterNumber = Loc.tr("Localizable", "Enter number", fallback: "Enter number")
  /// Enter text
  internal static let enterText = Loc.tr("Localizable", "Enter text", fallback: "Enter text")
  /// Enter value
  internal static let enterValue = Loc.tr("Localizable", "Enter value", fallback: "Enter value")
  /// Error
  internal static let error = Loc.tr("Localizable", "Error", fallback: "Error")
  /// Error creating wallet
  internal static let errorCreatingWallet = Loc.tr("Localizable", "Error creating wallet", fallback: "Error creating wallet")
  /// Error select account
  internal static let errorSelectAccount = Loc.tr("Localizable", "Error select account", fallback: "Error select account")
  /// Error wallet recover account
  internal static let errorWalletRecoverAccount = Loc.tr("Localizable", "Error wallet recover account", fallback: "Error wallet recover account")
  /// Everywhere
  internal static let everywhere = Loc.tr("Localizable", "Everywhere", fallback: "Everywhere")
  /// Exact day
  internal static let exactDay = Loc.tr("Localizable", "Exact day", fallback: "Exact day")
  /// Failed to sync, trying again...
  internal static let failedToSyncTryingAgain = Loc.tr("Localizable", "Failed to sync, trying again...", fallback: "Failed to sync, trying again...")
  /// Favorite
  internal static let favorite = Loc.tr("Localizable", "Favorite", fallback: "Favorite")
  /// Favorites
  internal static let favorites = Loc.tr("Localizable", "Favorites", fallback: "Favorites")
  /// Featured relations
  internal static let featuredRelations = Loc.tr("Localizable", "Featured relations", fallback: "Featured relations")
  /// File
  internal static let file = Loc.tr("Localizable", "File", fallback: "File")
  /// Store file in original state
  internal static let fileBlockSubtitle = Loc.tr("Localizable", "File block subtitle", fallback: "Store file in original state")
  /// Filter
  internal static let filter = Loc.tr("Localizable", "Filter", fallback: "Filter")
  /// Gallery
  internal static let gallery = Loc.tr("Localizable", "Gallery", fallback: "Gallery")
  /// Go back
  internal static let goBack = Loc.tr("Localizable", "Go back", fallback: "Go back")
  /// Gradients
  internal static let gradients = Loc.tr("Localizable", "Gradients", fallback: "Gradients")
  /// Green
  internal static let green = Loc.tr("Localizable", "Green", fallback: "Green")
  /// Green background
  internal static let greenBackground = Loc.tr("Localizable", "Green background", fallback: "Green background")
  /// Grey
  internal static let grey = Loc.tr("Localizable", "Grey", fallback: "Grey")
  /// Grey background
  internal static let greyBackground = Loc.tr("Localizable", "Grey background", fallback: "Grey background")
  /// Highlight
  internal static let highlight = Loc.tr("Localizable", "Highlight", fallback: "Highlight")
  /// Home
  internal static let home = Loc.tr("Localizable", "Home", fallback: "Home")
  /// Icon
  internal static let icon = Loc.tr("Localizable", "Icon", fallback: "Icon")
  /// In this object
  internal static let inThisObject = Loc.tr("Localizable", "In this object", fallback: "In this object")
  /// Initializing sync
  internal static let initializingSync = Loc.tr("Localizable", "Initializing sync", fallback: "Initializing sync")
  /// Into object
  internal static let intoObject = Loc.tr("Localizable", "Into object", fallback: "Into object")
  /// Layout
  internal static let layout = Loc.tr("Localizable", "Layout", fallback: "Layout")
  /// Limit object types
  internal static let limitObjectTypes = Loc.tr("Localizable", "Limit object types", fallback: "Limit object types")
  /// Link to
  internal static let linkTo = Loc.tr("Localizable", "Link to", fallback: "Link to")
  /// Plural format key: "%#@object@"
  internal static func linksCount(_ p1: Int) -> String {
    return Loc.tr("Localizable", "Links count", p1, fallback: "Plural format key: \"%#@object@\"")
  }
  /// List of related objects
  internal static let listOfRelatedObjects = Loc.tr("Localizable", "List of related objects", fallback: "List of related objects")
  /// Loading, please wait
  internal static let loadingPleaseWait = Loc.tr("Localizable", "Loading, please wait", fallback: "Loading, please wait")
  /// Lock
  internal static let lock = Loc.tr("Localizable", "Lock", fallback: "Lock")
  /// Log out
  internal static let logOut = Loc.tr("Localizable", "Log out", fallback: "Log out")
  /// Log In
  internal static let login = Loc.tr("Localizable", "Login", fallback: "Log In")
  /// Logout and clear data
  internal static let logoutAndClearData = Loc.tr("Localizable", "Logout and clear data", fallback: "Logout and clear data")
  /// Media
  internal static let media = Loc.tr("Localizable", "Media", fallback: "Media")
  /// Mode
  internal static let mode = Loc.tr("Localizable", "Mode", fallback: "Mode")
  /// Move
  internal static let move = Loc.tr("Localizable", "Move", fallback: "Move")
  /// Move to
  internal static let moveTo = Loc.tr("Localizable", "Move to", fallback: "Move to")
  /// Move To Bin
  internal static let moveToBin = Loc.tr("Localizable", "Move To Bin", fallback: "Move To Bin")
  /// Name
  internal static let name = Loc.tr("Localizable", "Name", fallback: "Name")
  /// New
  internal static let new = Loc.tr("Localizable", "New", fallback: "New")
  /// New relation
  internal static let newRelation = Loc.tr("Localizable", "New relation", fallback: "New relation")
  /// No connection
  internal static let noConnection = Loc.tr("Localizable", "No connection", fallback: "No connection")
  /// No date
  internal static let noDate = Loc.tr("Localizable", "No date", fallback: "No date")
  /// No items match filter
  internal static let noItemsMatchFilter = Loc.tr("Localizable", "No items match filter", fallback: "No items match filter")
  /// No name
  internal static let noName = Loc.tr("Localizable", "No name", fallback: "No name")
  /// No related options here. You can add some
  internal static let noRelatedOptionsHere = Loc.tr("Localizable", "No related options here", fallback: "No related options here. You can add some")
  /// Node is not connected
  internal static let nodeIsNotConnected = Loc.tr("Localizable", "Node is not connected", fallback: "Node is not connected")
  /// Non-existent object
  internal static let nonExistentObject = Loc.tr("Localizable", "Non-existent object", fallback: "Non-existent object")
  /// None
  internal static let `none` = Loc.tr("Localizable", "None", fallback: "None")
  /// Not syncing
  internal static let notSyncing = Loc.tr("Localizable", "Not syncing", fallback: "Not syncing")
  /// Note
  internal static let note = Loc.tr("Localizable", "Note", fallback: "Note")
  /// Nothing to redo
  internal static let nothingToRedo = Loc.tr("Localizable", "Nothing to redo", fallback: "Nothing to redo")
  /// Nothing to undo
  internal static let nothingToUndo = Loc.tr("Localizable", "Nothing to undo", fallback: "Nothing to undo")
  /// Plural format key: "%#@object@ selected"
  internal static func objectSelected(_ p1: Int) -> String {
    return Loc.tr("Localizable", "Object selected", p1, fallback: "Plural format key: \"%#@object@ selected\"")
  }
  /// Objects
  internal static let objects = Loc.tr("Localizable", "Objects", fallback: "Objects")
  /// Ok
  internal static let ok = Loc.tr("Localizable", "Ok", fallback: "Ok")
  /// On analytics
  internal static let onAnalytics = Loc.tr("Localizable", "On analytics", fallback: "On analytics")
  /// Open object
  internal static let openObject = Loc.tr("Localizable", "Open object", fallback: "Open object")
  /// Open source
  internal static let openSource = Loc.tr("Localizable", "Open source", fallback: "Open source")
  /// Not supported type "%@". You can open it via desktop.
  internal static func openTypeError(_ p1: Any) -> String {
    return Loc.tr("Localizable", "Open Type Error", String(describing: p1), fallback: "Not supported type \"%@\". You can open it via desktop.")
  }
  /// Other
  internal static let other = Loc.tr("Localizable", "Other", fallback: "Other")
  /// Other relations
  internal static let otherRelations = Loc.tr("Localizable", "Other relations", fallback: "Other relations")
  /// Paste
  internal static let paste = Loc.tr("Localizable", "Paste", fallback: "Paste")
  /// Paste or type URL
  internal static let pasteOrTypeURL = Loc.tr("Localizable", "Paste or type URL", fallback: "Paste or type URL")
  /// Paste processing...
  internal static let pasteProcessing = Loc.tr("Localizable", "Paste processing...", fallback: "Paste processing...")
  /// We're sorry to see you go. You have 30 days to cancel this request. After 30 days, your encrypted account data is permanently removed from the backup node.
  internal static let pendingDeletionText = Loc.tr("Localizable", "Pending deletion text", fallback: "We're sorry to see you go. You have 30 days to cancel this request. After 30 days, your encrypted account data is permanently removed from the backup node.")
  /// Personalization
  internal static let personalization = Loc.tr("Localizable", "Personalization", fallback: "Personalization")
  /// Picture
  internal static let picture = Loc.tr("Localizable", "Picture", fallback: "Picture")
  /// Upload and enrich the page with image
  internal static let pictureBlockSubtitle = Loc.tr("Localizable", "Picture block subtitle", fallback: "Upload and enrich the page with image")
  /// Pink
  internal static let pink = Loc.tr("Localizable", "Pink", fallback: "Pink")
  /// Pink background
  internal static let pinkBackground = Loc.tr("Localizable", "Pink background", fallback: "Pink background")
  /// Preparing...
  internal static let preparing = Loc.tr("Localizable", "Preparing...", fallback: "Preparing...")
  /// Preview
  internal static let preview = Loc.tr("Localizable", "Preview", fallback: "Preview")
  /// Preview layout
  internal static let previewLayout = Loc.tr("Localizable", "Preview layout", fallback: "Preview layout")
  /// Profile
  internal static let profile = Loc.tr("Localizable", "Profile", fallback: "Profile")
  /// Progress...
  internal static let progress = Loc.tr("Localizable", "Progress...", fallback: "Progress...")
  /// Purple
  internal static let purple = Loc.tr("Localizable", "Purple", fallback: "Purple")
  /// Purple background
  internal static let purpleBackground = Loc.tr("Localizable", "Purple background", fallback: "Purple background")
  /// Random
  internal static let random = Loc.tr("Localizable", "Random", fallback: "Random")
  /// Recent
  internal static let recent = Loc.tr("Localizable", "Recent", fallback: "Recent")
  /// Red
  internal static let red = Loc.tr("Localizable", "Red", fallback: "Red")
  /// Red background
  internal static let redBackground = Loc.tr("Localizable", "Red background", fallback: "Red background")
  /// Relations
  internal static let relations = Loc.tr("Localizable", "Relations", fallback: "Relations")
  /// Remove
  internal static let remove = Loc.tr("Localizable", "Remove", fallback: "Remove")
  /// Remove From Favorite
  internal static let removeFromFavorite = Loc.tr("Localizable", "Remove From Favorite", fallback: "Remove From Favorite")
  /// Remove photo
  internal static let removePhoto = Loc.tr("Localizable", "Remove photo", fallback: "Remove photo")
  /// Removing cache
  internal static let removingCache = Loc.tr("Localizable", "Removing cache", fallback: "Removing cache")
  /// Restore
  internal static let restore = Loc.tr("Localizable", "Restore", fallback: "Restore")
  /// Restore from keychain
  internal static let restoreFromKeychain = Loc.tr("Localizable", "Restore from keychain", fallback: "Restore from keychain")
  /// Restore Recovery Phrase from the keychain
  internal static let restoreSecretPhraseFromKeychain = Loc.tr("Localizable", "Restore secret phrase from keychain", fallback: "Restore Recovery Phrase from the keychain")
  /// Scan QR code
  internal static let scanQRCode = Loc.tr("Localizable", "Scan QR code", fallback: "Scan QR code")
  /// Search
  internal static let search = Loc.tr("Localizable", "Search", fallback: "Search")
  /// Search for language
  internal static let searchForLanguage = Loc.tr("Localizable", "Search for language", fallback: "Search for language")
  /// Select account error
  internal static let selectAccountError = Loc.tr("Localizable", "Select account error", fallback: "Select account error")
  /// Select all
  internal static let selectAll = Loc.tr("Localizable", "Select all", fallback: "Select all")
  /// Select date
  internal static let selectDate = Loc.tr("Localizable", "Select date", fallback: "Select date")
  /// Select file
  internal static let selectFile = Loc.tr("Localizable", "Select file", fallback: "Select file")
  /// Select object
  internal static let selectObject = Loc.tr("Localizable", "Select object", fallback: "Select object")
  /// Select relation type
  internal static let selectRelationType = Loc.tr("Localizable", "Select relation type", fallback: "Select relation type")
  /// Select status
  internal static let selectStatus = Loc.tr("Localizable", "Select status", fallback: "Select status")
  /// Select tag
  internal static let selectTag = Loc.tr("Localizable", "Select tag", fallback: "Select tag")
  /// Plural format key: "%#@object@"
  internal static func selectedBlocks(_ p1: Int) -> String {
    return Loc.tr("Localizable", "Selected blocks", p1, fallback: "Plural format key: \"%#@object@\"")
  }
  /// Set
  internal static let `set` = Loc.tr("Localizable", "Set", fallback: "Set")
  /// Sets
  internal static let sets = Loc.tr("Localizable", "Sets", fallback: "Sets")
  /// Setting up encrypted storage
  /// Please wait
  internal static let settingUpEncryptedStoragePleaseWait = Loc.tr("Localizable", "Setting up encrypted storage\nPlease wait", fallback: "Setting up encrypted storage\nPlease wait")
  /// Settings
  internal static let settings = Loc.tr("Localizable", "Settings", fallback: "Settings")
  /// Shared
  internal static let shared = Loc.tr("Localizable", "Shared", fallback: "Shared")
  /// Sign up
  internal static let signUp = Loc.tr("Localizable", "Sign up", fallback: "Sign up")
  /// Sky
  internal static let sky = Loc.tr("Localizable", "Sky", fallback: "Sky")
  /// Sky background
  internal static let skyBackground = Loc.tr("Localizable", "Sky background", fallback: "Sky background")
  /// Solid colors
  internal static let solidColors = Loc.tr("Localizable", "Solid colors", fallback: "Solid colors")
  /// Sort
  internal static let sort = Loc.tr("Localizable", "Sort", fallback: "Sort")
  /// Standard layout for canvas blocks
  internal static let standardLayoutForCanvasBlocks = Loc.tr("Localizable", "Standard layout for canvas blocks", fallback: "Standard layout for canvas blocks")
  /// Start
  internal static let start = Loc.tr("Localizable", "Start", fallback: "Start")
  /// Style
  internal static let style = Loc.tr("Localizable", "Style", fallback: "Style")
  /// Synced
  internal static let synced = Loc.tr("Localizable", "Synced", fallback: "Synced")
  /// Syncing...
  internal static let syncing = Loc.tr("Localizable", "Syncing...", fallback: "Syncing...")
  /// Task
  internal static let task = Loc.tr("Localizable", "Task", fallback: "Task")
  /// Teal
  internal static let teal = Loc.tr("Localizable", "Teal", fallback: "Teal")
  /// Teal background
  internal static let tealBackground = Loc.tr("Localizable", "Teal background", fallback: "Teal background")
  /// There is no emoji named
  internal static let thereIsNoEmojiNamed = Loc.tr("Localizable", "There is no emoji named", fallback: "There is no emoji named")
  /// There is no object named %@
  internal static func thereIsNoObjectNamed(_ p1: Any) -> String {
    return Loc.tr("Localizable", "There is no object named", String(describing: p1), fallback: "There is no object named %@")
  }
  /// There is no type named %@
  internal static func thereIsNoTypeNamed(_ p1: Any) -> String {
    return Loc.tr("Localizable", "There is no type named", String(describing: p1), fallback: "There is no type named %@")
  }
  /// These objects will be deleted irrevocably. You can’t undo this action.
  internal static let theseObjectsWillBeDeletedIrrevocably = Loc.tr("Localizable", "These objects will be deleted irrevocably", fallback: "These objects will be deleted irrevocably. You can’t undo this action.")
  /// This object doesn't exist
  internal static let thisObjectDoesnTExist = Loc.tr("Localizable", "This object doesn't exist", fallback: "This object doesn't exist")
  /// To Bin
  internal static let toBin = Loc.tr("Localizable", "To Bin", fallback: "To Bin")
  /// Today
  internal static let today = Loc.tr("Localizable", "Today", fallback: "Today")
  /// Tomorrow
  internal static let tomorrow = Loc.tr("Localizable", "Tomorrow", fallback: "Tomorrow")
  /// Try to find a new one or upload your image
  internal static let tryToFindANewOneOrUploadYourImage = Loc.tr("Localizable", "Try to find a new one or upload your image", fallback: "Try to find a new one or upload your image")
  /// Type
  internal static let type = Loc.tr("Localizable", "Type", fallback: "Type")
  /// Undo
  internal static let undo = Loc.tr("Localizable", "Undo", fallback: "Undo")
  /// Undo typing
  internal static let undoTyping = Loc.tr("Localizable", "Undo typing", fallback: "Undo typing")
  /// Undo/Redo
  internal static let undoRedo = Loc.tr("Localizable", "Undo/Redo", fallback: "Undo/Redo")
  /// Unfavorite
  internal static let unfavorite = Loc.tr("Localizable", "Unfavorite", fallback: "Unfavorite")
  /// Unknown
  internal static let unknown = Loc.tr("Localizable", "Unknown", fallback: "Unknown")
  /// Unknown error
  internal static let unknownError = Loc.tr("Localizable", "Unknown error", fallback: "Unknown error")
  /// Unlock
  internal static let unlock = Loc.tr("Localizable", "Unlock", fallback: "Unlock")
  /// Unselect all
  internal static let unselectAll = Loc.tr("Localizable", "Unselect all", fallback: "Unselect all")
  /// Unsplash
  internal static let unsplash = Loc.tr("Localizable", "Unsplash", fallback: "Unsplash")
  /// Unsupported block
  internal static let unsupportedBlock = Loc.tr("Localizable", "Unsupported block", fallback: "Unsupported block")
  /// Unsupported value
  internal static let unsupportedValue = Loc.tr("Localizable", "Unsupported value", fallback: "Unsupported value")
  /// Upload
  internal static let upload = Loc.tr("Localizable", "Upload", fallback: "Upload")
  /// Upload playable audio
  internal static let uploadPlayableAudio = Loc.tr("Localizable", "Upload playable audio", fallback: "Upload playable audio")
  /// Video
  internal static let video = Loc.tr("Localizable", "Video", fallback: "Video")
  /// Upload playable video
  internal static let videoBlockSubtitle = Loc.tr("Localizable", "Video block subtitle", fallback: "Upload playable video")
  /// View
  internal static let view = Loc.tr("Localizable", "View", fallback: "View")
  /// Views
  internal static let views = Loc.tr("Localizable", "Views", fallback: "Views")
  /// Wallpaper
  internal static let wallpaper = Loc.tr("Localizable", "Wallpaper", fallback: "Wallpaper")
  /// Web pages
  internal static let webPages = Loc.tr("Localizable", "Web pages", fallback: "Web pages")
  /// Yellow
  internal static let yellow = Loc.tr("Localizable", "Yellow", fallback: "Yellow")
  /// Yellow background
  internal static let yellowBackground = Loc.tr("Localizable", "Yellow background", fallback: "Yellow background")
  /// Yesterday
  internal static let yesterday = Loc.tr("Localizable", "Yesterday", fallback: "Yesterday")
  internal enum About {
    /// Account ID: %@
    internal static func accountId(_ p1: Any) -> String {
      return Loc.tr("Localizable", "About.accountId", String(describing: p1), fallback: "Account ID: %@")
    }
    /// Analytics ID: %@
    internal static func analyticsId(_ p1: Any) -> String {
      return Loc.tr("Localizable", "About.analyticsId", String(describing: p1), fallback: "Analytics ID: %@")
    }
    /// Anytype Community
    internal static let anytypeCommunity = Loc.tr("Localizable", "About.AnytypeCommunity", fallback: "Anytype Community")
    /// App version: %@
    internal static func appVersion(_ p1: Any) -> String {
      return Loc.tr("Localizable", "About.AppVersion", String(describing: p1), fallback: "App version: %@")
    }
    /// Build number: %@
    internal static func buildNumber(_ p1: Any) -> String {
      return Loc.tr("Localizable", "About.BuildNumber", String(describing: p1), fallback: "Build number: %@")
    }
    /// Contact Us
    internal static let contactUs = Loc.tr("Localizable", "About.ContactUs", fallback: "Contact Us")
    /// Device: %@
    internal static func device(_ p1: Any) -> String {
      return Loc.tr("Localizable", "About.Device", String(describing: p1), fallback: "Device: %@")
    }
    /// Device ID: %@
    internal static func deviceId(_ p1: Any) -> String {
      return Loc.tr("Localizable", "About.deviceId", String(describing: p1), fallback: "Device ID: %@")
    }
    /// Help & Community
    internal static let helpCommunity = Loc.tr("Localizable", "About.HelpCommunity", fallback: "Help & Community")
    /// Help & Tutorials
    internal static let helpTutorials = Loc.tr("Localizable", "About.HelpTutorials", fallback: "Help & Tutorials")
    /// Legal
    internal static let legal = Loc.tr("Localizable", "About.Legal", fallback: "Legal")
    /// Library version: %@
    internal static func library(_ p1: Any) -> String {
      return Loc.tr("Localizable", "About.Library", String(describing: p1), fallback: "Library version: %@")
    }
    /// OS version: %@
    internal static func osVersion(_ p1: Any) -> String {
      return Loc.tr("Localizable", "About.OSVersion", String(describing: p1), fallback: "OS version: %@")
    }
    /// Privacy Policy
    internal static let privacyPolicy = Loc.tr("Localizable", "About.PrivacyPolicy", fallback: "Privacy Policy")
    /// Tech Info
    internal static let techInfo = Loc.tr("Localizable", "About.TechInfo", fallback: "Tech Info")
    /// Terms of Use
    internal static let termsOfUse = Loc.tr("Localizable", "About.TermsOfUse", fallback: "Terms of Use")
    /// What’s New
    internal static let whatsNew = Loc.tr("Localizable", "About.WhatsNew", fallback: "What’s New")
    internal enum Mail {
      /// 
      /// 
      /// Technical information
      /// %@
      internal static func body(_ p1: Any) -> String {
        return Loc.tr("Localizable", "About.Mail.Body", String(describing: p1), fallback: "\n\nTechnical information\n%@")
      }
      /// Support request, Account ID %@
      internal static func subject(_ p1: Any) -> String {
        return Loc.tr("Localizable", "About.Mail.Subject", String(describing: p1), fallback: "Support request, Account ID %@")
      }
    }
  }
  internal enum Account {
    internal enum Select {
      internal enum Incompatible {
        internal enum Version {
          internal enum Error {
            /// Unable to retrieve account data due to incompatible version on remote nodes. Please update Anytype to the latest version.
            internal static let text = Loc.tr("Localizable", "Account.Select.Incompatible.Version.Error.Text", fallback: "Unable to retrieve account data due to incompatible version on remote nodes. Please update Anytype to the latest version.")
          }
        }
      }
    }
  }
  internal enum Actions {
    /// Link to
    internal static let linkItself = Loc.tr("Localizable", "Actions.LinkItself", fallback: "Link to")
    /// Make template
    internal static let makeAsTemplate = Loc.tr("Localizable", "Actions.MakeAsTemplate", fallback: "Make template")
    /// Make default
    internal static let templateMakeDefault = Loc.tr("Localizable", "Actions.TemplateMakeDefault", fallback: "Make default")
    internal enum CreateWidget {
      /// New widget was created
      internal static let success = Loc.tr("Localizable", "Actions.CreateWidget.Success", fallback: "New widget was created")
      /// To widgets
      internal static let title = Loc.tr("Localizable", "Actions.CreateWidget.Title", fallback: "To widgets")
    }
  }
  internal enum Alert {
    internal enum CameraPermissions {
      /// Anytype needs access to your camera to scan QR codes.
      /// 
      /// Please, go to your device's Settings -> Anytype and set Camera to ON
      internal static let goToSettings = Loc.tr("Localizable", "Alert.CameraPermissions.GoToSettings", fallback: "Anytype needs access to your camera to scan QR codes.\n\nPlease, go to your device's Settings -> Anytype and set Camera to ON")
      /// Settings
      internal static let settings = Loc.tr("Localizable", "Alert.CameraPermissions.Settings", fallback: "Settings")
    }
  }
  internal enum Auth {
    /// Please allow access
    internal static let cameraPermissionTitle = Loc.tr("Localizable", "Auth.CameraPermissionTitle", fallback: "Please allow access")
    /// Create New Account
    internal static let join = Loc.tr("Localizable", "Auth.Join", fallback: "Create New Account")
    /// Log In
    internal static let logIn = Loc.tr("Localizable", "Auth.LogIn", fallback: "Log In")
    /// Next
    internal static let next = Loc.tr("Localizable", "Auth.Next", fallback: "Next")
    internal enum Caption {
      internal enum Privacy {
        /// By continuing you agree to [Terms of Use](%@) and [Privacy Policy](%@)
        internal static func text(_ p1: Any, _ p2: Any) -> String {
          return Loc.tr("Localizable", "Auth.Caption.Privacy.Text", String(describing: p1), String(describing: p2), fallback: "By continuing you agree to [Terms of Use](%@) and [Privacy Policy](%@)")
        }
      }
    }
    internal enum JoinFlow {
      internal enum Creating {
        internal enum Soul {
          /// Generating new account
          internal static let title = Loc.tr("Localizable", "Auth.JoinFlow.Creating.Soul.Title", fallback: "Generating new account")
        }
      }
      internal enum Key {
        /// It’s a novel way of authentication that gives you full ownership over your account and data.
        internal static let description = Loc.tr("Localizable", "Auth.JoinFlow.Key.Description", fallback: "It’s a novel way of authentication that gives you full ownership over your account and data.")
        /// Save your Recovery Phrase
        internal static let title = Loc.tr("Localizable", "Auth.JoinFlow.Key.Title", fallback: "Save your Recovery Phrase")
        internal enum Button {
          internal enum Copy {
            /// Copy to clipboard
            internal static let title = Loc.tr("Localizable", "Auth.JoinFlow.Key.Button.Copy.Title", fallback: "Copy to clipboard")
          }
          internal enum Info {
            /// Read more
            internal static let title = Loc.tr("Localizable", "Auth.JoinFlow.Key.Button.Info.Title", fallback: "Read more")
          }
          internal enum Later {
            /// Skip
            internal static let title = Loc.tr("Localizable", "Auth.JoinFlow.Key.Button.Later.Title", fallback: "Skip")
          }
          internal enum Saved {
            /// Go to the app
            internal static let title = Loc.tr("Localizable", "Auth.JoinFlow.Key.Button.Saved.Title", fallback: "Go to the app")
          }
          internal enum Show {
            /// Show Recovery Phrase
            internal static let title = Loc.tr("Localizable", "Auth.JoinFlow.Key.Button.Show.Title", fallback: "Show Recovery Phrase")
          }
          internal enum Tip {
            /// You can find Recovery Phrase later in Anytype settings
            internal static let title = Loc.tr("Localizable", "Auth.JoinFlow.Key.Button.Tip.Title", fallback: "You can find Recovery Phrase later in Anytype settings")
          }
        }
        internal enum ReadMore {
          /// What is Recovery Phrase?
          internal static let title = Loc.tr("Localizable", "Auth.JoinFlow.Key.ReadMore.Title", fallback: "What is Recovery Phrase?")
          internal enum Instruction {
            /// How to save my phrase?
            internal static let title = Loc.tr("Localizable", "Auth.JoinFlow.Key.ReadMore.Instruction.Title", fallback: "How to save my phrase?")
            internal enum Option1 {
              /// The easiest way to store your Recovery Phrase is to save it in your password manager.
              internal static let title = Loc.tr("Localizable", "Auth.JoinFlow.Key.ReadMore.Instruction.Option1.Title", fallback: "The easiest way to store your Recovery Phrase is to save it in your password manager.")
            }
            internal enum Option2 {
              /// The most secure way is to write it down on paper and keep it offline, in a safe and secure place.
              internal static let title = Loc.tr("Localizable", "Auth.JoinFlow.Key.ReadMore.Instruction.Option2.Title", fallback: "The most secure way is to write it down on paper and keep it offline, in a safe and secure place.")
            }
          }
          internal enum Option1 {
            /// Recovery Phrase is a random combination of 12 words from which your account is magically generated on this device.
            internal static let title = Loc.tr("Localizable", "Auth.JoinFlow.Key.ReadMore.Option1.Title", fallback: "Recovery Phrase is a random combination of 12 words from which your account is magically generated on this device.")
          }
          internal enum Option2 {
            /// Whomever knows Recovery Phrase, owns the account. **At this moment, you are the only person in the world who knows it.**
            internal static let title = Loc.tr("Localizable", "Auth.JoinFlow.Key.ReadMore.Option2.Title", fallback: "Whomever knows Recovery Phrase, owns the account. **At this moment, you are the only person in the world who knows it.**")
          }
          internal enum Option3 {
            /// That's why it's essential to keep Recovery Phrase safe. As the sole owner, nobody can help you if it's lost.
            internal static let title = Loc.tr("Localizable", "Auth.JoinFlow.Key.ReadMore.Option3.Title", fallback: "That's why it's essential to keep Recovery Phrase safe. As the sole owner, nobody can help you if it's lost.")
          }
        }
        internal enum TextField {
          /// Type your recovery phrase
          internal static let placeholder = Loc.tr("Localizable", "Auth.JoinFlow.Key.TextField.Placeholder", fallback: "Type your recovery phrase")
        }
      }
      internal enum Personal {
        internal enum Space {
          /// Personal Space
          internal static let title = Loc.tr("Localizable", "Auth.JoinFlow.Personal.Space.Title", fallback: "Personal Space")
        }
      }
      internal enum Setting {
        internal enum Space {
          /// Setting up your personal space
          internal static let title = Loc.tr("Localizable", "Auth.JoinFlow.Setting.Space.Title", fallback: "Setting up your personal space")
        }
      }
      internal enum Soul {
        /// This is how you will appear in the app.
        internal static let description = Loc.tr("Localizable", "Auth.JoinFlow.Soul.Description", fallback: "This is how you will appear in the app.")
        /// Untitled
        internal static let placeholder = Loc.tr("Localizable", "Auth.JoinFlow.Soul.Placeholder", fallback: "Untitled")
        /// Choose your name
        internal static let title = Loc.tr("Localizable", "Auth.JoinFlow.Soul.Title", fallback: "Choose your name")
      }
    }
    internal enum LoginFlow {
      /// OR
      internal static let or = Loc.tr("Localizable", "Auth.LoginFlow.Or", fallback: "OR")
      internal enum Enter {
        internal enum Button {
          /// Login
          internal static let title = Loc.tr("Localizable", "Auth.LoginFlow.Enter.Button.Title", fallback: "Login")
        }
      }
      internal enum Entering {
        internal enum Void {
          /// Entering the Void
          internal static let title = Loc.tr("Localizable", "Auth.LoginFlow.Entering.Void.Title", fallback: "Entering the Void")
        }
      }
      internal enum Textfield {
        /// Type your recovery phrase
        internal static let placeholder = Loc.tr("Localizable", "Auth.LoginFlow.Textfield.Placeholder", fallback: "Type your recovery phrase")
      }
      internal enum Use {
        internal enum Keychain {
          /// Use keychain
          internal static let title = Loc.tr("Localizable", "Auth.LoginFlow.Use.Keychain.Title", fallback: "Use keychain")
        }
      }
    }
    internal enum Welcome {
      /// Anytype is your safe space to write, plan, think and organise everything that matters to you.
      internal static let subtitle = Loc.tr("Localizable", "Auth.Welcome.Subtitle", fallback: "Anytype is your safe space to write, plan, think and organise everything that matters to you.")
    }
  }
  internal enum BlockLink {
    internal enum PreviewSettings {
      internal enum IconSize {
        /// Medium
        internal static let medium = Loc.tr("Localizable", "BlockLink.PreviewSettings.IconSize.Medium", fallback: "Medium")
        /// None
        internal static let `none` = Loc.tr("Localizable", "BlockLink.PreviewSettings.IconSize.None", fallback: "None")
        /// Small
        internal static let small = Loc.tr("Localizable", "BlockLink.PreviewSettings.IconSize.Small", fallback: "Small")
      }
      internal enum Layout {
        internal enum Card {
          /// Card
          internal static let title = Loc.tr("Localizable", "BlockLink.PreviewSettings.Layout.Card.Title", fallback: "Card")
        }
        internal enum Text {
          /// Text
          internal static let title = Loc.tr("Localizable", "BlockLink.PreviewSettings.Layout.Text.Title", fallback: "Text")
        }
      }
    }
  }
  internal enum BlockText {
    internal enum Content {
      /// Untitled
      internal static let placeholder = Loc.tr("Localizable", "BlockText.Content.Placeholder", fallback: "Untitled")
    }
    internal enum ContentType {
      internal enum Bulleted {
        /// Bulleted list item
        internal static let placeholder = Loc.tr("Localizable", "BlockText.ContentType.Bulleted.Placeholder", fallback: "Bulleted list item")
      }
      internal enum Checkbox {
        /// Checkbox
        internal static let placeholder = Loc.tr("Localizable", "BlockText.ContentType.Checkbox.Placeholder", fallback: "Checkbox")
      }
      internal enum Description {
        /// Add a description
        internal static let placeholder = Loc.tr("Localizable", "BlockText.ContentType.Description.Placeholder", fallback: "Add a description")
      }
      internal enum Header {
        /// Title
        internal static let placeholder = Loc.tr("Localizable", "BlockText.ContentType.Header.Placeholder", fallback: "Title")
      }
      internal enum Header2 {
        /// Heading
        internal static let placeholder = Loc.tr("Localizable", "BlockText.ContentType.Header2.Placeholder", fallback: "Heading")
      }
      internal enum Header3 {
        /// Subheading
        internal static let placeholder = Loc.tr("Localizable", "BlockText.ContentType.Header3.Placeholder", fallback: "Subheading")
      }
      internal enum Numbered {
        /// Numbered list item
        internal static let placeholder = Loc.tr("Localizable", "BlockText.ContentType.Numbered.Placeholder", fallback: "Numbered list item")
      }
      internal enum Quote {
        /// Highlighted text
        internal static let placeholder = Loc.tr("Localizable", "BlockText.ContentType.Quote.Placeholder", fallback: "Highlighted text")
      }
      internal enum Title {
        /// Untitled
        internal static let placeholder = Loc.tr("Localizable", "BlockText.ContentType.Title.Placeholder", fallback: "Untitled")
      }
      internal enum Toggle {
        /// Toggle block
        internal static let placeholder = Loc.tr("Localizable", "BlockText.ContentType.Toggle.Placeholder", fallback: "Toggle block")
      }
    }
  }
  internal enum ClearCache {
    /// Error, try again later
    internal static let error = Loc.tr("Localizable", "ClearCache.Error", fallback: "Error, try again later")
    /// Cache sucessfully cleared
    internal static let success = Loc.tr("Localizable", "ClearCache.Success", fallback: "Cache sucessfully cleared")
  }
  internal enum ClearCacheAlert {
    /// All media files stored in Anytype will be deleted from your current device. They can be downloaded again from a backup node or another device.
    internal static let description = Loc.tr("Localizable", "ClearCacheAlert.Description", fallback: "All media files stored in Anytype will be deleted from your current device. They can be downloaded again from a backup node or another device.")
    /// Are you sure?
    internal static let title = Loc.tr("Localizable", "ClearCacheAlert.Title", fallback: "Are you sure?")
  }
  internal enum Collection {
    internal enum View {
      internal enum Empty {
        /// Create first object to continue
        internal static let subtitle = Loc.tr("Localizable", "Collection.View.Empty.Subtitle", fallback: "Create first object to continue")
        /// No objects
        internal static let title = Loc.tr("Localizable", "Collection.View.Empty.Title", fallback: "No objects")
        internal enum Button {
          /// Create object
          internal static let title = Loc.tr("Localizable", "Collection.View.Empty.Button.Title", fallback: "Create object")
        }
      }
    }
  }
  internal enum CommonOpenErrorView {
    /// No data found
    internal static let message = Loc.tr("Localizable", "CommonOpenErrorView.Message", fallback: "No data found")
  }
  internal enum Content {
    internal enum Audio {
      /// Upload audio
      internal static let upload = Loc.tr("Localizable", "Content.Audio.Upload", fallback: "Upload audio")
    }
    internal enum Bookmark {
      /// Add a web bookmark
      internal static let add = Loc.tr("Localizable", "Content.Bookmark.Add", fallback: "Add a web bookmark")
      /// Loading, please wait...
      internal static let loading = Loc.tr("Localizable", "Content.Bookmark.Loading", fallback: "Loading, please wait...")
    }
    internal enum Common {
      /// Something went wrong, try again
      internal static let error = Loc.tr("Localizable", "Content.Common.Error", fallback: "Something went wrong, try again")
      /// Uploading...
      internal static let uploading = Loc.tr("Localizable", "Content.Common.Uploading", fallback: "Uploading...")
    }
    internal enum DataView {
      internal enum InlineCollection {
        /// Inline collection
        internal static let subtitle = Loc.tr("Localizable", "Content.DataView.InlineCollection.Subtitle", fallback: "Inline collection")
        /// Untitled collection
        internal static let untitled = Loc.tr("Localizable", "Content.DataView.InlineCollection.Untitled", fallback: "Untitled collection")
      }
      internal enum InlineSet {
        /// No data
        internal static let noData = Loc.tr("Localizable", "Content.DataView.InlineSet.NoData", fallback: "No data")
        /// No source
        internal static let noSource = Loc.tr("Localizable", "Content.DataView.InlineSet.NoSource", fallback: "No source")
        /// Inline set
        internal static let subtitle = Loc.tr("Localizable", "Content.DataView.InlineSet.Subtitle", fallback: "Inline set")
        /// Untitled set
        internal static let untitled = Loc.tr("Localizable", "Content.DataView.InlineSet.Untitled", fallback: "Untitled set")
        internal enum Toast {
          /// This inline set doesn’t have a source
          internal static let failure = Loc.tr("Localizable", "Content.DataView.InlineSet.Toast.Failure", fallback: "This inline set doesn’t have a source")
        }
      }
    }
    internal enum File {
      /// Upload a file
      internal static let upload = Loc.tr("Localizable", "Content.File.Upload", fallback: "Upload a file")
    }
    internal enum Picture {
      /// Upload a picture
      internal static let upload = Loc.tr("Localizable", "Content.Picture.Upload", fallback: "Upload a picture")
    }
    internal enum Video {
      /// Upload a video
      internal static let upload = Loc.tr("Localizable", "Content.Video.Upload", fallback: "Upload a video")
    }
  }
  internal enum DataviewType {
    /// Calendar
    internal static let calendar = Loc.tr("Localizable", "DataviewType.calendar", fallback: "Calendar")
    /// Gallery
    internal static let gallery = Loc.tr("Localizable", "DataviewType.gallery", fallback: "Gallery")
    /// Grid
    internal static let grid = Loc.tr("Localizable", "DataviewType.grid", fallback: "Grid")
    /// Kanban
    internal static let kanban = Loc.tr("Localizable", "DataviewType.kanban", fallback: "Kanban")
    /// List
    internal static let list = Loc.tr("Localizable", "DataviewType.list", fallback: "List")
  }
  internal enum DebugMenu {
    /// Release: %@, %@
    internal static func toggleAuthor(_ p1: Any, _ p2: Any) -> String {
      return Loc.tr("Localizable", "DebugMenu.ToggleAuthor", String(describing: p1), String(describing: p2), fallback: "Release: %@, %@")
    }
  }
  internal enum DeletionAlert {
    /// You will be logged out on all other devices. You will have 30 days to recover it. Afterwards it will be deleted permanently
    internal static let description = Loc.tr("Localizable", "DeletionAlert.description", fallback: "You will be logged out on all other devices. You will have 30 days to recover it. Afterwards it will be deleted permanently")
    /// Are you sure to delete account?
    internal static let title = Loc.tr("Localizable", "DeletionAlert.title", fallback: "Are you sure to delete account?")
  }
  internal enum EditSet {
    internal enum Popup {
      internal enum Filter {
        internal enum Condition {
          internal enum Checkbox {
            /// Is
            internal static let equal = Loc.tr("Localizable", "EditSet.Popup.Filter.Condition.Checkbox.Equal", fallback: "Is")
            /// Is not
            internal static let notEqual = Loc.tr("Localizable", "EditSet.Popup.Filter.Condition.Checkbox.NotEqual", fallback: "Is not")
          }
          internal enum Date {
            /// Is after
            internal static let after = Loc.tr("Localizable", "EditSet.Popup.Filter.Condition.Date.After", fallback: "Is after")
            /// Is before
            internal static let before = Loc.tr("Localizable", "EditSet.Popup.Filter.Condition.Date.Before", fallback: "Is before")
            /// Is
            internal static let equal = Loc.tr("Localizable", "EditSet.Popup.Filter.Condition.Date.Equal", fallback: "Is")
            /// Is within
            internal static let `in` = Loc.tr("Localizable", "EditSet.Popup.Filter.Condition.Date.In", fallback: "Is within")
            /// Is on or after
            internal static let onOrAfter = Loc.tr("Localizable", "EditSet.Popup.Filter.Condition.Date.OnOrAfter", fallback: "Is on or after")
            /// Is on or before
            internal static let onOrBefore = Loc.tr("Localizable", "EditSet.Popup.Filter.Condition.Date.OnOrBefore", fallback: "Is on or before")
          }
          internal enum General {
            /// Is empty
            internal static let empty = Loc.tr("Localizable", "EditSet.Popup.Filter.Condition.General.Empty", fallback: "Is empty")
            /// All
            internal static let `none` = Loc.tr("Localizable", "EditSet.Popup.Filter.Condition.General.None", fallback: "All")
            /// Is not empty
            internal static let notEmpty = Loc.tr("Localizable", "EditSet.Popup.Filter.Condition.General.NotEmpty", fallback: "Is not empty")
          }
          internal enum Number {
            /// Is equal to
            internal static let equal = Loc.tr("Localizable", "EditSet.Popup.Filter.Condition.Number.Equal", fallback: "Is equal to")
            /// Is greater than
            internal static let greater = Loc.tr("Localizable", "EditSet.Popup.Filter.Condition.Number.Greater", fallback: "Is greater than")
            /// Is greater than or equal to
            internal static let greaterOrEqual = Loc.tr("Localizable", "EditSet.Popup.Filter.Condition.Number.GreaterOrEqual", fallback: "Is greater than or equal to")
            /// Is less than
            internal static let less = Loc.tr("Localizable", "EditSet.Popup.Filter.Condition.Number.Less", fallback: "Is less than")
            /// Is less than or equal to
            internal static let lessOrEqual = Loc.tr("Localizable", "EditSet.Popup.Filter.Condition.Number.LessOrEqual", fallback: "Is less than or equal to")
            /// Is not equal to
            internal static let notEqual = Loc.tr("Localizable", "EditSet.Popup.Filter.Condition.Number.NotEqual", fallback: "Is not equal to")
          }
          internal enum Selected {
            /// Has all of
            internal static let allIn = Loc.tr("Localizable", "EditSet.Popup.Filter.Condition.Selected.AllIn", fallback: "Has all of")
            /// Is exactly
            internal static let equal = Loc.tr("Localizable", "EditSet.Popup.Filter.Condition.Selected.Equal", fallback: "Is exactly")
            /// Has any of
            internal static let `in` = Loc.tr("Localizable", "EditSet.Popup.Filter.Condition.Selected.In", fallback: "Has any of")
            /// Has none of
            internal static let notIn = Loc.tr("Localizable", "EditSet.Popup.Filter.Condition.Selected.NotIn", fallback: "Has none of")
          }
          internal enum Text {
            /// Is
            internal static let equal = Loc.tr("Localizable", "EditSet.Popup.Filter.Condition.Text.Equal", fallback: "Is")
            /// Contains
            internal static let like = Loc.tr("Localizable", "EditSet.Popup.Filter.Condition.Text.Like", fallback: "Contains")
            /// Is not
            internal static let notEqual = Loc.tr("Localizable", "EditSet.Popup.Filter.Condition.Text.NotEqual", fallback: "Is not")
            /// Doesn't contain
            internal static let notLike = Loc.tr("Localizable", "EditSet.Popup.Filter.Condition.Text.NotLike", fallback: "Doesn't contain")
          }
        }
        internal enum Date {
          internal enum Option {
            /// Current month
            internal static let currentMonth = Loc.tr("Localizable", "EditSet.Popup.Filter.Date.Option.CurrentMonth", fallback: "Current month")
            /// Current week
            internal static let currentWeek = Loc.tr("Localizable", "EditSet.Popup.Filter.Date.Option.CurrentWeek", fallback: "Current week")
            /// Exact date
            internal static let exactDate = Loc.tr("Localizable", "EditSet.Popup.Filter.Date.Option.ExactDate", fallback: "Exact date")
            /// Last month
            internal static let lastMonth = Loc.tr("Localizable", "EditSet.Popup.Filter.Date.Option.LastMonth", fallback: "Last month")
            /// Last week
            internal static let lastWeek = Loc.tr("Localizable", "EditSet.Popup.Filter.Date.Option.LastWeek", fallback: "Last week")
            /// Next month
            internal static let nextMonth = Loc.tr("Localizable", "EditSet.Popup.Filter.Date.Option.NextMonth", fallback: "Next month")
            /// Next week
            internal static let nextWeek = Loc.tr("Localizable", "EditSet.Popup.Filter.Date.Option.NextWeek", fallback: "Next week")
            /// Number of days ago
            internal static let numberOfDaysAgo = Loc.tr("Localizable", "EditSet.Popup.Filter.Date.Option.NumberOfDaysAgo", fallback: "Number of days ago")
            /// Number of days from now
            internal static let numberOfDaysFromNow = Loc.tr("Localizable", "EditSet.Popup.Filter.Date.Option.NumberOfDaysFromNow", fallback: "Number of days from now")
            /// Today
            internal static let today = Loc.tr("Localizable", "EditSet.Popup.Filter.Date.Option.Today", fallback: "Today")
            /// Tomorrow
            internal static let tomorrow = Loc.tr("Localizable", "EditSet.Popup.Filter.Date.Option.Tomorrow", fallback: "Tomorrow")
            /// Yesterday
            internal static let yesterday = Loc.tr("Localizable", "EditSet.Popup.Filter.Date.Option.Yesterday", fallback: "Yesterday")
            internal enum NumberOfDaysAgo {
              /// %@ days ago
              internal static func short(_ p1: Any) -> String {
                return Loc.tr("Localizable", "EditSet.Popup.Filter.Date.Option.NumberOfDaysAgo.Short", String(describing: p1), fallback: "%@ days ago")
              }
            }
            internal enum NumberOfDaysFromNow {
              /// %@ days from now
              internal static func short(_ p1: Any) -> String {
                return Loc.tr("Localizable", "EditSet.Popup.Filter.Date.Option.NumberOfDaysFromNow.Short", String(describing: p1), fallback: "%@ days from now")
              }
            }
          }
        }
        internal enum Value {
          /// Checked
          internal static let checked = Loc.tr("Localizable", "EditSet.Popup.Filter.Value.Checked", fallback: "Checked")
          /// Unchecked
          internal static let unchecked = Loc.tr("Localizable", "EditSet.Popup.Filter.Value.Unchecked", fallback: "Unchecked")
        }
      }
      internal enum Filters {
        internal enum EmptyView {
          /// No filters here. You can add some
          internal static let title = Loc.tr("Localizable", "EditSet.Popup.Filters.EmptyView.Title", fallback: "No filters here. You can add some")
        }
        internal enum NavigationView {
          /// Filters
          internal static let title = Loc.tr("Localizable", "EditSet.Popup.Filters.NavigationView.Title", fallback: "Filters")
        }
        internal enum TextView {
          /// Value
          internal static let placeholder = Loc.tr("Localizable", "EditSet.Popup.Filters.TextView.Placeholder", fallback: "Value")
        }
      }
      internal enum Sort {
        internal enum Add {
          /// Сhoose a relation to sort
          internal static let searchPlaceholder = Loc.tr("Localizable", "EditSet.Popup.Sort.Add.SearchPlaceholder", fallback: "Сhoose a relation to sort")
        }
        internal enum Types {
          /// Ascending
          internal static let ascending = Loc.tr("Localizable", "EditSet.Popup.Sort.Types.Ascending", fallback: "Ascending")
          /// Descending
          internal static let descending = Loc.tr("Localizable", "EditSet.Popup.Sort.Types.Descending", fallback: "Descending")
        }
      }
      internal enum Sorts {
        internal enum EmptyView {
          /// No sorts here. You can add some
          internal static let title = Loc.tr("Localizable", "EditSet.Popup.Sorts.EmptyView.Title", fallback: "No sorts here. You can add some")
        }
        internal enum NavigationView {
          /// Sorts
          internal static let title = Loc.tr("Localizable", "EditSet.Popup.Sorts.NavigationView.Title", fallback: "Sorts")
        }
      }
    }
  }
  internal enum Editor {
    internal enum LinkToObject {
      /// Copy link
      internal static let copyLink = Loc.tr("Localizable", "Editor.LinkToObject.CopyLink", fallback: "Copy link")
      /// Linked to
      internal static let linkedTo = Loc.tr("Localizable", "Editor.LinkToObject.LinkedTo", fallback: "Linked to")
      /// Paste from clipboard
      internal static let pasteFromClipboard = Loc.tr("Localizable", "Editor.LinkToObject.PasteFromClipboard", fallback: "Paste from clipboard")
      /// Remove link
      internal static let removeLink = Loc.tr("Localizable", "Editor.LinkToObject.RemoveLink", fallback: "Remove link")
      /// Paste link or search objects
      internal static let searchPlaceholder = Loc.tr("Localizable", "Editor.LinkToObject.SearchPlaceholder", fallback: "Paste link or search objects")
    }
    internal enum MovingState {
      /// Scroll to select a place
      internal static let scrollToSelectedPlace = Loc.tr("Localizable", "Editor.MovingState.ScrollToSelectedPlace", fallback: "Scroll to select a place")
    }
    internal enum Toast {
      /// linked to
      internal static let linkedTo = Loc.tr("Localizable", "Editor.Toast.LinkedTo", fallback: "linked to")
      /// Block moved to
      internal static let movedTo = Loc.tr("Localizable", "Editor.Toast.MovedTo", fallback: "Block moved to")
    }
  }
  internal enum EditorSetViewPicker {
    internal enum View {
      internal enum Not {
        internal enum Supported {
          /// Unsupported
          internal static let title = Loc.tr("Localizable", "EditorSetViewPicker.View.Not.Supported.Title", fallback: "Unsupported")
        }
      }
    }
  }
  internal enum Error {
    internal enum AnytypeNeedsUpgrate {
      /// Update
      internal static let confirm = Loc.tr("Localizable", "Error.AnytypeNeedsUpgrate.Confirm", fallback: "Update")
      /// This object was modified in a newer version of Anytype. Please update the app to open it on this device
      internal static let message = Loc.tr("Localizable", "Error.AnytypeNeedsUpgrate.Message", fallback: "This object was modified in a newer version of Anytype. Please update the app to open it on this device")
      /// Update Your App
      internal static let title = Loc.tr("Localizable", "Error.AnytypeNeedsUpgrate.Title", fallback: "Update Your App")
    }
  }
  internal enum ErrorOccurred {
    /// Error occurred. Please try again
    internal static let pleaseTryAgain = Loc.tr("Localizable", "Error occurred. Please try again", fallback: "Error occurred. Please try again")
  }
  internal enum FileStorage {
    /// You exceeded file limit upload
    internal static let limitError = Loc.tr("Localizable", "FileStorage.LimitError", fallback: "You exceeded file limit upload")
    /// Manage files
    internal static let manageFiles = Loc.tr("Localizable", "FileStorage.ManageFiles", fallback: "Manage files")
    /// Offload files
    internal static let offloadTitle = Loc.tr("Localizable", "FileStorage.OffloadTitle", fallback: "Offload files")
    /// File storage
    internal static let title = Loc.tr("Localizable", "FileStorage.Title", fallback: "File storage")
    internal enum LimitLegend {
      /// %@ | %@
      internal static func current(_ p1: Any, _ p2: Any) -> String {
        return Loc.tr("Localizable", "FileStorage.LimitLegend.Current", String(describing: p1), String(describing: p2), fallback: "%@ | %@")
      }
      /// Free | %@
      internal static func free(_ p1: Any) -> String {
        return Loc.tr("Localizable", "FileStorage.LimitLegend.Free", String(describing: p1), fallback: "Free | %@")
      }
      /// Other spaces | %@
      internal static func other(_ p1: Any) -> String {
        return Loc.tr("Localizable", "FileStorage.LimitLegend.Other", String(describing: p1), fallback: "Other spaces | %@")
      }
    }
    internal enum Local {
      /// In order to save space on your local device, you can offload all your files to our encrypted backup node. The files will be loaded back when you open them.
      internal static let instruction = Loc.tr("Localizable", "FileStorage.Local.Instruction", fallback: "In order to save space on your local device, you can offload all your files to our encrypted backup node. The files will be loaded back when you open them.")
      /// Local storage
      internal static let title = Loc.tr("Localizable", "FileStorage.Local.Title", fallback: "Local storage")
      /// %@ used
      internal static func used(_ p1: Any) -> String {
        return Loc.tr("Localizable", "FileStorage.Local.Used", String(describing: p1), fallback: "%@ used")
      }
    }
    internal enum Space {
      /// Get more space
      internal static let getMore = Loc.tr("Localizable", "FileStorage.Space.GetMore", fallback: "Get more space")
      /// You can store up to %@ of your files on our encrypted backup node for free. If you reach the limit, files will be stored only locally.
      internal static func instruction(_ p1: Any) -> String {
        return Loc.tr("Localizable", "FileStorage.Space.Instruction", String(describing: p1), fallback: "You can store up to %@ of your files on our encrypted backup node for free. If you reach the limit, files will be stored only locally.")
      }
      /// Remote storage
      internal static let title = Loc.tr("Localizable", "FileStorage.Space.Title", fallback: "Remote storage")
      /// %@ of %@ used
      internal static func used(_ p1: Any, _ p2: Any) -> String {
        return Loc.tr("Localizable", "FileStorage.Space.Used", String(describing: p1), String(describing: p2), fallback: "%@ of %@ used")
      }
      internal enum Mail {
        /// Hi, Anytype team. I am reaching out to request an increase in my file storage capacity as I have run out of storage. My current limits is %@. My account id is %@. Cheers, %@.
        internal static func body(_ p1: Any, _ p2: Any, _ p3: Any) -> String {
          return Loc.tr("Localizable", "FileStorage.Space.Mail.Body", String(describing: p1), String(describing: p2), String(describing: p3), fallback: "Hi, Anytype team. I am reaching out to request an increase in my file storage capacity as I have run out of storage. My current limits is %@. My account id is %@. Cheers, %@.")
        }
        /// Get more storage, account %@
        internal static func subject(_ p1: Any) -> String {
          return Loc.tr("Localizable", "FileStorage.Space.Mail.Subject", String(describing: p1), fallback: "Get more storage, account %@")
        }
      }
    }
  }
  internal enum FilesList {
    /// Synced files
    internal static let title = Loc.tr("Localizable", "FilesList.Title", fallback: "Synced files")
    internal enum ForceDelete {
      /// Are you sure you want to permanently delete the files?
      internal static let title = Loc.tr("Localizable", "FilesList.ForceDelete.Title", fallback: "Are you sure you want to permanently delete the files?")
    }
  }
  internal enum Gallery {
    internal enum Unavailable {
      /// Please use the desktop app for now
      internal static let message = Loc.tr("Localizable", "Gallery.Unavailable.Message", fallback: "Please use the desktop app for now")
      /// Gallery will be supported soon
      internal static let title = Loc.tr("Localizable", "Gallery.Unavailable.Title", fallback: "Gallery will be supported soon")
    }
  }
  internal enum Home {
    internal enum Snackbar {
      /// Library is available in desktop app
      internal static let library = Loc.tr("Localizable", "Home.Snackbar.Library", fallback: "Library is available in desktop app")
    }
  }
  internal enum Initial {
    internal enum UnstableMiddle {
      /// Continue with current account
      internal static let `continue` = Loc.tr("Localizable", "Initial.UnstableMiddle.Continue", fallback: "Continue with current account")
      /// Logout from current account
      internal static let logout = Loc.tr("Localizable", "Initial.UnstableMiddle.Logout", fallback: "Logout from current account")
      /// You launch app with a unstable middleware. Don't use your production account. Your account may be broken.
      internal static let message = Loc.tr("Localizable", "Initial.UnstableMiddle.Message", fallback: "You launch app with a unstable middleware. Don't use your production account. Your account may be broken.")
      /// Warning
      internal static let title = Loc.tr("Localizable", "Initial.UnstableMiddle.Title", fallback: "Warning")
      /// I won't be using my production account
      internal static let wontUseProd = Loc.tr("Localizable", "Initial.UnstableMiddle.WontUseProd", fallback: "I won't be using my production account")
    }
  }
  internal enum InterfaceStyle {
    /// Dark
    internal static let dark = Loc.tr("Localizable", "InterfaceStyle.dark", fallback: "Dark")
    /// Light
    internal static let light = Loc.tr("Localizable", "InterfaceStyle.light", fallback: "Light")
    /// System
    internal static let system = Loc.tr("Localizable", "InterfaceStyle.system", fallback: "System")
  }
  internal enum Keychain {
    /// Don’t forget to save your recovery phrase
    internal static let donTForgetToSaveYourRecoveryPhrase = Loc.tr("Localizable", "Keychain.Don’t forget to save your recovery phrase", fallback: "Don’t forget to save your recovery phrase")
    /// Have you backed up your recovery phrase?
    internal static let haveYouBackedUpYourRecoveryPhrase = Loc.tr("Localizable", "Keychain.Have you backed up your recovery phrase?", fallback: "Have you backed up your recovery phrase?")
    /// Recovery phrase
    internal static let recoveryPhrase = Loc.tr("Localizable", "Keychain.Recovery phrase", fallback: "Recovery phrase")
    /// Recovery phrase copied
    internal static let recoveryPhraseCopiedToClipboard = Loc.tr("Localizable", "Keychain.Recovery phrase copied to clipboard", fallback: "Recovery phrase copied")
    /// You will need it to sign in. Keep it in a safe place. If you lose it, you can no longer access your account.
    internal static let recoveryPhraseDescription = Loc.tr("Localizable", "Keychain.Recovery phrase description", fallback: "You will need it to sign in. Keep it in a safe place. If you lose it, you can no longer access your account.")
    /// If you lose the recovery phrase and get logged out you will not be able to 
    internal static let saveKeychainAlertPart1 = Loc.tr("Localizable", "Keychain.Save keychain alert part 1", fallback: "If you lose the recovery phrase and get logged out you will not be able to ")
    /// ever access your data again
    internal static let saveKeychainAlertPart2 = Loc.tr("Localizable", "Keychain.Save keychain alert part 2", fallback: "ever access your data again")
    /// .
    /// Save this recovery phrase outside of Anytype for data recovery.
    /// We recommend using a secure data vault, password manager or piece of paper in the safe.
    internal static let saveKeychainAlertPart3 = Loc.tr("Localizable", "Keychain.Save keychain alert part 3", fallback: ".\nSave this recovery phrase outside of Anytype for data recovery.\nWe recommend using a secure data vault, password manager or piece of paper in the safe.")
    /// witch collapse practice feed shame open despair creek road again ice least lake tree young address brain despair
    internal static let seedPhrasePlaceholder = Loc.tr("Localizable", "Keychain.SeedPhrasePlaceholder", fallback: "witch collapse practice feed shame open despair creek road again ice least lake tree young address brain despair")
    /// Show and copy phrase
    internal static let showAndCopyPhrase = Loc.tr("Localizable", "Keychain.Show and copy phrase", fallback: "Show and copy phrase")
    internal enum Error {
      /// Data to String conversion error
      internal static let dataToStringConversionError = Loc.tr("Localizable", "Keychain.Error.Data to String conversion error", fallback: "Data to String conversion error")
      /// String to Data conversion error
      internal static let stringToDataConversionError = Loc.tr("Localizable", "Keychain.Error.String to Data conversion error", fallback: "String to Data conversion error")
      /// Unknown Keychain Error
      internal static let unknownKeychainError = Loc.tr("Localizable", "Keychain.Error.Unknown Keychain Error", fallback: "Unknown Keychain Error")
    }
  }
  internal enum LinkAppearance {
    internal enum Description {
      internal enum Content {
        /// Content preview
        internal static let title = Loc.tr("Localizable", "LinkAppearance.Description.Content.Title", fallback: "Content preview")
      }
      internal enum None {
        /// None
        internal static let title = Loc.tr("Localizable", "LinkAppearance.Description.None.Title", fallback: "None")
      }
      internal enum Object {
        /// Object description
        internal static let title = Loc.tr("Localizable", "LinkAppearance.Description.Object.Title", fallback: "Object description")
      }
    }
    internal enum ObjectType {
      /// Object type
      internal static let title = Loc.tr("Localizable", "LinkAppearance.ObjectType.Title", fallback: "Object type")
    }
  }
  internal enum LinkPaste {
    /// Create bookmark
    internal static let bookmark = Loc.tr("Localizable", "LinkPaste.bookmark", fallback: "Create bookmark")
    /// Paste as link
    internal static let link = Loc.tr("Localizable", "LinkPaste.link", fallback: "Paste as link")
    /// Paste as text
    internal static let text = Loc.tr("Localizable", "LinkPaste.text", fallback: "Paste as text")
  }
  internal enum LongTapCreateTip {
    /// Long tap on Create Object button to open menu with types
    internal static let message = Loc.tr("Localizable", "LongTapCreateTip.Message", fallback: "Long tap on Create Object button to open menu with types")
    /// Crete Objects with specific Type
    internal static let title = Loc.tr("Localizable", "LongTapCreateTip.Title", fallback: "Crete Objects with specific Type")
  }
  internal enum Mention {
    internal enum Subtitle {
      /// Object
      internal static let placeholder = Loc.tr("Localizable", "Mention.Subtitle.Placeholder", fallback: "Object")
    }
  }
  internal enum Object {
    internal enum Deleted {
      /// Deleted object
      internal static let placeholder = Loc.tr("Localizable", "Object.Deleted.Placeholder", fallback: "Deleted object")
    }
    internal enum Title {
      /// Untitled
      internal static let placeholder = Loc.tr("Localizable", "Object.Title.Placeholder", fallback: "Untitled")
    }
  }
  internal enum ObjectType {
    /// Type ‘%@’ added to your library
    internal static func addedToLibrary(_ p1: Any) -> String {
      return Loc.tr("Localizable", "ObjectType.AddedToLibrary", String(describing: p1), fallback: "Type ‘%@’ added to your library")
    }
    /// Deleted type
    internal static let deletedName = Loc.tr("Localizable", "ObjectType.DeletedName", fallback: "Deleted type")
    /// Blank canvas with no title
    internal static let fallbackDescription = Loc.tr("Localizable", "ObjectType.fallbackDescription", fallback: "Blank canvas with no title")
    /// My Types
    internal static let myTypes = Loc.tr("Localizable", "ObjectType.MyTypes", fallback: "My Types")
    /// Search for Type
    internal static let search = Loc.tr("Localizable", "ObjectType.Search", fallback: "Search for Type")
    /// Search or install a new type
    internal static let searchOrInstall = Loc.tr("Localizable", "ObjectType.SearchOrInstall", fallback: "Search or install a new type")
  }
  internal enum QuickAction {
    /// Create %@
    internal static func create(_ p1: Any) -> String {
      return Loc.tr("Localizable", "QuickAction.create", String(describing: p1), fallback: "Create %@")
    }
  }
  internal enum RedactedText {
    /// Wake up, Neo
    internal static let pageTitle = Loc.tr("Localizable", "RedactedText.pageTitle", fallback: "Wake up, Neo")
    /// Red pill
    internal static let pageType = Loc.tr("Localizable", "RedactedText.pageType", fallback: "Red pill")
  }
  internal enum Relation {
    /// Relation ‘%@’ added to your library
    internal static func addedToLibrary(_ p1: Any) -> String {
      return Loc.tr("Localizable", "Relation.AddedToLibrary", String(describing: p1), fallback: "Relation ‘%@’ added to your library")
    }
    /// Deleted relation
    internal static let deleted = Loc.tr("Localizable", "Relation.Deleted", fallback: "Deleted relation")
    /// My relations
    internal static let myRelations = Loc.tr("Localizable", "Relation.MyRelations", fallback: "My relations")
    internal enum Format {
      internal enum Checkbox {
        /// Checkbox
        internal static let title = Loc.tr("Localizable", "Relation.Format.Checkbox.Title", fallback: "Checkbox")
      }
      internal enum Date {
        /// Date
        internal static let title = Loc.tr("Localizable", "Relation.Format.Date.Title", fallback: "Date")
      }
      internal enum Email {
        /// Email
        internal static let title = Loc.tr("Localizable", "Relation.Format.Email.Title", fallback: "Email")
      }
      internal enum FileMedia {
        /// File & Media
        internal static let title = Loc.tr("Localizable", "Relation.Format.FileMedia.Title", fallback: "File & Media")
      }
      internal enum Number {
        /// Number
        internal static let title = Loc.tr("Localizable", "Relation.Format.Number.Title", fallback: "Number")
      }
      internal enum Object {
        /// Object
        internal static let title = Loc.tr("Localizable", "Relation.Format.Object.Title", fallback: "Object")
      }
      internal enum Phone {
        /// Phone number
        internal static let title = Loc.tr("Localizable", "Relation.Format.Phone.Title", fallback: "Phone number")
      }
      internal enum Status {
        /// Status
        internal static let title = Loc.tr("Localizable", "Relation.Format.Status.Title", fallback: "Status")
      }
      internal enum Tag {
        /// Tag
        internal static let title = Loc.tr("Localizable", "Relation.Format.Tag.Title", fallback: "Tag")
      }
      internal enum Text {
        /// Text
        internal static let title = Loc.tr("Localizable", "Relation.Format.Text.Title", fallback: "Text")
      }
      internal enum Url {
        /// URL
        internal static let title = Loc.tr("Localizable", "Relation.Format.Url.Title", fallback: "URL")
      }
    }
    internal enum From {
      /// From type %@
      internal static func type(_ p1: Any) -> String {
        return Loc.tr("Localizable", "Relation.From.Type", String(describing: p1), fallback: "From type %@")
      }
    }
    internal enum LinksFrom {
      /// from
      internal static let title = Loc.tr("Localizable", "Relation.LinksFrom.Title", fallback: "from")
    }
    internal enum LinksTo {
      /// to
      internal static let title = Loc.tr("Localizable", "Relation.LinksTo.Title", fallback: "to")
    }
    internal enum View {
      internal enum Hint {
        /// empty
        internal static let empty = Loc.tr("Localizable", "Relation.View.Hint.Empty", fallback: "empty")
      }
    }
  }
  internal enum RelationAction {
    /// Call phone numbler
    internal static let callPhone = Loc.tr("Localizable", "RelationAction.CallPhone", fallback: "Call phone numbler")
    /// Copied
    internal static let copied = Loc.tr("Localizable", "RelationAction.Copied", fallback: "Copied")
    /// Copy email
    internal static let copyEmail = Loc.tr("Localizable", "RelationAction.CopyEmail", fallback: "Copy email")
    /// Copy link
    internal static let copyLink = Loc.tr("Localizable", "RelationAction.CopyLink", fallback: "Copy link")
    /// Copy phone number
    internal static let copyPhone = Loc.tr("Localizable", "RelationAction.CopyPhone", fallback: "Copy phone number")
    /// Open link
    internal static let openLink = Loc.tr("Localizable", "RelationAction.OpenLink", fallback: "Open link")
    /// Reload object content
    internal static let reloadContent = Loc.tr("Localizable", "RelationAction.ReloadContent", fallback: "Reload object content")
    /// Reloading content
    internal static let reloadingContent = Loc.tr("Localizable", "RelationAction.ReloadingContent", fallback: "Reloading content")
    /// Send email
    internal static let sendEmail = Loc.tr("Localizable", "RelationAction.SendEmail", fallback: "Send email")
  }
  internal enum RelativeFormatter {
    /// Previous 30 days
    internal static let days30 = Loc.tr("Localizable", "RelativeFormatter.days30", fallback: "Previous 30 days")
    /// Previous 7 days
    internal static let days7 = Loc.tr("Localizable", "RelativeFormatter.days7", fallback: "Previous 7 days")
    /// Older
    internal static let older = Loc.tr("Localizable", "RelativeFormatter.older", fallback: "Older")
  }
  internal enum Scanner {
    internal enum Error {
      /// Scanning not supported
      internal static let scanningNotSupported = Loc.tr("Localizable", "Scanner.Error.Scanning not supported", fallback: "Scanning not supported")
    }
  }
  internal enum Server {
    /// Add Self-hosted Network
    internal static let addButton = Loc.tr("Localizable", "Server.AddButton", fallback: "Add Self-hosted Network")
    /// Anytype
    internal static let anytype = Loc.tr("Localizable", "Server.Anytype", fallback: "Anytype")
    /// Local-only
    internal static let localOnly = Loc.tr("Localizable", "Server.LocalOnly", fallback: "Local-only")
    /// Network
    internal static let network = Loc.tr("Localizable", "Server.Network", fallback: "Network")
    /// Networks
    internal static let networks = Loc.tr("Localizable", "Server.Networks", fallback: "Networks")
  }
  internal enum Set {
    internal enum Bookmark {
      internal enum Create {
        /// Paste link
        internal static let placeholder = Loc.tr("Localizable", "Set.Bookmark.Create.Placeholder", fallback: "Paste link")
      }
      internal enum Error {
        /// Oops - something went wrong. Please try again
        internal static let message = Loc.tr("Localizable", "Set.Bookmark.Error.Message", fallback: "Oops - something went wrong. Please try again")
      }
    }
    internal enum Button {
      internal enum Title {
        /// Apply
        internal static let apply = Loc.tr("Localizable", "Set.Button.Title.Apply", fallback: "Apply")
      }
    }
    internal enum Create {
      internal enum ObjectTitle {
        /// Untitled
        internal static let placeholder = Loc.tr("Localizable", "Set.Create.ObjectTitle.Placeholder", fallback: "Untitled")
      }
    }
    internal enum FeaturedRelations {
      /// Query
      internal static let query = Loc.tr("Localizable", "Set.FeaturedRelations.Query", fallback: "Query")
      /// Relation:
      internal static let relation = Loc.tr("Localizable", "Set.FeaturedRelations.Relation", fallback: "Relation:")
      /// Relations:
      internal static let relationsList = Loc.tr("Localizable", "Set.FeaturedRelations.RelationsList", fallback: "Relations:")
      /// Type:
      internal static let type = Loc.tr("Localizable", "Set.FeaturedRelations.Type", fallback: "Type:")
    }
    internal enum SourceType {
      /// Select query
      internal static let selectQuery = Loc.tr("Localizable", "Set.SourceType.SelectQuery", fallback: "Select query")
      internal enum Cancel {
        internal enum Toast {
          /// This query can be changed on desktop only
          internal static let title = Loc.tr("Localizable", "Set.SourceType.Cancel.Toast.Title", fallback: "This query can be changed on desktop only")
        }
      }
    }
    internal enum TypeRelation {
      internal enum ContextMenu {
        /// Change query
        internal static let changeQuery = Loc.tr("Localizable", "Set.TypeRelation.ContextMenu.ChangeQuery", fallback: "Change query")
        /// Turn Set into Collection
        internal static let turnIntoCollection = Loc.tr("Localizable", "Set.TypeRelation.ContextMenu.TurnIntoCollection", fallback: "Turn Set into Collection")
      }
    }
    internal enum View {
      internal enum Empty {
        /// Add search query to aggregate objects with equal types and relations in a live mode
        internal static let subtitle = Loc.tr("Localizable", "Set.View.Empty.Subtitle", fallback: "Add search query to aggregate objects with equal types and relations in a live mode")
        /// No query selected
        internal static let title = Loc.tr("Localizable", "Set.View.Empty.Title", fallback: "No query selected")
      }
      internal enum Kanban {
        internal enum Column {
          internal enum Paging {
            internal enum Title {
              /// Show more objects
              internal static let showMore = Loc.tr("Localizable", "Set.View.Kanban.Column.Paging.Title.ShowMore", fallback: "Show more objects")
            }
          }
          internal enum Settings {
            internal enum Color {
              /// Column color
              internal static let title = Loc.tr("Localizable", "Set.View.Kanban.Column.Settings.Color.Title", fallback: "Column color")
            }
            internal enum Hide {
              internal enum Column {
                /// Hide column
                internal static let title = Loc.tr("Localizable", "Set.View.Kanban.Column.Settings.Hide.Column.Title", fallback: "Hide column")
              }
            }
          }
          internal enum Title {
            /// %@ is checked
            internal static func checked(_ p1: Any) -> String {
              return Loc.tr("Localizable", "Set.View.Kanban.Column.Title.Checked", String(describing: p1), fallback: "%@ is checked")
            }
            /// Uncategorized
            internal static let uncategorized = Loc.tr("Localizable", "Set.View.Kanban.Column.Title.Uncategorized", fallback: "Uncategorized")
            /// %@ is unchecked
            internal static func unchecked(_ p1: Any) -> String {
              return Loc.tr("Localizable", "Set.View.Kanban.Column.Title.Unchecked", String(describing: p1), fallback: "%@ is unchecked")
            }
          }
        }
      }
      internal enum Settings {
        internal enum CardSize {
          /// Card size
          internal static let title = Loc.tr("Localizable", "Set.View.Settings.CardSize.Title", fallback: "Card size")
          internal enum Large {
            /// Large
            internal static let title = Loc.tr("Localizable", "Set.View.Settings.CardSize.Large.Title", fallback: "Large")
          }
          internal enum Small {
            /// Small
            internal static let title = Loc.tr("Localizable", "Set.View.Settings.CardSize.Small.Title", fallback: "Small")
          }
        }
        internal enum GroupBackgroundColors {
          /// Color columns
          internal static let title = Loc.tr("Localizable", "Set.View.Settings.GroupBackgroundColors.Title", fallback: "Color columns")
        }
        internal enum GroupBy {
          /// Group by
          internal static let title = Loc.tr("Localizable", "Set.View.Settings.GroupBy.Title", fallback: "Group by")
        }
        internal enum ImageFit {
          /// Fit image
          internal static let title = Loc.tr("Localizable", "Set.View.Settings.ImageFit.Title", fallback: "Fit image")
        }
        internal enum ImagePreview {
          /// Image preview
          internal static let title = Loc.tr("Localizable", "Set.View.Settings.ImagePreview.Title", fallback: "Image preview")
        }
        internal enum NoFilters {
          /// No filters
          internal static let placeholder = Loc.tr("Localizable", "Set.View.Settings.NoFilters.Placeholder", fallback: "No filters")
        }
        internal enum NoRelations {
          /// No relations
          internal static let placeholder = Loc.tr("Localizable", "Set.View.Settings.NoRelations.Placeholder", fallback: "No relations")
        }
        internal enum NoSorts {
          /// No sorts
          internal static let placeholder = Loc.tr("Localizable", "Set.View.Settings.NoSorts.Placeholder", fallback: "No sorts")
        }
        internal enum Objects {
          internal enum Applied {
            /// %d applied
            internal static func title(_ p1: Int) -> String {
              return Loc.tr("Localizable", "Set.View.Settings.Objects.Applied.Title", p1, fallback: "%d applied")
            }
          }
        }
      }
    }
  }
  internal enum SetViewTypesPicker {
    /// Edit view
    internal static let title = Loc.tr("Localizable", "SetViewTypesPicker.Title", fallback: "Edit view")
    internal enum New {
      /// New view
      internal static let title = Loc.tr("Localizable", "SetViewTypesPicker.New.Title", fallback: "New view")
    }
    internal enum Section {
      internal enum Types {
        /// View as
        internal static let title = Loc.tr("Localizable", "SetViewTypesPicker.Section.Types.Title", fallback: "View as")
      }
    }
    internal enum Settings {
      internal enum Delete {
        /// Delete view
        internal static let view = Loc.tr("Localizable", "SetViewTypesPicker.Settings.Delete.View", fallback: "Delete view")
      }
      internal enum Duplicate {
        /// Duplicate
        internal static let view = Loc.tr("Localizable", "SetViewTypesPicker.Settings.Duplicate.View", fallback: "Duplicate")
      }
      internal enum Textfield {
        internal enum Placeholder {
          /// Untitled
          internal static let untitled = Loc.tr("Localizable", "SetViewTypesPicker.Settings.Textfield.Placeholder.Untitled", fallback: "Untitled")
          internal enum New {
            /// New view
            internal static let view = Loc.tr("Localizable", "SetViewTypesPicker.Settings.Textfield.Placeholder.New.View", fallback: "New view")
          }
        }
      }
    }
  }
  internal enum Settings {
    /// Account and access
    internal static let accountAndAccess = Loc.tr("Localizable", "Settings.AccountAndAccess", fallback: "Account and access")
    /// Space name
    internal static let spaceName = Loc.tr("Localizable", "Settings.SpaceName", fallback: "Space name")
    /// Settings
    internal static let title = Loc.tr("Localizable", "Settings.Title", fallback: "Settings")
    /// Personal Space
    internal static let titleLegacy = Loc.tr("Localizable", "Settings.TitleLegacy", fallback: "Personal Space")
  }
  internal enum Sharing {
    /// Add to
    internal static let addTo = Loc.tr("Localizable", "Sharing.AddTo", fallback: "Add to")
    /// Link to
    internal static let linkTo = Loc.tr("Localizable", "Sharing.LinkTo", fallback: "Link to")
    /// SAVE AS
    internal static let saveAs = Loc.tr("Localizable", "Sharing.SaveAs", fallback: "SAVE AS")
    /// Space
    internal static let selectSpace = Loc.tr("Localizable", "Sharing.SelectSpace", fallback: "Space")
    internal enum Navigation {
      /// Add to Anytype
      internal static let title = Loc.tr("Localizable", "Sharing.Navigation.title", fallback: "Add to Anytype")
      internal enum LeftButton {
        /// Cancel
        internal static let title = Loc.tr("Localizable", "Sharing.Navigation.LeftButton.Title", fallback: "Cancel")
      }
      internal enum RightButton {
        /// Done
        internal static let title = Loc.tr("Localizable", "Sharing.Navigation.RightButton.Title", fallback: "Done")
      }
    }
    internal enum Text {
      /// Note object
      internal static let noteObject = Loc.tr("Localizable", "Sharing.Text.NoteObject", fallback: "Note object")
      /// Text block
      internal static let textBlock = Loc.tr("Localizable", "Sharing.Text.TextBlock", fallback: "Text block")
    }
    internal enum Tip {
      /// Share Extension
      internal static let title = Loc.tr("Localizable", "Sharing.Tip.Title", fallback: "Share Extension")
      internal enum Button {
        /// Show share menu
        internal static let title = Loc.tr("Localizable", "Sharing.Tip.Button.title", fallback: "Show share menu")
      }
      internal enum Steps {
        /// Tap the iOS sharing button
        internal static let _1 = Loc.tr("Localizable", "Sharing.Tip.Steps.1", fallback: "Tap the iOS sharing button")
        /// Scroll past the app and tap More
        internal static let _2 = Loc.tr("Localizable", "Sharing.Tip.Steps.2", fallback: "Scroll past the app and tap More")
        /// Tap Edit to find “Anytype” and tap
        internal static let _3 = Loc.tr("Localizable", "Sharing.Tip.Steps.3", fallback: "Tap Edit to find “Anytype” and tap")
      }
    }
    internal enum Url {
      /// Bookmark object
      internal static let bookmark = Loc.tr("Localizable", "Sharing.URL.Bookmark", fallback: "Bookmark object")
      /// Text block
      internal static let text = Loc.tr("Localizable", "Sharing.URL.Text", fallback: "Text block")
    }
  }
  internal enum SimpleTableMenu {
    internal enum Item {
      /// Clear
      internal static let clearContents = Loc.tr("Localizable", "SimpleTableMenu.Item.clearContents", fallback: "Clear")
      /// Reset style
      internal static let clearStyle = Loc.tr("Localizable", "SimpleTableMenu.Item.clearStyle", fallback: "Reset style")
      /// Color
      internal static let color = Loc.tr("Localizable", "SimpleTableMenu.Item.color", fallback: "Color")
      /// Delete
      internal static let delete = Loc.tr("Localizable", "SimpleTableMenu.Item.Delete", fallback: "Delete")
      /// Duplicate
      internal static let duplicate = Loc.tr("Localizable", "SimpleTableMenu.Item.Duplicate", fallback: "Duplicate")
      /// Insert above
      internal static let insertAbove = Loc.tr("Localizable", "SimpleTableMenu.Item.InsertAbove", fallback: "Insert above")
      /// Insert below
      internal static let insertBelow = Loc.tr("Localizable", "SimpleTableMenu.Item.InsertBelow", fallback: "Insert below")
      /// Insert left
      internal static let insertLeft = Loc.tr("Localizable", "SimpleTableMenu.Item.InsertLeft", fallback: "Insert left")
      /// Insert right
      internal static let insertRight = Loc.tr("Localizable", "SimpleTableMenu.Item.InsertRight", fallback: "Insert right")
      /// Move down
      internal static let moveDown = Loc.tr("Localizable", "SimpleTableMenu.Item.MoveDown", fallback: "Move down")
      /// Move left
      internal static let moveLeft = Loc.tr("Localizable", "SimpleTableMenu.Item.MoveLeft", fallback: "Move left")
      /// Move right
      internal static let moveRight = Loc.tr("Localizable", "SimpleTableMenu.Item.MoveRight", fallback: "Move right")
      /// Move up
      internal static let moveUp = Loc.tr("Localizable", "SimpleTableMenu.Item.MoveUp", fallback: "Move up")
      /// Sort
      internal static let sort = Loc.tr("Localizable", "SimpleTableMenu.Item.Sort", fallback: "Sort")
      /// Style
      internal static let style = Loc.tr("Localizable", "SimpleTableMenu.Item.style", fallback: "Style")
    }
  }
  internal enum SlashMenu {
    /// Dots divider
    internal static let dotsDivider = Loc.tr("Localizable", "SlashMenu.DotsDivider", fallback: "Dots divider")
    /// Line divider
    internal static let lineDivider = Loc.tr("Localizable", "SlashMenu.LineDivider", fallback: "Line divider")
    /// Table
    internal static let table = Loc.tr("Localizable", "SlashMenu.Table", fallback: "Table")
    /// Table of contents
    internal static let tableOfContents = Loc.tr("Localizable", "SlashMenu.TableOfContents", fallback: "Table of contents")
    internal enum LinkTo {
      /// Create link to another object
      internal static let description = Loc.tr("Localizable", "SlashMenu.LinkTo.Description", fallback: "Create link to another object")
    }
  }
  internal enum SpaceCreate {
    /// Create a space
    internal static let title = Loc.tr("Localizable", "SpaceCreate.Title", fallback: "Create a space")
  }
  internal enum SpaceSettings {
    /// Delete space
    internal static let deleteButton = Loc.tr("Localizable", "SpaceSettings.DeleteButton", fallback: "Delete space")
    /// Space info
    internal static let info = Loc.tr("Localizable", "SpaceSettings.Info", fallback: "Space info")
    /// Network ID
    internal static let networkId = Loc.tr("Localizable", "SpaceSettings.NetworkId", fallback: "Network ID")
    /// Remote storage
    internal static let remoteStorage = Loc.tr("Localizable", "SpaceSettings.RemoteStorage", fallback: "Remote storage")
    /// Space settings
    internal static let title = Loc.tr("Localizable", "SpaceSettings.Title", fallback: "Space settings")
    internal enum DeleteAlert {
      /// This space will be deleted irrevocably. You can’t undo this action.
      internal static let message = Loc.tr("Localizable", "SpaceSettings.DeleteAlert.Message", fallback: "This space will be deleted irrevocably. You can’t undo this action.")
      /// Delete ‘%@’ space
      internal static func title(_ p1: Any) -> String {
        return Loc.tr("Localizable", "SpaceSettings.DeleteAlert.Title", String(describing: p1), fallback: "Delete ‘%@’ space")
      }
    }
  }
  internal enum Spaces {
    internal enum Accessibility {
      /// Personal Space
      internal static let personal = Loc.tr("Localizable", "Spaces.Accessibility.Personal", fallback: "Personal Space")
      /// Private Space
      internal static let `private` = Loc.tr("Localizable", "Spaces.Accessibility.Private", fallback: "Private Space")
      /// Public Space
      internal static let `public` = Loc.tr("Localizable", "Spaces.Accessibility.Public", fallback: "Public Space")
    }
    internal enum Search {
      /// Search spaces
      internal static let title = Loc.tr("Localizable", "Spaces.Search.Title", fallback: "Search spaces")
    }
  }
  internal enum StyleMenu {
    internal enum Color {
      internal enum TextColor {
        /// A
        internal static let placeholder = Loc.tr("Localizable", "StyleMenu.Color.TextColor.Placeholder", fallback: "A")
      }
    }
  }
  internal enum Sync {
    internal enum Status {
      internal enum Version {
        internal enum Outdated {
          /// Version outdated. Please update Anytype
          internal static let description = Loc.tr("Localizable", "Sync.Status.Version.Outdated.Description", fallback: "Version outdated. Please update Anytype")
        }
      }
    }
  }
  internal enum SyncStatus {
    internal enum LocalOnly {
      /// Local only
      internal static let description = Loc.tr("Localizable", "SyncStatus.LocalOnly.Description", fallback: "Local only")
      /// Local-only
      internal static let title = Loc.tr("Localizable", "SyncStatus.LocalOnly.Title", fallback: "Local-only")
    }
    internal enum Synced {
      internal enum Anytype {
        /// Backed up on Anytype Network
        internal static let description = Loc.tr("Localizable", "SyncStatus.Synced.Anytype.Description", fallback: "Backed up on Anytype Network")
      }
      internal enum AnytypeStaging {
        /// Backed up on Anytype Staging
        internal static let description = Loc.tr("Localizable", "SyncStatus.Synced.AnytypeStaging.Description", fallback: "Backed up on Anytype Staging")
      }
      internal enum SelfHosted {
        /// Backed up on Self-hosted Network
        internal static let description = Loc.tr("Localizable", "SyncStatus.Synced.SelfHosted.Description", fallback: "Backed up on Self-hosted Network")
      }
    }
  }
  internal enum TalbeOfContents {
    /// Add headings to create a table of contents
    internal static let empty = Loc.tr("Localizable", "TalbeOfContents.Empty", fallback: "Add headings to create a table of contents")
  }
  internal enum TemplateEditing {
    /// Edit template
    internal static let title = Loc.tr("Localizable", "TemplateEditing.Title", fallback: "Edit template")
  }
  internal enum TemplateOptions {
    internal enum Alert {
      /// Delete
      internal static let delete = Loc.tr("Localizable", "TemplateOptions.Alert.Delete", fallback: "Delete")
      /// Duplicate
      internal static let duplicate = Loc.tr("Localizable", "TemplateOptions.Alert.Duplicate", fallback: "Duplicate")
      /// Edit template
      internal static let editTemplate = Loc.tr("Localizable", "TemplateOptions.Alert.EditTemplate", fallback: "Edit template")
    }
  }
  internal enum TemplatePicker {
    /// Choose template
    internal static let chooseTemplate = Loc.tr("Localizable", "TemplatePicker.ChooseTemplate", fallback: "Choose template")
    internal enum Buttons {
      /// Use template
      internal static let useTemplate = Loc.tr("Localizable", "TemplatePicker.Buttons.UseTemplate", fallback: "Use template")
    }
  }
  internal enum TemplateSelection {
    /// Blank
    internal static let blankTemplate = Loc.tr("Localizable", "TemplateSelection.blankTemplate", fallback: "Blank")
    /// Select template
    internal static let selectTemplate = Loc.tr("Localizable", "TemplateSelection.SelectTemplate", fallback: "Select template")
    internal enum Available {
      /// This type has %d templates
      internal static func title(_ p1: Int) -> String {
        return Loc.tr("Localizable", "TemplateSelection.Available.Title", p1, fallback: "This type has %d templates")
      }
    }
    internal enum ObjectType {
      /// Object type
      internal static let subtitle = Loc.tr("Localizable", "TemplateSelection.ObjectType.Subtitle", fallback: "Object type")
    }
    internal enum Template {
      /// Template
      internal static let subtitle = Loc.tr("Localizable", "TemplateSelection.Template.Subtitle", fallback: "Template")
    }
  }
  internal enum Templates {
    internal enum Popup {
      /// The template was set as default
      internal static let `default` = Loc.tr("Localizable", "Templates.Popup.Default", fallback: "The template was set as default")
      /// The template was duplicated
      internal static let duplicated = Loc.tr("Localizable", "Templates.Popup.Duplicated", fallback: "The template was duplicated")
      /// The template was removed
      internal static let removed = Loc.tr("Localizable", "Templates.Popup.Removed", fallback: "The template was removed")
      /// New template was added to the type
      internal static let wasAddedTo = Loc.tr("Localizable", "Templates.Popup.WasAddedTo", fallback: "New template was added to the type")
    }
  }
  internal enum TextStyle {
    internal enum Bold {
      /// Bold
      internal static let title = Loc.tr("Localizable", "TextStyle.Bold.Title", fallback: "Bold")
    }
    internal enum Bulleted {
      /// Simple list
      internal static let subtitle = Loc.tr("Localizable", "TextStyle.Bulleted.Subtitle", fallback: "Simple list")
      /// Bulleted
      internal static let title = Loc.tr("Localizable", "TextStyle.Bulleted.Title", fallback: "Bulleted")
    }
    internal enum Callout {
      /// Bordered text with icon
      internal static let subtitle = Loc.tr("Localizable", "TextStyle.Callout.Subtitle", fallback: "Bordered text with icon")
      /// Callout
      internal static let title = Loc.tr("Localizable", "TextStyle.Callout.Title", fallback: "Callout")
    }
    internal enum Checkbox {
      /// Create and track task with to-do list
      internal static let subtitle = Loc.tr("Localizable", "TextStyle.Checkbox.Subtitle", fallback: "Create and track task with to-do list")
      /// Checkbox
      internal static let title = Loc.tr("Localizable", "TextStyle.Checkbox.Title", fallback: "Checkbox")
    }
    internal enum Code {
      /// Code
      internal static let title = Loc.tr("Localizable", "TextStyle.Code.Title", fallback: "Code")
    }
    internal enum Heading {
      /// Medium headline
      internal static let subtitle = Loc.tr("Localizable", "TextStyle.Heading.Subtitle", fallback: "Medium headline")
      /// Heading
      internal static let title = Loc.tr("Localizable", "TextStyle.Heading.Title", fallback: "Heading")
    }
    internal enum Highlighted {
      /// Spotlight, that needs special attention
      internal static let subtitle = Loc.tr("Localizable", "TextStyle.Highlighted.Subtitle", fallback: "Spotlight, that needs special attention")
      /// Highlighted
      internal static let title = Loc.tr("Localizable", "TextStyle.Highlighted.Title", fallback: "Highlighted")
    }
    internal enum Italic {
      /// Italic
      internal static let title = Loc.tr("Localizable", "TextStyle.Italic.Title", fallback: "Italic")
    }
    internal enum Link {
      /// Link
      internal static let title = Loc.tr("Localizable", "TextStyle.Link.Title", fallback: "Link")
    }
    internal enum Numbered {
      /// Numbered list
      internal static let subtitle = Loc.tr("Localizable", "TextStyle.Numbered.Subtitle", fallback: "Numbered list")
      /// Numbered list
      internal static let title = Loc.tr("Localizable", "TextStyle.Numbered.Title", fallback: "Numbered list")
    }
    internal enum Strikethrough {
      /// Strikethrough
      internal static let title = Loc.tr("Localizable", "TextStyle.Strikethrough.Title", fallback: "Strikethrough")
    }
    internal enum Subheading {
      /// Small headline
      internal static let subtitle = Loc.tr("Localizable", "TextStyle.Subheading.Subtitle", fallback: "Small headline")
      /// Subheading
      internal static let title = Loc.tr("Localizable", "TextStyle.Subheading.Title", fallback: "Subheading")
    }
    internal enum Text {
      /// Just start writing with a plain text
      internal static let subtitle = Loc.tr("Localizable", "TextStyle.Text.Subtitle", fallback: "Just start writing with a plain text")
      /// Text
      internal static let title = Loc.tr("Localizable", "TextStyle.Text.Title", fallback: "Text")
    }
    internal enum Title {
      /// Big section heading
      internal static let subtitle = Loc.tr("Localizable", "TextStyle.Title.Subtitle", fallback: "Big section heading")
      /// Title
      internal static let title = Loc.tr("Localizable", "TextStyle.Title.Title", fallback: "Title")
    }
    internal enum Toggle {
      /// Hide and show content inside
      internal static let subtitle = Loc.tr("Localizable", "TextStyle.Toggle.Subtitle", fallback: "Hide and show content inside")
      /// Toggle
      internal static let title = Loc.tr("Localizable", "TextStyle.Toggle.Title", fallback: "Toggle")
    }
  }
  internal enum ToggleEmpty {
    /// Toggle empty. Tap to create block.
    internal static let tapToCreateBlock = Loc.tr("Localizable", "Toggle empty. Tap to create block.", fallback: "Toggle empty. Tap to create block.")
  }
  internal enum WidgetExtension {
    internal enum LockScreen {
      /// Create a new object on the fly
      internal static let description = Loc.tr("Localizable", "WidgetExtension.LockScreen.Description", fallback: "Create a new object on the fly")
      /// New object
      internal static let title = Loc.tr("Localizable", "WidgetExtension.LockScreen.Title", fallback: "New object")
    }
  }
  internal enum WidgetObjectList {
    internal enum ForceDelete {
      /// You can’t undo this action.
      internal static let message = Loc.tr("Localizable", "WidgetObjectList.ForceDelete.Message", fallback: "You can’t undo this action.")
    }
  }
  internal enum Widgets {
    /// Widget source
    internal static let sourceSearch = Loc.tr("Localizable", "Widgets.SourceSearch", fallback: "Widget source")
    internal enum Actions {
      /// Add Below
      internal static let addBelow = Loc.tr("Localizable", "Widgets.Actions.AddBelow", fallback: "Add Below")
      /// Plural format key: "%#@object@"
      internal static func binConfirm(_ p1: Int) -> String {
        return Loc.tr("Localizable", "Widgets.Actions.BinConfirm", p1, fallback: "Plural format key: \"%#@object@\"")
      }
      /// Change Source
      internal static let changeSource = Loc.tr("Localizable", "Widgets.Actions.ChangeSource", fallback: "Change Source")
      /// Change Widget Type
      internal static let changeWidgetType = Loc.tr("Localizable", "Widgets.Actions.ChangeWidgetType", fallback: "Change Widget Type")
      /// Edit Widgets
      internal static let editWidgets = Loc.tr("Localizable", "Widgets.Actions.EditWidgets", fallback: "Edit Widgets")
      /// Empty Bin
      internal static let emptyBin = Loc.tr("Localizable", "Widgets.Actions.EmptyBin", fallback: "Empty Bin")
      /// New Object
      internal static let newObject = Loc.tr("Localizable", "Widgets.Actions.NewObject", fallback: "New Object")
      /// Remove Widget
      internal static let removeWidget = Loc.tr("Localizable", "Widgets.Actions.RemoveWidget", fallback: "Remove Widget")
    }
    internal enum Empty {
      /// This data view contains no objects
      internal static let title = Loc.tr("Localizable", "Widgets.Empty.Title", fallback: "This data view contains no objects")
    }
    internal enum Layout {
      internal enum CompactList {
        /// Widget with list view of set object
        internal static let description = Loc.tr("Localizable", "Widgets.Layout.CompactList.Description", fallback: "Widget with list view of set object")
        /// Сompact list
        internal static let title = Loc.tr("Localizable", "Widgets.Layout.CompactList.Title", fallback: "Сompact list")
      }
      internal enum Link {
        /// Сompact version of the object
        internal static let description = Loc.tr("Localizable", "Widgets.Layout.Link.Description", fallback: "Сompact version of the object")
        /// Link
        internal static let title = Loc.tr("Localizable", "Widgets.Layout.Link.Title", fallback: "Link")
      }
      internal enum List {
        /// Widget with list view of set object
        internal static let description = Loc.tr("Localizable", "Widgets.Layout.List.Description", fallback: "Widget with list view of set object")
        /// List
        internal static let title = Loc.tr("Localizable", "Widgets.Layout.List.Title", fallback: "List")
      }
      internal enum Screen {
        /// Widget type
        internal static let title = Loc.tr("Localizable", "Widgets.Layout.Screen.Title", fallback: "Widget type")
      }
      internal enum Tree {
        /// Hierarchical structure of objects
        internal static let description = Loc.tr("Localizable", "Widgets.Layout.Tree.Description", fallback: "Hierarchical structure of objects")
        /// Tree
        internal static let title = Loc.tr("Localizable", "Widgets.Layout.Tree.Title", fallback: "Tree")
      }
    }
    internal enum Library {
      internal enum RecentlyEdited {
        /// Recently edited
        internal static let name = Loc.tr("Localizable", "Widgets.Library.RecentlyEdited.Name", fallback: "Recently edited")
      }
      internal enum RecentlyOpened {
        /// On this device
        internal static let description = Loc.tr("Localizable", "Widgets.Library.RecentlyOpened.Description", fallback: "On this device")
        /// Recently opened
        internal static let name = Loc.tr("Localizable", "Widgets.Library.RecentlyOpened.Name", fallback: "Recently opened")
      }
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension Loc {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
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
