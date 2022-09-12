// swiftlint:disable all

import Foundation
import SwiftProtobuf
import AnytypeCore

public typealias ObjectId = String

public protocol BundledRelationsValueProvider {

    var meditation: Bool { get }
    var relationOptionsDict: [ObjectId] { get }
    var tag: [ObjectId] { get }
    var camera: String { get }
    var heightInPixels: Int? { get }
    var location: String { get }
    var createdDate: Date? { get }
    var toBeDeletedDate: Date? { get }
    var relationFormatObjectTypes: [ObjectId] { get }
    var relationKey: String { get }
    var relationOptionText: String { get }
    var relationOptionColor: String { get }
    var instructions: String { get }
    var done: Bool { get }
    var mediaArtistURL: AnytypeURL? { get }
    var templateIsBundled: Bool { get }
    var shipTo: String { get }
    var dateOfBirth: Date? { get }
    var restrictions: Int? { get }
    var isHighlighted: Bool { get }
    var thumbnailImage: [Hash] { get }
    var attachments: [Hash] { get }
    var audioArtist: String { get }
    var tasks: [ObjectId] { get }
    var snippet: String { get }
    var hypothesisAssumptions: String { get }
    var gratefulFor: String { get }
    var founders: [ObjectId] { get }
    var website: AnytypeURL? { get }
    var relationFormat: Int? { get }
    var relationReadonlyValue: Bool { get }
    var iconImage: Hash? { get }
    var ingredients: String { get }
    var total: Int? { get }
    var responsible: [ObjectId] { get }
    var genre: [ObjectId] { get }
    var solution: String { get }
    var releasedYear: Int? { get }
    var coverScale: Int? { get }
    var twitter: AnytypeURL? { get }
    var resources: String { get }
    var userStories: String { get }
    var relationDefaultValue: String { get }
    var linkedProjects: [ObjectId] { get }
    var audioAlbum: String { get }
    var participants: [ObjectId] { get }
    var problem: String { get }
    var layoutAlign: Int? { get }
    var `class`: [ObjectId] { get }
    var difficulty: Int? { get }
    var director: [ObjectId] { get }
    var status: ObjectId? { get }
    var candidate: [ObjectId] { get }
    var happenings: String { get }
    var durationInSeconds: Int? { get }
    var billToAddress: String { get }
    var logic: String { get }
    var alternative: String { get }
    var linkedContacts: [ObjectId] { get }
    var rottenTomatoesRating: Int? { get }
    var isHidden: Bool { get }
    var subsidiaries: [ObjectId] { get }
    var additional: String { get }
    var budget: Int? { get }
    var mediaArtistName: String { get }
    var rating: String { get }
    var email: String? { get }
    var company: ObjectId { get }
    var aperture: String { get }
    var lastModifiedDate: Date? { get }
    var stakeholders: [ObjectId] { get }
    var measureOfSuccess: String { get }
    var notes: String { get }
    var recommendedRelations: [ObjectId] { get }
    var creator: ObjectId { get }
    var recommendedLayout: Int? { get }
    var result: String { get }
    var reflection: Bool { get }
    var lastOpenedDate: Date? { get }
    var author: [ObjectId] { get }
    var artist: String { get }
    var dueDate: Date? { get }
    var ceo: [ObjectId] { get }
    var records: String { get }
    var iconEmoji: Emoji? { get }
    var coverType: Int? { get }
    var tickerSymbol: String { get }
    var coverY: Int? { get }
    var story: String { get }
    var time: Int? { get }
    var sizeInBytes: Int? { get }
    var collectionOf: [ObjectId] { get }
    var events: [ObjectId] { get }
    var owner: [ObjectId] { get }
    var timeframe: String { get }
    var isReadonly: Bool { get }
    var addedDate: Date? { get }
    var assignee: [ObjectId] { get }
    var exposure: String { get }
    var targetObjectType: ObjectId { get }
    var materials: String { get }
    var isFavorite: Bool { get }
    var stars: [ObjectId] { get }
    var quote: String { get }
    var workspaceId: ObjectId { get }
    var journaling: Bool { get }
    var billTo: String { get }
    var audioGenre: String { get }
    var intentions: String { get }
    var telegram: AnytypeURL? { get }
    var isDraft: Bool { get }
    var trailer: [Hash] { get }
    var name: String { get }
    var mood: [ObjectId] { get }
    var agenda: String { get }
    var number: Int? { get }
    var audioLyrics: String { get }
    var instagram: AnytypeURL? { get }
    var classType: [ObjectId] { get }
    var howToReproduce: String { get }
    var focalRatio: Int? { get }
    var priority: Int? { get }
    var fileMimeType: String { get }
    var type: ObjectId { get }
    var numberOfEmployees: Int? { get }
    var layout: Int? { get }
    var audioAlbumTrackNumber: Int? { get }
    var placeOfBirth: String { get }
    var composer: String { get }
    var internalFlags: [Int] { get }
    var socialProfile: AnytypeURL? { get }
    var occupation: String { get }
    var _7hourssleep: Bool { get }
    var coverX: Int? { get }
    var description: String { get }
    var facebook: AnytypeURL? { get }
    var address: String { get }
    var picture: Hash? { get }
    var id: ObjectId { get }
    var stockprice: Int? { get }
    var url: AnytypeURL? { get }
    var objectives: String { get }
    var cameraIso: Int? { get }
    var healthyEating: Bool { get }
    var isDeleted: Bool { get }
    var links: [ObjectId] { get }
    var servings: Int? { get }
    var category: [ObjectId] { get }
    var shipToAddress: String { get }
    var founded: Date? { get }
    var coverId: String { get }
    var lastModifiedBy: ObjectId { get }
    var relationMaxCount: Int? { get }
    var questions: String { get }
    var worriedAbout: String { get }
    var headquarters: String { get }
    var widthInPixels: Int? { get }
    var running: Bool { get }
    var progress: Int? { get }
    var setOf: [ObjectId] { get }
    var gender: ObjectId? { get }
    var isArchived: Bool { get }
    var fileExt: String { get }
    var scope: String { get }
    var job: String { get }
    var mpAddedToLibrary: Bool { get }
    var featuredRelations: [ObjectId] { get }
    var phone: String? { get }
    var imdbRating: Int? { get }
    var smartblockTypes: [Int] { get }
    var source: AnytypeURL? { get }
} 

public extension BundledRelationsValueProvider where Self: RelationValueProvider {
    var meditation: Bool {
        return value(for: BundledRelationKey.meditation.rawValue)
    }
    /// Strict dictionary to select relation values from
    var relationOptionsDict: [ObjectId] {
        return value(for: BundledRelationKey.relationOptionsDict.rawValue)
    }
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
    var location: String {
        return value(for: BundledRelationKey.location.rawValue)
    }
    /// Date when the object was initially created
    var createdDate: Date? {
        return value(for: BundledRelationKey.createdDate.rawValue)
    }
    /// Date when the object will be deleted from your device
    var toBeDeletedDate: Date? {
        return value(for: BundledRelationKey.toBeDeletedDate.rawValue)
    }
    /// Types that used for such relation
    var relationFormatObjectTypes: [ObjectId] {
        return value(for: BundledRelationKey.relationFormatObjectTypes.rawValue)
    }
    /// Relation key
    var relationKey: String {
        return value(for: BundledRelationKey.relationKey.rawValue)
    }
    /// Relation option text
    var relationOptionText: String {
        return value(for: BundledRelationKey.relationOptionText.rawValue)
    }
    /// Relation option color
    var relationOptionColor: String {
        return value(for: BundledRelationKey.relationOptionColor.rawValue)
    }
    var instructions: String {
        return value(for: BundledRelationKey.instructions.rawValue)
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
    var shipTo: String {
        return value(for: BundledRelationKey.shipTo.rawValue)
    }
    var dateOfBirth: Date? {
        return value(for: BundledRelationKey.dateOfBirth.rawValue)
    }
    /// Object restrictions list
    var restrictions: Int? {
        return value(for: BundledRelationKey.restrictions.rawValue)
    }
    /// Adds the object to the highlighted dataview in space
    var isHighlighted: Bool {
        return value(for: BundledRelationKey.isHighlighted.rawValue)
    }
    var thumbnailImage: [Hash] {
        return value(for: BundledRelationKey.thumbnailImage.rawValue)
    }
    var attachments: [Hash] {
        return value(for: BundledRelationKey.attachments.rawValue)
    }
    /// The artist that performed this album or recording
    var audioArtist: String {
        return value(for: BundledRelationKey.audioArtist.rawValue)
    }
    /// List of related tasks
    var tasks: [ObjectId] {
        return value(for: BundledRelationKey.tasks.rawValue)
    }
    /// Plaintext extracted from the object's blocks 
    var snippet: String {
        return value(for: BundledRelationKey.snippet.rawValue)
    }
    var hypothesisAssumptions: String {
        return value(for: BundledRelationKey.hypothesisAssumptions.rawValue)
    }
    var gratefulFor: String {
        return value(for: BundledRelationKey.gratefulFor.rawValue)
    }
    var founders: [ObjectId] {
        return value(for: BundledRelationKey.founders.rawValue)
    }
    var website: AnytypeURL? {
        return value(for: BundledRelationKey.website.rawValue)
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
    var iconImage: Hash? {
        return value(for: BundledRelationKey.iconImage.rawValue)
    }
    var ingredients: String {
        return value(for: BundledRelationKey.ingredients.rawValue)
    }
    var total: Int? {
        return value(for: BundledRelationKey.total.rawValue)
    }
    var responsible: [ObjectId] {
        return value(for: BundledRelationKey.responsible.rawValue)
    }
    var genre: [ObjectId] {
        return value(for: BundledRelationKey.genre.rawValue)
    }
    var solution: String {
        return value(for: BundledRelationKey.solution.rawValue)
    }
    /// Year when this object were released
    var releasedYear: Int? {
        return value(for: BundledRelationKey.releasedYear.rawValue)
    }
    /// Option that contains scale of Cover the image
    var coverScale: Int? {
        return value(for: BundledRelationKey.coverScale.rawValue)
    }
    var twitter: AnytypeURL? {
        return value(for: BundledRelationKey.twitter.rawValue)
    }
    var resources: String {
        return value(for: BundledRelationKey.resources.rawValue)
    }
    var userStories: String {
        return value(for: BundledRelationKey.userStories.rawValue)
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
    var participants: [ObjectId] {
        return value(for: BundledRelationKey.participants.rawValue)
    }
    var problem: String {
        return value(for: BundledRelationKey.problem.rawValue)
    }
    /// Specify visual align of the layout
    var layoutAlign: Int? {
        return value(for: BundledRelationKey.layoutAlign.rawValue)
    }
    var `class`: [ObjectId] {
        return value(for: BundledRelationKey.`class`.rawValue)
    }
    var difficulty: Int? {
        return value(for: BundledRelationKey.difficulty.rawValue)
    }
    var director: [ObjectId] {
        return value(for: BundledRelationKey.director.rawValue)
    }
    /// Task status
    var status: ObjectId? {
        return value(for: BundledRelationKey.status.rawValue)
    }
    var candidate: [ObjectId] {
        return value(for: BundledRelationKey.candidate.rawValue)
    }
    var happenings: String {
        return value(for: BundledRelationKey.happenings.rawValue)
    }
    /// Duration of audio/video file in seconds
    var durationInSeconds: Int? {
        return value(for: BundledRelationKey.durationInSeconds.rawValue)
    }
    var billToAddress: String {
        return value(for: BundledRelationKey.billToAddress.rawValue)
    }
    var logic: String {
        return value(for: BundledRelationKey.logic.rawValue)
    }
    var alternative: String {
        return value(for: BundledRelationKey.alternative.rawValue)
    }
    var linkedContacts: [ObjectId] {
        return value(for: BundledRelationKey.linkedContacts.rawValue)
    }
    var rottenTomatoesRating: Int? {
        return value(for: BundledRelationKey.rottenTomatoesRating.rawValue)
    }
    /// Specify if object is hidden
    var isHidden: Bool {
        return value(for: BundledRelationKey.isHidden.rawValue)
    }
    /// A subsidiary, subsidiary company or daughter company is a company owned or controlled by another company, which is called the parent company or holding company
    var subsidiaries: [ObjectId] {
        return value(for: BundledRelationKey.subsidiaries.rawValue)
    }
    var additional: String {
        return value(for: BundledRelationKey.additional.rawValue)
    }
    var budget: Int? {
        return value(for: BundledRelationKey.budget.rawValue)
    }
    /// Artist name
    var mediaArtistName: String {
        return value(for: BundledRelationKey.mediaArtistName.rawValue)
    }
    var rating: String {
        return value(for: BundledRelationKey.rating.rawValue)
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
    var stakeholders: [ObjectId] {
        return value(for: BundledRelationKey.stakeholders.rawValue)
    }
    var measureOfSuccess: String {
        return value(for: BundledRelationKey.measureOfSuccess.rawValue)
    }
    var notes: String {
        return value(for: BundledRelationKey.notes.rawValue)
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
    var result: String {
        return value(for: BundledRelationKey.result.rawValue)
    }
    var reflection: Bool {
        return value(for: BundledRelationKey.reflection.rawValue)
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
    var ceo: [ObjectId] {
        return value(for: BundledRelationKey.ceo.rawValue)
    }
    var records: String {
        return value(for: BundledRelationKey.records.rawValue)
    }
    /// 1 emoji(can contains multiple UTF symbols) used as an icon
    var iconEmoji: Emoji? {
        return value(for: BundledRelationKey.iconEmoji.rawValue)
    }
    /// 1-image, 2-color, 3-gradient, 4-prebuilt bg image. Value stored in coverId
    var coverType: Int? {
        return value(for: BundledRelationKey.coverType.rawValue)
    }
    /// A ticker symbol or stock symbol is an abbreviation used to uniquely identify publicly traded shares of a particular stock on a particular stock market
    var tickerSymbol: String {
        return value(for: BundledRelationKey.tickerSymbol.rawValue)
    }
    /// Image y offset of the provided image
    var coverY: Int? {
        return value(for: BundledRelationKey.coverY.rawValue)
    }
    var story: String {
        return value(for: BundledRelationKey.story.rawValue)
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
    var events: [ObjectId] {
        return value(for: BundledRelationKey.events.rawValue)
    }
    var owner: [ObjectId] {
        return value(for: BundledRelationKey.owner.rawValue)
    }
    var timeframe: String {
        return value(for: BundledRelationKey.timeframe.rawValue)
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
    var materials: String {
        return value(for: BundledRelationKey.materials.rawValue)
    }
    /// Adds the object to the home dashboard
    var isFavorite: Bool {
        return value(for: BundledRelationKey.isFavorite.rawValue)
    }
    var stars: [ObjectId] {
        return value(for: BundledRelationKey.stars.rawValue)
    }
    /// Repeat words that someone else has said or written
    var quote: String {
        return value(for: BundledRelationKey.quote.rawValue)
    }
    /// Space object belongs to
    var workspaceId: ObjectId {
        return value(for: BundledRelationKey.workspaceId.rawValue)
    }
    var journaling: Bool {
        return value(for: BundledRelationKey.journaling.rawValue)
    }
    var billTo: String {
        return value(for: BundledRelationKey.billTo.rawValue)
    }
    /// Audio record's genre name
    var audioGenre: String {
        return value(for: BundledRelationKey.audioGenre.rawValue)
    }
    var intentions: String {
        return value(for: BundledRelationKey.intentions.rawValue)
    }
    var telegram: AnytypeURL? {
        return value(for: BundledRelationKey.telegram.rawValue)
    }
    /// Relation that indicates document in draft state
    var isDraft: Bool {
        return value(for: BundledRelationKey.isDraft.rawValue)
    }
    var trailer: [Hash] {
        return value(for: BundledRelationKey.trailer.rawValue)
    }
    /// Name of the object
    var name: String {
        return value(for: BundledRelationKey.name.rawValue)
    }
    var mood: [ObjectId] {
        return value(for: BundledRelationKey.mood.rawValue)
    }
    var agenda: String {
        return value(for: BundledRelationKey.agenda.rawValue)
    }
    var number: Int? {
        return value(for: BundledRelationKey.number.rawValue)
    }
    /// The text lyrics of the music record
    var audioLyrics: String {
        return value(for: BundledRelationKey.audioLyrics.rawValue)
    }
    var instagram: AnytypeURL? {
        return value(for: BundledRelationKey.instagram.rawValue)
    }
    var classType: [ObjectId] {
        return value(for: BundledRelationKey.classType.rawValue)
    }
    var howToReproduce: String {
        return value(for: BundledRelationKey.howToReproduce.rawValue)
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
    var numberOfEmployees: Int? {
        return value(for: BundledRelationKey.numberOfEmployees.rawValue)
    }
    /// Anytype layout ID(from pb enum)
    var layout: Int? {
        return value(for: BundledRelationKey.layout.rawValue)
    }
    /// Number of the track in the
    var audioAlbumTrackNumber: Int? {
        return value(for: BundledRelationKey.audioAlbumTrackNumber.rawValue)
    }
    var placeOfBirth: String {
        return value(for: BundledRelationKey.placeOfBirth.rawValue)
    }
    var composer: String {
        return value(for: BundledRelationKey.composer.rawValue)
    }
    /// Set of internal flags
    var internalFlags: [Int] {
        return value(for: BundledRelationKey.internalFlags.rawValue)
    }
    var socialProfile: AnytypeURL? {
        return value(for: BundledRelationKey.socialProfile.rawValue)
    }
    var occupation: String {
        return value(for: BundledRelationKey.occupation.rawValue)
    }
    var _7hourssleep: Bool {
        return value(for: BundledRelationKey._7hourssleep.rawValue)
    }
    /// Image x offset of the provided image
    var coverX: Int? {
        return value(for: BundledRelationKey.coverX.rawValue)
    }
    var description: String {
        return value(for: BundledRelationKey.description.rawValue)
    }
    var facebook: AnytypeURL? {
        return value(for: BundledRelationKey.facebook.rawValue)
    }
    var address: String {
        return value(for: BundledRelationKey.address.rawValue)
    }
    /// An image is an artifact that depicts visual perception, such as a photograph or other two-dimensional picture
    var picture: Hash? {
        return value(for: BundledRelationKey.picture.rawValue)
    }
    /// Link to itself. Used in databases
    var id: ObjectId {
        return value(for: BundledRelationKey.id.rawValue)
    }
    var stockprice: Int? {
        return value(for: BundledRelationKey.stockprice.rawValue)
    }
    /// Web address, a reference to a web resource that specifies its location on a computer network and a mechanism for retrieving it
    var url: AnytypeURL? {
        return value(for: BundledRelationKey.url.rawValue)
    }
    var objectives: String {
        return value(for: BundledRelationKey.objectives.rawValue)
    }
    var cameraIso: Int? {
        return value(for: BundledRelationKey.cameraIso.rawValue)
    }
    var healthyEating: Bool {
        return value(for: BundledRelationKey.healthyEating.rawValue)
    }
    /// Relation that indicates document has been deleted
    var isDeleted: Bool {
        return value(for: BundledRelationKey.isDeleted.rawValue)
    }
    /// Outgoing links
    var links: [ObjectId] {
        return value(for: BundledRelationKey.links.rawValue)
    }
    var servings: Int? {
        return value(for: BundledRelationKey.servings.rawValue)
    }
    var category: [ObjectId] {
        return value(for: BundledRelationKey.category.rawValue)
    }
    var shipToAddress: String {
        return value(for: BundledRelationKey.shipToAddress.rawValue)
    }
    var founded: Date? {
        return value(for: BundledRelationKey.founded.rawValue)
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
    var questions: String {
        return value(for: BundledRelationKey.questions.rawValue)
    }
    var worriedAbout: String {
        return value(for: BundledRelationKey.worriedAbout.rawValue)
    }
    var headquarters: String {
        return value(for: BundledRelationKey.headquarters.rawValue)
    }
    /// Width of image/video in pixels
    var widthInPixels: Int? {
        return value(for: BundledRelationKey.widthInPixels.rawValue)
    }
    var running: Bool {
        return value(for: BundledRelationKey.running.rawValue)
    }
    var progress: Int? {
        return value(for: BundledRelationKey.progress.rawValue)
    }
    /// Point to the object types used to aggregate the set. Empty means object of all types will be aggregated 
    var setOf: [ObjectId] {
        return value(for: BundledRelationKey.setOf.rawValue)
    }
    var gender: ObjectId? {
        return value(for: BundledRelationKey.gender.rawValue)
    }
    /// Hides the object
    var isArchived: Bool {
        return value(for: BundledRelationKey.isArchived.rawValue)
    }
    var fileExt: String {
        return value(for: BundledRelationKey.fileExt.rawValue)
    }
    var scope: String {
        return value(for: BundledRelationKey.scope.rawValue)
    }
    var job: String {
        return value(for: BundledRelationKey.job.rawValue)
    }
    /// Have been added to library from marketplace
    var mpAddedToLibrary: Bool {
        return value(for: BundledRelationKey.mpAddedToLibrary.rawValue)
    }
    /// Important relations that always appear at the top of the object
    var featuredRelations: [ObjectId] {
        return value(for: BundledRelationKey.featuredRelations.rawValue)
    }
    var phone: String? {
        return value(for: BundledRelationKey.phone.rawValue)
    }
    var imdbRating: Int? {
        return value(for: BundledRelationKey.imdbRating.rawValue)
    }
    /// List of smartblock types
    var smartblockTypes: [Int] {
        return value(for: BundledRelationKey.smartblockTypes.rawValue)
    }
    var source: AnytypeURL? {
        return value(for: BundledRelationKey.source.rawValue)
    }
}
