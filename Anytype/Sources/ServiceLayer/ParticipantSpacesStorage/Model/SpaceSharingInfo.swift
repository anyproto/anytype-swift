struct SpaceSharingInfo {
    let sharedSpacesLimit: Int

    let sharedDataSpacesCount: Int
    let sharedChatSpacesCount: Int
    let sharedStreamSpacesCount: Int

    var limitsAllowSharing: Bool {
        sharedDataSpacesCount < sharedSpacesLimit
    }
}
