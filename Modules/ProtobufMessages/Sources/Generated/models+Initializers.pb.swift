// DO NOT EDIT
//
// Generated automatically by the AnytypeSwiftCodegen.
//
// For more info see:
// https://github.com/anytypeio/anytype-swift-codegen

import Foundation
import SwiftProtobuf
import Combine

extension Anytype_Model_Account {
    public init(id: String, name: String, avatar: Anytype_Model_Account.Avatar, config: Anytype_Model_Account.Config, status: Anytype_Model_Account.Status, info: Anytype_Model_Account.Info) {
        self.id = id
        self.name = name
        self.avatar = avatar
        self.config = config
        self.status = status
        self.info = info
    }
}

extension Anytype_Model_Account.Avatar {
    public init(avatar: Anytype_Model_Account.Avatar.OneOf_Avatar? = nil) {
        self.avatar = avatar
    }
}

extension Anytype_Model_Account.Config {
    public init(enableDataview: Bool = false, enableDebug: Bool = false, enablePrereleaseChannel: Bool = false, enableSpaces: Bool = false, extra: SwiftProtobuf.Google_Protobuf_Struct) {
        self.enableDataview = enableDataview
        self.enableDebug = enableDebug
        self.enablePrereleaseChannel = enablePrereleaseChannel
        self.enableSpaces = enableSpaces
        self.extra = extra
    }
}

extension Anytype_Model_Account.Info {
    public init(homeObjectID: String = String(), archiveObjectID: String = String(), profileObjectID: String = String(), marketplaceTypeObjectID: String = String(), marketplaceRelationObjectID: String = String(), marketplaceTemplateObjectID: String = String(), marketplaceWorkspaceID: String = String(), deviceID: String = String(), accountSpaceID: String = String(), widgetsID: String = String(), gatewayURL: String = String(), localStoragePath: String = String(), timeZone: String = String()) {
        self.homeObjectID = homeObjectID
        self.archiveObjectID = archiveObjectID
        self.profileObjectID = profileObjectID
        self.marketplaceTypeObjectID = marketplaceTypeObjectID
        self.marketplaceRelationObjectID = marketplaceRelationObjectID
        self.marketplaceTemplateObjectID = marketplaceTemplateObjectID
        self.marketplaceWorkspaceID = marketplaceWorkspaceID
        self.deviceID = deviceID
        self.accountSpaceID = accountSpaceID
        self.widgetsID = widgetsID
        self.gatewayURL = gatewayURL
        self.localStoragePath = localStoragePath
        self.timeZone = timeZone
    }
}

extension Anytype_Model_Account.Status {
    public init(statusType: Anytype_Model_Account.StatusType = .active, deletionDate: Int64 = 0) {
        self.statusType = statusType
        self.deletionDate = deletionDate
    }
}

extension Anytype_Model_Block {
    public init(id: String, fields: SwiftProtobuf.Google_Protobuf_Struct, restrictions: Anytype_Model_Block.Restrictions, childrenIds: [String], backgroundColor: String, align: Anytype_Model_Block.Align, verticalAlign: Anytype_Model_Block.VerticalAlign, content: OneOf_Content?) {
        self.id = id
        self.fields = fields
        self.restrictions = restrictions
        self.childrenIds = childrenIds
        self.backgroundColor = backgroundColor
        self.align = align
        self.verticalAlign = verticalAlign
        self.content = content
    }
}

extension Anytype_Model_Block.Content.Bookmark {
    public init(url: String = String(), title: String = String(), description_p: String = String(), imageHash: String = String(), faviconHash: String = String(), type: Anytype_Model_LinkPreview.TypeEnum = .unknown, targetObjectID: String = String(), state: Anytype_Model_Block.Content.Bookmark.State = .empty) {
        self.url = url
        self.title = title
        self.description_p = description_p
        self.imageHash = imageHash
        self.faviconHash = faviconHash
        self.type = type
        self.targetObjectID = targetObjectID
        self.state = state
    }
}

extension Anytype_Model_Block.Content.Dataview {
    public init(source: [String] = [], views: [Anytype_Model_Block.Content.Dataview.View] = [], relations: [Anytype_Model_Relation] = [], activeView: String = String(), groupOrders: [Anytype_Model_Block.Content.Dataview.GroupOrder] = [], objectOrders: [Anytype_Model_Block.Content.Dataview.ObjectOrder] = [], relationLinks: [Anytype_Model_RelationLink] = []) {
        self.source = source
        self.views = views
        self.relations = relations
        self.activeView = activeView
        self.groupOrders = groupOrders
        self.objectOrders = objectOrders
        self.relationLinks = relationLinks
    }
}

extension Anytype_Model_Block.Content.Dataview.Checkbox {
    public init(checked: Bool = false) {
        self.checked = checked
    }
}

extension Anytype_Model_Block.Content.Dataview.Filter {
    public init(`operator`: Anytype_Model_Block.Content.Dataview.Filter.Operator = .and, relationKey: String = String(), relationProperty: String = String(), condition: Anytype_Model_Block.Content.Dataview.Filter.Condition = .none, value: SwiftProtobuf.Google_Protobuf_Value, quickOption: Anytype_Model_Block.Content.Dataview.Filter.QuickOption = .exactDate, format: Anytype_Model_RelationFormat = .longtext, includeTime: Bool = false) {
        self.`operator` = `operator`
        self.relationKey = relationKey
        self.relationProperty = relationProperty
        self.condition = condition
        self.value = value
        self.quickOption = quickOption
        self.format = format
        self.includeTime = includeTime
    }
}

extension Anytype_Model_Block.Content.Dataview.Group {
    public init(id: String = String(), value: Anytype_Model_Block.Content.Dataview.Group.OneOf_Value? = nil) {
        self.id = id
        self.value = value
    }
}

extension Anytype_Model_Block.Content.Dataview.GroupOrder {
    public init(viewID: String = String(), viewGroups: [Anytype_Model_Block.Content.Dataview.ViewGroup] = []) {
        self.viewID = viewID
        self.viewGroups = viewGroups
    }
}

extension Anytype_Model_Block.Content.Dataview.ObjectOrder {
    public init(viewID: String = String(), groupID: String = String(), objectIds: [String] = []) {
        self.viewID = viewID
        self.groupID = groupID
        self.objectIds = objectIds
    }
}

extension Anytype_Model_Block.Content.Dataview.Relation {
    public init(key: String = String(), isVisible: Bool = false, width: Int32 = 0, dateIncludeTime: Bool = false, timeFormat: Anytype_Model_Block.Content.Dataview.Relation.TimeFormat = .format12, dateFormat: Anytype_Model_Block.Content.Dataview.Relation.DateFormat = .monthAbbrBeforeDay) {
        self.key = key
        self.isVisible = isVisible
        self.width = width
        self.dateIncludeTime = dateIncludeTime
        self.timeFormat = timeFormat
        self.dateFormat = dateFormat
    }
}

extension Anytype_Model_Block.Content.Dataview.Sort {
    public init(relationKey: String = String(), type: Anytype_Model_Block.Content.Dataview.Sort.TypeEnum = .asc, customOrder: [SwiftProtobuf.Google_Protobuf_Value] = []) {
        self.relationKey = relationKey
        self.type = type
        self.customOrder = customOrder
    }
}

extension Anytype_Model_Block.Content.Dataview.Status {
    public init(id: String = String()) {
        self.id = id
    }
}

extension Anytype_Model_Block.Content.Dataview.Tag {
    public init(ids: [String] = []) {
        self.ids = ids
    }
}

extension Anytype_Model_Block.Content.Dataview.View {
    public init(id: String = String(), type: Anytype_Model_Block.Content.Dataview.View.TypeEnum = .table, name: String = String(), sorts: [Anytype_Model_Block.Content.Dataview.Sort] = [], filters: [Anytype_Model_Block.Content.Dataview.Filter] = [], relations: [Anytype_Model_Block.Content.Dataview.Relation] = [], coverRelationKey: String = String(), hideIcon: Bool = false, cardSize: Anytype_Model_Block.Content.Dataview.View.Size = .small, coverFit: Bool = false, groupRelationKey: String = String(), groupBackgroundColors: Bool = false) {
        self.id = id
        self.type = type
        self.name = name
        self.sorts = sorts
        self.filters = filters
        self.relations = relations
        self.coverRelationKey = coverRelationKey
        self.hideIcon = hideIcon
        self.cardSize = cardSize
        self.coverFit = coverFit
        self.groupRelationKey = groupRelationKey
        self.groupBackgroundColors = groupBackgroundColors
    }
}

extension Anytype_Model_Block.Content.Dataview.ViewGroup {
    public init(groupID: String = String(), index: Int32 = 0, hidden: Bool = false, backgroundColor: String = String()) {
        self.groupID = groupID
        self.index = index
        self.hidden = hidden
        self.backgroundColor = backgroundColor
    }
}

extension Anytype_Model_Block.Content.Div {
    public init(style: Anytype_Model_Block.Content.Div.Style = .line) {
        self.style = style
    }
}

extension Anytype_Model_Block.Content.File {
    public init(hash: String = String(), name: String = String(), type: Anytype_Model_Block.Content.File.TypeEnum = .none, mime: String = String(), size: Int64 = 0, addedAt: Int64 = 0, state: Anytype_Model_Block.Content.File.State = .empty, style: Anytype_Model_Block.Content.File.Style = .auto) {
        self.hash = hash
        self.name = name
        self.type = type
        self.mime = mime
        self.size = size
        self.addedAt = addedAt
        self.state = state
        self.style = style
    }
}

extension Anytype_Model_Block.Content.Icon {
    public init(name: String = String()) {
        self.name = name
    }
}

extension Anytype_Model_Block.Content.Latex {
    public init(text: String = String()) {
        self.text = text
    }
}

extension Anytype_Model_Block.Content.Layout {
    public init(style: Anytype_Model_Block.Content.Layout.Style = .row) {
        self.style = style
    }
}

extension Anytype_Model_Block.Content.Link {
    public init(targetBlockID: String = String(), style: Anytype_Model_Block.Content.Link.Style = .page, fields: SwiftProtobuf.Google_Protobuf_Struct, iconSize: Anytype_Model_Block.Content.Link.IconSize = .sizeNone, cardStyle: Anytype_Model_Block.Content.Link.CardStyle = .text, description_p: Anytype_Model_Block.Content.Link.Description = .none, relations: [String] = []) {
        self.targetBlockID = targetBlockID
        self.style = style
        self.fields = fields
        self.iconSize = iconSize
        self.cardStyle = cardStyle
        self.description_p = description_p
        self.relations = relations
    }
}

extension Anytype_Model_Block.Content.Relation {
    public init(key: String = String()) {
        self.key = key
    }
}

extension Anytype_Model_Block.Content.TableRow {
    public init(isHeader: Bool = false) {
        self.isHeader = isHeader
    }
}

extension Anytype_Model_Block.Content.Text {
    public init(text: String = String(), style: Anytype_Model_Block.Content.Text.Style = .paragraph, marks: Anytype_Model_Block.Content.Text.Marks, checked: Bool = false, color: String = String(), iconEmoji: String = String(), iconImage: String = String()) {
        self.text = text
        self.style = style
        self.marks = marks
        self.checked = checked
        self.color = color
        self.iconEmoji = iconEmoji
        self.iconImage = iconImage
    }
}

extension Anytype_Model_Block.Content.Text.Mark {
    public init(range: Anytype_Model_Range, type: Anytype_Model_Block.Content.Text.Mark.TypeEnum = .strikethrough, param: String = String()) {
        self.range = range
        self.type = type
        self.param = param
    }
}

extension Anytype_Model_Block.Content.Text.Marks {
    public init(marks: [Anytype_Model_Block.Content.Text.Mark] = []) {
        self.marks = marks
    }
}

extension Anytype_Model_Block.Content.Widget {
    public init(layout: Anytype_Model_Block.Content.Widget.Layout = .link) {
        self.layout = layout
    }
}

extension Anytype_Model_Block.Restrictions {
    public init(read: Bool = false, edit: Bool = false, remove: Bool = false, drag: Bool = false, dropOn: Bool = false) {
        self.read = read
        self.edit = edit
        self.remove = remove
        self.drag = drag
        self.dropOn = dropOn
    }
}

extension Anytype_Model_BlockMetaOnly {
    public init(id: String = String(), fields: SwiftProtobuf.Google_Protobuf_Struct) {
        self.id = id
        self.fields = fields
    }
}

extension Anytype_Model_InternalFlag {
    public init(value: Anytype_Model_InternalFlag.Value = .editorDeleteEmpty) {
        self.value = value
    }
}

extension Anytype_Model_Layout {
    public init(id: Anytype_Model_ObjectType.Layout = .basic, name: String = String(), requiredRelations: [Anytype_Model_Relation] = []) {
        self.id = id
        self.name = name
        self.requiredRelations = requiredRelations
    }
}

extension Anytype_Model_LinkPreview {
    public init(url: String = String(), title: String = String(), description_p: String = String(), imageURL: String = String(), faviconURL: String = String(), type: Anytype_Model_LinkPreview.TypeEnum = .unknown) {
        self.url = url
        self.title = title
        self.description_p = description_p
        self.imageURL = imageURL
        self.faviconURL = faviconURL
        self.type = type
    }
}

extension Anytype_Model_ObjectType {
    public init(url: String = String(), name: String = String(), relationLinks: [Anytype_Model_RelationLink] = [], layout: Anytype_Model_ObjectType.Layout = .basic, iconEmoji: String = String(), description_p: String = String(), hidden: Bool = false, readonly: Bool = false, types: [Anytype_Model_SmartBlockType] = [], isArchived: Bool = false, installedByDefault: Bool = false) {
        self.url = url
        self.name = name
        self.relationLinks = relationLinks
        self.layout = layout
        self.iconEmoji = iconEmoji
        self.description_p = description_p
        self.hidden = hidden
        self.readonly = readonly
        self.types = types
        self.isArchived = isArchived
        self.installedByDefault = installedByDefault
    }
}

extension Anytype_Model_ObjectView {
    public init(rootID: String = String(), blocks: [Anytype_Model_Block] = [], details: [Anytype_Model_ObjectView.DetailsSet] = [], type: Anytype_Model_SmartBlockType = .accountOld, relations: [Anytype_Model_Relation] = [], relationLinks: [Anytype_Model_RelationLink] = [], restrictions: Anytype_Model_Restrictions, history: Anytype_Model_ObjectView.HistorySize) {
        self.rootID = rootID
        self.blocks = blocks
        self.details = details
        self.type = type
        self.relations = relations
        self.relationLinks = relationLinks
        self.restrictions = restrictions
        self.history = history
    }
}

extension Anytype_Model_ObjectView.DetailsSet {
    public init(id: String = String(), details: SwiftProtobuf.Google_Protobuf_Struct, subIds: [String] = []) {
        self.id = id
        self.details = details
        self.subIds = subIds
    }
}

extension Anytype_Model_ObjectView.HistorySize {
    public init(undo: Int32 = 0, redo: Int32 = 0) {
        self.undo = undo
        self.redo = redo
    }
}

extension Anytype_Model_ObjectView.RelationWithValuePerObject {
    public init(objectID: String = String(), relations: [Anytype_Model_RelationWithValue] = []) {
        self.objectID = objectID
        self.relations = relations
    }
}

extension Anytype_Model_Range {
    public init(from: Int32 = 0, to: Int32 = 0) {
        self.from = from
        self.to = to
    }
}

extension Anytype_Model_Relation {
    public init(id: String = String(), key: String = String(), format: Anytype_Model_RelationFormat = .longtext, name: String = String(), defaultValue: SwiftProtobuf.Google_Protobuf_Value, dataSource: Anytype_Model_Relation.DataSource = .details, hidden: Bool = false, readOnly: Bool = false, readOnlyRelation: Bool = false, multi: Bool = false, objectTypes: [String] = [], selectDict: [Anytype_Model_Relation.Option] = [], maxCount: Int32 = 0, description_p: String = String(), scope: Anytype_Model_Relation.Scope = .object, creator: String = String()) {
        self.id = id
        self.key = key
        self.format = format
        self.name = name
        self.defaultValue = defaultValue
        self.dataSource = dataSource
        self.hidden = hidden
        self.readOnly = readOnly
        self.readOnlyRelation = readOnlyRelation
        self.multi = multi
        self.objectTypes = objectTypes
        self.selectDict = selectDict
        self.maxCount = maxCount
        self.description_p = description_p
        self.scope = scope
        self.creator = creator
    }
}

extension Anytype_Model_Relation.Option {
    public init(id: String = String(), text: String = String(), color: String = String(), relationKey: String = String()) {
        self.id = id
        self.text = text
        self.color = color
        self.relationKey = relationKey
    }
}

extension Anytype_Model_RelationLink {
    public init(key: String = String(), format: Anytype_Model_RelationFormat = .longtext) {
        self.key = key
        self.format = format
    }
}

extension Anytype_Model_RelationOptions {
    public init(options: [Anytype_Model_Relation.Option] = []) {
        self.options = options
    }
}

extension Anytype_Model_RelationWithValue {
    public init(relation: Anytype_Model_Relation, value: SwiftProtobuf.Google_Protobuf_Value) {
        self.relation = relation
        self.value = value
    }
}

extension Anytype_Model_Relations {
    public init(relations: [Anytype_Model_Relation] = []) {
        self.relations = relations
    }
}

extension Anytype_Model_Restrictions {
    public init(object: [Anytype_Model_Restrictions.ObjectRestriction] = [], dataview: [Anytype_Model_Restrictions.DataviewRestrictions] = []) {
        self.object = object
        self.dataview = dataview
    }
}

extension Anytype_Model_Restrictions.DataviewRestrictions {
    public init(blockID: String = String(), restrictions: [Anytype_Model_Restrictions.DataviewRestriction] = []) {
        self.blockID = blockID
        self.restrictions = restrictions
    }
}

extension Anytype_Model_SmartBlockSnapshotBase {
    public init(blocks: [Anytype_Model_Block] = [], details: SwiftProtobuf.Google_Protobuf_Struct, fileKeys: SwiftProtobuf.Google_Protobuf_Struct, extraRelations: [Anytype_Model_Relation] = [], objectTypes: [String] = [], collections: SwiftProtobuf.Google_Protobuf_Struct, removedCollectionKeys: [String] = [], relationLinks: [Anytype_Model_RelationLink] = []) {
        self.blocks = blocks
        self.details = details
        self.fileKeys = fileKeys
        self.extraRelations = extraRelations
        self.objectTypes = objectTypes
        self.collections = collections
        self.removedCollectionKeys = removedCollectionKeys
        self.relationLinks = relationLinks
    }
}

extension Anytype_Model_ThreadCreateQueueEntry {
    public init(collectionThread: String = String(), threadID: String = String()) {
        self.collectionThread = collectionThread
        self.threadID = threadID
    }
}

extension Anytype_Model_ThreadDeeplinkPayload {
    public init(key: String = String(), addrs: [String] = []) {
        self.key = key
        self.addrs = addrs
    }
}

