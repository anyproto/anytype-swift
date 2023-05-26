// swiftlint:disable all

// Generated from https://github.com/anytypeio/go-anytype-middleware/blob/master/pkg/lib/bundle/relations.json

import Foundation

public enum BundledRelationKey: String {

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

    case instructions = "instructions"

    /// Done checkbox used to render action layout. 
    case done = "done"

    /// Artist URL
    case mediaArtistURL = "mediaArtistURL"

    /// Specifies whether template is provided by anytype
    case templateIsBundled = "templateIsBundled"

    case dateOfBirth = "dateOfBirth"

    /// Object restrictions list
    case restrictions = "restrictions"

    /// Adds the object to the highlighted dataview in space
    case isHighlighted = "isHighlighted"

    case thumbnailImage = "thumbnailImage"

    case attachments = "attachments"

    /// The artist that performed this album or recording
    case audioArtist = "audioArtist"

    /// List of related tasks
    case tasks = "tasks"

    /// Plaintext extracted from the object's blocks 
    case snippet = "snippet"

    case hypothesisAssumptions = "hypothesisAssumptions"

    /// Type of the underlying value
    case relationFormat = "relationFormat"

    /// Indicates whether the relation value is readonly
    case relationReadonlyValue = "relationReadonlyValue"

    /// Image icon
    case iconImage = "iconImage"

    case ingredients = "ingredients"

    case genre = "genre"

    case solution = "solution"

    /// Year when this object were released
    case releasedYear = "releasedYear"

    /// Option that contains scale of Cover the image
    case coverScale = "coverScale"

    case twitter = "twitter"

    case userStories = "userStories"

    case relationDefaultValue = "relationDefaultValue"

    case linkedProjects = "linkedProjects"

    /// Audio record's album name
    case audioAlbum = "audioAlbum"

    case problem = "problem"

    /// Specify visual align of the layout
    case layoutAlign = "layoutAlign"

    case `class` = "class"

    case difficulty = "difficulty"

    case director = "director"

    /// Task status
    case status = "status"

    case logic = "logic"

    case alternative = "alternative"

    case linkedContacts = "linkedContacts"

    case rottenTomatoesRating = "rottenTomatoesRating"

    /// Specify if object is hidden
    case isHidden = "isHidden"

    case additional = "additional"

    case budget = "budget"

    /// Artist name
    case mediaArtistName = "mediaArtistName"

    case rating = "rating"

    case email = "email"

    case company = "company"

    case aperture = "aperture"

    /// Date when the object was modified last time
    case lastModifiedDate = "lastModifiedDate"

    case stakeholders = "stakeholders"

    case measureOfSuccess = "measureOfSuccess"

    /// List of recommended relations
    case recommendedRelations = "recommendedRelations"

    /// Human which created this object
    case creator = "creator"

    /// Recommended layout for new templates and objects of specific objec
    case recommendedLayout = "recommendedLayout"

    case result = "result"

    case reflection = "reflection"

    /// Date when the object was modified last opened
    case lastOpenedDate = "lastOpenedDate"

    case author = "author"

    /// Name of artist
    case artist = "artist"

    case dueDate = "dueDate"

    case records = "records"

    /// 1 emoji(can contains multiple UTF symbols) used as an icon
    case iconEmoji = "iconEmoji"

    /// 1-image, 2-color, 3-gradient, 4-prebuilt bg image. Value stored in coverId
    case coverType = "coverType"

    /// Image y offset of the provided image
    case coverY = "coverY"

    case time = "time"

    /// Size of file/image in bytes
    case sizeInBytes = "sizeInBytes"

    /// Point to the object types that can be added to collection. Empty means any object type can be added to the collection
    case collectionOf = "collectionOf"

    case events = "events"

    case timeframe = "timeframe"

    /// Indicates whether the object is read-only. Means it can't be edited and archived
    case isReadonly = "isReadonly"

    /// Date when the file were added into the anytype
    case addedDate = "addedDate"

    /// Person who is responsible for this task or object
    case assignee = "assignee"

    case exposure = "exposure"

    /// Type that is used for templating
    case targetObjectType = "targetObjectType"

    case materials = "materials"

    /// Adds the object to the home dashboard
    case isFavorite = "isFavorite"

    case stars = "stars"

    /// Space object belongs to
    case workspaceId = "workspaceId"

    /// Audio record's genre name
    case audioGenre = "audioGenre"

    case telegram = "telegram"

    case trailer = "trailer"

    /// Name of the object
    case name = "name"

    case mood = "mood"

    /// The text lyrics of the music record
    case audioLyrics = "audioLyrics"

    case instagram = "instagram"

    case classType = "classType"

    case howToReproduce = "howToReproduce"

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

    case placeOfBirth = "placeOfBirth"

    case composer = "composer"

    /// Set of internal flags
    case internalFlags = "internalFlags"

    case socialProfile = "socialProfile"

    case occupation = "occupation"

    /// Image x offset of the provided image
    case coverX = "coverX"

    case description = "description"

    case facebook = "facebook"

    /// An image is an artifact that depicts visual perception, such as a photograph or other two-dimensional picture
    case picture = "picture"

    /// Link to itself. Used in databases
    case id = "id"

    /// Web address, a reference to a web resource that specifies its location on a computer network and a mechanism for retrieving it
    case url = "url"

    case objectives = "objectives"

    case cameraIso = "cameraIso"

    /// Relation that indicates document has been deleted
    case isDeleted = "isDeleted"

    /// Outgoing links
    case links = "links"

    case servings = "servings"

    case category = "category"

    /// Can contains image hash, color or prebuild bg id, depends on coverType relation
    case coverId = "coverId"

    /// Human who updated the object last time
    case lastModifiedBy = "lastModifiedBy"

    /// Relation allows multi values
    case relationMaxCount = "relationMaxCount"

    case questions = "questions"

    /// Width of image/video in pixels
    case widthInPixels = "widthInPixels"

    case progress = "progress"

    /// Point to the object types or realtions used to aggregate the set. Empty means object of all types will be aggregated 
    case setOf = "setOf"

    case gender = "gender"

    /// Hides the object
    case isArchived = "isArchived"

    case fileExt = "fileExt"

    case scope = "scope"

    case job = "job"

    /// Important relations that always appear at the top of the object
    case featuredRelations = "featuredRelations"

    case phone = "phone"

    case imdbRating = "imdbRating"

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

    /// File path or url with original object
    case sourceFilePath = "sourceFilePath"

    /// File sync status
    case fileSyncStatus = "fileSyncStatus"
}
