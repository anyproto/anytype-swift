enum AmplitudeConfiguration {
    static let devAPIKey = "827af3255d76ef87541cd459a0a38242"
    static let prodAPIKey = "1ba981d1a9afb8af8c81847ef3383a20"
}

enum AmplitudeEventsName {
    // Auth events
    static let walletCreate = "WalletCreate"
    static let walletRecover = "WalletRecover"
    static let accountCreate = "AccountCreate"
    static let accountRecover = "AccountRecover"
    static let accountSelect = "AccountSelect"
    static let accountStop = "AccountStop"

    // Block events
    static let blockCreate = "BlockCreate"
    static let blockBookmarkFetch = "BlockBookmarkFetch"
    static let blockListDuplicate = "BlockListDuplicate"
    static let blockCreatePage = "BlockCreatePage"
    static let blockListConvertChildrenToPages = "BlockListConvertChildrenToPages"
    static let blockListSetAlign = "BlockListSetAlign"
    static let blockListSetBackgroundColor = "BlockListSetBackgroundColor"
    static let blockListSetDivStyle = "BlockListSetDivStyle"
    static let blockMerge = "BlockMerge"
    static let blockSetDetails = "BlockSetDetails"
    static let blockSetTextChecked = "BlockSetTextChecked"
    static let blockSetTextStyle = "BlockSetTextStyle"
    static let blockSetTextText = "BlockSetTextText"
    static let blockSplit = "BlockSplit"
    static let blockUnlink = "BlockUnlink"
    static let blockUpload = "BlockUpload"
    static let downloadFile = "DownloadFile"
    static let pageCreate = "PageCreate"

    // Events in editing accessory view
    static let buttonSlashMenu = "ButtonSlashMenu"
    static let buttonStyleMenu = "ButtonStyleMenu"
    static let buttonMentionMenu = "ButtonMentionMenu"
    static let buttonHideKeyboard = "ButtonHideKeyboard"

    // Profile events
    static let buttonProfileLogOut = "ButtonProfileLogOut"

    // Emoji picker events
    static let buttonRandomEmoji = "ButtonRandomEmoji"
    static let buttonRemoveEmoji = "ButtonRemoveEmoji"
    static let buttonUploadPhoto = "ButtonUploadPhoto"

    // Settings object events
    static let buttonCoverInObjectSettings = "ButtonCoverInObjectSettings"
    static let buttonIconInObjectSettings = "ButtonIconInObjectSettings"
    static let buttonLayoutInObjectSettings = "ButtonLayoutInObjectSettings"
    static let buttonRelationsInObjectSettings = "ButtonRelationsInObjectSettings"

    // Dashboard view events
    static let favoritesTabSelected = "FavoritesTabSelected"
    static let archiveTabSelected = "ArchiveTabSelected"
    static let recentTabSelected = "RecentTabSelected"
    static let sharedTabSelected = "SharedTabSelected"

    static let profilePage = "Page: Profile"
    static let documentPage = "Page: Document"
    static let dashboardPage = "Page: Dashboard"

    // Screen show events
    static let showAuthScreen = "Auth Screen: Show"
    static let showKeychainPhraseScreen = "Show Keychain Phrase Screen"
    static let showAboutScreen = "Show About Screen"

    // Popup events
    static let popupSettings = "PopupSettings"
    static let popupSlashMenu = "PopupSlashMenu"
    static let popupActionMenu = "PopupActionMenu"
    static let popupBookmarkMenu = "PopupBookmarkMenu"
    static let popupDocumentMenu = "PopupDocumentMenu"
    static let popupChooseEmojiMenu = "PopupChooseEmojiMenu"
    static let popupChooseLayout = "PopupChooseLayout"
    static let popupChooseCover = "PopupChooseCover"
    static let popupStyleMenu = "PopupStyleMenu"
    static let popupMentionMenu = "PopupMentionMenu"
    static let popupProfileIconMenu = "PopupProfileIconMenu"
    
    // Service events
    static let objectListDelete = "ObjectListDelete"
}

enum AmplitudeEventsPropertiesKey {
    static let accountId = "accountId"
    static let blockStyle = "style"
    static let blockType = "type"
    static let documentId = "documentId"
    static let count = "count"
}
