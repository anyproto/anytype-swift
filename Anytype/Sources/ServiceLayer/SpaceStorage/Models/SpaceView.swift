import Foundation
import Services

struct SpaceView: Identifiable, Equatable {
    let id: String
    let name: String
    let objectIconImage: Icon?
    let targetSpaceId: String
    let createdDate: Date?
    let accountStatus: SpaceStatus?
    let localStatus: SpaceStatus?
    let spaceAccessType: SpaceAccessType?
    let readersLimit: Int?
    let writersLimit: Int?
}

extension SpaceView: DetailsModel {
    init(details: ObjectDetails) {
        self.id = details.id
        self.name = details.name
        self.objectIconImage = details.objectIconImage
        self.targetSpaceId = details.targetSpaceId
        self.createdDate = details.createdDate
        self.accountStatus = details.spaceAccountStatusValue
        self.localStatus = details.spaceLocalStatusValue
        self.spaceAccessType = details.spaceAccessTypeValue
        self.readersLimit = details.readersLimit
        self.writersLimit = details.writersLimit
    }
    
    static var subscriptionKeys: [BundledRelationKey] = .builder {
        BundledRelationKey.id
        BundledRelationKey.name
        BundledRelationKey.objectIconImageKeys
        BundledRelationKey.targetSpaceId
        BundledRelationKey.createdDate
        BundledRelationKey.spaceAccessType
        BundledRelationKey.spaceAccountStatus
        BundledRelationKey.spaceLocalStatus
        BundledRelationKey.readersLimit
        BundledRelationKey.writersLimit
    }
}

extension SpaceView {
    
    var title: String {
        name.withPlaceholder
    }
    
    func canBeShared(isOwner: Bool) -> Bool {
        isOwner && (spaceAccessType == .shared || spaceAccessType == .private)
    }
    
    func canStopShating(isOwner: Bool) -> Bool {
        isOwner && (spaceAccessType == .shared)
    }
    
    var isShared: Bool {
        spaceAccessType == .shared
    }
    
    var canBeDelete: Bool {
        spaceAccessType == .private
    }
    
    var canBeArchive: Bool {
        accountStatus == .spaceRemoving
    }
    
    var canCancelJoinRequest: Bool {
        accountStatus == .spaceJoining
    }
    
    var isActive: Bool {
        localStatus == .ok && accountStatus != .spaceRemoving && accountStatus != .spaceDeleted
    }
    
    func canAddWriters(participants: [Participant]) -> Bool {
        guard canAddReaders(participants: participants) else { return false }
        guard let writersLimit else { return true }
        let activeParticipants = participants.filter { $0.permission == .writer || $0.permission == .owner }.count
        return writersLimit > activeParticipants
    }
    
    func canAddReaders(participants: [Participant]) -> Bool {
        guard let readersLimit else { return true }
        let activeParticipants = participants.filter { $0.permission == .reader || $0.permission == .writer || $0.permission == .owner }.count
        return readersLimit > activeParticipants
    }
    
}
