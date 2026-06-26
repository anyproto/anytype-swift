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
    let joinDate: Date?
    let accountStatus: SpaceStatus?
    let localStatus: SpaceStatus?
    let spaceAccessType: SpaceAccessType?
    let readersLimit: Int?
    let writersLimit: Int?
    let chatId: String
    let spaceOrder: String
    // Legacy proto field. Kept only as a fallback for stream channels —
    // they have no representation in `SpaceType`. Sole reader: `isLegacyStream`.
    // Do not introduce new readers; use `spaceType` for all new logic.
    private let uxType: SpaceUxType
    let spaceType: SpaceType
    let pushNotificationEncryptionKey: String
    let pushNotificationMode: SpacePushNotificationsMode
    let forceAllIds: [String]
    let forceMuteIds: [String]
    let forceMentionIds: [String]
    let oneToOneIdentity: String
    let homepage: SpaceHomepage

    init(
        id: String,
        name: String,
        description: String,
        objectIconImage: Icon,
        targetSpaceId: String,
        createdDate: Date?,
        joinDate: Date?,
        accountStatus: SpaceStatus?,
        localStatus: SpaceStatus?,
        spaceAccessType: SpaceAccessType?,
        readersLimit: Int?,
        writersLimit: Int?,
        chatId: String,
        spaceOrder: String,
        spaceType: SpaceType,
        pushNotificationEncryptionKey: String,
        pushNotificationMode: SpacePushNotificationsMode,
        forceAllIds: [String],
        forceMuteIds: [String],
        forceMentionIds: [String],
        oneToOneIdentity: String,
        homepage: SpaceHomepage,
        uxType: SpaceUxType = .data
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.objectIconImage = objectIconImage
        self.targetSpaceId = targetSpaceId
        self.createdDate = createdDate
        self.joinDate = joinDate
        self.accountStatus = accountStatus
        self.localStatus = localStatus
        self.spaceAccessType = spaceAccessType
        self.readersLimit = readersLimit
        self.writersLimit = writersLimit
        self.chatId = chatId
        self.spaceOrder = spaceOrder
        self.uxType = uxType
        self.spaceType = spaceType
        self.pushNotificationEncryptionKey = pushNotificationEncryptionKey
        self.pushNotificationMode = pushNotificationMode
        self.forceAllIds = forceAllIds
        self.forceMuteIds = forceMuteIds
        self.forceMentionIds = forceMentionIds
        self.oneToOneIdentity = oneToOneIdentity
        self.homepage = homepage
    }
}

extension SpaceView: DetailsModel {
    init(details: ObjectDetails) {
        self.id = details.id
        self.name = details.name
        self.description = details.description
        self.objectIconImage = details.objectIconImage
        self.targetSpaceId = details.targetSpaceId
        self.createdDate = details.createdDate
        self.joinDate = details.spaceJoinDate
        self.accountStatus = details.spaceAccountStatusValue
        self.localStatus = details.spaceLocalStatusValue
        self.spaceAccessType = details.spaceAccessTypeValue
        self.readersLimit = details.readersLimit
        self.writersLimit = details.writersLimit
        self.chatId = details.chatId
        self.spaceOrder = details.spaceOrder
        self.uxType = details.spaceUxTypeValue ?? .data
        self.spaceType = details.spaceTypeValue ?? .regular
        self.pushNotificationEncryptionKey = details.spacePushNotificationEncryptionKey
        self.pushNotificationMode = details.spacePushNotificationModeValue ?? .all
        self.forceAllIds = details.spacePushNotificationForceAllIds
        self.forceMuteIds = details.spacePushNotificationForceMuteIds
        self.forceMentionIds = details.spacePushNotificationForceMentionIds
        self.oneToOneIdentity = details.oneToOneIdentity
        self.homepage = SpaceHomepage(rawValue: details.homepage)
    }
    
    static let subscriptionKeys: [BundledPropertyKey] = .builder {
        BundledPropertyKey.id
        BundledPropertyKey.name
        BundledPropertyKey.description
        BundledPropertyKey.objectIconImageKeys
        BundledPropertyKey.targetSpaceId
        BundledPropertyKey.createdDate
        BundledPropertyKey.spaceJoinDate
        BundledPropertyKey.spaceAccessType
        BundledPropertyKey.spaceAccountStatus
        BundledPropertyKey.spaceLocalStatus
        BundledPropertyKey.readersLimit
        BundledPropertyKey.writersLimit
        BundledPropertyKey.sharedSpacesLimit
        BundledPropertyKey.chatId
        BundledPropertyKey.spaceOrder
        BundledPropertyKey.spaceUxType
        BundledPropertyKey.spaceType
        BundledPropertyKey.spacePushNotificationEncryptionKey
        BundledPropertyKey.spacePushNotificationMode
        BundledPropertyKey.spacePushNotificationForceAllIds
        BundledPropertyKey.spacePushNotificationForceMuteIds
        BundledPropertyKey.spacePushNotificationForceMentionIds
        BundledPropertyKey.oneToOneIdentity
        BundledPropertyKey.homepage
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
    
    var isOneToOne: Bool {
        spaceType == .oneToOne
    }

    // Sole reader of the legacy `uxType` field. Used only to enforce
    // owner-only-write on legacy stream spaces, which have no representation
    // in the new `SpaceType` enum.
    var isLegacyStream: Bool {
        uxType == .stream
    }

    var showsMessageAuthor: Bool {
        spaceType.showsMessageAuthor
    }

    @available(*, deprecated, message: "Use homepage to determine initial screen")
    var initialScreenIsChat: Bool {
        spaceType.initialScreenIsChat
    }

    @available(*, deprecated, message: "Will be reworked with homepage logic")
    var canAddChatWidget: Bool {
        !initialScreenIsChat && isShared && hasChat
    }

    @available(*, deprecated, message: "Will be reworked with homepage logic")
    var canShowChatWidget: Bool {
        !spaceType.supportsMultiChats
    }

    var hasChat: Bool {
        chatId.isNotEmpty
    }
    
    /// Available writer slots for new members, accounting for the owner occupying one seat.
    /// Returns nil when the tier limit is unknown.
    var availableWriterSlots: Int? {
        writersLimit.map { max(0, $0 - 1) }
    }

    func canAddWriters(participants: [Participant]) -> Bool {
        guard let writersLimit else { return true }
        return writersLimit > activeWriters(participants: participants)
    }

    func canChangeWriterToReader(participants: [Participant]) -> Bool {
        return true
    }
    
    func canChangeReaderToWriter(participants: [Participant]) -> Bool {
        guard let writersLimit else { return true }
        return writersLimit > activeWriters(participants: participants)
    }

    private func activeWriters(participants: [Participant]) -> Int {
        participants.filter { $0.permission == .writer || $0.permission == .owner || $0.permission == .admin }.count
    }

    func effectiveNotificationMode(for chatId: String) -> SpacePushNotificationsMode {
        if forceAllIds.contains(chatId) {
            return .all
        }
        if forceMuteIds.contains(chatId) {
            return .nothing
        }
        if forceMentionIds.contains(chatId) {
            return .mentions
        }
        return pushNotificationMode
    }
}
