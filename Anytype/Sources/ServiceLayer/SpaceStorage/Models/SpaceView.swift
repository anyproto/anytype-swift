import Foundation
import Services
import AnytypeCore

struct SpaceView: Identifiable, Equatable, Hashable {
    let id: String
    let name: String
    let description: String
    let objectIconImage: Icon
    let targetSpaceId: String
    let createdDate: Date?
    let accountStatus: SpaceStatus?
    let localStatus: SpaceStatus?
    let spaceAccessType: SpaceAccessType?
    let readersLimit: Int?
    let writersLimit: Int?
    let chatId: String
    let spaceOrder: String
    let uxType: SpaceUxType
    let pushNotificationEncryptionKey: String
    let pushNotificationMode: SpacePushNotificationsMode
}

extension SpaceView: DetailsModel {
    init(details: ObjectDetails) {
        self.id = details.id
        self.name = details.name
        self.description = details.description
        self.objectIconImage = details.objectIconImage
        self.targetSpaceId = details.targetSpaceId
        self.createdDate = details.createdDate
        self.accountStatus = details.spaceAccountStatusValue
        self.localStatus = details.spaceLocalStatusValue
        self.spaceAccessType = details.spaceAccessTypeValue
        self.readersLimit = details.readersLimit
        self.writersLimit = details.writersLimit
        self.chatId = details.chatId
        self.spaceOrder = details.spaceOrder
        self.uxType = details.spaceUxTypeValue ?? .data
        self.pushNotificationEncryptionKey = details.spacePushNotificationEncryptionKey
        self.pushNotificationMode = details.spacePushNotificationModeValue ?? .all
    }
    
    static let subscriptionKeys: [BundledPropertyKey] = .builder {
        BundledPropertyKey.id
        BundledPropertyKey.name
        BundledPropertyKey.description
        BundledPropertyKey.objectIconImageKeys
        BundledPropertyKey.targetSpaceId
        BundledPropertyKey.createdDate
        BundledPropertyKey.spaceAccessType
        BundledPropertyKey.spaceAccountStatus
        BundledPropertyKey.spaceLocalStatus
        BundledPropertyKey.readersLimit
        BundledPropertyKey.writersLimit
        BundledPropertyKey.sharedSpacesLimit
        BundledPropertyKey.chatId
        BundledPropertyKey.spaceOrder
        BundledPropertyKey.spaceUxType
        BundledPropertyKey.spacePushNotificationEncryptionKey
        BundledPropertyKey.spacePushNotificationMode
    }
}

extension SpaceView {
    
    var title: String {
        name.withPlaceholder
    }
    
    var isPinned: Bool {
        spaceOrder.isNotEmpty
    }
    
    var isShared: Bool {
        spaceAccessType == .shared
    }
    
    var isActive: Bool {
        let spaceIsNotDeleted = accountStatus != .spaceRemoving && accountStatus != .spaceDeleted
        let spaceIsNotJoining = accountStatus != .spaceJoining
        return localStatus == .ok && spaceIsNotDeleted && spaceIsNotJoining
    }
    
    var isJoining: Bool {
        accountStatus == .spaceJoining
    }
    
    var isLoading: Bool {
        let spaceIsLoading = localStatus == .loading || localStatus == .unknown
        let spaceIsNotDeleted = accountStatus != .spaceRemoving && accountStatus != .spaceDeleted
        let spaceIsNotJoining = accountStatus != .spaceJoining
        return spaceIsLoading && spaceIsNotDeleted && spaceIsNotJoining
    }
    
    var initialScreenIsChat: Bool {
        uxType == .chat || uxType == .stream
    }
    
    var chatToggleEnable: Bool {
        FeatureFlags.showHomeSpaceLevelChat(spaceId: targetSpaceId)
    }
    
    var canAddChatWidget: Bool {
        !initialScreenIsChat && isShared
    }
    
    func canAddWriters(participants: [Participant]) -> Bool {
        guard canAddReaders(participants: participants) else { return false }
        guard let writersLimit else { return true }
        return writersLimit > activeWriters(participants: participants)
    }
    
    func canAddReaders(participants: [Participant]) -> Bool {
        guard let readersLimit else { return true }
        return readersLimit > activeReaders(participants: participants)
    }
    
    func canChangeWriterToReader(participants: [Participant]) -> Bool {
        guard let readersLimit else { return true }
        return readersLimit >= activeReaders(participants: participants)
    }
    
    func canChangeReaderToWriter(participants: [Participant]) -> Bool {
        guard let writersLimit else { return true }
        return writersLimit > activeWriters(participants: participants)
    }
    
    private func activeReaders(participants: [Participant]) -> Int {
        participants.filter { $0.permission == .reader || $0.permission == .writer || $0.permission == .owner }.count
    }
    
    private func activeWriters(participants: [Participant]) -> Int {
        participants.filter { $0.permission == .writer || $0.permission == .owner }.count
    }
}
