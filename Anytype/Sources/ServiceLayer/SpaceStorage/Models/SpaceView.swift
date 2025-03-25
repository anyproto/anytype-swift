import Foundation
import Services
import AnytypeCore

struct SpaceView: Identifiable, Equatable {
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
    let isPinned: Bool
    let uxType: SpaceUxType
    let unreadMessagesCount: Int
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
        self.isPinned = details.spaceOrder.isNotEmpty
        self.uxType = details.spaceUxTypeValue ?? .data
        self.unreadMessagesCount = 0
    }
    
    static let subscriptionKeys: [BundledRelationKey] = .builder {
        BundledRelationKey.id
        BundledRelationKey.name
        BundledRelationKey.description
        BundledRelationKey.objectIconImageKeys
        BundledRelationKey.targetSpaceId
        BundledRelationKey.createdDate
        BundledRelationKey.spaceAccessType
        BundledRelationKey.spaceAccountStatus
        BundledRelationKey.spaceLocalStatus
        BundledRelationKey.readersLimit
        BundledRelationKey.writersLimit
        BundledRelationKey.sharedSpacesLimit
        BundledRelationKey.chatId
        BundledRelationKey.spaceOrder
        BundledRelationKey.spaceUxType
    }
}

extension SpaceView {
    
    var title: String {
        name.withPlaceholder
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
    
    var showChat: Bool {
        (uxType == .chat || uxType == .stream) && FeatureFlags.showHomeSpaceLevelChat(spaceId: targetSpaceId)
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
    
    func updateUnreadMessagesCount(_ count: Int) -> SpaceView {
        SpaceView(
            id: id,
            name: name,
            description: description,
            objectIconImage: objectIconImage,
            targetSpaceId: targetSpaceId,
            createdDate: createdDate,
            accountStatus: accountStatus,
            localStatus: localStatus,
            spaceAccessType: spaceAccessType,
            readersLimit: readersLimit,
            writersLimit: writersLimit,
            chatId: chatId,
            isPinned: isPinned,
            unreadMessagesCount: count
        )
    }
    
    private func activeReaders(participants: [Participant]) -> Int {
        participants.filter { $0.permission == .reader || $0.permission == .writer || $0.permission == .owner }.count
    }
    
    private func activeWriters(participants: [Participant]) -> Int {
        participants.filter { $0.permission == .writer || $0.permission == .owner }.count
    }
}
