// swiftlint:disable all

// Generated from https://github.com/anytypeio/go-anytype-middleware/blob/master/pkg/lib/bundle/relations.json

import Foundation

public enum BundledPropertyKey: String, Sendable {

    case tag = "tag"

    /// Camera used to capture image or video
    case camera = "camera"

    /// Height of image/video in pixels
    case heightInPixels = "heightInPixels"

    /// Date when the object was initially created
    case createdDate = "createdDate"

    /// Date when the object will be deleted from your device
    case toBeDeletedDate = "toBeDeletedDate"

    /// Prioritized target types for the relation's value
    case relationFormatObjectTypes = "relationFormatObjectTypes"

    /// Relation key
    case relationKey = "relationKey"

    /// Relation option color
    case relationOptionColor = "relationOptionColor"

    /// Latest Acl head id
    case latestAclHeadId = "latestAclHeadId"

    /// Done checkbox used to render action layout. 
    case done = "done"

    /// Artist URL
    case mediaArtistURL = "mediaArtistURL"

    /// Specifies whether template is provided by anytype
    case templateIsBundled = "templateIsBundled"

    /// Object restrictions list
    case restrictions = "restrictions"

    /// Readers limit
    case readersLimit = "readersLimit"

    /// Writers limit
    case writersLimit = "writersLimit"

    /// Shared spaces limit
    case sharedSpacesLimit = "sharedSpacesLimit"

    /// Adds the object to the highlighted dataview in space
    case isHighlighted = "isHighlighted"

    /// List of related tasks
    case tasks = "tasks"

    /// Plaintext extracted from the object's blocks 
    case snippet = "snippet"

    /// Type of the underlying value
    case relationFormat = "relationFormat"

    /// Indicates whether the relation value is readonly
    case relationReadonlyValue = "relationReadonlyValue"

    /// Image icon
    case iconImage = "iconImage"

    case ingredients = "ingredients"

    case genre = "genre"

    /// Year when this object were released
    case releasedYear = "releasedYear"

    /// Option that contains scale of Cover the image
    case coverScale = "coverScale"

    case relationDefaultValue = "relationDefaultValue"

    case linkedProjects = "linkedProjects"

    /// Audio record's album name
    case audioAlbum = "audioAlbum"

    /// Specify visual align of the layout
    case layoutAlign = "layoutAlign"

    /// Task status
    case status = "status"

    /// Specify if object is hidden
    case isHidden = "isHidden"

    /// Specify if object discovery is hidden
    case isHiddenDiscovery = "isHiddenDiscovery"

    /// Artist name
    case mediaArtistName = "mediaArtistName"

    case email = "email"

    case company = "company"

    case aperture = "aperture"

    /// Date when the object was modified last time
    case lastModifiedDate = "lastModifiedDate"

    /// List of recommended relations
    case recommendedRelations = "recommendedRelations"

    /// Human which created this object
    case creator = "creator"

    /// Recommended layout for new templates and objects of specific objec
    case recommendedLayout = "recommendedLayout"

    /// Date when the object was modified last opened
    case lastOpenedDate = "lastOpenedDate"

    case author = "author"

    /// Name of artist
    case artist = "artist"

    case dueDate = "dueDate"

    /// 1 emoji(can contains multiple UTF symbols) used as an icon
    case iconEmoji = "iconEmoji"

    /// 1-image, 2-color, 3-gradient, 4-prebuilt bg image, 5 - unsplash image. Value stored in coverId
    case coverType = "coverType"

    /// Image y offset of the provided image
    case coverY = "coverY"

    case time = "time"

    /// Size of file/image in bytes
    case sizeInBytes = "sizeInBytes"

    /// Point to the object types that can be added to collection. Empty means any object type can be added to the collection
    case collectionOf = "collectionOf"

    /// Indicates whether the object is read-only. Means it can't be edited and archived
    case isReadonly = "isReadonly"

    /// Date when the file were added into the anytype
    case addedDate = "addedDate"

    /// Person who is responsible for this task or object
    case assignee = "assignee"

    case exposure = "exposure"

    /// Type that is used for templating
    case targetObjectType = "targetObjectType"

    /// Adds the object to the home dashboard
    case isFavorite = "isFavorite"

    /// Space object belongs to
    case workspaceId = "workspaceId"

    /// Space belongs to
    case spaceId = "spaceId"

    /// Audio record's genre name
    case audioGenre = "audioGenre"

    /// Name of the object
    case name = "name"

    case mood = "mood"

    /// The text lyrics of the music record
    case audioLyrics = "audioLyrics"

    case focalRatio = "focalRatio"

    /// Used to order tasks in list/canban
    case priority = "priority"

    /// Mime type of object
    case fileMimeType = "fileMimeType"

    /// Relation that stores the object's type
    case type = "type"

    /// Anytype layout ID(from pb enum)
    case layout = "layout"

    /// Number of the track in the
    case audioAlbumTrackNumber = "audioAlbumTrackNumber"

    /// Set of internal flags
    case internalFlags = "internalFlags"

    /// Image x offset of the provided image
    case coverX = "coverX"

    case description = "description"

    /// An image is an artifact that depicts visual perception, such as a photograph or other two-dimensional picture
    case picture = "picture"

    /// Link to itself. Used in databases
    case id = "id"

    /// Web address, a reference to a web resource that specifies its location on a computer network and a mechanism for retrieving it
    case url = "url"

    case cameraIso = "cameraIso"

    /// Relation that indicates document has been deleted
    case isDeleted = "isDeleted"

    /// Outgoing links
    case links = "links"

    /// Can contains image hash, color or prebuild bg id, depends on coverType relation
    case coverId = "coverId"

    /// Human who updated the object last time
    case lastModifiedBy = "lastModifiedBy"

    /// Relation allows multi values
    case relationMaxCount = "relationMaxCount"

    /// Width of image/video in pixels
    case widthInPixels = "widthInPixels"

    case progress = "progress"

    /// Point to the object types or realtions used to aggregate the set. Empty means object of all types will be aggregated 
    case setOf = "setOf"

    /// Hides the object
    case isArchived = "isArchived"

    case fileExt = "fileExt"

    /// Important relations that always appear at the top of the object
    case featuredRelations = "featuredRelations"

    case phone = "phone"

    /// Stored for object type. Contains tge list of smartblock types used to create the object
    case smartblockTypes = "smartblockTypes"

    case source = "source"

    case sourceObject = "sourceObject"

    case oldAnytypeID = "oldAnytypeID"

    /// Space Dashboard object ID
    case spaceDashboardId = "spaceDashboardId"

    /// Choose one of our pre-installed icons during On-boarding
    case iconOption = "iconOption"

    /// There are two options of accessibility of workspace - private (0) or public (1)
    case spaceAccessibility = "spaceAccessibility"

    /// Space access type, see enum model.SpaceAccessType
    case spaceAccessType = "spaceAccessType"

    /// Space UX type, see enum model.SpaceUxType
    case spaceUxType = "spaceUxType"

    /// File path or url with original object
    case sourceFilePath = "sourceFilePath"

    /// File sync status
    case fileSyncStatus = "fileSyncStatus"

    /// File backup status
    case fileBackupStatus = "fileBackupStatus"

    /// File indexing status
    case fileIndexingStatus = "fileIndexingStatus"

    /// Last change ID
    case lastChangeId = "lastChangeId"

    case starred = "starred"

    /// ID of template chosen as default for particular object type
    case defaultTemplateId = "defaultTemplateId"

    /// Unique key used to ensure object uniqueness within the space
    case uniqueKey = "uniqueKey"

    /// List of links coming to object
    case backlinks = "backlinks"

    /// Relation that indicates document has been uninstalled
    case isUninstalled = "isUninstalled"

    /// Source of objects in Anytype (clipboard, import)
    case origin = "origin"

    /// Relation that indicates the local status of space. Possible values: models.SpaceStatus
    case spaceLocalStatus = "spaceLocalStatus"

    /// Relation that indicates the remote status of space. Possible values: models.SpaceStatus
    case spaceRemoteStatus = "spaceRemoteStatus"

    /// Specify if the space is shareable
    case spaceShareableStatus = "spaceShareableStatus"

    /// Specify if access control list is shared
    case isAclShared = "isAclShared"

    /// Relation that indicates the status of space that the user is set. Possible values: models.SpaceStatus
    case spaceAccountStatus = "spaceAccountStatus"

    /// CID of invite file for current space. It stored in SpaceView
    case spaceInviteFileCid = "spaceInviteFileCid"

    /// Encoded encryption key of invite file for current space. It stored in SpaceView
    case spaceInviteFileKey = "spaceInviteFileKey"

    /// Encoded encryption key of invite file for current space. It stored in SpaceView
    case spaceInviteType = "spaceInviteType"

    /// CID of invite file for  for guest user in the current space. It's stored in SpaceView
    case spaceInviteGuestFileCid = "spaceInviteGuestFileCid"

    /// Encoded encryption key of invite file for guest user in the current space. It's stored in SpaceView
    case spaceInviteGuestFileKey = "spaceInviteGuestFileKey"

    /// Guest key to read public space
    case guestKey = "guestKey"

    /// Participant permissions. Possible values: models.ParticipantPermissions
    case participantPermissions = "participantPermissions"

    /// Invite permissions. Possible values: models.ParticipantPermissions
    case spaceInvitePermissions = "spaceInvitePermissions"

    /// Identity
    case identity = "identity"

    /// Participant status. Possible values: models.ParticipantStatus
    case participantStatus = "participantStatus"

    /// Link to the profile attached to Anytype Identity
    case identityProfileLink = "identityProfileLink"

    /// Link the profile object to specific Identity
    case profileOwnerIdentity = "profileOwnerIdentity"

    /// Relation that indicates the real space id on the spaceView
    case targetSpaceId = "targetSpaceId"

    case fileId = "fileId"

    /// Last time object type was used
    case lastUsedDate = "lastUsedDate"

    /// Revision of system object
    case revision = "revision"

    /// Describes how this image is used
    case imageKind = "imageKind"

    /// Import type, used to create object (notion, md and etc)
    case importType = "importType"

    /// Name of profile that the user could be mentioned by
    case globalName = "globalName"

    /// Object sync status
    case syncStatus = "syncStatus"

    /// Object sync date
    case syncDate = "syncDate"

    /// Object sync error
    case syncError = "syncError"

    /// Object has a chat
    case hasChat = "hasChat"

    /// Chat id
    case chatId = "chatId"

    /// Objects that are mentioned in blocks of this object
    case mentions = "mentions"

    /// Unix time representation of date object
    case timestamp = "timestamp"

    /// Width of object's layout
    case layoutWidth = "layoutWidth"

    /// Layout resolved based on object self layout and type recommended layout
    case resolvedLayout = "resolvedLayout"

    case fileVariantIds = "fileVariantIds"

    case fileVariantPaths = "fileVariantPaths"

    case fileVariantKeys = "fileVariantKeys"

    case fileVariantWidths = "fileVariantWidths"

    case fileVariantChecksums = "fileVariantChecksums"

    case fileVariantMills = "fileVariantMills"

    case fileVariantOptions = "fileVariantOptions"

    case fileSourceChecksum = "fileSourceChecksum"

    /// Space order
    case spaceOrder = "spaceOrder"

    /// Choose icon for the type among custom Anytype icons
    case iconName = "iconName"

    /// List of recommended featured relations
    case recommendedFeaturedRelations = "recommendedFeaturedRelations"

    /// List of recommended relations that are hidden in layout
    case recommendedHiddenRelations = "recommendedHiddenRelations"

    /// List of recommended file-specific relations
    case recommendedFileRelations = "recommendedFileRelations"

    /// Default view type that will be used for new sets/collections
    case defaultViewType = "defaultViewType"

    /// Default object type id that will be set to new sets/collections
    case defaultTypeId = "defaultTypeId"

    /// Automatically generated widget. Used to avoid creating widget if was removed by user
    case autoWidgetTargets = "autoWidgetTargets"

    case autoWidgetDisabled = "autoWidgetDisabled"

    /// Name of Object type in plural form
    case pluralName = "pluralName"

    /// Layout of header relations. Line or column
    case headerRelationsLayout = "headerRelationsLayout"

    /// Identifier to use in intergrations with Anytype API
    case apiObjectKey = "apiObjectKey"

    /// Should time be shown for relation values with date format
    case relationFormatIncludeTime = "relationFormatIncludeTime"

    /// Push notification mode - mute/all/mentions (see model.SpacePushNotificationMode)
    case spacePushNotificationMode = "spacePushNotificationMode"

    /// Push notifications space key (base64)
    case spacePushNotificationKey = "spacePushNotificationKey"

    /// Push notifications encryption key (base64)
    case spacePushNotificationEncryptionKey = "spacePushNotificationEncryptionKey"
}
