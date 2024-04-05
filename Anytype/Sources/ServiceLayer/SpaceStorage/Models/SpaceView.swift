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
    
    var canStopShare: Bool {
        isShared
    }
    
    var isActive: Bool {
        localStatus == .ok && accountStatus != .spaceRemoving && accountStatus != .spaceDeleted
    }
}
