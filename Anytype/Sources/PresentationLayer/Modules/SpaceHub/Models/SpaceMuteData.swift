import Services

struct SpaceMuteData: Identifiable, Equatable {
    let spaceId: String
    let mode: SpacePushNotificationsMode
    
    var id: String { spaceId }
}
