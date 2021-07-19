//
//  AmplitudeConstants.swift
//  Anytype
//
//  Created by Denis Batvinkin on 15.07.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

enum AmplitudeConfiguration {
    static let apiKey = "827af3255d76ef87541cd459a0a38242"
}

enum AmplitudeEventsName {
    static let showAuthScreen = "Auth Screen: Show"
    static let walletCreate = "WalletCreate"
    static let accountCreate = "AccountCreate"
    static let accountRecover = "AccountRecover"
    static let accountSelect = "AccountSelect"
    static let accountStop = "AccountStop"

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
    static let buttonActionMenu = "ButtonActionMenu"
    static let buttonStyleMenu = "ButtonStyleMenu"
    static let buttonMentionMenu = "ButtonMentionMenu"
    static let buttonHideKeyboard = "ButtonHideKeyboard"

    // Profile events
    static let buttonProfileLogOut = "ButtonProfileLogOut"

    // Emoji picker events
    static let buttonRandomEmoji = "ButtonRandomEmoji"
    static let buttonRemoveEmoji = "ButtonRemoveEmoji"
    static let buttonUploadPhoto = "ButtonUploadPhoto"

    // Settings view events
    static let buttonProfileWallpaper = "ButtonProfileWallpaper"

    // Home view events
    static let favoritesPage = "Page: Favorites"
    static let archivePage = "Page: Archive"
    static let recentPage = "Page: Recent"
    static let inboxPage = "Page: Inbox"
    static let profilePage = "Page: Profile"

}

enum AmplitudeEventsPropertiesKey {
    static let accountId = "accountId"
    static let blockStyle = "style"
    static let blockType = "type"
}
