// swiftlint:disable all

import Foundation
import SwiftProtobuf
import AnytypeCore

public protocol RelationValueProvider {

    var values: [String: Google_Protobuf_Value] { get }

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
    var mediaArtistURL: String { get }
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
    var website: String { get }
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
    var twitter: String { get }
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
    var status: ObjectId { get }
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
    var email: String { get }
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
    var telegram: String { get }
    var isDraft: Bool { get }
    var trailer: [Hash] { get }
    var name: String { get }
    var mood: [ObjectId] { get }
    var agenda: String { get }
    var number: Int? { get }
    var audioLyrics: String { get }
    var instagram: String { get }
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
    var socialProfile: String { get }
    var occupation: String { get }
    var _7hourssleep: Bool { get }
    var coverX: Int? { get }
    var description: String { get }
    var facebook: String { get }
    var address: String { get }
    var picture: Hash? { get }
    var id: ObjectId { get }
    var stockprice: Int? { get }
    var url: String { get }
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
    var gender: ObjectId { get }
    var isArchived: Bool { get }
    var fileExt: String { get }
    var scope: String { get }
    var job: String { get }
    var mpAddedToLibrary: Bool { get }
    var featuredRelations: [ObjectId] { get }
    var phone: String { get }
    var imdbRating: Int? { get }
    var smartblockTypes: [Int] { get }
    var source: String { get }
} 

public extension RelationValueProvider {
    var meditation: Bool {
        return value(for: RelationKey.meditation.rawValue)
    }
    var relationOptionsDict: [ObjectId] {
        return value(for: RelationKey.relationOptionsDict.rawValue)
    }
    var tag: [ObjectId] {
        return value(for: RelationKey.tag.rawValue)
    }
    var camera: String {
        return value(for: RelationKey.camera.rawValue)
    }
    var heightInPixels: Int? {
        return value(for: RelationKey.heightInPixels.rawValue)
    }
    var location: String {
        return value(for: RelationKey.location.rawValue)
    }
    var createdDate: Date? {
        return value(for: RelationKey.createdDate.rawValue)
    }
    var toBeDeletedDate: Date? {
        return value(for: RelationKey.toBeDeletedDate.rawValue)
    }
    var relationFormatObjectTypes: [ObjectId] {
        return value(for: RelationKey.relationFormatObjectTypes.rawValue)
    }
    var relationKey: String {
        return value(for: RelationKey.relationKey.rawValue)
    }
    var relationOptionText: String {
        return value(for: RelationKey.relationOptionText.rawValue)
    }
    var relationOptionColor: String {
        return value(for: RelationKey.relationOptionColor.rawValue)
    }
    var instructions: String {
        return value(for: RelationKey.instructions.rawValue)
    }
    var done: Bool {
        return value(for: RelationKey.done.rawValue)
    }
    var mediaArtistURL: String {
        return value(for: RelationKey.mediaArtistURL.rawValue)
    }
    var templateIsBundled: Bool {
        return value(for: RelationKey.templateIsBundled.rawValue)
    }
    var shipTo: String {
        return value(for: RelationKey.shipTo.rawValue)
    }
    var dateOfBirth: Date? {
        return value(for: RelationKey.dateOfBirth.rawValue)
    }
    var restrictions: Int? {
        return value(for: RelationKey.restrictions.rawValue)
    }
    var isHighlighted: Bool {
        return value(for: RelationKey.isHighlighted.rawValue)
    }
    var thumbnailImage: [Hash] {
        return value(for: RelationKey.thumbnailImage.rawValue)
    }
    var attachments: [Hash] {
        return value(for: RelationKey.attachments.rawValue)
    }
    var audioArtist: String {
        return value(for: RelationKey.audioArtist.rawValue)
    }
    var tasks: [ObjectId] {
        return value(for: RelationKey.tasks.rawValue)
    }
    var snippet: String {
        return value(for: RelationKey.snippet.rawValue)
    }
    var hypothesisAssumptions: String {
        return value(for: RelationKey.hypothesisAssumptions.rawValue)
    }
    var gratefulFor: String {
        return value(for: RelationKey.gratefulFor.rawValue)
    }
    var founders: [ObjectId] {
        return value(for: RelationKey.founders.rawValue)
    }
    var website: String {
        return value(for: RelationKey.website.rawValue)
    }
    var relationFormat: Int? {
        return value(for: RelationKey.relationFormat.rawValue)
    }
    var relationReadonlyValue: Bool {
        return value(for: RelationKey.relationReadonlyValue.rawValue)
    }
    var iconImage: Hash? {
        return value(for: RelationKey.iconImage.rawValue)
    }
    var ingredients: String {
        return value(for: RelationKey.ingredients.rawValue)
    }
    var total: Int? {
        return value(for: RelationKey.total.rawValue)
    }
    var responsible: [ObjectId] {
        return value(for: RelationKey.responsible.rawValue)
    }
    var genre: [ObjectId] {
        return value(for: RelationKey.genre.rawValue)
    }
    var solution: String {
        return value(for: RelationKey.solution.rawValue)
    }
    var releasedYear: Int? {
        return value(for: RelationKey.releasedYear.rawValue)
    }
    var coverScale: Int? {
        return value(for: RelationKey.coverScale.rawValue)
    }
    var twitter: String {
        return value(for: RelationKey.twitter.rawValue)
    }
    var resources: String {
        return value(for: RelationKey.resources.rawValue)
    }
    var userStories: String {
        return value(for: RelationKey.userStories.rawValue)
    }
    var relationDefaultValue: String {
        return value(for: RelationKey.relationDefaultValue.rawValue)
    }
    var linkedProjects: [ObjectId] {
        return value(for: RelationKey.linkedProjects.rawValue)
    }
    var audioAlbum: String {
        return value(for: RelationKey.audioAlbum.rawValue)
    }
    var participants: [ObjectId] {
        return value(for: RelationKey.participants.rawValue)
    }
    var problem: String {
        return value(for: RelationKey.problem.rawValue)
    }
    var layoutAlign: Int? {
        return value(for: RelationKey.layoutAlign.rawValue)
    }
    var `class`: [ObjectId] {
        return value(for: RelationKey.`class`.rawValue)
    }
    var difficulty: Int? {
        return value(for: RelationKey.difficulty.rawValue)
    }
    var director: [ObjectId] {
        return value(for: RelationKey.director.rawValue)
    }
    var status: ObjectId {
        return value(for: RelationKey.status.rawValue)
    }
    var candidate: [ObjectId] {
        return value(for: RelationKey.candidate.rawValue)
    }
    var happenings: String {
        return value(for: RelationKey.happenings.rawValue)
    }
    var durationInSeconds: Int? {
        return value(for: RelationKey.durationInSeconds.rawValue)
    }
    var billToAddress: String {
        return value(for: RelationKey.billToAddress.rawValue)
    }
    var logic: String {
        return value(for: RelationKey.logic.rawValue)
    }
    var alternative: String {
        return value(for: RelationKey.alternative.rawValue)
    }
    var linkedContacts: [ObjectId] {
        return value(for: RelationKey.linkedContacts.rawValue)
    }
    var rottenTomatoesRating: Int? {
        return value(for: RelationKey.rottenTomatoesRating.rawValue)
    }
    var isHidden: Bool {
        return value(for: RelationKey.isHidden.rawValue)
    }
    var subsidiaries: [ObjectId] {
        return value(for: RelationKey.subsidiaries.rawValue)
    }
    var additional: String {
        return value(for: RelationKey.additional.rawValue)
    }
    var budget: Int? {
        return value(for: RelationKey.budget.rawValue)
    }
    var mediaArtistName: String {
        return value(for: RelationKey.mediaArtistName.rawValue)
    }
    var rating: String {
        return value(for: RelationKey.rating.rawValue)
    }
    var email: String {
        return value(for: RelationKey.email.rawValue)
    }
    var company: ObjectId {
        return value(for: RelationKey.company.rawValue)
    }
    var aperture: String {
        return value(for: RelationKey.aperture.rawValue)
    }
    var lastModifiedDate: Date? {
        return value(for: RelationKey.lastModifiedDate.rawValue)
    }
    var stakeholders: [ObjectId] {
        return value(for: RelationKey.stakeholders.rawValue)
    }
    var measureOfSuccess: String {
        return value(for: RelationKey.measureOfSuccess.rawValue)
    }
    var notes: String {
        return value(for: RelationKey.notes.rawValue)
    }
    var recommendedRelations: [ObjectId] {
        return value(for: RelationKey.recommendedRelations.rawValue)
    }
    var creator: ObjectId {
        return value(for: RelationKey.creator.rawValue)
    }
    var recommendedLayout: Int? {
        return value(for: RelationKey.recommendedLayout.rawValue)
    }
    var result: String {
        return value(for: RelationKey.result.rawValue)
    }
    var reflection: Bool {
        return value(for: RelationKey.reflection.rawValue)
    }
    var lastOpenedDate: Date? {
        return value(for: RelationKey.lastOpenedDate.rawValue)
    }
    var author: [ObjectId] {
        return value(for: RelationKey.author.rawValue)
    }
    var artist: String {
        return value(for: RelationKey.artist.rawValue)
    }
    var dueDate: Date? {
        return value(for: RelationKey.dueDate.rawValue)
    }
    var ceo: [ObjectId] {
        return value(for: RelationKey.ceo.rawValue)
    }
    var records: String {
        return value(for: RelationKey.records.rawValue)
    }
    var iconEmoji: Emoji? {
        return value(for: RelationKey.iconEmoji.rawValue)
    }
    var coverType: Int? {
        return value(for: RelationKey.coverType.rawValue)
    }
    var tickerSymbol: String {
        return value(for: RelationKey.tickerSymbol.rawValue)
    }
    var coverY: Int? {
        return value(for: RelationKey.coverY.rawValue)
    }
    var story: String {
        return value(for: RelationKey.story.rawValue)
    }
    var time: Int? {
        return value(for: RelationKey.time.rawValue)
    }
    var sizeInBytes: Int? {
        return value(for: RelationKey.sizeInBytes.rawValue)
    }
    var collectionOf: [ObjectId] {
        return value(for: RelationKey.collectionOf.rawValue)
    }
    var events: [ObjectId] {
        return value(for: RelationKey.events.rawValue)
    }
    var owner: [ObjectId] {
        return value(for: RelationKey.owner.rawValue)
    }
    var timeframe: String {
        return value(for: RelationKey.timeframe.rawValue)
    }
    var isReadonly: Bool {
        return value(for: RelationKey.isReadonly.rawValue)
    }
    var addedDate: Date? {
        return value(for: RelationKey.addedDate.rawValue)
    }
    var assignee: [ObjectId] {
        return value(for: RelationKey.assignee.rawValue)
    }
    var exposure: String {
        return value(for: RelationKey.exposure.rawValue)
    }
    var targetObjectType: ObjectId {
        return value(for: RelationKey.targetObjectType.rawValue)
    }
    var materials: String {
        return value(for: RelationKey.materials.rawValue)
    }
    var isFavorite: Bool {
        return value(for: RelationKey.isFavorite.rawValue)
    }
    var stars: [ObjectId] {
        return value(for: RelationKey.stars.rawValue)
    }
    var quote: String {
        return value(for: RelationKey.quote.rawValue)
    }
    var workspaceId: ObjectId {
        return value(for: RelationKey.workspaceId.rawValue)
    }
    var journaling: Bool {
        return value(for: RelationKey.journaling.rawValue)
    }
    var billTo: String {
        return value(for: RelationKey.billTo.rawValue)
    }
    var audioGenre: String {
        return value(for: RelationKey.audioGenre.rawValue)
    }
    var intentions: String {
        return value(for: RelationKey.intentions.rawValue)
    }
    var telegram: String {
        return value(for: RelationKey.telegram.rawValue)
    }
    var isDraft: Bool {
        return value(for: RelationKey.isDraft.rawValue)
    }
    var trailer: [Hash] {
        return value(for: RelationKey.trailer.rawValue)
    }
    var name: String {
        return value(for: RelationKey.name.rawValue)
    }
    var mood: [ObjectId] {
        return value(for: RelationKey.mood.rawValue)
    }
    var agenda: String {
        return value(for: RelationKey.agenda.rawValue)
    }
    var number: Int? {
        return value(for: RelationKey.number.rawValue)
    }
    var audioLyrics: String {
        return value(for: RelationKey.audioLyrics.rawValue)
    }
    var instagram: String {
        return value(for: RelationKey.instagram.rawValue)
    }
    var classType: [ObjectId] {
        return value(for: RelationKey.classType.rawValue)
    }
    var howToReproduce: String {
        return value(for: RelationKey.howToReproduce.rawValue)
    }
    var focalRatio: Int? {
        return value(for: RelationKey.focalRatio.rawValue)
    }
    var priority: Int? {
        return value(for: RelationKey.priority.rawValue)
    }
    var fileMimeType: String {
        return value(for: RelationKey.fileMimeType.rawValue)
    }
    var type: ObjectId {
        return value(for: RelationKey.type.rawValue)
    }
    var numberOfEmployees: Int? {
        return value(for: RelationKey.numberOfEmployees.rawValue)
    }
    var layout: Int? {
        return value(for: RelationKey.layout.rawValue)
    }
    var audioAlbumTrackNumber: Int? {
        return value(for: RelationKey.audioAlbumTrackNumber.rawValue)
    }
    var placeOfBirth: String {
        return value(for: RelationKey.placeOfBirth.rawValue)
    }
    var composer: String {
        return value(for: RelationKey.composer.rawValue)
    }
    var internalFlags: [Int] {
        return value(for: RelationKey.internalFlags.rawValue)
    }
    var socialProfile: String {
        return value(for: RelationKey.socialProfile.rawValue)
    }
    var occupation: String {
        return value(for: RelationKey.occupation.rawValue)
    }
    var _7hourssleep: Bool {
        return value(for: RelationKey._7hourssleep.rawValue)
    }
    var coverX: Int? {
        return value(for: RelationKey.coverX.rawValue)
    }
    var description: String {
        return value(for: RelationKey.description.rawValue)
    }
    var facebook: String {
        return value(for: RelationKey.facebook.rawValue)
    }
    var address: String {
        return value(for: RelationKey.address.rawValue)
    }
    var picture: Hash? {
        return value(for: RelationKey.picture.rawValue)
    }
    var id: ObjectId {
        return value(for: RelationKey.id.rawValue)
    }
    var stockprice: Int? {
        return value(for: RelationKey.stockprice.rawValue)
    }
    var url: String {
        return value(for: RelationKey.url.rawValue)
    }
    var objectives: String {
        return value(for: RelationKey.objectives.rawValue)
    }
    var cameraIso: Int? {
        return value(for: RelationKey.cameraIso.rawValue)
    }
    var healthyEating: Bool {
        return value(for: RelationKey.healthyEating.rawValue)
    }
    var isDeleted: Bool {
        return value(for: RelationKey.isDeleted.rawValue)
    }
    var links: [ObjectId] {
        return value(for: RelationKey.links.rawValue)
    }
    var servings: Int? {
        return value(for: RelationKey.servings.rawValue)
    }
    var category: [ObjectId] {
        return value(for: RelationKey.category.rawValue)
    }
    var shipToAddress: String {
        return value(for: RelationKey.shipToAddress.rawValue)
    }
    var founded: Date? {
        return value(for: RelationKey.founded.rawValue)
    }
    var coverId: String {
        return value(for: RelationKey.coverId.rawValue)
    }
    var lastModifiedBy: ObjectId {
        return value(for: RelationKey.lastModifiedBy.rawValue)
    }
    var relationMaxCount: Int? {
        return value(for: RelationKey.relationMaxCount.rawValue)
    }
    var questions: String {
        return value(for: RelationKey.questions.rawValue)
    }
    var worriedAbout: String {
        return value(for: RelationKey.worriedAbout.rawValue)
    }
    var headquarters: String {
        return value(for: RelationKey.headquarters.rawValue)
    }
    var widthInPixels: Int? {
        return value(for: RelationKey.widthInPixels.rawValue)
    }
    var running: Bool {
        return value(for: RelationKey.running.rawValue)
    }
    var progress: Int? {
        return value(for: RelationKey.progress.rawValue)
    }
    var setOf: [ObjectId] {
        return value(for: RelationKey.setOf.rawValue)
    }
    var gender: ObjectId {
        return value(for: RelationKey.gender.rawValue)
    }
    var isArchived: Bool {
        return value(for: RelationKey.isArchived.rawValue)
    }
    var fileExt: String {
        return value(for: RelationKey.fileExt.rawValue)
    }
    var scope: String {
        return value(for: RelationKey.scope.rawValue)
    }
    var job: String {
        return value(for: RelationKey.job.rawValue)
    }
    var mpAddedToLibrary: Bool {
        return value(for: RelationKey.mpAddedToLibrary.rawValue)
    }
    var featuredRelations: [ObjectId] {
        return value(for: RelationKey.featuredRelations.rawValue)
    }
    var phone: String {
        return value(for: RelationKey.phone.rawValue)
    }
    var imdbRating: Int? {
        return value(for: RelationKey.imdbRating.rawValue)
    }
    var smartblockTypes: [Int] {
        return value(for: RelationKey.smartblockTypes.rawValue)
    }
    var source: String {
        return value(for: RelationKey.source.rawValue)
    }

    func value<T>(for key: String) -> T? where T: ProtobufSupport{
        guard let value = values[key]?.unwrapedListValue else { return nil }
        return T(value) 
    }

    func value<T>(for key: String) -> T where T: ProtobufSupport, T: ProtobufDefaultTypeProvider {
        guard let value = values[key]?.unwrapedListValue else { return T.protobufDefaultType() }
        return T(value) ?? T.protobufDefaultType()
    }

    func value<T: ProtobufSupport>(for key: String) -> [T] {
        guard let values = values[key]?.listValue.values else { return [] }
        return values.compactMap { T($0) }
    }
}
