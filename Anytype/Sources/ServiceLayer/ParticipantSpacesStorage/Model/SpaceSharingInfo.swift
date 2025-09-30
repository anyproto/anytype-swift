struct SpaceSharingInfo {
    let sharedSpacesLimit: Int
    let sharedSpacesCount: Int

    var limitsAllowSharing: Bool {
        sharedSpacesCount < sharedSpacesLimit
    }
}
