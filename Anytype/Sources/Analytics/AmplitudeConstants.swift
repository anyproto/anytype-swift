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
    static let blockCopy = "BlockCopy"
    static let blockCreatePage = "BlockCreatePage"
}

enum AmplitudeEventsPropertiesKey {
    static let accountId = "accountId"
    static let blockStyle = "style"
    static let blockType = "type"
}

enum AmplitudeUserPropertiesKey {
    static let appVersion = "appVersion"
}
