// DO NOT EDIT
//
// Generated automatically by the AnytypeSwiftCodegen.
//
// For more info see:
// https://github.com/anytypeio/anytype-swift-codegen

import Foundation
import SwiftProtobuf
import Combine

extension Anytype_Event {
    public init(messages: [Anytype_Event.Message] = [], contextID: String = String(), initiator: Anytype_Model_Account, traceID: String = String()) {
        self.messages = messages
        self.contextID = contextID
        self.initiator = initiator
        self.traceID = traceID
    }
}

extension Anytype_Event.Account.Config.Update {
    public init(config: Anytype_Model_Account.Config, status: Anytype_Model_Account.Status) {
        self.config = config
        self.status = status
    }
}

extension Anytype_Event.Account.Details {
    public init(profileID: String = String(), details: SwiftProtobuf.Google_Protobuf_Struct) {
        self.profileID = profileID
        self.details = details
    }
}

extension Anytype_Event.Account.Show {
    public init(index: Int32 = 0, account: Anytype_Model_Account) {
        self.index = index
        self.account = account
    }
}

extension Anytype_Event.Account.Update {
    public init(config: Anytype_Model_Account.Config, status: Anytype_Model_Account.Status) {
        self.config = config
        self.status = status
    }
}

extension Anytype_Event.Block.Add {
    public init(blocks: [Anytype_Model_Block] = []) {
        self.blocks = blocks
    }
}

extension Anytype_Event.Block.Dataview.GroupOrderUpdate {
    public init(id: String = String(), groupOrder: Anytype_Model_Block.Content.Dataview.GroupOrder) {
        self.id = id
        self.groupOrder = groupOrder
    }
}

extension Anytype_Event.Block.Dataview.ObjectOrderUpdate {
    public init(id: String = String(), viewID: String = String(), groupID: String = String(), sliceChanges: [Anytype_Event.Block.Dataview.SliceChange] = []) {
        self.id = id
        self.viewID = viewID
        self.groupID = groupID
        self.sliceChanges = sliceChanges
    }
}

extension Anytype_Event.Block.Dataview.OldRelationDelete {
    public init(id: String = String(), relationKey: String = String()) {
        self.id = id
        self.relationKey = relationKey
    }
}

extension Anytype_Event.Block.Dataview.OldRelationSet {
    public init(id: String, relationKey: String, relation: Anytype_Model_Relation) {
        self.id = id
        self.relationKey = relationKey
        self.relation = relation
    }
}

extension Anytype_Event.Block.Dataview.RelationDelete {
    public init(id: String = String(), relationIds: [String] = []) {
        self.id = id
        self.relationIds = relationIds
    }
}

extension Anytype_Event.Block.Dataview.RelationSet {
    public init(id: String = String(), relationLinks: [Anytype_Model_RelationLink] = []) {
        self.id = id
        self.relationLinks = relationLinks
    }
}

extension Anytype_Event.Block.Dataview.SliceChange {
    public init(op: Anytype_Event.Block.Dataview.SliceOperation = .none, ids: [String] = [], afterID: String = String()) {
        self.op = op
        self.ids = ids
        self.afterID = afterID
    }
}

extension Anytype_Event.Block.Dataview.SourceSet {
    public init(id: String = String(), source: [String] = []) {
        self.id = id
        self.source = source
    }
}

extension Anytype_Event.Block.Dataview.ViewDelete {
    public init(id: String = String(), viewID: String = String()) {
        self.id = id
        self.viewID = viewID
    }
}

extension Anytype_Event.Block.Dataview.ViewOrder {
    public init(id: String = String(), viewIds: [String] = []) {
        self.id = id
        self.viewIds = viewIds
    }
}

extension Anytype_Event.Block.Dataview.ViewSet {
    public init(id: String = String(), viewID: String = String(), view: Anytype_Model_Block.Content.Dataview.View, offset: UInt32 = 0, limit: UInt32 = 0) {
        self.id = id
        self.viewID = viewID
        self.view = view
        self.offset = offset
        self.limit = limit
    }
}

extension Anytype_Event.Block.Delete {
    public init(blockIds: [String] = []) {
        self.blockIds = blockIds
    }
}

extension Anytype_Event.Block.FilesUpload {
    public init(blockID: String = String(), filePath: [String] = []) {
        self.blockID = blockID
        self.filePath = filePath
    }
}

extension Anytype_Event.Block.Fill.Align {
    public init(id: String = String(), align: Anytype_Model_Block.Align = .left) {
        self.id = id
        self.align = align
    }
}

extension Anytype_Event.Block.Fill.BackgroundColor {
    public init(id: String = String(), backgroundColor: String = String()) {
        self.id = id
        self.backgroundColor = backgroundColor
    }
}

extension Anytype_Event.Block.Fill.Bookmark {
    public init(id: String = String(), url: Anytype_Event.Block.Fill.Bookmark.Url, title: Anytype_Event.Block.Fill.Bookmark.Title, description_p: Anytype_Event.Block.Fill.Bookmark.Description, imageHash: Anytype_Event.Block.Fill.Bookmark.ImageHash, faviconHash: Anytype_Event.Block.Fill.Bookmark.FaviconHash, type: Anytype_Event.Block.Fill.Bookmark.TypeMessage, targetObjectID: Anytype_Event.Block.Fill.Bookmark.TargetObjectId) {
        self.id = id
        self.url = url
        self.title = title
        self.description_p = description_p
        self.imageHash = imageHash
        self.faviconHash = faviconHash
        self.type = type
        self.targetObjectID = targetObjectID
    }
}

extension Anytype_Event.Block.Fill.Bookmark.Description {
    public init(value: String = String()) {
        self.value = value
    }
}

extension Anytype_Event.Block.Fill.Bookmark.FaviconHash {
    public init(value: String = String()) {
        self.value = value
    }
}

extension Anytype_Event.Block.Fill.Bookmark.ImageHash {
    public init(value: String = String()) {
        self.value = value
    }
}

extension Anytype_Event.Block.Fill.Bookmark.TargetObjectId {
    public init(value: String = String()) {
        self.value = value
    }
}

extension Anytype_Event.Block.Fill.Bookmark.Title {
    public init(value: String = String()) {
        self.value = value
    }
}

extension Anytype_Event.Block.Fill.Bookmark.TypeMessage {
    public init(value: Anytype_Model_LinkPreview.TypeEnum = .unknown) {
        self.value = value
    }
}

extension Anytype_Event.Block.Fill.Bookmark.Url {
    public init(value: String = String()) {
        self.value = value
    }
}

extension Anytype_Event.Block.Fill.ChildrenIds {
    public init(id: String = String(), childrenIds: [String] = []) {
        self.id = id
        self.childrenIds = childrenIds
    }
}

extension Anytype_Event.Block.Fill.DatabaseRecords {
    public init(id: String = String(), records: [SwiftProtobuf.Google_Protobuf_Struct] = []) {
        self.id = id
        self.records = records
    }
}

extension Anytype_Event.Block.Fill.Details {
    public init(id: String = String(), details: SwiftProtobuf.Google_Protobuf_Struct) {
        self.id = id
        self.details = details
    }
}

extension Anytype_Event.Block.Fill.Div {
    public init(id: String = String(), style: Anytype_Event.Block.Fill.Div.Style) {
        self.id = id
        self.style = style
    }
}

extension Anytype_Event.Block.Fill.Div.Style {
    public init(value: Anytype_Model_Block.Content.Div.Style = .line) {
        self.value = value
    }
}

extension Anytype_Event.Block.Fill.Fields {
    public init(id: String = String(), fields: SwiftProtobuf.Google_Protobuf_Struct) {
        self.id = id
        self.fields = fields
    }
}

extension Anytype_Event.Block.Fill.File {
    public init(id: String = String(), type: Anytype_Event.Block.Fill.File.TypeMessage, state: Anytype_Event.Block.Fill.File.State, mime: Anytype_Event.Block.Fill.File.Mime, hash: Anytype_Event.Block.Fill.File.Hash, name: Anytype_Event.Block.Fill.File.Name, size: Anytype_Event.Block.Fill.File.Size, style: Anytype_Event.Block.Fill.File.Style) {
        self.id = id
        self.type = type
        self.state = state
        self.mime = mime
        self.hash = hash
        self.name = name
        self.size = size
        self.style = style
    }
}

extension Anytype_Event.Block.Fill.File.Hash {
    public init(value: String = String()) {
        self.value = value
    }
}

extension Anytype_Event.Block.Fill.File.Mime {
    public init(value: String = String()) {
        self.value = value
    }
}

extension Anytype_Event.Block.Fill.File.Name {
    public init(value: String = String()) {
        self.value = value
    }
}

extension Anytype_Event.Block.Fill.File.Size {
    public init(value: Int64 = 0) {
        self.value = value
    }
}

extension Anytype_Event.Block.Fill.File.State {
    public init(value: Anytype_Model_Block.Content.File.State = .empty) {
        self.value = value
    }
}

extension Anytype_Event.Block.Fill.File.Style {
    public init(value: Anytype_Model_Block.Content.File.Style = .auto) {
        self.value = value
    }
}

extension Anytype_Event.Block.Fill.File.TypeMessage {
    public init(value: Anytype_Model_Block.Content.File.TypeEnum = .none) {
        self.value = value
    }
}

extension Anytype_Event.Block.Fill.File.Width {
    public init(value: Int32 = 0) {
        self.value = value
    }
}

extension Anytype_Event.Block.Fill.Link {
    public init(id: String = String(), targetBlockID: Anytype_Event.Block.Fill.Link.TargetBlockId, style: Anytype_Event.Block.Fill.Link.Style, fields: Anytype_Event.Block.Fill.Link.Fields) {
        self.id = id
        self.targetBlockID = targetBlockID
        self.style = style
        self.fields = fields
    }
}

extension Anytype_Event.Block.Fill.Link.Fields {
    public init(value: SwiftProtobuf.Google_Protobuf_Struct) {
        self.value = value
    }
}

extension Anytype_Event.Block.Fill.Link.Style {
    public init(value: Anytype_Model_Block.Content.Link.Style = .page) {
        self.value = value
    }
}

extension Anytype_Event.Block.Fill.Link.TargetBlockId {
    public init(value: String = String()) {
        self.value = value
    }
}

extension Anytype_Event.Block.Fill.Restrictions {
    public init(id: String = String(), restrictions: Anytype_Model_Block.Restrictions) {
        self.id = id
        self.restrictions = restrictions
    }
}

extension Anytype_Event.Block.Fill.Text {
    public init(id: String = String(), text: Anytype_Event.Block.Fill.Text.Text, style: Anytype_Event.Block.Fill.Text.Style, marks: Anytype_Event.Block.Fill.Text.Marks, checked: Anytype_Event.Block.Fill.Text.Checked, color: Anytype_Event.Block.Fill.Text.Color) {
        self.id = id
        self.text = text
        self.style = style
        self.marks = marks
        self.checked = checked
        self.color = color
    }
}

extension Anytype_Event.Block.Fill.Text.Checked {
    public init(value: Bool = false) {
        self.value = value
    }
}

extension Anytype_Event.Block.Fill.Text.Color {
    public init(value: String = String()) {
        self.value = value
    }
}

extension Anytype_Event.Block.Fill.Text.Marks {
    public init(value: Anytype_Model_Block.Content.Text.Marks) {
        self.value = value
    }
}

extension Anytype_Event.Block.Fill.Text.Style {
    public init(value: Anytype_Model_Block.Content.Text.Style = .paragraph) {
        self.value = value
    }
}

extension Anytype_Event.Block.Fill.Text.Text {
    public init(value: String = String()) {
        self.value = value
    }
}

extension Anytype_Event.Block.MarksInfo {
    public init(marksInRange: [Anytype_Model_Block.Content.Text.Mark.TypeEnum] = []) {
        self.marksInRange = marksInRange
    }
}

extension Anytype_Event.Block.Set.Align {
    public init(id: String = String(), align: Anytype_Model_Block.Align = .left) {
        self.id = id
        self.align = align
    }
}

extension Anytype_Event.Block.Set.BackgroundColor {
    public init(id: String = String(), backgroundColor: String = String()) {
        self.id = id
        self.backgroundColor = backgroundColor
    }
}

extension Anytype_Event.Block.Set.Bookmark {
    public init(id: String = String(), url: Anytype_Event.Block.Set.Bookmark.Url, title: Anytype_Event.Block.Set.Bookmark.Title, description_p: Anytype_Event.Block.Set.Bookmark.Description, imageHash: Anytype_Event.Block.Set.Bookmark.ImageHash, faviconHash: Anytype_Event.Block.Set.Bookmark.FaviconHash, type: Anytype_Event.Block.Set.Bookmark.TypeMessage, targetObjectID: Anytype_Event.Block.Set.Bookmark.TargetObjectId, state: Anytype_Event.Block.Set.Bookmark.State) {
        self.id = id
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

extension Anytype_Event.Block.Set.Bookmark.Description {
    public init(value: String = String()) {
        self.value = value
    }
}

extension Anytype_Event.Block.Set.Bookmark.FaviconHash {
    public init(value: String = String()) {
        self.value = value
    }
}

extension Anytype_Event.Block.Set.Bookmark.ImageHash {
    public init(value: String = String()) {
        self.value = value
    }
}

extension Anytype_Event.Block.Set.Bookmark.State {
    public init(value: Anytype_Model_Block.Content.Bookmark.State = .empty) {
        self.value = value
    }
}

extension Anytype_Event.Block.Set.Bookmark.TargetObjectId {
    public init(value: String = String()) {
        self.value = value
    }
}

extension Anytype_Event.Block.Set.Bookmark.Title {
    public init(value: String = String()) {
        self.value = value
    }
}

extension Anytype_Event.Block.Set.Bookmark.TypeMessage {
    public init(value: Anytype_Model_LinkPreview.TypeEnum = .unknown) {
        self.value = value
    }
}

extension Anytype_Event.Block.Set.Bookmark.Url {
    public init(value: String = String()) {
        self.value = value
    }
}

extension Anytype_Event.Block.Set.ChildrenIds {
    public init(id: String = String(), childrenIds: [String] = []) {
        self.id = id
        self.childrenIds = childrenIds
    }
}

extension Anytype_Event.Block.Set.Div {
    public init(id: String = String(), style: Anytype_Event.Block.Set.Div.Style) {
        self.id = id
        self.style = style
    }
}

extension Anytype_Event.Block.Set.Div.Style {
    public init(value: Anytype_Model_Block.Content.Div.Style = .line) {
        self.value = value
    }
}

extension Anytype_Event.Block.Set.Fields {
    public init(id: String = String(), fields: SwiftProtobuf.Google_Protobuf_Struct) {
        self.id = id
        self.fields = fields
    }
}

extension Anytype_Event.Block.Set.File {
    public init(id: String = String(), type: Anytype_Event.Block.Set.File.TypeMessage, state: Anytype_Event.Block.Set.File.State, mime: Anytype_Event.Block.Set.File.Mime, hash: Anytype_Event.Block.Set.File.Hash, name: Anytype_Event.Block.Set.File.Name, size: Anytype_Event.Block.Set.File.Size, style: Anytype_Event.Block.Set.File.Style) {
        self.id = id
        self.type = type
        self.state = state
        self.mime = mime
        self.hash = hash
        self.name = name
        self.size = size
        self.style = style
    }
}

extension Anytype_Event.Block.Set.File.Hash {
    public init(value: String = String()) {
        self.value = value
    }
}

extension Anytype_Event.Block.Set.File.Mime {
    public init(value: String = String()) {
        self.value = value
    }
}

extension Anytype_Event.Block.Set.File.Name {
    public init(value: String = String()) {
        self.value = value
    }
}

extension Anytype_Event.Block.Set.File.Size {
    public init(value: Int64 = 0) {
        self.value = value
    }
}

extension Anytype_Event.Block.Set.File.State {
    public init(value: Anytype_Model_Block.Content.File.State = .empty) {
        self.value = value
    }
}

extension Anytype_Event.Block.Set.File.Style {
    public init(value: Anytype_Model_Block.Content.File.Style = .auto) {
        self.value = value
    }
}

extension Anytype_Event.Block.Set.File.TypeMessage {
    public init(value: Anytype_Model_Block.Content.File.TypeEnum = .none) {
        self.value = value
    }
}

extension Anytype_Event.Block.Set.File.Width {
    public init(value: Int32 = 0) {
        self.value = value
    }
}

extension Anytype_Event.Block.Set.Latex {
    public init(id: String = String(), text: Anytype_Event.Block.Set.Latex.Text) {
        self.id = id
        self.text = text
    }
}

extension Anytype_Event.Block.Set.Latex.Text {
    public init(value: String = String()) {
        self.value = value
    }
}

extension Anytype_Event.Block.Set.Link {
    public init(id: String = String(), targetBlockID: Anytype_Event.Block.Set.Link.TargetBlockId, style: Anytype_Event.Block.Set.Link.Style, fields: Anytype_Event.Block.Set.Link.Fields, iconSize: Anytype_Event.Block.Set.Link.IconSize, cardStyle: Anytype_Event.Block.Set.Link.CardStyle, description_p: Anytype_Event.Block.Set.Link.Description, relations: Anytype_Event.Block.Set.Link.Relations) {
        self.id = id
        self.targetBlockID = targetBlockID
        self.style = style
        self.fields = fields
        self.iconSize = iconSize
        self.cardStyle = cardStyle
        self.description_p = description_p
        self.relations = relations
    }
}

extension Anytype_Event.Block.Set.Link.CardStyle {
    public init(value: Anytype_Model_Block.Content.Link.CardStyle = .text) {
        self.value = value
    }
}

extension Anytype_Event.Block.Set.Link.Description {
    public init(value: Anytype_Model_Block.Content.Link.Description = .none) {
        self.value = value
    }
}

extension Anytype_Event.Block.Set.Link.Fields {
    public init(value: SwiftProtobuf.Google_Protobuf_Struct) {
        self.value = value
    }
}

extension Anytype_Event.Block.Set.Link.IconSize {
    public init(value: Anytype_Model_Block.Content.Link.IconSize = .sizeNone) {
        self.value = value
    }
}

extension Anytype_Event.Block.Set.Link.Relations {
    public init(value: [String] = []) {
        self.value = value
    }
}

extension Anytype_Event.Block.Set.Link.Style {
    public init(value: Anytype_Model_Block.Content.Link.Style = .page) {
        self.value = value
    }
}

extension Anytype_Event.Block.Set.Link.TargetBlockId {
    public init(value: String = String()) {
        self.value = value
    }
}

extension Anytype_Event.Block.Set.Relation {
    public init(id: String = String(), key: Anytype_Event.Block.Set.Relation.Key) {
        self.id = id
        self.key = key
    }
}

extension Anytype_Event.Block.Set.Relation.Key {
    public init(value: String = String()) {
        self.value = value
    }
}

extension Anytype_Event.Block.Set.Restrictions {
    public init(id: String = String(), restrictions: Anytype_Model_Block.Restrictions) {
        self.id = id
        self.restrictions = restrictions
    }
}

extension Anytype_Event.Block.Set.TableRow {
    public init(id: String = String(), isHeader: Anytype_Event.Block.Set.TableRow.IsHeader) {
        self.id = id
        self.isHeader = isHeader
    }
}

extension Anytype_Event.Block.Set.TableRow.IsHeader {
    public init(value: Bool = false) {
        self.value = value
    }
}

extension Anytype_Event.Block.Set.Text {
    public init(id: String = String(), text: Anytype_Event.Block.Set.Text.Text, style: Anytype_Event.Block.Set.Text.Style, marks: Anytype_Event.Block.Set.Text.Marks, checked: Anytype_Event.Block.Set.Text.Checked, color: Anytype_Event.Block.Set.Text.Color, iconEmoji: Anytype_Event.Block.Set.Text.IconEmoji, iconImage: Anytype_Event.Block.Set.Text.IconImage) {
        self.id = id
        self.text = text
        self.style = style
        self.marks = marks
        self.checked = checked
        self.color = color
        self.iconEmoji = iconEmoji
        self.iconImage = iconImage
    }
}

extension Anytype_Event.Block.Set.Text.Checked {
    public init(value: Bool = false) {
        self.value = value
    }
}

extension Anytype_Event.Block.Set.Text.Color {
    public init(value: String = String()) {
        self.value = value
    }
}

extension Anytype_Event.Block.Set.Text.IconEmoji {
    public init(value: String = String()) {
        self.value = value
    }
}

extension Anytype_Event.Block.Set.Text.IconImage {
    public init(value: String = String()) {
        self.value = value
    }
}

extension Anytype_Event.Block.Set.Text.Marks {
    public init(value: Anytype_Model_Block.Content.Text.Marks) {
        self.value = value
    }
}

extension Anytype_Event.Block.Set.Text.Style {
    public init(value: Anytype_Model_Block.Content.Text.Style = .paragraph) {
        self.value = value
    }
}

extension Anytype_Event.Block.Set.Text.Text {
    public init(value: String = String()) {
        self.value = value
    }
}

extension Anytype_Event.Block.Set.VerticalAlign {
    public init(id: String = String(), verticalAlign: Anytype_Model_Block.VerticalAlign = .top) {
        self.id = id
        self.verticalAlign = verticalAlign
    }
}

extension Anytype_Event.Message {
    public init(value: Anytype_Event.Message.OneOf_Value? = nil) {
        self.value = value
    }
}

extension Anytype_Event.Object.Details.Amend {
    public init(id: String = String(), details: [Anytype_Event.Object.Details.Amend.KeyValue] = [], subIds: [String] = []) {
        self.id = id
        self.details = details
        self.subIds = subIds
    }
}

extension Anytype_Event.Object.Details.Amend.KeyValue {
    public init(key: String = String(), value: SwiftProtobuf.Google_Protobuf_Value) {
        self.key = key
        self.value = value
    }
}

extension Anytype_Event.Object.Details.Set {
    public init(id: String = String(), details: SwiftProtobuf.Google_Protobuf_Struct, subIds: [String] = []) {
        self.id = id
        self.details = details
        self.subIds = subIds
    }
}

extension Anytype_Event.Object.Details.Unset {
    public init(id: String = String(), keys: [String] = [], subIds: [String] = []) {
        self.id = id
        self.keys = keys
        self.subIds = subIds
    }
}

extension Anytype_Event.Object.Relations.Amend {
    public init(id: String = String(), relationLinks: [Anytype_Model_RelationLink] = []) {
        self.id = id
        self.relationLinks = relationLinks
    }
}

extension Anytype_Event.Object.Relations.Remove {
    public init(id: String = String(), relationIds: [String] = []) {
        self.id = id
        self.relationIds = relationIds
    }
}

extension Anytype_Event.Object.Remove {
    public init(ids: [String] = []) {
        self.ids = ids
    }
}

extension Anytype_Event.Object.Restriction {
    public init(id: String = String(), restrictions: Anytype_Model_Restrictions) {
        self.id = id
        self.restrictions = restrictions
    }
}

extension Anytype_Event.Object.Subscription.Add {
    public init(id: String = String(), afterID: String = String(), subID: String = String()) {
        self.id = id
        self.afterID = afterID
        self.subID = subID
    }
}

extension Anytype_Event.Object.Subscription.Counters {
    public init(total: Int64 = 0, nextCount: Int64 = 0, prevCount: Int64 = 0, subID: String = String()) {
        self.total = total
        self.nextCount = nextCount
        self.prevCount = prevCount
        self.subID = subID
    }
}

extension Anytype_Event.Object.Subscription.Position {
    public init(id: String = String(), afterID: String = String(), subID: String = String()) {
        self.id = id
        self.afterID = afterID
        self.subID = subID
    }
}

extension Anytype_Event.Object.Subscription.Remove {
    public init(id: String = String(), subID: String = String()) {
        self.id = id
        self.subID = subID
    }
}

extension Anytype_Event.Ping {
    public init(index: Int32 = 0) {
        self.index = index
    }
}

extension Anytype_Event.Process.Done {
    public init(process: Anytype_Model.Process) {
        self.process = process
    }
}

extension Anytype_Event.Process.New {
    public init(process: Anytype_Model.Process) {
        self.process = process
    }
}

extension Anytype_Event.Process.Update {
    public init(process: Anytype_Model.Process) {
        self.process = process
    }
}

extension Anytype_Event.Status.Thread {
    public init(summary: Anytype_Event.Status.Thread.Summary, cafe: Anytype_Event.Status.Thread.Cafe, accounts: [Anytype_Event.Status.Thread.Account] = []) {
        self.summary = summary
        self.cafe = cafe
        self.accounts = accounts
    }
}

extension Anytype_Event.Status.Thread.Account {
    public init(id: String = String(), name: String = String(), imageHash: String = String(), online: Bool = false, lastPulled: Int64 = 0, lastEdited: Int64 = 0, devices: [Anytype_Event.Status.Thread.Device] = []) {
        self.id = id
        self.name = name
        self.imageHash = imageHash
        self.online = online
        self.lastPulled = lastPulled
        self.lastEdited = lastEdited
        self.devices = devices
    }
}

extension Anytype_Event.Status.Thread.Cafe {
    public init(status: Anytype_Event.Status.Thread.SyncStatus = .unknown, lastPulled: Int64 = 0, lastPushSucceed: Bool = false, files: Anytype_Event.Status.Thread.Cafe.PinStatus) {
        self.status = status
        self.lastPulled = lastPulled
        self.lastPushSucceed = lastPushSucceed
        self.files = files
    }
}

extension Anytype_Event.Status.Thread.Cafe.PinStatus {
    public init(pinning: Int32 = 0, pinned: Int32 = 0, failed: Int32 = 0, updated: Int64 = 0) {
        self.pinning = pinning
        self.pinned = pinned
        self.failed = failed
        self.updated = updated
    }
}

extension Anytype_Event.Status.Thread.Device {
    public init(name: String = String(), online: Bool = false, lastPulled: Int64 = 0, lastEdited: Int64 = 0) {
        self.name = name
        self.online = online
        self.lastPulled = lastPulled
        self.lastEdited = lastEdited
    }
}

extension Anytype_Event.Status.Thread.Summary {
    public init(status: Anytype_Event.Status.Thread.SyncStatus = .unknown) {
        self.status = status
    }
}

extension Anytype_Event.User.Block.Join {
    public init(account: Anytype_Event.Account) {
        self.account = account
    }
}

extension Anytype_Event.User.Block.Left {
    public init(account: Anytype_Event.Account) {
        self.account = account
    }
}

extension Anytype_Event.User.Block.SelectRange {
    public init(account: Anytype_Event.Account, blockIdsArray: [String] = []) {
        self.account = account
        self.blockIdsArray = blockIdsArray
    }
}

extension Anytype_Event.User.Block.TextRange {
    public init(account: Anytype_Event.Account, blockID: String = String(), range: Anytype_Model_Range) {
        self.account = account
        self.blockID = blockID
        self.range = range
    }
}

extension Anytype_Model.Process {
    public init(id: String = String(), type: Anytype_Model.Process.TypeEnum = .dropFiles, state: Anytype_Model.Process.State = .none, progress: Anytype_Model.Process.Progress) {
        self.id = id
        self.type = type
        self.state = state
        self.progress = progress
    }
}

extension Anytype_Model.Process.Progress {
    public init(total: Int64 = 0, done: Int64 = 0, message: String = String()) {
        self.total = total
        self.done = done
        self.message = message
    }
}

extension Anytype_ResponseEvent {
    public init(messages: [Anytype_Event.Message] = [], contextID: String = String(), traceID: String = String()) {
        self.messages = messages
        self.contextID = contextID
        self.traceID = traceID
    }
}

