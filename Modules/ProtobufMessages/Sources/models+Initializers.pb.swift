// DO NOT EDIT
//
// Generated automatically by the AnytypeSwiftCodegen.
//
// For more info see:
// https://github.com/anytypeio/anytype-swift-codegen

import Foundation
import SwiftProtobuf

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
  public init(avatar: Anytype_Model_Account.Avatar.OneOf_Avatar?) {
    self.avatar = avatar
  }
}

extension Anytype_Model_Account.Config {
  public init(enableDataview: Bool, enableDebug: Bool, enableReleaseChannelSwitch: Bool, enableSpaces: Bool, extra: SwiftProtobuf.Google_Protobuf_Struct) {
    self.enableDataview = enableDataview
    self.enableDebug = enableDebug
    self.enableReleaseChannelSwitch = enableReleaseChannelSwitch
    self.enableSpaces = enableSpaces
    self.extra = extra
  }
}

extension Anytype_Model_Account.Info {
  public init(
    homeObjectID: String, archiveObjectID: String, profileObjectID: String, marketplaceTypeObjectID: String, marketplaceRelationObjectID: String, marketplaceTemplateObjectID: String, deviceID: String,
    gatewayURL: String
  ) {
    self.homeObjectID = homeObjectID
    self.archiveObjectID = archiveObjectID
    self.profileObjectID = profileObjectID
    self.marketplaceTypeObjectID = marketplaceTypeObjectID
    self.marketplaceRelationObjectID = marketplaceRelationObjectID
    self.marketplaceTemplateObjectID = marketplaceTemplateObjectID
    self.deviceID = deviceID
    self.gatewayURL = gatewayURL
  }
}

extension Anytype_Model_Account.Status {
  public init(statusType: Anytype_Model_Account.StatusType, deletionDate: Int64) {
    self.statusType = statusType
    self.deletionDate = deletionDate
  }
}

extension Anytype_Model_Block {
  public init(
    id: String, fields: SwiftProtobuf.Google_Protobuf_Struct, restrictions: Anytype_Model_Block.Restrictions, childrenIds: [String], backgroundColor: String, align: Anytype_Model_Block.Align,
    content: OneOf_Content?
  ) {
    self.id = id
    self.fields = fields
    self.restrictions = restrictions
    self.childrenIds = childrenIds
    self.backgroundColor = backgroundColor
    self.align = align
    self.content = content
  }
}

extension Anytype_Model_Block.Content.Bookmark {
  public init(url: String, title: String, description_p: String, imageHash: String, faviconHash: String, type: Anytype_Model_LinkPreview.TypeEnum) {
    self.url = url
    self.title = title
    self.description_p = description_p
    self.imageHash = imageHash
    self.faviconHash = faviconHash
    self.type = type
  }
}

extension Anytype_Model_Block.Content.Dataview {
  public init(source: [String], views: [Anytype_Model_Block.Content.Dataview.View], relations: [Anytype_Model_Relation], activeView: String) {
    self.source = source
    self.views = views
    self.relations = relations
    self.activeView = activeView
  }
}

extension Anytype_Model_Block.Content.Dataview.Filter {
  public init(
    `operator`: Anytype_Model_Block.Content.Dataview.Filter.Operator, relationKey: String, relationProperty: String, condition: Anytype_Model_Block.Content.Dataview.Filter.Condition,
    value: SwiftProtobuf.Google_Protobuf_Value, quickOption: Anytype_Model_Block.Content.Dataview.Filter.QuickOption
  ) {
    self.`operator` = `operator`
    self.relationKey = relationKey
    self.relationProperty = relationProperty
    self.condition = condition
    self.value = value
    self.quickOption = quickOption
  }
}

extension Anytype_Model_Block.Content.Dataview.Relation {
  public init(
    key: String, isVisible: Bool, width: Int32, dateIncludeTime: Bool, timeFormat: Anytype_Model_Block.Content.Dataview.Relation.TimeFormat,
    dateFormat: Anytype_Model_Block.Content.Dataview.Relation.DateFormat
  ) {
    self.key = key
    self.isVisible = isVisible
    self.width = width
    self.dateIncludeTime = dateIncludeTime
    self.timeFormat = timeFormat
    self.dateFormat = dateFormat
  }
}

extension Anytype_Model_Block.Content.Dataview.Sort {
  public init(relationKey: String, type: Anytype_Model_Block.Content.Dataview.Sort.TypeEnum) {
    self.relationKey = relationKey
    self.type = type
  }
}

extension Anytype_Model_Block.Content.Dataview.View {
  public init(
    id: String, type: Anytype_Model_Block.Content.Dataview.View.TypeEnum, name: String, sorts: [Anytype_Model_Block.Content.Dataview.Sort], filters: [Anytype_Model_Block.Content.Dataview.Filter],
    relations: [Anytype_Model_Block.Content.Dataview.Relation], coverRelationKey: String, hideIcon: Bool, cardSize: Anytype_Model_Block.Content.Dataview.View.Size, coverFit: Bool
  ) {
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
  }
}

extension Anytype_Model_Block.Content.Div {
  public init(style: Anytype_Model_Block.Content.Div.Style) {
    self.style = style
  }
}

extension Anytype_Model_Block.Content.File {
  public init(
    hash: String, name: String, type: Anytype_Model_Block.Content.File.TypeEnum, mime: String, size: Int64, addedAt: Int64, state: Anytype_Model_Block.Content.File.State,
    style: Anytype_Model_Block.Content.File.Style
  ) {
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
  public init(name: String) {
    self.name = name
  }
}

extension Anytype_Model_Block.Content.Latex {
  public init(text: String) {
    self.text = text
  }
}

extension Anytype_Model_Block.Content.Layout {
  public init(style: Anytype_Model_Block.Content.Layout.Style) {
    self.style = style
  }
}

extension Anytype_Model_Block.Content.Link {
  public init(
    targetBlockID: String, style: Anytype_Model_Block.Content.Link.Style, fields: SwiftProtobuf.Google_Protobuf_Struct, iconSize: Anytype_Model_Block.Content.Link.IconSize,
    cardStyle: Anytype_Model_Block.Content.Link.CardStyle, description_p: Anytype_Model_Block.Content.Link.Description, relations: [String]
  ) {
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
  public init(key: String) {
    self.key = key
  }
}

extension Anytype_Model_Block.Content.Text {
  public init(text: String, style: Anytype_Model_Block.Content.Text.Style, marks: Anytype_Model_Block.Content.Text.Marks, checked: Bool, color: String, iconEmoji: String, iconImage: String) {
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
  public init(range: Anytype_Model_Range, type: Anytype_Model_Block.Content.Text.Mark.TypeEnum, param: String) {
    self.range = range
    self.type = type
    self.param = param
  }
}

extension Anytype_Model_Block.Content.Text.Marks {
  public init(marks: [Anytype_Model_Block.Content.Text.Mark]) {
    self.marks = marks
  }
}

extension Anytype_Model_Block.Restrictions {
  public init(read: Bool, edit: Bool, remove: Bool, drag: Bool, dropOn: Bool) {
    self.read = read
    self.edit = edit
    self.remove = remove
    self.drag = drag
    self.dropOn = dropOn
  }
}

extension Anytype_Model_BlockMetaOnly {
  public init(id: String, fields: SwiftProtobuf.Google_Protobuf_Struct) {
    self.id = id
    self.fields = fields
  }
}

extension Anytype_Model_Layout {
  public init(id: Anytype_Model_ObjectType.Layout, name: String, requiredRelations: [Anytype_Model_Relation]) {
    self.id = id
    self.name = name
    self.requiredRelations = requiredRelations
  }
}

extension Anytype_Model_LinkPreview {
  public init(url: String, title: String, description_p: String, imageURL: String, faviconURL: String, type: Anytype_Model_LinkPreview.TypeEnum) {
    self.url = url
    self.title = title
    self.description_p = description_p
    self.imageURL = imageURL
    self.faviconURL = faviconURL
    self.type = type
  }
}

extension Anytype_Model_ObjectType {
  public init(
    url: String, name: String, relations: [Anytype_Model_Relation], layout: Anytype_Model_ObjectType.Layout, iconEmoji: String, description_p: String, hidden: Bool, readonly: Bool,
    types: [Anytype_Model_SmartBlockType], isArchived: Bool
  ) {
    self.url = url
    self.name = name
    self.relations = relations
    self.layout = layout
    self.iconEmoji = iconEmoji
    self.description_p = description_p
    self.hidden = hidden
    self.readonly = readonly
    self.types = types
    self.isArchived = isArchived
  }
}

extension Anytype_Model_Range {
  public init(from: Int32, to: Int32) {
    self.from = from
    self.to = to
  }
}

extension Anytype_Model_Relation {
  public init(
    key: String, format: Anytype_Model_RelationFormat, name: String, defaultValue: SwiftProtobuf.Google_Protobuf_Value, dataSource: Anytype_Model_Relation.DataSource, hidden: Bool, readOnly: Bool,
    readOnlyRelation: Bool, multi: Bool, objectTypes: [String], selectDict: [Anytype_Model_Relation.Option], maxCount: Int32, description_p: String, scope: Anytype_Model_Relation.Scope,
    creator: String
  ) {
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
  public init(id: String, text: String, color: String, scope: Anytype_Model_Relation.Option.Scope) {
    self.id = id
    self.text = text
    self.color = color
    self.scope = scope
  }
}

extension Anytype_Model_RelationOptions {
  public init(options: [Anytype_Model_Relation.Option]) {
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
  public init(relations: [Anytype_Model_Relation]) {
    self.relations = relations
  }
}

extension Anytype_Model_Restrictions {
  public init(object: [Anytype_Model_Restrictions.ObjectRestriction], dataview: [Anytype_Model_Restrictions.DataviewRestrictions]) {
    self.object = object
    self.dataview = dataview
  }
}

extension Anytype_Model_Restrictions.DataviewRestrictions {
  public init(blockID: String, restrictions: [Anytype_Model_Restrictions.DataviewRestriction]) {
    self.blockID = blockID
    self.restrictions = restrictions
  }
}

extension Anytype_Model_SmartBlockSnapshotBase {
  public init(
    blocks: [Anytype_Model_Block], details: SwiftProtobuf.Google_Protobuf_Struct, fileKeys: SwiftProtobuf.Google_Protobuf_Struct, extraRelations: [Anytype_Model_Relation], objectTypes: [String],
    collections: SwiftProtobuf.Google_Protobuf_Struct
  ) {
    self.blocks = blocks
    self.details = details
    self.fileKeys = fileKeys
    self.extraRelations = extraRelations
    self.objectTypes = objectTypes
    self.collections = collections
  }
}

extension Anytype_Model_ThreadCreateQueueEntry {
  public init(collectionThread: String, threadID: String) {
    self.collectionThread = collectionThread
    self.threadID = threadID
  }
}

extension Anytype_Model_ThreadDeeplinkPayload {
  public init(key: String, addrs: [String]) {
    self.key = key
    self.addrs = addrs
  }
}
