import Foundation
import Services

struct SpaceView: Identifiable {
    let id: String
    let name: String
    let title: String
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
        self.title = details.title
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
        BundledRelationKey.titleKeys
        BundledRelationKey.objectIconImageKeys
        BundledRelationKey.targetSpaceId
        BundledRelationKey.createdDate
        BundledRelationKey.spaceAccessType
        BundledRelationKey.spaceAccountStatus
        BundledRelationKey.spaceLocalStatus
    }
}

extension SpaceView {
    func canBeShared(isOwner: Bool) -> Bool {
        isOwner && (spaceAccessType == .shared || spaceAccessType == .private)
    }
    
    var isShared: Bool {
        spaceAccessType == .shared
    }
    
    var canBeDelete: Bool {
        spaceAccessType == .private && accountStatus != .spaceRemoving
    }
    
    var canBeArchive: Bool {
        accountStatus == .spaceRemoving
    }
    
    var canCancelJoinRequest: Bool {
        accountStatus == .spaceJoining
    }
}
