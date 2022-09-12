// swiftlint:disable all

import Foundation

public enum BundledRelationKey: String {

    case meditation = "meditation"

    /// Strict dictionary to select relation values from
    case relationOptionsDict = "relationOptionsDict"

    case tag = "tag"

    /// Camera used to capture image or video
    case camera = "camera"

    /// Height of image/video in pixels
    case heightInPixels = "heightInPixels"

    case location = "location"

    /// Date when the object was initially created
    case createdDate = "createdDate"

    /// Date when the object will be deleted from your device
    case toBeDeletedDate = "toBeDeletedDate"

    /// Types that used for such relation
    case relationFormatObjectTypes = "relationFormatObjectTypes"

    /// Relation key
    case relationKey = "relationKey"

    /// Relation option text
    case relationOptionText = "relationOptionText"

    /// Relation option color
    case relationOptionColor = "relationOptionColor"

    case instructions = "instructions"

    /// Done checkbox used to render action layout. 
    case done = "done"

    /// Artist URL
    case mediaArtistURL = "mediaArtistURL"

    /// Specifies whether template is provided by anytype
    case templateIsBundled = "templateIsBundled"

    case shipTo = "shipTo"

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

    case gratefulFor = "gratefulFor"

    case founders = "founders"

    case website = "website"

    /// Type of the underlying value
    case relationFormat = "relationFormat"

    /// Indicates whether the relation value is readonly
    case relationReadonlyValue = "relationReadonlyValue"

    /// Image icon
    case iconImage = "iconImage"

    case ingredients = "ingredients"

    case total = "total"

    case responsible = "responsible"

    case genre = "genre"

    case solution = "solution"

    /// Year when this object were released
    case releasedYear = "releasedYear"

    /// Option that contains scale of Cover the image
    case coverScale = "coverScale"

    case twitter = "twitter"

    case resources = "resources"

    case userStories = "userStories"

    case relationDefaultValue = "relationDefaultValue"

    case linkedProjects = "linkedProjects"

    /// Audio record's album name
    case audioAlbum = "audioAlbum"

    case participants = "participants"

    case problem = "problem"

    /// Specify visual align of the layout
    case layoutAlign = "layoutAlign"

    case `class` = "class"

    case difficulty = "difficulty"

    case director = "director"

    /// Task status
    case status = "status"

    case candidate = "candidate"

    case happenings = "happenings"

    /// Duration of audio/video file in seconds
    case durationInSeconds = "durationInSeconds"

    case billToAddress = "billToAddress"

    case logic = "logic"

    case alternative = "alternative"

    case linkedContacts = "linkedContacts"

    case rottenTomatoesRating = "rottenTomatoesRating"

    /// Specify if object is hidden
    case isHidden = "isHidden"

    /// A subsidiary, subsidiary company or daughter company is a company owned or controlled by another company, which is called the parent company or holding company
    case subsidiaries = "subsidiaries"

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

    case notes = "notes"

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

    case ceo = "ceo"

    case records = "records"

    /// 1 emoji(can contains multiple UTF symbols) used as an icon
    case iconEmoji = "iconEmoji"

    /// 1-image, 2-color, 3-gradient, 4-prebuilt bg image. Value stored in coverId
    case coverType = "coverType"

    /// A ticker symbol or stock symbol is an abbreviation used to uniquely identify publicly traded shares of a particular stock on a particular stock market
    case tickerSymbol = "tickerSymbol"

    /// Image y offset of the provided image
    case coverY = "coverY"

    case story = "story"

    case time = "time"

    /// Size of file/image in bytes
    case sizeInBytes = "sizeInBytes"

    /// Point to the object types that can be added to collection. Empty means any object type can be added to the collection
    case collectionOf = "collectionOf"

    case events = "events"

    case owner = "owner"

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

    /// Repeat words that someone else has said or written
    case quote = "quote"

    /// Space object belongs to
    case workspaceId = "workspaceId"

    case journaling = "journaling"

    case billTo = "billTo"

    /// Audio record's genre name
    case audioGenre = "audioGenre"

    case intentions = "intentions"

    case telegram = "telegram"

    /// Relation that indicates document in draft state
    case isDraft = "isDraft"

    case trailer = "trailer"

    /// Name of the object
    case name = "name"

    case mood = "mood"

    case agenda = "agenda"

    case number = "number"

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

    case numberOfEmployees = "numberOfEmployees"

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

    case _7hourssleep = "7hourssleep"

    /// Image x offset of the provided image
    case coverX = "coverX"

    case description = "description"

    case facebook = "facebook"

    case address = "address"

    /// An image is an artifact that depicts visual perception, such as a photograph or other two-dimensional picture
    case picture = "picture"

    /// Link to itself. Used in databases
    case id = "id"

    case stockprice = "stockprice"

    /// Web address, a reference to a web resource that specifies its location on a computer network and a mechanism for retrieving it
    case url = "url"

    case objectives = "objectives"

    case cameraIso = "cameraIso"

    case healthyEating = "healthyEating"

    /// Relation that indicates document has been deleted
    case isDeleted = "isDeleted"

    /// Outgoing links
    case links = "links"

    case servings = "servings"

    case category = "category"

    case shipToAddress = "shipToAddress"

    case founded = "founded"

    /// Can contains image hash, color or prebuild bg id, depends on coverType relation
    case coverId = "coverId"

    /// Human who updated the object last time
    case lastModifiedBy = "lastModifiedBy"

    /// Relation allows multi values
    case relationMaxCount = "relationMaxCount"

    case questions = "questions"

    case worriedAbout = "worriedAbout"

    case headquarters = "headquarters"

    /// Width of image/video in pixels
    case widthInPixels = "widthInPixels"

    case running = "running"

    case progress = "progress"

    /// Point to the object types used to aggregate the set. Empty means object of all types will be aggregated 
    case setOf = "setOf"

    case gender = "gender"

    /// Hides the object
    case isArchived = "isArchived"

    case fileExt = "fileExt"

    case scope = "scope"

    case job = "job"

    /// Have been added to library from marketplace
    case mpAddedToLibrary = "mpAddedToLibrary"

    /// Important relations that always appear at the top of the object
    case featuredRelations = "featuredRelations"

    case phone = "phone"

    case imdbRating = "imdbRating"

    /// List of smartblock types
    case smartblockTypes = "smartblockTypes"

    case source = "source"
}
