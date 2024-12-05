import AnytypeCore

extension FeatureFlags {
    
    static func showHomeSpaceLevelChat(spaceId: String) -> Bool {
        FeatureFlags.homeSpaceLevelChat || spaceId == "bafyreiezhzb4ggnhjwejmh67pd5grilk6jn3jt7y2rnfpbkjwekilreola.1t123w9f2lgn5"
    }
}
