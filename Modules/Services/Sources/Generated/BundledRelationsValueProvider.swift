// swiftlint:disable all

import Foundation
import SwiftProtobuf
import AnytypeCore

public typealias ObjectId = String

public protocol BundledRelationsValueProvider {

    var tag: [ObjectId] { get }
    var camera: String { get }
    var heightInPixels: Int? { get }
    var createdDate: Date? { get }
    var toBeDeletedDate: Date? { get }
    var relationFormatObjectTypes: [ObjectId] { get }
    var relationKey: String { get }
    var relationOptionColor: String { get }
    var latestAclHeadId: String { get }
    var done: Bool { get }
    var mediaArtistURL: AnytypeURL? { get }
    var templateIsBundled: Bool { get }
    var restrictions: [Int] { get }
    var readersLimit: Int? { get }
    var writersLimit: Int? { get }
    var sharedSpacesLimit: Int? { get }
    var isHighlighted: Bool { get }
    var tasks: [ObjectId] { get }
    var snippet: String { get }
    var relationFormat: Int? { get }
    var relationReadonlyValue: Bool { get }
    var iconImage: ObjectId { get }
    var ingredients: String { get }
    var genre: [ObjectId] { get }
    var releasedYear: Int? { get }
    var coverScale: Int? { get }
    var relationDefaultValue: String { get }
    var linkedProjects: [ObjectId] { get }
    var audioAlbum: String { get }
    var layoutAlign: Int? { get }
    var status: ObjectId? { get }
    var isHidden: Bool { get }
    var isHiddenDiscovery: Bool { get }
    var mediaArtistName: String { get }
    var email: String? { get }
    var company: ObjectId { get }
    var aperture: String { get }
    var lastModifiedDate: Date? { get }
    var recommendedRelations: [ObjectId] { get }
    var creator: ObjectId { get }
    var recommendedLayout: Int? { get }
    var lastOpenedDate: Date? { get }
    var author: [ObjectId] { get }
    var artist: String { get }
    var dueDate: Date? { get }
    var iconEmoji: Emoji? { get }
    var coverType: Int? { get }
    var coverY: Int? { get }
    var time: Int? { get }
    var sizeInBytes: Int? { get }
    var collectionOf: [ObjectId] { get }
    var isReadonly: Bool { get }
    var addedDate: Date? { get }
    var assignee: [ObjectId] { get }
    var exposure: String { get }
    var targetObjectType: ObjectId { get }
    var isFavorite: Bool { get }
    var workspaceId: ObjectId { get }
    var spaceId: ObjectId { get }
    var audioGenre: String { get }
    var name: String { get }
    var mood: [ObjectId] { get }
    var audioLyrics: String { get }
    var focalRatio: Int? { get }
    var priority: Int? { get }
    var fileMimeType: String { get }
    var type: ObjectId { get }
    var layout: Int? { get }
    var audioAlbumTrackNumber: Int? { get }
    var internalFlags: [Int] { get }
    var coverX: Int? { get }
    var description: String { get }
    var picture: ObjectId { get }
    var id: ObjectId { get }
    var url: AnytypeURL? { get }
    var cameraIso: Int? { get }
    var isDeleted: Bool { get }
    var links: [ObjectId] { get }
    var coverId: String { get }
    var lastModifiedBy: ObjectId { get }
    var relationMaxCount: Int? { get }
    var widthInPixels: Int? { get }
    var progress: Int? { get }
    var setOf: [ObjectId] { get }
    var isArchived: Bool { get }
    var fileExt: String { get }
    var featuredRelations: [ObjectId] { get }
    var phone: String? { get }
    var smartblockTypes: [Int] { get }
    var source: AnytypeURL? { get }
    var sourceObject: ObjectId { get }
    var oldAnytypeID: String { get }
    var spaceDashboardId: ObjectId { get }
    var iconOption: Int? { get }
    var spaceAccessibility: Int? { get }
    var spaceAccessType: Int? { get }
    var spaceUxType: Int? { get }
    var sourceFilePath: String { get }
    var fileSyncStatus: Int? { get }
    var fileBackupStatus: Int? { get }
    var fileIndexingStatus: Int? { get }
    var lastChangeId: String { get }
    var starred: Bool { get }
    var defaultTemplateId: ObjectId { get }
    var uniqueKey: String { get }
    var backlinks: [ObjectId] { get }
    var isUninstalled: Bool { get }
    var origin: Int? { get }
    var spaceLocalStatus: Int? { get }
    var spaceRemoteStatus: Int? { get }
    var spaceShareableStatus: Int? { get }
    var isAclShared: Bool { get }
    var spaceAccountStatus: Int? { get }
    var spaceInviteFileCid: String { get }
    var spaceInviteFileKey: String { get }
    var spaceInviteGuestFileCid: String { get }
    var spaceInviteGuestFileKey: String { get }
    var guestKey: String { get }
    var participantPermissions: Int? { get }
    var identity: String { get }
    var participantStatus: Int? { get }
    var identityProfileLink: ObjectId { get }
    var profileOwnerIdentity: String { get }
    var targetSpaceId: String { get }
    var fileId: [String] { get }
    var lastUsedDate: Date? { get }
    var revision: Int? { get }
    var imageKind: Int? { get }
    var importType: Int? { get }
    var globalName: String { get }
    var syncStatus: Int? { get }
    var syncDate: Date? { get }
    var syncError: Int? { get }
    var hasChat: Bool { get }
    var chatId: ObjectId { get }
    var mentions: [ObjectId] { get }
    var timestamp: Date? { get }
    var layoutWidth: Int? { get }
    var resolvedLayout: Int? { get }
    var spaceOrder: String { get }
    var iconName: String { get }
    var recommendedFeaturedRelations: [ObjectId] { get }
    var recommendedHiddenRelations: [ObjectId] { get }
    var recommendedFileRelations: [ObjectId] { get }
    var defaultViewType: Int? { get }
    var defaultTypeId: ObjectId { get }
    var autoWidgetTargets: [ObjectId] { get }
    var pluralName: String { get }
} 

public extension BundledRelationsValueProvider where Self: RelationValueProvider {
    var tag: [ObjectId] {
        return value(for: BundledRelationKey.tag.rawValue)
    }
    /// Camera used to capture image or video
    var camera: String {
        return value(for: BundledRelationKey.camera.rawValue)
    }
    /// Height of image/video in pixels
    var heightInPixels: Int? {
        return value(for: BundledRelationKey.heightInPixels.rawValue)
    }
    /// Date when the object was initially created
    var createdDate: Date? {
        return value(for: BundledRelationKey.createdDate.rawValue)
    }
    /// Date when the object will be deleted from your device
    var toBeDeletedDate: Date? {
        return value(for: BundledRelationKey.toBeDeletedDate.rawValue)
    }
    /// Prioritized target types for the relation's value
    var relationFormatObjectTypes: [ObjectId] {
        return value(for: BundledRelationKey.relationFormatObjectTypes.rawValue)
    }
    /// Relation key
    var relationKey: String {
        return value(for: BundledRelationKey.relationKey.rawValue)
    }
    /// Relation option color
    var relationOptionColor: String {
        return value(for: BundledRelationKey.relationOptionColor.rawValue)
    }
    /// Latest Acl head id
    var latestAclHeadId: String {
        return value(for: BundledRelationKey.latestAclHeadId.rawValue)
    }
    /// Done checkbox used to render action layout. 
    var done: Bool {
        return value(for: BundledRelationKey.done.rawValue)
    }
    /// Artist URL
    var mediaArtistURL: AnytypeURL? {
        return value(for: BundledRelationKey.mediaArtistURL.rawValue)
    }
    /// Specifies whether template is provided by anytype
    var templateIsBundled: Bool {
        return value(for: BundledRelationKey.templateIsBundled.rawValue)
    }
    /// Object restrictions list
    var restrictions: [Int] {
        return value(for: BundledRelationKey.restrictions.rawValue)
    }
    /// Readers limit
    var readersLimit: Int? {
        return value(for: BundledRelationKey.readersLimit.rawValue)
    }
    /// Writers limit
    var writersLimit: Int? {
        return value(for: BundledRelationKey.writersLimit.rawValue)
    }
    /// Shared spaces limit
    var sharedSpacesLimit: Int? {
        return value(for: BundledRelationKey.sharedSpacesLimit.rawValue)
    }
    /// Adds the object to the highlighted dataview in space
    var isHighlighted: Bool {
        return value(for: BundledRelationKey.isHighlighted.rawValue)
    }
    /// List of related tasks
    var tasks: [ObjectId] {
        return value(for: BundledRelationKey.tasks.rawValue)
    }
    /// Plaintext extracted from the object's blocks 
    var snippet: String {
        return value(for: BundledRelationKey.snippet.rawValue)
    }
    /// Type of the underlying value
    var relationFormat: Int? {
        return value(for: BundledRelationKey.relationFormat.rawValue)
    }
    /// Indicates whether the relation value is readonly
    var relationReadonlyValue: Bool {
        return value(for: BundledRelationKey.relationReadonlyValue.rawValue)
    }
    /// Image icon
    var iconImage: ObjectId {
        return value(for: BundledRelationKey.iconImage.rawValue)
    }
    var ingredients: String {
        return value(for: BundledRelationKey.ingredients.rawValue)
    }
    var genre: [ObjectId] {
        return value(for: BundledRelationKey.genre.rawValue)
    }
    /// Year when this object were released
    var releasedYear: Int? {
        return value(for: BundledRelationKey.releasedYear.rawValue)
    }
    /// Option that contains scale of Cover the image
    var coverScale: Int? {
        return value(for: BundledRelationKey.coverScale.rawValue)
    }
    var relationDefaultValue: String {
        return value(for: BundledRelationKey.relationDefaultValue.rawValue)
    }
    var linkedProjects: [ObjectId] {
        return value(for: BundledRelationKey.linkedProjects.rawValue)
    }
    /// Audio record's album name
    var audioAlbum: String {
        return value(for: BundledRelationKey.audioAlbum.rawValue)
    }
    /// Specify visual align of the layout
    var layoutAlign: Int? {
        return value(for: BundledRelationKey.layoutAlign.rawValue)
    }
    /// Task status
    var status: ObjectId? {
        return value(for: BundledRelationKey.status.rawValue)
    }
    /// Specify if object is hidden
    var isHidden: Bool {
        return value(for: BundledRelationKey.isHidden.rawValue)
    }
    /// Specify if object discovery is hidden
    var isHiddenDiscovery: Bool {
        return value(for: BundledRelationKey.isHiddenDiscovery.rawValue)
    }
    /// Artist name
    var mediaArtistName: String {
        return value(for: BundledRelationKey.mediaArtistName.rawValue)
    }
    var email: String? {
        return value(for: BundledRelationKey.email.rawValue)
    }
    var company: ObjectId {
        return value(for: BundledRelationKey.company.rawValue)
    }
    var aperture: String {
        return value(for: BundledRelationKey.aperture.rawValue)
    }
    /// Date when the object was modified last time
    var lastModifiedDate: Date? {
        return value(for: BundledRelationKey.lastModifiedDate.rawValue)
    }
    /// List of recommended relations
    var recommendedRelations: [ObjectId] {
        return value(for: BundledRelationKey.recommendedRelations.rawValue)
    }
    /// Human which created this object
    var creator: ObjectId {
        return value(for: BundledRelationKey.creator.rawValue)
    }
    /// Recommended layout for new templates and objects of specific objec
    var recommendedLayout: Int? {
        return value(for: BundledRelationKey.recommendedLayout.rawValue)
    }
    /// Date when the object was modified last opened
    var lastOpenedDate: Date? {
        return value(for: BundledRelationKey.lastOpenedDate.rawValue)
    }
    var author: [ObjectId] {
        return value(for: BundledRelationKey.author.rawValue)
    }
    /// Name of artist
    var artist: String {
        return value(for: BundledRelationKey.artist.rawValue)
    }
    var dueDate: Date? {
        return value(for: BundledRelationKey.dueDate.rawValue)
    }
    /// 1 emoji(can contains multiple UTF symbols) used as an icon
    var iconEmoji: Emoji? {
        return value(for: BundledRelationKey.iconEmoji.rawValue)
    }
    /// 1-image, 2-color, 3-gradient, 4-prebuilt bg image, 5 - unsplash image. Value stored in coverId
    var coverType: Int? {
        return value(for: BundledRelationKey.coverType.rawValue)
    }
    /// Image y offset of the provided image
    var coverY: Int? {
        return value(for: BundledRelationKey.coverY.rawValue)
    }
    var time: Int? {
        return value(for: BundledRelationKey.time.rawValue)
    }
    /// Size of file/image in bytes
    var sizeInBytes: Int? {
        return value(for: BundledRelationKey.sizeInBytes.rawValue)
    }
    /// Point to the object types that can be added to collection. Empty means any object type can be added to the collection
    var collectionOf: [ObjectId] {
        return value(for: BundledRelationKey.collectionOf.rawValue)
    }
    /// Indicates whether the object is read-only. Means it can't be edited and archived
    var isReadonly: Bool {
        return value(for: BundledRelationKey.isReadonly.rawValue)
    }
    /// Date when the file were added into the anytype
    var addedDate: Date? {
        return value(for: BundledRelationKey.addedDate.rawValue)
    }
    /// Person who is responsible for this task or object
    var assignee: [ObjectId] {
        return value(for: BundledRelationKey.assignee.rawValue)
    }
    var exposure: String {
        return value(for: BundledRelationKey.exposure.rawValue)
    }
    /// Type that is used for templating
    var targetObjectType: ObjectId {
        return value(for: BundledRelationKey.targetObjectType.rawValue)
    }
    /// Adds the object to the home dashboard
    var isFavorite: Bool {
        return value(for: BundledRelationKey.isFavorite.rawValue)
    }
    /// Space object belongs to
    var workspaceId: ObjectId {
        return value(for: BundledRelationKey.workspaceId.rawValue)
    }
    /// Space belongs to
    var spaceId: ObjectId {
        return value(for: BundledRelationKey.spaceId.rawValue)
    }
    /// Audio record's genre name
    var audioGenre: String {
        return value(for: BundledRelationKey.audioGenre.rawValue)
    }
    /// Name of the object
    var name: String {
        return value(for: BundledRelationKey.name.rawValue)
    }
    var mood: [ObjectId] {
        return value(for: BundledRelationKey.mood.rawValue)
    }
    /// The text lyrics of the music record
    var audioLyrics: String {
        return value(for: BundledRelationKey.audioLyrics.rawValue)
    }
    var focalRatio: Int? {
        return value(for: BundledRelationKey.focalRatio.rawValue)
    }
    /// Used to order tasks in list/canban
    var priority: Int? {
        return value(for: BundledRelationKey.priority.rawValue)
    }
    /// Mime type of object
    var fileMimeType: String {
        return value(for: BundledRelationKey.fileMimeType.rawValue)
    }
    /// Relation that stores the object's type
    var type: ObjectId {
        return value(for: BundledRelationKey.type.rawValue)
    }
    /// Anytype layout ID(from pb enum)
    var layout: Int? {
        return value(for: BundledRelationKey.layout.rawValue)
    }
    /// Number of the track in the
    var audioAlbumTrackNumber: Int? {
        return value(for: BundledRelationKey.audioAlbumTrackNumber.rawValue)
    }
    /// Set of internal flags
    var internalFlags: [Int] {
        return value(for: BundledRelationKey.internalFlags.rawValue)
    }
    /// Image x offset of the provided image
    var coverX: Int? {
        return value(for: BundledRelationKey.coverX.rawValue)
    }
    var description: String {
        return value(for: BundledRelationKey.description.rawValue)
    }
    /// An image is an artifact that depicts visual perception, such as a photograph or other two-dimensional picture
    var picture: ObjectId {
        return value(for: BundledRelationKey.picture.rawValue)
    }
    /// Link to itself. Used in databases
    var id: ObjectId {
        return value(for: BundledRelationKey.id.rawValue)
    }
    /// Web address, a reference to a web resource that specifies its location on a computer network and a mechanism for retrieving it
    var url: AnytypeURL? {
        return value(for: BundledRelationKey.url.rawValue)
    }
    var cameraIso: Int? {
        return value(for: BundledRelationKey.cameraIso.rawValue)
    }
    /// Relation that indicates document has been deleted
    var isDeleted: Bool {
        return value(for: BundledRelationKey.isDeleted.rawValue)
    }
    /// Outgoing links
    var links: [ObjectId] {
        return value(for: BundledRelationKey.links.rawValue)
    }
    /// Can contains image hash, color or prebuild bg id, depends on coverType relation
    var coverId: String {
        return value(for: BundledRelationKey.coverId.rawValue)
    }
    /// Human who updated the object last time
    var lastModifiedBy: ObjectId {
        return value(for: BundledRelationKey.lastModifiedBy.rawValue)
    }
    /// Relation allows multi values
    var relationMaxCount: Int? {
        return value(for: BundledRelationKey.relationMaxCount.rawValue)
    }
    /// Width of image/video in pixels
    var widthInPixels: Int? {
        return value(for: BundledRelationKey.widthInPixels.rawValue)
    }
    var progress: Int? {
        return value(for: BundledRelationKey.progress.rawValue)
    }
    /// Point to the object types or realtions used to aggregate the set. Empty means object of all types will be aggregated 
    var setOf: [ObjectId] {
        return value(for: BundledRelationKey.setOf.rawValue)
    }
    /// Hides the object
    var isArchived: Bool {
        return value(for: BundledRelationKey.isArchived.rawValue)
    }
    var fileExt: String {
        return value(for: BundledRelationKey.fileExt.rawValue)
    }
    /// Important relations that always appear at the top of the object
    var featuredRelations: [ObjectId] {
        return value(for: BundledRelationKey.featuredRelations.rawValue)
    }
    var phone: String? {
        return value(for: BundledRelationKey.phone.rawValue)
    }
    /// Stored for object type. Contains tge list of smartblock types used to create the object
    var smartblockTypes: [Int] {
        return value(for: BundledRelationKey.smartblockTypes.rawValue)
    }
    var source: AnytypeURL? {
        return value(for: BundledRelationKey.source.rawValue)
    }
    var sourceObject: ObjectId {
        return value(for: BundledRelationKey.sourceObject.rawValue)
    }
    var oldAnytypeID: String {
        return value(for: BundledRelationKey.oldAnytypeID.rawValue)
    }
    /// Space Dashboard object ID
    var spaceDashboardId: ObjectId {
        return value(for: BundledRelationKey.spaceDashboardId.rawValue)
    }
    /// Choose one of our pre-installed icons during On-boarding
    var iconOption: Int? {
        return value(for: BundledRelationKey.iconOption.rawValue)
    }
    /// There are two options of accessibility of workspace - private (0) or public (1)
    var spaceAccessibility: Int? {
        return value(for: BundledRelationKey.spaceAccessibility.rawValue)
    }
    /// Space access type, see enum model.SpaceAccessType
    var spaceAccessType: Int? {
        return value(for: BundledRelationKey.spaceAccessType.rawValue)
    }
    /// Space UX type, see enum model.SpaceUxType
    var spaceUxType: Int? {
        return value(for: BundledRelationKey.spaceUxType.rawValue)
    }
    /// File path or url with original object
    var sourceFilePath: String {
        return value(for: BundledRelationKey.sourceFilePath.rawValue)
    }
    /// File sync status
    var fileSyncStatus: Int? {
        return value(for: BundledRelationKey.fileSyncStatus.rawValue)
    }
    /// File backup status
    var fileBackupStatus: Int? {
        return value(for: BundledRelationKey.fileBackupStatus.rawValue)
    }
    /// File indexing status
    var fileIndexingStatus: Int? {
        return value(for: BundledRelationKey.fileIndexingStatus.rawValue)
    }
    /// Last change ID
    var lastChangeId: String {
        return value(for: BundledRelationKey.lastChangeId.rawValue)
    }
    var starred: Bool {
        return value(for: BundledRelationKey.starred.rawValue)
    }
    /// ID of template chosen as default for particular object type
    var defaultTemplateId: ObjectId {
        return value(for: BundledRelationKey.defaultTemplateId.rawValue)
    }
    /// Unique key used to ensure object uniqueness within the space
    var uniqueKey: String {
        return value(for: BundledRelationKey.uniqueKey.rawValue)
    }
    /// List of links coming to object
    var backlinks: [ObjectId] {
        return value(for: BundledRelationKey.backlinks.rawValue)
    }
    /// Relation that indicates document has been uninstalled
    var isUninstalled: Bool {
        return value(for: BundledRelationKey.isUninstalled.rawValue)
    }
    /// Source of objects in Anytype (clipboard, import)
    var origin: Int? {
        return value(for: BundledRelationKey.origin.rawValue)
    }
    /// Relation that indicates the local status of space. Possible values: models.SpaceStatus
    var spaceLocalStatus: Int? {
        return value(for: BundledRelationKey.spaceLocalStatus.rawValue)
    }
    /// Relation that indicates the remote status of space. Possible values: models.SpaceStatus
    var spaceRemoteStatus: Int? {
        return value(for: BundledRelationKey.spaceRemoteStatus.rawValue)
    }
    /// Specify if the space is shareable
    var spaceShareableStatus: Int? {
        return value(for: BundledRelationKey.spaceShareableStatus.rawValue)
    }
    /// Specify if access control list is shared
    var isAclShared: Bool {
        return value(for: BundledRelationKey.isAclShared.rawValue)
    }
    /// Relation that indicates the status of space that the user is set. Possible values: models.SpaceStatus
    var spaceAccountStatus: Int? {
        return value(for: BundledRelationKey.spaceAccountStatus.rawValue)
    }
    /// CID of invite file for current space. It stored in SpaceView
    var spaceInviteFileCid: String {
        return value(for: BundledRelationKey.spaceInviteFileCid.rawValue)
    }
    /// Encoded encryption key of invite file for current space. It stored in SpaceView
    var spaceInviteFileKey: String {
        return value(for: BundledRelationKey.spaceInviteFileKey.rawValue)
    }
    /// CID of invite file for  for guest user in the current space. It's stored in SpaceView
    var spaceInviteGuestFileCid: String {
        return value(for: BundledRelationKey.spaceInviteGuestFileCid.rawValue)
    }
    /// Encoded encryption key of invite file for guest user in the current space. It's stored in SpaceView
    var spaceInviteGuestFileKey: String {
        return value(for: BundledRelationKey.spaceInviteGuestFileKey.rawValue)
    }
    /// Guest key to read public space
    var guestKey: String {
        return value(for: BundledRelationKey.guestKey.rawValue)
    }
    /// Participant permissions. Possible values: models.ParticipantPermissions
    var participantPermissions: Int? {
        return value(for: BundledRelationKey.participantPermissions.rawValue)
    }
    /// Identity
    var identity: String {
        return value(for: BundledRelationKey.identity.rawValue)
    }
    /// Participant status. Possible values: models.ParticipantStatus
    var participantStatus: Int? {
        return value(for: BundledRelationKey.participantStatus.rawValue)
    }
    /// Link to the profile attached to Anytype Identity
    var identityProfileLink: ObjectId {
        return value(for: BundledRelationKey.identityProfileLink.rawValue)
    }
    /// Link the profile object to specific Identity
    var profileOwnerIdentity: String {
        return value(for: BundledRelationKey.profileOwnerIdentity.rawValue)
    }
    /// Relation that indicates the real space id on the spaceView
    var targetSpaceId: String {
        return value(for: BundledRelationKey.targetSpaceId.rawValue)
    }
    var fileId: [String] {
        return value(for: BundledRelationKey.fileId.rawValue)
    }
    /// Last time object type was used
    var lastUsedDate: Date? {
        return value(for: BundledRelationKey.lastUsedDate.rawValue)
    }
    /// Revision of system object
    var revision: Int? {
        return value(for: BundledRelationKey.revision.rawValue)
    }
    /// Describes how this image is used
    var imageKind: Int? {
        return value(for: BundledRelationKey.imageKind.rawValue)
    }
    /// Import type, used to create object (notion, md and etc)
    var importType: Int? {
        return value(for: BundledRelationKey.importType.rawValue)
    }
    /// Name of profile that the user could be mentioned by
    var globalName: String {
        return value(for: BundledRelationKey.globalName.rawValue)
    }
    /// Object sync status
    var syncStatus: Int? {
        return value(for: BundledRelationKey.syncStatus.rawValue)
    }
    /// Object sync date
    var syncDate: Date? {
        return value(for: BundledRelationKey.syncDate.rawValue)
    }
    /// Object sync error
    var syncError: Int? {
        return value(for: BundledRelationKey.syncError.rawValue)
    }
    /// Object has a chat
    var hasChat: Bool {
        return value(for: BundledRelationKey.hasChat.rawValue)
    }
    /// Chat id
    var chatId: ObjectId {
        return value(for: BundledRelationKey.chatId.rawValue)
    }
    /// Objects that are mentioned in blocks of this object
    var mentions: [ObjectId] {
        return value(for: BundledRelationKey.mentions.rawValue)
    }
    /// Unix time representation of date object
    var timestamp: Date? {
        return value(for: BundledRelationKey.timestamp.rawValue)
    }
    /// Width of object's layout
    var layoutWidth: Int? {
        return value(for: BundledRelationKey.layoutWidth.rawValue)
    }
    /// Layout resolved based on object self layout and type recommended layout
    var resolvedLayout: Int? {
        return value(for: BundledRelationKey.resolvedLayout.rawValue)
    }
    /// Space order
    var spaceOrder: String {
        return value(for: BundledRelationKey.spaceOrder.rawValue)
    }
    /// Choose icon for the type among custom Anytype icons
    var iconName: String {
        return value(for: BundledRelationKey.iconName.rawValue)
    }
    /// List of recommended featured relations
    var recommendedFeaturedRelations: [ObjectId] {
        return value(for: BundledRelationKey.recommendedFeaturedRelations.rawValue)
    }
    /// List of recommended relations that are hidden in layout
    var recommendedHiddenRelations: [ObjectId] {
        return value(for: BundledRelationKey.recommendedHiddenRelations.rawValue)
    }
    /// List of recommended file-specific relations
    var recommendedFileRelations: [ObjectId] {
        return value(for: BundledRelationKey.recommendedFileRelations.rawValue)
    }
    /// Default view type that will be used for new sets/collections
    var defaultViewType: Int? {
        return value(for: BundledRelationKey.defaultViewType.rawValue)
    }
    /// Default object type id that will be set to new sets/collections
    var defaultTypeId: ObjectId {
        return value(for: BundledRelationKey.defaultTypeId.rawValue)
    }
    /// Automatically generated widget. Used to avoid creating widget if was removed by user
    var autoWidgetTargets: [ObjectId] {
        return value(for: BundledRelationKey.autoWidgetTargets.rawValue)
    }
    /// Name of Object type in plural form
    var pluralName: String {
        return value(for: BundledRelationKey.pluralName.rawValue)
    }
}
