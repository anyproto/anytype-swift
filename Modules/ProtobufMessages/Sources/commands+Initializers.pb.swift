// DO NOT EDIT
//
// Generated automatically by the AnytypeSwiftCodegen.
//
// For more info see:
// https://github.com/anytypeio/anytype-swift-codegen

import Combine
import Foundation
import SwiftProtobuf

extension Anytype_Rpc.Account.Config {
  public init(enableDataview: Bool = false, enableDebug: Bool = false, enableReleaseChannelSwitch: Bool = false, enableSpaces: Bool = false, extra: SwiftProtobuf.Google_Protobuf_Struct) {
    self.enableDataview = enableDataview
    self.enableDebug = enableDebug
    self.enableReleaseChannelSwitch = enableReleaseChannelSwitch
    self.enableSpaces = enableSpaces
    self.extra = extra
  }
}

extension Anytype_Rpc.Account.Create.Request {
  public init(name: String = String(), avatar: Anytype_Rpc.Account.Create.Request.OneOf_Avatar? = nil, storePath: String = String(), alphaInviteCode: String = String()) {
    self.name = name
    self.avatar = avatar
    self.storePath = storePath
    self.alphaInviteCode = alphaInviteCode
  }
}

extension Anytype_Rpc.Account.Create.Response {
  public init(error: Anytype_Rpc.Account.Create.Response.Error, account: Anytype_Model_Account, config: Anytype_Rpc.Account.Config) {
    self.error = error
    self.account = account
    self.config = config
  }
}

extension Anytype_Rpc.Account.Create.Response.Error {
  public init(code: Anytype_Rpc.Account.Create.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Account.Delete.Request {
  public init(revert: Bool = false) {
    self.revert = revert
  }
}

extension Anytype_Rpc.Account.Delete.Response {
  public init(error: Anytype_Rpc.Account.Delete.Response.Error, status: Anytype_Model_Account.Status) {
    self.error = error
    self.status = status
  }
}

extension Anytype_Rpc.Account.Delete.Response.Error {
  public init(code: Anytype_Rpc.Account.Delete.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Account.Move.Request {
  public init(newPath: String = String()) {
    self.newPath = newPath
  }
}

extension Anytype_Rpc.Account.Move.Response {
  public init(error: Anytype_Rpc.Account.Move.Response.Error) {
    self.error = error
  }
}

extension Anytype_Rpc.Account.Move.Response.Error {
  public init(code: Anytype_Rpc.Account.Move.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Account.Recover.Response {
  public init(error: Anytype_Rpc.Account.Recover.Response.Error) {
    self.error = error
  }
}

extension Anytype_Rpc.Account.Recover.Response.Error {
  public init(code: Anytype_Rpc.Account.Recover.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Account.Select.Request {
  public init(id: String = String(), rootPath: String = String()) {
    self.id = id
    self.rootPath = rootPath
  }
}

extension Anytype_Rpc.Account.Select.Response {
  public init(error: Anytype_Rpc.Account.Select.Response.Error, account: Anytype_Model_Account, config: Anytype_Rpc.Account.Config) {
    self.error = error
    self.account = account
    self.config = config
  }
}

extension Anytype_Rpc.Account.Select.Response.Error {
  public init(code: Anytype_Rpc.Account.Select.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Account.Stop.Request {
  public init(removeData: Bool = false) {
    self.removeData = removeData
  }
}

extension Anytype_Rpc.Account.Stop.Response {
  public init(error: Anytype_Rpc.Account.Stop.Response.Error) {
    self.error = error
  }
}

extension Anytype_Rpc.Account.Stop.Response.Error {
  public init(code: Anytype_Rpc.Account.Stop.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.App.GetVersion.Response {
  public init(error: Anytype_Rpc.App.GetVersion.Response.Error, version: String = String(), details: String = String()) {
    self.error = error
    self.version = version
    self.details = details
  }
}

extension Anytype_Rpc.App.GetVersion.Response.Error {
  public init(code: Anytype_Rpc.App.GetVersion.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.App.SetDeviceState.Request {
  public init(deviceState: Anytype_Rpc.App.SetDeviceState.Request.DeviceState = .background) {
    self.deviceState = deviceState
  }
}

extension Anytype_Rpc.App.SetDeviceState.Response {
  public init(error: Anytype_Rpc.App.SetDeviceState.Response.Error) {
    self.error = error
  }
}

extension Anytype_Rpc.App.SetDeviceState.Response.Error {
  public init(code: Anytype_Rpc.App.SetDeviceState.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.App.Shutdown.Response {
  public init(error: Anytype_Rpc.App.Shutdown.Response.Error) {
    self.error = error
  }
}

extension Anytype_Rpc.App.Shutdown.Response.Error {
  public init(code: Anytype_Rpc.App.Shutdown.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Block.Copy.Request {
  public init(contextID: String = String(), blocks: [Anytype_Model_Block] = [], selectedTextRange: Anytype_Model_Range) {
    self.contextID = contextID
    self.blocks = blocks
    self.selectedTextRange = selectedTextRange
  }
}

extension Anytype_Rpc.Block.Copy.Response {
  public init(error: Anytype_Rpc.Block.Copy.Response.Error, textSlot: String = String(), htmlSlot: String = String(), anySlot: [Anytype_Model_Block] = []) {
    self.error = error
    self.textSlot = textSlot
    self.htmlSlot = htmlSlot
    self.anySlot = anySlot
  }
}

extension Anytype_Rpc.Block.Copy.Response.Error {
  public init(code: Anytype_Rpc.Block.Copy.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Block.Create.Request {
  public init(contextID: String = String(), targetID: String = String(), block: Anytype_Model_Block, position: Anytype_Model_Block.Position = .none) {
    self.contextID = contextID
    self.targetID = targetID
    self.block = block
    self.position = position
  }
}

extension Anytype_Rpc.Block.Create.Response {
  public init(error: Anytype_Rpc.Block.Create.Response.Error, blockID: String = String(), event: Anytype_ResponseEvent) {
    self.error = error
    self.blockID = blockID
    self.event = event
  }
}

extension Anytype_Rpc.Block.Create.Response.Error {
  public init(code: Anytype_Rpc.Block.Create.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Block.Cut.Request {
  public init(contextID: String = String(), blocks: [Anytype_Model_Block] = [], selectedTextRange: Anytype_Model_Range) {
    self.contextID = contextID
    self.blocks = blocks
    self.selectedTextRange = selectedTextRange
  }
}

extension Anytype_Rpc.Block.Cut.Response {
  public init(error: Anytype_Rpc.Block.Cut.Response.Error, textSlot: String = String(), htmlSlot: String = String(), anySlot: [Anytype_Model_Block] = [], event: Anytype_ResponseEvent) {
    self.error = error
    self.textSlot = textSlot
    self.htmlSlot = htmlSlot
    self.anySlot = anySlot
    self.event = event
  }
}

extension Anytype_Rpc.Block.Cut.Response.Error {
  public init(code: Anytype_Rpc.Block.Cut.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Block.Download.Request {
  public init(contextID: String = String(), blockID: String = String()) {
    self.contextID = contextID
    self.blockID = blockID
  }
}

extension Anytype_Rpc.Block.Download.Response {
  public init(error: Anytype_Rpc.Block.Download.Response.Error, event: Anytype_ResponseEvent) {
    self.error = error
    self.event = event
  }
}

extension Anytype_Rpc.Block.Download.Response.Error {
  public init(code: Anytype_Rpc.Block.Download.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Block.Export.Request {
  public init(contextID: String = String(), blocks: [Anytype_Model_Block] = []) {
    self.contextID = contextID
    self.blocks = blocks
  }
}

extension Anytype_Rpc.Block.Export.Response {
  public init(error: Anytype_Rpc.Block.Export.Response.Error, path: String = String(), event: Anytype_ResponseEvent) {
    self.error = error
    self.path = path
    self.event = event
  }
}

extension Anytype_Rpc.Block.Export.Response.Error {
  public init(code: Anytype_Rpc.Block.Export.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Block.ListConvertToObjects.Request {
  public init(contextID: String = String(), blockIds: [String] = [], objectType: String = String()) {
    self.contextID = contextID
    self.blockIds = blockIds
    self.objectType = objectType
  }
}

extension Anytype_Rpc.Block.ListConvertToObjects.Response {
  public init(error: Anytype_Rpc.Block.ListConvertToObjects.Response.Error, linkIds: [String] = [], event: Anytype_ResponseEvent) {
    self.error = error
    self.linkIds = linkIds
    self.event = event
  }
}

extension Anytype_Rpc.Block.ListConvertToObjects.Response.Error {
  public init(code: Anytype_Rpc.Block.ListConvertToObjects.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Block.ListDelete.Request {
  public init(contextID: String = String(), blockIds: [String] = []) {
    self.contextID = contextID
    self.blockIds = blockIds
  }
}

extension Anytype_Rpc.Block.ListDelete.Response {
  public init(error: Anytype_Rpc.Block.ListDelete.Response.Error, event: Anytype_ResponseEvent) {
    self.error = error
    self.event = event
  }
}

extension Anytype_Rpc.Block.ListDelete.Response.Error {
  public init(code: Anytype_Rpc.Block.ListDelete.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Block.ListDuplicate.Request {
  public init(contextID: String = String(), targetID: String = String(), blockIds: [String] = [], position: Anytype_Model_Block.Position = .none) {
    self.contextID = contextID
    self.targetID = targetID
    self.blockIds = blockIds
    self.position = position
  }
}

extension Anytype_Rpc.Block.ListDuplicate.Response {
  public init(error: Anytype_Rpc.Block.ListDuplicate.Response.Error, blockIds: [String] = [], event: Anytype_ResponseEvent) {
    self.error = error
    self.blockIds = blockIds
    self.event = event
  }
}

extension Anytype_Rpc.Block.ListDuplicate.Response.Error {
  public init(code: Anytype_Rpc.Block.ListDuplicate.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Block.ListMoveToExistingObject.Request {
  public init(contextID: String = String(), blockIds: [String] = [], targetContextID: String = String(), dropTargetID: String = String(), position: Anytype_Model_Block.Position = .none) {
    self.contextID = contextID
    self.blockIds = blockIds
    self.targetContextID = targetContextID
    self.dropTargetID = dropTargetID
    self.position = position
  }
}

extension Anytype_Rpc.Block.ListMoveToExistingObject.Response {
  public init(error: Anytype_Rpc.Block.ListMoveToExistingObject.Response.Error, event: Anytype_ResponseEvent) {
    self.error = error
    self.event = event
  }
}

extension Anytype_Rpc.Block.ListMoveToExistingObject.Response.Error {
  public init(code: Anytype_Rpc.Block.ListMoveToExistingObject.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Block.ListMoveToNewObject.Request {
  public init(contextID: String = String(), blockIds: [String] = [], details: SwiftProtobuf.Google_Protobuf_Struct, dropTargetID: String = String(), position: Anytype_Model_Block.Position = .none) {
    self.contextID = contextID
    self.blockIds = blockIds
    self.details = details
    self.dropTargetID = dropTargetID
    self.position = position
  }
}

extension Anytype_Rpc.Block.ListMoveToNewObject.Response {
  public init(error: Anytype_Rpc.Block.ListMoveToNewObject.Response.Error, linkID: String = String(), event: Anytype_ResponseEvent) {
    self.error = error
    self.linkID = linkID
    self.event = event
  }
}

extension Anytype_Rpc.Block.ListMoveToNewObject.Response.Error {
  public init(code: Anytype_Rpc.Block.ListMoveToNewObject.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Block.ListSetAlign.Request {
  public init(contextID: String = String(), blockIds: [String] = [], align: Anytype_Model_Block.Align = .left) {
    self.contextID = contextID
    self.blockIds = blockIds
    self.align = align
  }
}

extension Anytype_Rpc.Block.ListSetAlign.Response {
  public init(error: Anytype_Rpc.Block.ListSetAlign.Response.Error, event: Anytype_ResponseEvent) {
    self.error = error
    self.event = event
  }
}

extension Anytype_Rpc.Block.ListSetAlign.Response.Error {
  public init(code: Anytype_Rpc.Block.ListSetAlign.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Block.ListSetBackgroundColor.Request {
  public init(contextID: String = String(), blockIds: [String] = [], color: String = String()) {
    self.contextID = contextID
    self.blockIds = blockIds
    self.color = color
  }
}

extension Anytype_Rpc.Block.ListSetBackgroundColor.Response {
  public init(error: Anytype_Rpc.Block.ListSetBackgroundColor.Response.Error, event: Anytype_ResponseEvent) {
    self.error = error
    self.event = event
  }
}

extension Anytype_Rpc.Block.ListSetBackgroundColor.Response.Error {
  public init(code: Anytype_Rpc.Block.ListSetBackgroundColor.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Block.ListSetFields.Request {
  public init(contextID: String = String(), blockFields: [Anytype_Rpc.Block.ListSetFields.Request.BlockField] = []) {
    self.contextID = contextID
    self.blockFields = blockFields
  }
}

extension Anytype_Rpc.Block.ListSetFields.Request.BlockField {
  public init(blockID: String = String(), fields: SwiftProtobuf.Google_Protobuf_Struct) {
    self.blockID = blockID
    self.fields = fields
  }
}

extension Anytype_Rpc.Block.ListSetFields.Response {
  public init(error: Anytype_Rpc.Block.ListSetFields.Response.Error, event: Anytype_ResponseEvent) {
    self.error = error
    self.event = event
  }
}

extension Anytype_Rpc.Block.ListSetFields.Response.Error {
  public init(code: Anytype_Rpc.Block.ListSetFields.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Block.ListTurnInto.Request {
  public init(contextID: String = String(), blockIds: [String] = [], style: Anytype_Model_Block.Content.Text.Style = .paragraph) {
    self.contextID = contextID
    self.blockIds = blockIds
    self.style = style
  }
}

extension Anytype_Rpc.Block.ListTurnInto.Response {
  public init(error: Anytype_Rpc.Block.ListTurnInto.Response.Error, event: Anytype_ResponseEvent) {
    self.error = error
    self.event = event
  }
}

extension Anytype_Rpc.Block.ListTurnInto.Response.Error {
  public init(code: Anytype_Rpc.Block.ListTurnInto.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Block.ListUpdate.Request {
  public init(contextID: String = String(), blockIds: [String] = [], field: Anytype_Rpc.Block.ListUpdate.Request.OneOf_Field? = nil) {
    self.contextID = contextID
    self.blockIds = blockIds
    self.field = field
  }
}

extension Anytype_Rpc.Block.ListUpdate.Request.Text {
  public init(field: Anytype_Rpc.Block.ListUpdate.Request.Text.OneOf_Field? = nil) {
    self.field = field
  }
}

extension Anytype_Rpc.Block.Merge.Request {
  public init(contextID: String = String(), firstBlockID: String = String(), secondBlockID: String = String()) {
    self.contextID = contextID
    self.firstBlockID = firstBlockID
    self.secondBlockID = secondBlockID
  }
}

extension Anytype_Rpc.Block.Merge.Response {
  public init(error: Anytype_Rpc.Block.Merge.Response.Error, event: Anytype_ResponseEvent) {
    self.error = error
    self.event = event
  }
}

extension Anytype_Rpc.Block.Merge.Response.Error {
  public init(code: Anytype_Rpc.Block.Merge.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Block.Paste.Request {
  public init(
    contextID: String = String(), focusedBlockID: String = String(), selectedTextRange: Anytype_Model_Range, selectedBlockIds: [String] = [], isPartOfBlock: Bool = false, textSlot: String = String(),
    htmlSlot: String = String(), anySlot: [Anytype_Model_Block] = [], fileSlot: [Anytype_Rpc.Block.Paste.Request.File] = []
  ) {
    self.contextID = contextID
    self.focusedBlockID = focusedBlockID
    self.selectedTextRange = selectedTextRange
    self.selectedBlockIds = selectedBlockIds
    self.isPartOfBlock = isPartOfBlock
    self.textSlot = textSlot
    self.htmlSlot = htmlSlot
    self.anySlot = anySlot
    self.fileSlot = fileSlot
  }
}

extension Anytype_Rpc.Block.Paste.Request.File {
  public init(name: String = String(), data: Data = Data(), localPath: String = String()) {
    self.name = name
    self.data = data
    self.localPath = localPath
  }
}

extension Anytype_Rpc.Block.Paste.Response {
  public init(error: Anytype_Rpc.Block.Paste.Response.Error, blockIds: [String] = [], caretPosition: Int32 = 0, isSameBlockCaret: Bool = false, event: Anytype_ResponseEvent) {
    self.error = error
    self.blockIds = blockIds
    self.caretPosition = caretPosition
    self.isSameBlockCaret = isSameBlockCaret
    self.event = event
  }
}

extension Anytype_Rpc.Block.Paste.Response.Error {
  public init(code: Anytype_Rpc.Block.Paste.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Block.Replace.Request {
  public init(contextID: String = String(), blockID: String = String(), block: Anytype_Model_Block) {
    self.contextID = contextID
    self.blockID = blockID
    self.block = block
  }
}

extension Anytype_Rpc.Block.Replace.Response {
  public init(error: Anytype_Rpc.Block.Replace.Response.Error, blockID: String = String(), event: Anytype_ResponseEvent) {
    self.error = error
    self.blockID = blockID
    self.event = event
  }
}

extension Anytype_Rpc.Block.Replace.Response.Error {
  public init(code: Anytype_Rpc.Block.Replace.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Block.SetFields.Request {
  public init(contextID: String = String(), blockID: String = String(), fields: SwiftProtobuf.Google_Protobuf_Struct) {
    self.contextID = contextID
    self.blockID = blockID
    self.fields = fields
  }
}

extension Anytype_Rpc.Block.SetFields.Response {
  public init(error: Anytype_Rpc.Block.SetFields.Response.Error, event: Anytype_ResponseEvent) {
    self.error = error
    self.event = event
  }
}

extension Anytype_Rpc.Block.SetFields.Response.Error {
  public init(code: Anytype_Rpc.Block.SetFields.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Block.Split.Request {
  public init(
    contextID: String = String(), blockID: String = String(), range: Anytype_Model_Range, style: Anytype_Model_Block.Content.Text.Style = .paragraph,
    mode: Anytype_Rpc.Block.Split.Request.Mode = .bottom
  ) {
    self.contextID = contextID
    self.blockID = blockID
    self.range = range
    self.style = style
    self.mode = mode
  }
}

extension Anytype_Rpc.Block.Split.Response {
  public init(error: Anytype_Rpc.Block.Split.Response.Error, blockID: String = String(), event: Anytype_ResponseEvent) {
    self.error = error
    self.blockID = blockID
    self.event = event
  }
}

extension Anytype_Rpc.Block.Split.Response.Error {
  public init(code: Anytype_Rpc.Block.Split.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Block.Upload.Request {
  public init(contextID: String = String(), blockID: String = String(), filePath: String = String(), url: String = String()) {
    self.contextID = contextID
    self.blockID = blockID
    self.filePath = filePath
    self.url = url
  }
}

extension Anytype_Rpc.Block.Upload.Response {
  public init(error: Anytype_Rpc.Block.Upload.Response.Error, event: Anytype_ResponseEvent) {
    self.error = error
    self.event = event
  }
}

extension Anytype_Rpc.Block.Upload.Response.Error {
  public init(code: Anytype_Rpc.Block.Upload.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.BlockBookmark.CreateAndFetch.Request {
  public init(contextID: String = String(), targetID: String = String(), position: Anytype_Model_Block.Position = .none, url: String = String()) {
    self.contextID = contextID
    self.targetID = targetID
    self.position = position
    self.url = url
  }
}

extension Anytype_Rpc.BlockBookmark.CreateAndFetch.Response {
  public init(error: Anytype_Rpc.BlockBookmark.CreateAndFetch.Response.Error, blockID: String = String(), event: Anytype_ResponseEvent) {
    self.error = error
    self.blockID = blockID
    self.event = event
  }
}

extension Anytype_Rpc.BlockBookmark.CreateAndFetch.Response.Error {
  public init(code: Anytype_Rpc.BlockBookmark.CreateAndFetch.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.BlockBookmark.Fetch.Request {
  public init(contextID: String = String(), blockID: String = String(), url: String = String()) {
    self.contextID = contextID
    self.blockID = blockID
    self.url = url
  }
}

extension Anytype_Rpc.BlockBookmark.Fetch.Response {
  public init(error: Anytype_Rpc.BlockBookmark.Fetch.Response.Error, event: Anytype_ResponseEvent) {
    self.error = error
    self.event = event
  }
}

extension Anytype_Rpc.BlockBookmark.Fetch.Response.Error {
  public init(code: Anytype_Rpc.BlockBookmark.Fetch.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.BlockDataview.CreateBookmark.Request {
  public init(contextID: String = String(), blockID: String = String(), url: String = String()) {
    self.contextID = contextID
    self.blockID = blockID
    self.url = url
  }
}

extension Anytype_Rpc.BlockDataview.CreateBookmark.Response {
  public init(error: Anytype_Rpc.BlockDataview.CreateBookmark.Response.Error, id: String = String()) {
    self.error = error
    self.id = id
  }
}

extension Anytype_Rpc.BlockDataview.CreateBookmark.Response.Error {
  public init(code: Anytype_Rpc.BlockDataview.CreateBookmark.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.BlockDataview.Relation.Add.Request {
  public init(contextID: String, blockID: String, relation: Anytype_Model_Relation) {
    self.contextID = contextID
    self.blockID = blockID
    self.relation = relation
  }
}

extension Anytype_Rpc.BlockDataview.Relation.Add.Response {
  public init(error: Anytype_Rpc.BlockDataview.Relation.Add.Response.Error, event: Anytype_ResponseEvent, relationKey: String, relation: Anytype_Model_Relation) {
    self.error = error
    self.event = event
    self.relationKey = relationKey
    self.relation = relation
  }
}

extension Anytype_Rpc.BlockDataview.Relation.Add.Response.Error {
  public init(code: Anytype_Rpc.BlockDataview.Relation.Add.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.BlockDataview.Relation.Delete.Request {
  public init(contextID: String = String(), blockID: String = String(), relationKey: String = String()) {
    self.contextID = contextID
    self.blockID = blockID
    self.relationKey = relationKey
  }
}

extension Anytype_Rpc.BlockDataview.Relation.Delete.Response {
  public init(error: Anytype_Rpc.BlockDataview.Relation.Delete.Response.Error, event: Anytype_ResponseEvent) {
    self.error = error
    self.event = event
  }
}

extension Anytype_Rpc.BlockDataview.Relation.Delete.Response.Error {
  public init(code: Anytype_Rpc.BlockDataview.Relation.Delete.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.BlockDataview.Relation.ListAvailable.Request {
  public init(contextID: String = String(), blockID: String = String()) {
    self.contextID = contextID
    self.blockID = blockID
  }
}

extension Anytype_Rpc.BlockDataview.Relation.ListAvailable.Response {
  public init(error: Anytype_Rpc.BlockDataview.Relation.ListAvailable.Response.Error, relations: [Anytype_Model_Relation] = []) {
    self.error = error
    self.relations = relations
  }
}

extension Anytype_Rpc.BlockDataview.Relation.ListAvailable.Response.Error {
  public init(code: Anytype_Rpc.BlockDataview.Relation.ListAvailable.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.BlockDataview.Relation.Update.Request {
  public init(contextID: String, blockID: String, relationKey: String, relation: Anytype_Model_Relation) {
    self.contextID = contextID
    self.blockID = blockID
    self.relationKey = relationKey
    self.relation = relation
  }
}

extension Anytype_Rpc.BlockDataview.Relation.Update.Response {
  public init(error: Anytype_Rpc.BlockDataview.Relation.Update.Response.Error, event: Anytype_ResponseEvent) {
    self.error = error
    self.event = event
  }
}

extension Anytype_Rpc.BlockDataview.Relation.Update.Response.Error {
  public init(code: Anytype_Rpc.BlockDataview.Relation.Update.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.BlockDataview.SetSource.Request {
  public init(contextID: String = String(), blockID: String = String(), source: [String] = []) {
    self.contextID = contextID
    self.blockID = blockID
    self.source = source
  }
}

extension Anytype_Rpc.BlockDataview.SetSource.Response {
  public init(error: Anytype_Rpc.BlockDataview.SetSource.Response.Error, event: Anytype_ResponseEvent) {
    self.error = error
    self.event = event
  }
}

extension Anytype_Rpc.BlockDataview.SetSource.Response.Error {
  public init(code: Anytype_Rpc.BlockDataview.SetSource.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.BlockDataview.View.Create.Request {
  public init(contextID: String = String(), blockID: String = String(), view: Anytype_Model_Block.Content.Dataview.View) {
    self.contextID = contextID
    self.blockID = blockID
    self.view = view
  }
}

extension Anytype_Rpc.BlockDataview.View.Create.Response {
  public init(error: Anytype_Rpc.BlockDataview.View.Create.Response.Error, event: Anytype_ResponseEvent, viewID: String = String()) {
    self.error = error
    self.event = event
    self.viewID = viewID
  }
}

extension Anytype_Rpc.BlockDataview.View.Create.Response.Error {
  public init(code: Anytype_Rpc.BlockDataview.View.Create.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.BlockDataview.View.Delete.Request {
  public init(contextID: String = String(), blockID: String = String(), viewID: String = String()) {
    self.contextID = contextID
    self.blockID = blockID
    self.viewID = viewID
  }
}

extension Anytype_Rpc.BlockDataview.View.Delete.Response {
  public init(error: Anytype_Rpc.BlockDataview.View.Delete.Response.Error, event: Anytype_ResponseEvent) {
    self.error = error
    self.event = event
  }
}

extension Anytype_Rpc.BlockDataview.View.Delete.Response.Error {
  public init(code: Anytype_Rpc.BlockDataview.View.Delete.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.BlockDataview.View.SetActive.Request {
  public init(contextID: String = String(), blockID: String = String(), viewID: String = String(), offset: UInt32 = 0, limit: UInt32 = 0) {
    self.contextID = contextID
    self.blockID = blockID
    self.viewID = viewID
    self.offset = offset
    self.limit = limit
  }
}

extension Anytype_Rpc.BlockDataview.View.SetActive.Response {
  public init(error: Anytype_Rpc.BlockDataview.View.SetActive.Response.Error, event: Anytype_ResponseEvent) {
    self.error = error
    self.event = event
  }
}

extension Anytype_Rpc.BlockDataview.View.SetActive.Response.Error {
  public init(code: Anytype_Rpc.BlockDataview.View.SetActive.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.BlockDataview.View.SetPosition.Request {
  public init(contextID: String = String(), blockID: String = String(), viewID: String = String(), position: UInt32 = 0) {
    self.contextID = contextID
    self.blockID = blockID
    self.viewID = viewID
    self.position = position
  }
}

extension Anytype_Rpc.BlockDataview.View.SetPosition.Response {
  public init(error: Anytype_Rpc.BlockDataview.View.SetPosition.Response.Error, event: Anytype_ResponseEvent) {
    self.error = error
    self.event = event
  }
}

extension Anytype_Rpc.BlockDataview.View.SetPosition.Response.Error {
  public init(code: Anytype_Rpc.BlockDataview.View.SetPosition.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.BlockDataview.View.Update.Request {
  public init(contextID: String = String(), blockID: String = String(), viewID: String = String(), view: Anytype_Model_Block.Content.Dataview.View) {
    self.contextID = contextID
    self.blockID = blockID
    self.viewID = viewID
    self.view = view
  }
}

extension Anytype_Rpc.BlockDataview.View.Update.Response {
  public init(error: Anytype_Rpc.BlockDataview.View.Update.Response.Error, event: Anytype_ResponseEvent) {
    self.error = error
    self.event = event
  }
}

extension Anytype_Rpc.BlockDataview.View.Update.Response.Error {
  public init(code: Anytype_Rpc.BlockDataview.View.Update.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.BlockDataviewRecord.Create.Request {
  public init(contextID: String = String(), blockID: String = String(), record: SwiftProtobuf.Google_Protobuf_Struct, templateID: String = String()) {
    self.contextID = contextID
    self.blockID = blockID
    self.record = record
    self.templateID = templateID
  }
}

extension Anytype_Rpc.BlockDataviewRecord.Create.Response {
  public init(error: Anytype_Rpc.BlockDataviewRecord.Create.Response.Error, record: SwiftProtobuf.Google_Protobuf_Struct) {
    self.error = error
    self.record = record
  }
}

extension Anytype_Rpc.BlockDataviewRecord.Create.Response.Error {
  public init(code: Anytype_Rpc.BlockDataviewRecord.Create.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.BlockDataviewRecord.Delete.Request {
  public init(contextID: String = String(), blockID: String = String(), recordID: String = String()) {
    self.contextID = contextID
    self.blockID = blockID
    self.recordID = recordID
  }
}

extension Anytype_Rpc.BlockDataviewRecord.Delete.Response {
  public init(error: Anytype_Rpc.BlockDataviewRecord.Delete.Response.Error, event: Anytype_ResponseEvent) {
    self.error = error
    self.event = event
  }
}

extension Anytype_Rpc.BlockDataviewRecord.Delete.Response.Error {
  public init(code: Anytype_Rpc.BlockDataviewRecord.Delete.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.BlockDataviewRecord.RelationOption.Add.Request {
  public init(contextID: String = String(), blockID: String = String(), relationKey: String = String(), option: Anytype_Model_Relation.Option, recordID: String = String()) {
    self.contextID = contextID
    self.blockID = blockID
    self.relationKey = relationKey
    self.option = option
    self.recordID = recordID
  }
}

extension Anytype_Rpc.BlockDataviewRecord.RelationOption.Add.Response {
  public init(error: Anytype_Rpc.BlockDataviewRecord.RelationOption.Add.Response.Error, event: Anytype_ResponseEvent, option: Anytype_Model_Relation.Option) {
    self.error = error
    self.event = event
    self.option = option
  }
}

extension Anytype_Rpc.BlockDataviewRecord.RelationOption.Add.Response.Error {
  public init(code: Anytype_Rpc.BlockDataviewRecord.RelationOption.Add.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.BlockDataviewRecord.RelationOption.Delete.Request {
  public init(contextID: String = String(), blockID: String = String(), relationKey: String = String(), optionID: String = String(), recordID: String = String()) {
    self.contextID = contextID
    self.blockID = blockID
    self.relationKey = relationKey
    self.optionID = optionID
    self.recordID = recordID
  }
}

extension Anytype_Rpc.BlockDataviewRecord.RelationOption.Delete.Response {
  public init(error: Anytype_Rpc.BlockDataviewRecord.RelationOption.Delete.Response.Error, event: Anytype_ResponseEvent) {
    self.error = error
    self.event = event
  }
}

extension Anytype_Rpc.BlockDataviewRecord.RelationOption.Delete.Response.Error {
  public init(code: Anytype_Rpc.BlockDataviewRecord.RelationOption.Delete.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.BlockDataviewRecord.RelationOption.Update.Request {
  public init(contextID: String = String(), blockID: String = String(), relationKey: String = String(), option: Anytype_Model_Relation.Option, recordID: String = String()) {
    self.contextID = contextID
    self.blockID = blockID
    self.relationKey = relationKey
    self.option = option
    self.recordID = recordID
  }
}

extension Anytype_Rpc.BlockDataviewRecord.RelationOption.Update.Response {
  public init(error: Anytype_Rpc.BlockDataviewRecord.RelationOption.Update.Response.Error, event: Anytype_ResponseEvent) {
    self.error = error
    self.event = event
  }
}

extension Anytype_Rpc.BlockDataviewRecord.RelationOption.Update.Response.Error {
  public init(code: Anytype_Rpc.BlockDataviewRecord.RelationOption.Update.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.BlockDataviewRecord.Update.Request {
  public init(contextID: String = String(), blockID: String = String(), recordID: String = String(), record: SwiftProtobuf.Google_Protobuf_Struct) {
    self.contextID = contextID
    self.blockID = blockID
    self.recordID = recordID
    self.record = record
  }
}

extension Anytype_Rpc.BlockDataviewRecord.Update.Response {
  public init(error: Anytype_Rpc.BlockDataviewRecord.Update.Response.Error) {
    self.error = error
  }
}

extension Anytype_Rpc.BlockDataviewRecord.Update.Response.Error {
  public init(code: Anytype_Rpc.BlockDataviewRecord.Update.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.BlockDiv.ListSetStyle.Request {
  public init(contextID: String = String(), blockIds: [String] = [], style: Anytype_Model_Block.Content.Div.Style = .line) {
    self.contextID = contextID
    self.blockIds = blockIds
    self.style = style
  }
}

extension Anytype_Rpc.BlockDiv.ListSetStyle.Response {
  public init(error: Anytype_Rpc.BlockDiv.ListSetStyle.Response.Error, event: Anytype_ResponseEvent) {
    self.error = error
    self.event = event
  }
}

extension Anytype_Rpc.BlockDiv.ListSetStyle.Response.Error {
  public init(code: Anytype_Rpc.BlockDiv.ListSetStyle.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.BlockFile.CreateAndUpload.Request {
  public init(
    contextID: String = String(), targetID: String = String(), position: Anytype_Model_Block.Position = .none, url: String = String(), localPath: String = String(),
    fileType: Anytype_Model_Block.Content.File.TypeEnum = .none
  ) {
    self.contextID = contextID
    self.targetID = targetID
    self.position = position
    self.url = url
    self.localPath = localPath
    self.fileType = fileType
  }
}

extension Anytype_Rpc.BlockFile.CreateAndUpload.Response {
  public init(error: Anytype_Rpc.BlockFile.CreateAndUpload.Response.Error, blockID: String = String(), event: Anytype_ResponseEvent) {
    self.error = error
    self.blockID = blockID
    self.event = event
  }
}

extension Anytype_Rpc.BlockFile.CreateAndUpload.Response.Error {
  public init(code: Anytype_Rpc.BlockFile.CreateAndUpload.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.BlockFile.ListSetStyle.Request {
  public init(contextID: String = String(), blockIds: [String] = [], style: Anytype_Model_Block.Content.File.Style = .auto) {
    self.contextID = contextID
    self.blockIds = blockIds
    self.style = style
  }
}

extension Anytype_Rpc.BlockFile.ListSetStyle.Response {
  public init(error: Anytype_Rpc.BlockFile.ListSetStyle.Response.Error, event: Anytype_ResponseEvent) {
    self.error = error
    self.event = event
  }
}

extension Anytype_Rpc.BlockFile.ListSetStyle.Response.Error {
  public init(code: Anytype_Rpc.BlockFile.ListSetStyle.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.BlockFile.SetName.Request {
  public init(contextID: String = String(), blockID: String = String(), name: String = String()) {
    self.contextID = contextID
    self.blockID = blockID
    self.name = name
  }
}

extension Anytype_Rpc.BlockFile.SetName.Response {
  public init(error: Anytype_Rpc.BlockFile.SetName.Response.Error, event: Anytype_ResponseEvent) {
    self.error = error
    self.event = event
  }
}

extension Anytype_Rpc.BlockFile.SetName.Response.Error {
  public init(code: Anytype_Rpc.BlockFile.SetName.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.BlockImage.SetName.Request {
  public init(contextID: String = String(), blockID: String = String(), name: String = String()) {
    self.contextID = contextID
    self.blockID = blockID
    self.name = name
  }
}

extension Anytype_Rpc.BlockImage.SetName.Response {
  public init(error: Anytype_Rpc.BlockImage.SetName.Response.Error) {
    self.error = error
  }
}

extension Anytype_Rpc.BlockImage.SetName.Response.Error {
  public init(code: Anytype_Rpc.BlockImage.SetName.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.BlockImage.SetWidth.Request {
  public init(contextID: String = String(), blockID: String = String(), width: Int32 = 0) {
    self.contextID = contextID
    self.blockID = blockID
    self.width = width
  }
}

extension Anytype_Rpc.BlockImage.SetWidth.Response {
  public init(error: Anytype_Rpc.BlockImage.SetWidth.Response.Error) {
    self.error = error
  }
}

extension Anytype_Rpc.BlockImage.SetWidth.Response.Error {
  public init(code: Anytype_Rpc.BlockImage.SetWidth.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.BlockLatex.SetText.Request {
  public init(contextID: String = String(), blockID: String = String(), text: String = String()) {
    self.contextID = contextID
    self.blockID = blockID
    self.text = text
  }
}

extension Anytype_Rpc.BlockLatex.SetText.Response {
  public init(error: Anytype_Rpc.BlockLatex.SetText.Response.Error, event: Anytype_ResponseEvent) {
    self.error = error
    self.event = event
  }
}

extension Anytype_Rpc.BlockLatex.SetText.Response.Error {
  public init(code: Anytype_Rpc.BlockLatex.SetText.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.BlockLink.CreateWithObject.Request {
  public init(
    contextID: String = String(), details: SwiftProtobuf.Google_Protobuf_Struct, templateID: String = String(), internalFlags: [Anytype_Model_InternalFlag] = [], targetID: String = String(),
    position: Anytype_Model_Block.Position = .none, fields: SwiftProtobuf.Google_Protobuf_Struct
  ) {
    self.contextID = contextID
    self.details = details
    self.templateID = templateID
    self.internalFlags = internalFlags
    self.targetID = targetID
    self.position = position
    self.fields = fields
  }
}

extension Anytype_Rpc.BlockLink.CreateWithObject.Response {
  public init(error: Anytype_Rpc.BlockLink.CreateWithObject.Response.Error, blockID: String = String(), targetID: String = String(), event: Anytype_ResponseEvent) {
    self.error = error
    self.blockID = blockID
    self.targetID = targetID
    self.event = event
  }
}

extension Anytype_Rpc.BlockLink.CreateWithObject.Response.Error {
  public init(code: Anytype_Rpc.BlockLink.CreateWithObject.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.BlockLink.ListSetAppearance.Request {
  public init(
    contextID: String = String(), blockIds: [String] = [], iconSize: Anytype_Model_Block.Content.Link.IconSize = .sizeNone, cardStyle: Anytype_Model_Block.Content.Link.CardStyle = .text,
    description_p: Anytype_Model_Block.Content.Link.Description = .none, relations: [String] = []
  ) {
    self.contextID = contextID
    self.blockIds = blockIds
    self.iconSize = iconSize
    self.cardStyle = cardStyle
    self.description_p = description_p
    self.relations = relations
  }
}

extension Anytype_Rpc.BlockLink.ListSetAppearance.Response {
  public init(error: Anytype_Rpc.BlockLink.ListSetAppearance.Response.Error, event: Anytype_ResponseEvent) {
    self.error = error
    self.event = event
  }
}

extension Anytype_Rpc.BlockLink.ListSetAppearance.Response.Error {
  public init(code: Anytype_Rpc.BlockLink.ListSetAppearance.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.BlockRelation.Add.Request {
  public init(contextID: String, blockID: String, relation: Anytype_Model_Relation) {
    self.contextID = contextID
    self.blockID = blockID
    self.relation = relation
  }
}

extension Anytype_Rpc.BlockRelation.Add.Response {
  public init(error: Anytype_Rpc.BlockRelation.Add.Response.Error, event: Anytype_ResponseEvent) {
    self.error = error
    self.event = event
  }
}

extension Anytype_Rpc.BlockRelation.Add.Response.Error {
  public init(code: Anytype_Rpc.BlockRelation.Add.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.BlockRelation.SetKey.Request {
  public init(contextID: String = String(), blockID: String = String(), key: String = String()) {
    self.contextID = contextID
    self.blockID = blockID
    self.key = key
  }
}

extension Anytype_Rpc.BlockRelation.SetKey.Response {
  public init(error: Anytype_Rpc.BlockRelation.SetKey.Response.Error, event: Anytype_ResponseEvent) {
    self.error = error
    self.event = event
  }
}

extension Anytype_Rpc.BlockRelation.SetKey.Response.Error {
  public init(code: Anytype_Rpc.BlockRelation.SetKey.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.BlockText.ListSetColor.Request {
  public init(contextID: String = String(), blockIds: [String] = [], color: String = String()) {
    self.contextID = contextID
    self.blockIds = blockIds
    self.color = color
  }
}

extension Anytype_Rpc.BlockText.ListSetColor.Response {
  public init(error: Anytype_Rpc.BlockText.ListSetColor.Response.Error, event: Anytype_ResponseEvent) {
    self.error = error
    self.event = event
  }
}

extension Anytype_Rpc.BlockText.ListSetColor.Response.Error {
  public init(code: Anytype_Rpc.BlockText.ListSetColor.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.BlockText.ListSetMark.Request {
  public init(contextID: String = String(), blockIds: [String] = [], mark: Anytype_Model_Block.Content.Text.Mark) {
    self.contextID = contextID
    self.blockIds = blockIds
    self.mark = mark
  }
}

extension Anytype_Rpc.BlockText.ListSetMark.Response {
  public init(error: Anytype_Rpc.BlockText.ListSetMark.Response.Error, event: Anytype_ResponseEvent) {
    self.error = error
    self.event = event
  }
}

extension Anytype_Rpc.BlockText.ListSetMark.Response.Error {
  public init(code: Anytype_Rpc.BlockText.ListSetMark.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.BlockText.ListSetStyle.Request {
  public init(contextID: String = String(), blockIds: [String] = [], style: Anytype_Model_Block.Content.Text.Style = .paragraph) {
    self.contextID = contextID
    self.blockIds = blockIds
    self.style = style
  }
}

extension Anytype_Rpc.BlockText.ListSetStyle.Response {
  public init(error: Anytype_Rpc.BlockText.ListSetStyle.Response.Error, event: Anytype_ResponseEvent) {
    self.error = error
    self.event = event
  }
}

extension Anytype_Rpc.BlockText.ListSetStyle.Response.Error {
  public init(code: Anytype_Rpc.BlockText.ListSetStyle.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.BlockText.SetChecked.Request {
  public init(contextID: String = String(), blockID: String = String(), checked: Bool = false) {
    self.contextID = contextID
    self.blockID = blockID
    self.checked = checked
  }
}

extension Anytype_Rpc.BlockText.SetChecked.Response {
  public init(error: Anytype_Rpc.BlockText.SetChecked.Response.Error, event: Anytype_ResponseEvent) {
    self.error = error
    self.event = event
  }
}

extension Anytype_Rpc.BlockText.SetChecked.Response.Error {
  public init(code: Anytype_Rpc.BlockText.SetChecked.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.BlockText.SetColor.Request {
  public init(contextID: String = String(), blockID: String = String(), color: String = String()) {
    self.contextID = contextID
    self.blockID = blockID
    self.color = color
  }
}

extension Anytype_Rpc.BlockText.SetColor.Response {
  public init(error: Anytype_Rpc.BlockText.SetColor.Response.Error, event: Anytype_ResponseEvent) {
    self.error = error
    self.event = event
  }
}

extension Anytype_Rpc.BlockText.SetColor.Response.Error {
  public init(code: Anytype_Rpc.BlockText.SetColor.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.BlockText.SetIcon.Request {
  public init(contextID: String = String(), blockID: String = String(), iconImage: String = String(), iconEmoji: String = String()) {
    self.contextID = contextID
    self.blockID = blockID
    self.iconImage = iconImage
    self.iconEmoji = iconEmoji
  }
}

extension Anytype_Rpc.BlockText.SetIcon.Response {
  public init(error: Anytype_Rpc.BlockText.SetIcon.Response.Error, event: Anytype_ResponseEvent) {
    self.error = error
    self.event = event
  }
}

extension Anytype_Rpc.BlockText.SetIcon.Response.Error {
  public init(code: Anytype_Rpc.BlockText.SetIcon.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.BlockText.SetMarks.Get.Request {
  public init(contextID: String = String(), blockID: String = String(), range: Anytype_Model_Range) {
    self.contextID = contextID
    self.blockID = blockID
    self.range = range
  }
}

extension Anytype_Rpc.BlockText.SetMarks.Get.Response {
  public init(error: Anytype_Rpc.BlockText.SetMarks.Get.Response.Error, event: Anytype_ResponseEvent) {
    self.error = error
    self.event = event
  }
}

extension Anytype_Rpc.BlockText.SetMarks.Get.Response.Error {
  public init(code: Anytype_Rpc.BlockText.SetMarks.Get.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.BlockText.SetStyle.Request {
  public init(contextID: String = String(), blockID: String = String(), style: Anytype_Model_Block.Content.Text.Style = .paragraph) {
    self.contextID = contextID
    self.blockID = blockID
    self.style = style
  }
}

extension Anytype_Rpc.BlockText.SetStyle.Response {
  public init(error: Anytype_Rpc.BlockText.SetStyle.Response.Error, event: Anytype_ResponseEvent) {
    self.error = error
    self.event = event
  }
}

extension Anytype_Rpc.BlockText.SetStyle.Response.Error {
  public init(code: Anytype_Rpc.BlockText.SetStyle.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.BlockText.SetText.Request {
  public init(contextID: String = String(), blockID: String = String(), text: String = String(), marks: Anytype_Model_Block.Content.Text.Marks) {
    self.contextID = contextID
    self.blockID = blockID
    self.text = text
    self.marks = marks
  }
}

extension Anytype_Rpc.BlockText.SetText.Response {
  public init(error: Anytype_Rpc.BlockText.SetText.Response.Error, event: Anytype_ResponseEvent) {
    self.error = error
    self.event = event
  }
}

extension Anytype_Rpc.BlockText.SetText.Response.Error {
  public init(code: Anytype_Rpc.BlockText.SetText.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.BlockVideo.SetName.Request {
  public init(contextID: String = String(), blockID: String = String(), name: String = String()) {
    self.contextID = contextID
    self.blockID = blockID
    self.name = name
  }
}

extension Anytype_Rpc.BlockVideo.SetName.Response {
  public init(error: Anytype_Rpc.BlockVideo.SetName.Response.Error) {
    self.error = error
  }
}

extension Anytype_Rpc.BlockVideo.SetName.Response.Error {
  public init(code: Anytype_Rpc.BlockVideo.SetName.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.BlockVideo.SetWidth.Request {
  public init(contextID: String = String(), blockID: String = String(), width: Int32 = 0) {
    self.contextID = contextID
    self.blockID = blockID
    self.width = width
  }
}

extension Anytype_Rpc.BlockVideo.SetWidth.Response {
  public init(error: Anytype_Rpc.BlockVideo.SetWidth.Response.Error) {
    self.error = error
  }
}

extension Anytype_Rpc.BlockVideo.SetWidth.Response.Error {
  public init(code: Anytype_Rpc.BlockVideo.SetWidth.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Debug.ExportLocalstore.Request {
  public init(path: String = String(), docIds: [String] = []) {
    self.path = path
    self.docIds = docIds
  }
}

extension Anytype_Rpc.Debug.ExportLocalstore.Response {
  public init(error: Anytype_Rpc.Debug.ExportLocalstore.Response.Error, path: String = String(), event: Anytype_ResponseEvent) {
    self.error = error
    self.path = path
    self.event = event
  }
}

extension Anytype_Rpc.Debug.ExportLocalstore.Response.Error {
  public init(code: Anytype_Rpc.Debug.ExportLocalstore.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Debug.Ping.Request {
  public init(index: Int32 = 0, numberOfEventsToSend: Int32 = 0) {
    self.index = index
    self.numberOfEventsToSend = numberOfEventsToSend
  }
}

extension Anytype_Rpc.Debug.Ping.Response {
  public init(error: Anytype_Rpc.Debug.Ping.Response.Error, index: Int32 = 0) {
    self.error = error
    self.index = index
  }
}

extension Anytype_Rpc.Debug.Ping.Response.Error {
  public init(code: Anytype_Rpc.Debug.Ping.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Debug.Sync.Request {
  public init(recordsTraverseLimit: Int32 = 0, skipEmptyLogs: Bool = false, tryToDownloadRemoteRecords: Bool = false) {
    self.recordsTraverseLimit = recordsTraverseLimit
    self.skipEmptyLogs = skipEmptyLogs
    self.tryToDownloadRemoteRecords = tryToDownloadRemoteRecords
  }
}

extension Anytype_Rpc.Debug.Sync.Response {
  public init(
    error: Anytype_Rpc.Debug.Sync.Response.Error, threads: [Anytype_Rpc.Debug.threadInfo] = [], deviceID: String = String(), totalThreads: Int32 = 0, threadsWithoutReplInOwnLog: Int32 = 0,
    threadsWithoutHeadDownloaded: Int32 = 0, totalRecords: Int32 = 0, totalSize: Int32 = 0
  ) {
    self.error = error
    self.threads = threads
    self.deviceID = deviceID
    self.totalThreads = totalThreads
    self.threadsWithoutReplInOwnLog = threadsWithoutReplInOwnLog
    self.threadsWithoutHeadDownloaded = threadsWithoutHeadDownloaded
    self.totalRecords = totalRecords
    self.totalSize = totalSize
  }
}

extension Anytype_Rpc.Debug.Sync.Response.Error {
  public init(code: Anytype_Rpc.Debug.Sync.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Debug.Thread.Request {
  public init(threadID: String = String(), skipEmptyLogs: Bool = false, tryToDownloadRemoteRecords: Bool = false) {
    self.threadID = threadID
    self.skipEmptyLogs = skipEmptyLogs
    self.tryToDownloadRemoteRecords = tryToDownloadRemoteRecords
  }
}

extension Anytype_Rpc.Debug.Thread.Response {
  public init(error: Anytype_Rpc.Debug.Thread.Response.Error, info: Anytype_Rpc.Debug.threadInfo) {
    self.error = error
    self.info = info
  }
}

extension Anytype_Rpc.Debug.Thread.Response.Error {
  public init(code: Anytype_Rpc.Debug.Thread.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Debug.Tree.Request {
  public init(objectID: String = String(), path: String = String(), unanonymized: Bool = false, generateSvg: Bool = false) {
    self.objectID = objectID
    self.path = path
    self.unanonymized = unanonymized
    self.generateSvg = generateSvg
  }
}

extension Anytype_Rpc.Debug.Tree.Response {
  public init(error: Anytype_Rpc.Debug.Tree.Response.Error, filename: String = String()) {
    self.error = error
    self.filename = filename
  }
}

extension Anytype_Rpc.Debug.Tree.Response.Error {
  public init(code: Anytype_Rpc.Debug.Tree.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Debug.logInfo {
  public init(
    id: String = String(), head: String = String(), headDownloaded: Bool = false, totalRecords: Int32 = 0, totalSize: Int32 = 0, firstRecordTs: Int32 = 0, firstRecordVer: Int32 = 0,
    lastRecordTs: Int32 = 0, lastRecordVer: Int32 = 0, lastPullSecAgo: Int32 = 0, upStatus: String = String(), downStatus: String = String(), error: String = String()
  ) {
    self.id = id
    self.head = head
    self.headDownloaded = headDownloaded
    self.totalRecords = totalRecords
    self.totalSize = totalSize
    self.firstRecordTs = firstRecordTs
    self.firstRecordVer = firstRecordVer
    self.lastRecordTs = lastRecordTs
    self.lastRecordVer = lastRecordVer
    self.lastPullSecAgo = lastPullSecAgo
    self.upStatus = upStatus
    self.downStatus = downStatus
    self.error = error
  }
}

extension Anytype_Rpc.Debug.threadInfo {
  public init(
    id: String = String(), logsWithDownloadedHead: Int32 = 0, logsWithWholeTreeDownloaded: Int32 = 0, logs: [Anytype_Rpc.Debug.logInfo] = [], ownLogHasCafeReplicator: Bool = false,
    cafeLastPullSecAgo: Int32 = 0, cafeUpStatus: String = String(), cafeDownStatus: String = String(), totalRecords: Int32 = 0, totalSize: Int32 = 0, error: String = String()
  ) {
    self.id = id
    self.logsWithDownloadedHead = logsWithDownloadedHead
    self.logsWithWholeTreeDownloaded = logsWithWholeTreeDownloaded
    self.logs = logs
    self.ownLogHasCafeReplicator = ownLogHasCafeReplicator
    self.cafeLastPullSecAgo = cafeLastPullSecAgo
    self.cafeUpStatus = cafeUpStatus
    self.cafeDownStatus = cafeDownStatus
    self.totalRecords = totalRecords
    self.totalSize = totalSize
    self.error = error
  }
}

extension Anytype_Rpc.File.Download.Request {
  public init(hash: String = String(), path: String = String()) {
    self.hash = hash
    self.path = path
  }
}

extension Anytype_Rpc.File.Download.Response {
  public init(error: Anytype_Rpc.File.Download.Response.Error, localPath: String = String()) {
    self.error = error
    self.localPath = localPath
  }
}

extension Anytype_Rpc.File.Download.Response.Error {
  public init(code: Anytype_Rpc.File.Download.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.File.Drop.Request {
  public init(contextID: String = String(), dropTargetID: String = String(), position: Anytype_Model_Block.Position = .none, localFilePaths: [String] = []) {
    self.contextID = contextID
    self.dropTargetID = dropTargetID
    self.position = position
    self.localFilePaths = localFilePaths
  }
}

extension Anytype_Rpc.File.Drop.Response {
  public init(error: Anytype_Rpc.File.Drop.Response.Error, event: Anytype_ResponseEvent) {
    self.error = error
    self.event = event
  }
}

extension Anytype_Rpc.File.Drop.Response.Error {
  public init(code: Anytype_Rpc.File.Drop.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.File.ListOffload.Request {
  public init(onlyIds: [String] = [], includeNotPinned: Bool = false) {
    self.onlyIds = onlyIds
    self.includeNotPinned = includeNotPinned
  }
}

extension Anytype_Rpc.File.ListOffload.Response {
  public init(error: Anytype_Rpc.File.ListOffload.Response.Error, filesOffloaded: Int32 = 0, bytesOffloaded: UInt64 = 0) {
    self.error = error
    self.filesOffloaded = filesOffloaded
    self.bytesOffloaded = bytesOffloaded
  }
}

extension Anytype_Rpc.File.ListOffload.Response.Error {
  public init(code: Anytype_Rpc.File.ListOffload.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.File.Offload.Request {
  public init(id: String = String(), includeNotPinned: Bool = false) {
    self.id = id
    self.includeNotPinned = includeNotPinned
  }
}

extension Anytype_Rpc.File.Offload.Response {
  public init(error: Anytype_Rpc.File.Offload.Response.Error, bytesOffloaded: UInt64 = 0) {
    self.error = error
    self.bytesOffloaded = bytesOffloaded
  }
}

extension Anytype_Rpc.File.Offload.Response.Error {
  public init(code: Anytype_Rpc.File.Offload.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.File.Upload.Request {
  public init(
    url: String = String(), localPath: String = String(), type: Anytype_Model_Block.Content.File.TypeEnum = .none, disableEncryption: Bool = false,
    style: Anytype_Model_Block.Content.File.Style = .auto
  ) {
    self.url = url
    self.localPath = localPath
    self.type = type
    self.disableEncryption = disableEncryption
    self.style = style
  }
}

extension Anytype_Rpc.File.Upload.Response {
  public init(error: Anytype_Rpc.File.Upload.Response.Error, hash: String = String()) {
    self.error = error
    self.hash = hash
  }
}

extension Anytype_Rpc.File.Upload.Response.Error {
  public init(code: Anytype_Rpc.File.Upload.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.GenericErrorResponse {
  public init(error: Anytype_Rpc.GenericErrorResponse.Error) {
    self.error = error
  }
}

extension Anytype_Rpc.GenericErrorResponse.Error {
  public init(code: Anytype_Rpc.GenericErrorResponse.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.History.GetVersions.Request {
  public init(pageID: String = String(), lastVersionID: String = String(), limit: Int32 = 0) {
    self.pageID = pageID
    self.lastVersionID = lastVersionID
    self.limit = limit
  }
}

extension Anytype_Rpc.History.GetVersions.Response {
  public init(error: Anytype_Rpc.History.GetVersions.Response.Error, versions: [Anytype_Rpc.History.Version] = []) {
    self.error = error
    self.versions = versions
  }
}

extension Anytype_Rpc.History.GetVersions.Response.Error {
  public init(code: Anytype_Rpc.History.GetVersions.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.History.SetVersion.Request {
  public init(pageID: String = String(), versionID: String = String()) {
    self.pageID = pageID
    self.versionID = versionID
  }
}

extension Anytype_Rpc.History.SetVersion.Response {
  public init(error: Anytype_Rpc.History.SetVersion.Response.Error) {
    self.error = error
  }
}

extension Anytype_Rpc.History.SetVersion.Response.Error {
  public init(code: Anytype_Rpc.History.SetVersion.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.History.ShowVersion.Request {
  public init(pageID: String = String(), versionID: String = String(), traceID: String = String()) {
    self.pageID = pageID
    self.versionID = versionID
    self.traceID = traceID
  }
}

extension Anytype_Rpc.History.ShowVersion.Response {
  public init(error: Anytype_Rpc.History.ShowVersion.Response.Error, objectShow: Anytype_Event.Object.Show, version: Anytype_Rpc.History.Version, traceID: String) {
    self.error = error
    self.objectShow = objectShow
    self.version = version
    self.traceID = traceID
  }
}

extension Anytype_Rpc.History.ShowVersion.Response.Error {
  public init(code: Anytype_Rpc.History.ShowVersion.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.History.Version {
  public init(id: String = String(), previousIds: [String] = [], authorID: String = String(), authorName: String = String(), time: Int64 = 0, groupID: Int64 = 0) {
    self.id = id
    self.previousIds = previousIds
    self.authorID = authorID
    self.authorName = authorName
    self.time = time
    self.groupID = groupID
  }
}

extension Anytype_Rpc.LinkPreview.Request {
  public init(url: String = String()) {
    self.url = url
  }
}

extension Anytype_Rpc.LinkPreview.Response {
  public init(error: Anytype_Rpc.LinkPreview.Response.Error, linkPreview: Anytype_Model_LinkPreview) {
    self.error = error
    self.linkPreview = linkPreview
  }
}

extension Anytype_Rpc.LinkPreview.Response.Error {
  public init(code: Anytype_Rpc.LinkPreview.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Log.Send.Request {
  public init(message: String = String(), level: Anytype_Rpc.Log.Send.Request.Level = .debug) {
    self.message = message
    self.level = level
  }
}

extension Anytype_Rpc.Log.Send.Response {
  public init(error: Anytype_Rpc.Log.Send.Response.Error) {
    self.error = error
  }
}

extension Anytype_Rpc.Log.Send.Response.Error {
  public init(code: Anytype_Rpc.Log.Send.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Metrics.SetParameters.Request {
  public init(platform: String = String()) {
    self.platform = platform
  }
}

extension Anytype_Rpc.Metrics.SetParameters.Response {
  public init(error: Anytype_Rpc.Metrics.SetParameters.Response.Error) {
    self.error = error
  }
}

extension Anytype_Rpc.Metrics.SetParameters.Response.Error {
  public init(code: Anytype_Rpc.Metrics.SetParameters.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Navigation.GetObjectInfoWithLinks.Request {
  public init(objectID: String = String(), context: Anytype_Rpc.Navigation.Context = .navigation) {
    self.objectID = objectID
    self.context = context
  }
}

extension Anytype_Rpc.Navigation.GetObjectInfoWithLinks.Response {
  public init(error: Anytype_Rpc.Navigation.GetObjectInfoWithLinks.Response.Error, object: Anytype_Model_ObjectInfoWithLinks) {
    self.error = error
    self.object = object
  }
}

extension Anytype_Rpc.Navigation.GetObjectInfoWithLinks.Response.Error {
  public init(code: Anytype_Rpc.Navigation.GetObjectInfoWithLinks.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Navigation.ListObjects.Request {
  public init(context: Anytype_Rpc.Navigation.Context = .navigation, fullText: String = String(), limit: Int32 = 0, offset: Int32 = 0) {
    self.context = context
    self.fullText = fullText
    self.limit = limit
    self.offset = offset
  }
}

extension Anytype_Rpc.Navigation.ListObjects.Response {
  public init(error: Anytype_Rpc.Navigation.ListObjects.Response.Error, objects: [Anytype_Model_ObjectInfo] = []) {
    self.error = error
    self.objects = objects
  }
}

extension Anytype_Rpc.Navigation.ListObjects.Response.Error {
  public init(code: Anytype_Rpc.Navigation.ListObjects.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Object.AddWithObjectId.Request {
  public init(objectID: String = String(), payload: String = String()) {
    self.objectID = objectID
    self.payload = payload
  }
}

extension Anytype_Rpc.Object.AddWithObjectId.Response {
  public init(error: Anytype_Rpc.Object.AddWithObjectId.Response.Error) {
    self.error = error
  }
}

extension Anytype_Rpc.Object.AddWithObjectId.Response.Error {
  public init(code: Anytype_Rpc.Object.AddWithObjectId.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Object.ApplyTemplate.Request {
  public init(contextID: String = String(), templateID: String = String()) {
    self.contextID = contextID
    self.templateID = templateID
  }
}

extension Anytype_Rpc.Object.ApplyTemplate.Response {
  public init(error: Anytype_Rpc.Object.ApplyTemplate.Response.Error) {
    self.error = error
  }
}

extension Anytype_Rpc.Object.ApplyTemplate.Response.Error {
  public init(code: Anytype_Rpc.Object.ApplyTemplate.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Object.BookmarkFetch.Request {
  public init(contextID: String = String(), url: String = String()) {
    self.contextID = contextID
    self.url = url
  }
}

extension Anytype_Rpc.Object.BookmarkFetch.Response {
  public init(error: Anytype_Rpc.Object.BookmarkFetch.Response.Error) {
    self.error = error
  }
}

extension Anytype_Rpc.Object.BookmarkFetch.Response.Error {
  public init(code: Anytype_Rpc.Object.BookmarkFetch.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Object.Close.Request {
  public init(contextID: String = String(), objectID: String = String()) {
    self.contextID = contextID
    self.objectID = objectID
  }
}

extension Anytype_Rpc.Object.Close.Response {
  public init(error: Anytype_Rpc.Object.Close.Response.Error) {
    self.error = error
  }
}

extension Anytype_Rpc.Object.Close.Response.Error {
  public init(code: Anytype_Rpc.Object.Close.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Object.Create.Request {
  public init(details: SwiftProtobuf.Google_Protobuf_Struct, internalFlags: [Anytype_Model_InternalFlag] = [], templateID: String = String()) {
    self.details = details
    self.internalFlags = internalFlags
    self.templateID = templateID
  }
}

extension Anytype_Rpc.Object.Create.Response {
  public init(error: Anytype_Rpc.Object.Create.Response.Error, pageID: String = String(), event: Anytype_ResponseEvent) {
    self.error = error
    self.pageID = pageID
    self.event = event
  }
}

extension Anytype_Rpc.Object.Create.Response.Error {
  public init(code: Anytype_Rpc.Object.Create.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Object.CreateBookmark.Request {
  public init(url: String = String()) {
    self.url = url
  }
}

extension Anytype_Rpc.Object.CreateBookmark.Response {
  public init(error: Anytype_Rpc.Object.CreateBookmark.Response.Error, pageID: String = String()) {
    self.error = error
    self.pageID = pageID
  }
}

extension Anytype_Rpc.Object.CreateBookmark.Response.Error {
  public init(code: Anytype_Rpc.Object.CreateBookmark.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Object.CreateSet.Request {
  public init(source: [String] = [], details: SwiftProtobuf.Google_Protobuf_Struct, templateID: String = String(), internalFlags: [Anytype_Model_InternalFlag] = []) {
    self.source = source
    self.details = details
    self.templateID = templateID
    self.internalFlags = internalFlags
  }
}

extension Anytype_Rpc.Object.CreateSet.Response {
  public init(error: Anytype_Rpc.Object.CreateSet.Response.Error, id: String = String(), event: Anytype_ResponseEvent) {
    self.error = error
    self.id = id
    self.event = event
  }
}

extension Anytype_Rpc.Object.CreateSet.Response.Error {
  public init(code: Anytype_Rpc.Object.CreateSet.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Object.Duplicate.Request {
  public init(contextID: String = String()) {
    self.contextID = contextID
  }
}

extension Anytype_Rpc.Object.Duplicate.Response {
  public init(error: Anytype_Rpc.Object.Duplicate.Response.Error, id: String = String()) {
    self.error = error
    self.id = id
  }
}

extension Anytype_Rpc.Object.Duplicate.Response.Error {
  public init(code: Anytype_Rpc.Object.Duplicate.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Object.Graph.Edge {
  public init(
    source: String = String(), target: String = String(), name: String = String(), type: Anytype_Rpc.Object.Graph.Edge.TypeEnum = .link, description_p: String = String(), iconImage: String = String(),
    iconEmoji: String = String(), hidden: Bool = false
  ) {
    self.source = source
    self.target = target
    self.name = name
    self.type = type
    self.description_p = description_p
    self.iconImage = iconImage
    self.iconEmoji = iconEmoji
    self.hidden = hidden
  }
}

extension Anytype_Rpc.Object.Graph.Request {
  public init(filters: [Anytype_Model_Block.Content.Dataview.Filter] = [], limit: Int32 = 0, objectTypeFilter: [String] = [], keys: [String] = []) {
    self.filters = filters
    self.limit = limit
    self.objectTypeFilter = objectTypeFilter
    self.keys = keys
  }
}

extension Anytype_Rpc.Object.Graph.Response {
  public init(error: Anytype_Rpc.Object.Graph.Response.Error, nodes: [SwiftProtobuf.Google_Protobuf_Struct] = [], edges: [Anytype_Rpc.Object.Graph.Edge] = []) {
    self.error = error
    self.nodes = nodes
    self.edges = edges
  }
}

extension Anytype_Rpc.Object.Graph.Response.Error {
  public init(code: Anytype_Rpc.Object.Graph.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Object.ImportMarkdown.Request {
  public init(contextID: String = String(), importPath: String = String()) {
    self.contextID = contextID
    self.importPath = importPath
  }
}

extension Anytype_Rpc.Object.ImportMarkdown.Response {
  public init(error: Anytype_Rpc.Object.ImportMarkdown.Response.Error, rootLinkIds: [String] = [], event: Anytype_ResponseEvent) {
    self.error = error
    self.rootLinkIds = rootLinkIds
    self.event = event
  }
}

extension Anytype_Rpc.Object.ImportMarkdown.Response.Error {
  public init(code: Anytype_Rpc.Object.ImportMarkdown.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Object.ListDelete.Request {
  public init(objectIds: [String] = []) {
    self.objectIds = objectIds
  }
}

extension Anytype_Rpc.Object.ListDelete.Response {
  public init(error: Anytype_Rpc.Object.ListDelete.Response.Error, event: Anytype_ResponseEvent) {
    self.error = error
    self.event = event
  }
}

extension Anytype_Rpc.Object.ListDelete.Response.Error {
  public init(code: Anytype_Rpc.Object.ListDelete.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Object.ListDuplicate.Request {
  public init(objectIds: [String] = []) {
    self.objectIds = objectIds
  }
}

extension Anytype_Rpc.Object.ListDuplicate.Response {
  public init(error: Anytype_Rpc.Object.ListDuplicate.Response.Error, ids: [String] = []) {
    self.error = error
    self.ids = ids
  }
}

extension Anytype_Rpc.Object.ListDuplicate.Response.Error {
  public init(code: Anytype_Rpc.Object.ListDuplicate.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Object.ListExport.Request {
  public init(path: String = String(), objectIds: [String] = [], format: Anytype_Rpc.Object.ListExport.Format = .markdown, zip: Bool = false, includeNested: Bool = false, includeFiles: Bool = false) {
    self.path = path
    self.objectIds = objectIds
    self.format = format
    self.zip = zip
    self.includeNested = includeNested
    self.includeFiles = includeFiles
  }
}

extension Anytype_Rpc.Object.ListExport.Response {
  public init(error: Anytype_Rpc.Object.ListExport.Response.Error, path: String = String(), succeed: Int32 = 0, event: Anytype_ResponseEvent) {
    self.error = error
    self.path = path
    self.succeed = succeed
    self.event = event
  }
}

extension Anytype_Rpc.Object.ListExport.Response.Error {
  public init(code: Anytype_Rpc.Object.ListExport.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Object.ListSetIsArchived.Request {
  public init(objectIds: [String] = [], isArchived: Bool = false) {
    self.objectIds = objectIds
    self.isArchived = isArchived
  }
}

extension Anytype_Rpc.Object.ListSetIsArchived.Response {
  public init(error: Anytype_Rpc.Object.ListSetIsArchived.Response.Error) {
    self.error = error
  }
}

extension Anytype_Rpc.Object.ListSetIsArchived.Response.Error {
  public init(code: Anytype_Rpc.Object.ListSetIsArchived.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Object.ListSetIsFavorite.Request {
  public init(objectIds: [String] = [], isFavorite: Bool = false) {
    self.objectIds = objectIds
    self.isFavorite = isFavorite
  }
}

extension Anytype_Rpc.Object.ListSetIsFavorite.Response {
  public init(error: Anytype_Rpc.Object.ListSetIsFavorite.Response.Error) {
    self.error = error
  }
}

extension Anytype_Rpc.Object.ListSetIsFavorite.Response.Error {
  public init(code: Anytype_Rpc.Object.ListSetIsFavorite.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Object.Open.Request {
  public init(contextID: String = String(), objectID: String = String(), traceID: String = String()) {
    self.contextID = contextID
    self.objectID = objectID
    self.traceID = traceID
  }
}

extension Anytype_Rpc.Object.Open.Response {
  public init(error: Anytype_Rpc.Object.Open.Response.Error, event: Anytype_ResponseEvent) {
    self.error = error
    self.event = event
  }
}

extension Anytype_Rpc.Object.Open.Response.Error {
  public init(code: Anytype_Rpc.Object.Open.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Object.OpenBreadcrumbs.Request {
  public init(contextID: String = String(), traceID: String = String()) {
    self.contextID = contextID
    self.traceID = traceID
  }
}

extension Anytype_Rpc.Object.OpenBreadcrumbs.Response {
  public init(error: Anytype_Rpc.Object.OpenBreadcrumbs.Response.Error, objectID: String = String(), event: Anytype_ResponseEvent) {
    self.error = error
    self.objectID = objectID
    self.event = event
  }
}

extension Anytype_Rpc.Object.OpenBreadcrumbs.Response.Error {
  public init(code: Anytype_Rpc.Object.OpenBreadcrumbs.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Object.Redo.Request {
  public init(contextID: String = String()) {
    self.contextID = contextID
  }
}

extension Anytype_Rpc.Object.Redo.Response {
  public init(error: Anytype_Rpc.Object.Redo.Response.Error, event: Anytype_ResponseEvent, counters: Anytype_Rpc.Object.UndoRedoCounter) {
    self.error = error
    self.event = event
    self.counters = counters
  }
}

extension Anytype_Rpc.Object.Redo.Response.Error {
  public init(code: Anytype_Rpc.Object.Redo.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Object.Search.Request {
  public init(
    filters: [Anytype_Model_Block.Content.Dataview.Filter] = [], sorts: [Anytype_Model_Block.Content.Dataview.Sort] = [], fullText: String = String(), offset: Int32 = 0, limit: Int32 = 0,
    objectTypeFilter: [String] = [], keys: [String] = []
  ) {
    self.filters = filters
    self.sorts = sorts
    self.fullText = fullText
    self.offset = offset
    self.limit = limit
    self.objectTypeFilter = objectTypeFilter
    self.keys = keys
  }
}

extension Anytype_Rpc.Object.Search.Response {
  public init(error: Anytype_Rpc.Object.Search.Response.Error, records: [SwiftProtobuf.Google_Protobuf_Struct] = []) {
    self.error = error
    self.records = records
  }
}

extension Anytype_Rpc.Object.Search.Response.Error {
  public init(code: Anytype_Rpc.Object.Search.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Object.SearchSubscribe.Request {
  public init(
    subID: String = String(), filters: [Anytype_Model_Block.Content.Dataview.Filter] = [], sorts: [Anytype_Model_Block.Content.Dataview.Sort] = [], limit: Int64 = 0, offset: Int64 = 0,
    keys: [String] = [], afterID: String = String(), beforeID: String = String(), source: [String] = [], ignoreWorkspace: String = String(), noDepSubscription: Bool = false
  ) {
    self.subID = subID
    self.filters = filters
    self.sorts = sorts
    self.limit = limit
    self.offset = offset
    self.keys = keys
    self.afterID = afterID
    self.beforeID = beforeID
    self.source = source
    self.ignoreWorkspace = ignoreWorkspace
    self.noDepSubscription = noDepSubscription
  }
}

extension Anytype_Rpc.Object.SearchSubscribe.Response {
  public init(
    error: Anytype_Rpc.Object.SearchSubscribe.Response.Error, records: [SwiftProtobuf.Google_Protobuf_Struct] = [], dependencies: [SwiftProtobuf.Google_Protobuf_Struct] = [], subID: String = String(),
    counters: Anytype_Event.Object.Subscription.Counters
  ) {
    self.error = error
    self.records = records
    self.dependencies = dependencies
    self.subID = subID
    self.counters = counters
  }
}

extension Anytype_Rpc.Object.SearchSubscribe.Response.Error {
  public init(code: Anytype_Rpc.Object.SearchSubscribe.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Object.SearchUnsubscribe.Request {
  public init(subIds: [String] = []) {
    self.subIds = subIds
  }
}

extension Anytype_Rpc.Object.SearchUnsubscribe.Response {
  public init(error: Anytype_Rpc.Object.SearchUnsubscribe.Response.Error) {
    self.error = error
  }
}

extension Anytype_Rpc.Object.SearchUnsubscribe.Response.Error {
  public init(code: Anytype_Rpc.Object.SearchUnsubscribe.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Object.SetBreadcrumbs.Request {
  public init(breadcrumbsID: String = String(), ids: [String] = []) {
    self.breadcrumbsID = breadcrumbsID
    self.ids = ids
  }
}

extension Anytype_Rpc.Object.SetBreadcrumbs.Response {
  public init(error: Anytype_Rpc.Object.SetBreadcrumbs.Response.Error, event: Anytype_ResponseEvent) {
    self.error = error
    self.event = event
  }
}

extension Anytype_Rpc.Object.SetBreadcrumbs.Response.Error {
  public init(code: Anytype_Rpc.Object.SetBreadcrumbs.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Object.SetDetails.Detail {
  public init(key: String = String(), value: SwiftProtobuf.Google_Protobuf_Value) {
    self.key = key
    self.value = value
  }
}

extension Anytype_Rpc.Object.SetDetails.Request {
  public init(contextID: String = String(), details: [Anytype_Rpc.Object.SetDetails.Detail] = []) {
    self.contextID = contextID
    self.details = details
  }
}

extension Anytype_Rpc.Object.SetDetails.Response {
  public init(error: Anytype_Rpc.Object.SetDetails.Response.Error, event: Anytype_ResponseEvent) {
    self.error = error
    self.event = event
  }
}

extension Anytype_Rpc.Object.SetDetails.Response.Error {
  public init(code: Anytype_Rpc.Object.SetDetails.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Object.SetIsArchived.Request {
  public init(contextID: String = String(), isArchived: Bool = false) {
    self.contextID = contextID
    self.isArchived = isArchived
  }
}

extension Anytype_Rpc.Object.SetIsArchived.Response {
  public init(error: Anytype_Rpc.Object.SetIsArchived.Response.Error, event: Anytype_ResponseEvent) {
    self.error = error
    self.event = event
  }
}

extension Anytype_Rpc.Object.SetIsArchived.Response.Error {
  public init(code: Anytype_Rpc.Object.SetIsArchived.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Object.SetIsFavorite.Request {
  public init(contextID: String = String(), isFavorite: Bool = false) {
    self.contextID = contextID
    self.isFavorite = isFavorite
  }
}

extension Anytype_Rpc.Object.SetIsFavorite.Response {
  public init(error: Anytype_Rpc.Object.SetIsFavorite.Response.Error, event: Anytype_ResponseEvent) {
    self.error = error
    self.event = event
  }
}

extension Anytype_Rpc.Object.SetIsFavorite.Response.Error {
  public init(code: Anytype_Rpc.Object.SetIsFavorite.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Object.SetLayout.Request {
  public init(contextID: String = String(), layout: Anytype_Model_ObjectType.Layout = .basic) {
    self.contextID = contextID
    self.layout = layout
  }
}

extension Anytype_Rpc.Object.SetLayout.Response {
  public init(error: Anytype_Rpc.Object.SetLayout.Response.Error, event: Anytype_ResponseEvent) {
    self.error = error
    self.event = event
  }
}

extension Anytype_Rpc.Object.SetLayout.Response.Error {
  public init(code: Anytype_Rpc.Object.SetLayout.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Object.SetObjectType.Request {
  public init(contextID: String = String(), objectTypeURL: String = String()) {
    self.contextID = contextID
    self.objectTypeURL = objectTypeURL
  }
}

extension Anytype_Rpc.Object.SetObjectType.Response {
  public init(error: Anytype_Rpc.Object.SetObjectType.Response.Error, event: Anytype_ResponseEvent) {
    self.error = error
    self.event = event
  }
}

extension Anytype_Rpc.Object.SetObjectType.Response.Error {
  public init(code: Anytype_Rpc.Object.SetObjectType.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Object.ShareByLink.Request {
  public init(objectID: String = String()) {
    self.objectID = objectID
  }
}

extension Anytype_Rpc.Object.ShareByLink.Response {
  public init(link: String = String(), error: Anytype_Rpc.Object.ShareByLink.Response.Error) {
    self.link = link
    self.error = error
  }
}

extension Anytype_Rpc.Object.ShareByLink.Response.Error {
  public init(code: Anytype_Rpc.Object.ShareByLink.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Object.Show.Request {
  public init(contextID: String = String(), objectID: String = String(), traceID: String = String()) {
    self.contextID = contextID
    self.objectID = objectID
    self.traceID = traceID
  }
}

extension Anytype_Rpc.Object.Show.Response {
  public init(error: Anytype_Rpc.Object.Show.Response.Error, event: Anytype_ResponseEvent) {
    self.error = error
    self.event = event
  }
}

extension Anytype_Rpc.Object.Show.Response.Error {
  public init(code: Anytype_Rpc.Object.Show.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Object.SubscribeIds.Request {
  public init(subID: String = String(), ids: [String] = [], keys: [String] = [], ignoreWorkspace: String = String()) {
    self.subID = subID
    self.ids = ids
    self.keys = keys
    self.ignoreWorkspace = ignoreWorkspace
  }
}

extension Anytype_Rpc.Object.SubscribeIds.Response {
  public init(
    error: Anytype_Rpc.Object.SubscribeIds.Response.Error, records: [SwiftProtobuf.Google_Protobuf_Struct] = [], dependencies: [SwiftProtobuf.Google_Protobuf_Struct] = [], subID: String = String()
  ) {
    self.error = error
    self.records = records
    self.dependencies = dependencies
    self.subID = subID
  }
}

extension Anytype_Rpc.Object.SubscribeIds.Response.Error {
  public init(code: Anytype_Rpc.Object.SubscribeIds.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Object.ToBookmark.Request {
  public init(contextID: String = String(), url: String = String()) {
    self.contextID = contextID
    self.url = url
  }
}

extension Anytype_Rpc.Object.ToBookmark.Response {
  public init(error: Anytype_Rpc.Object.ToBookmark.Response.Error, objectID: String = String()) {
    self.error = error
    self.objectID = objectID
  }
}

extension Anytype_Rpc.Object.ToBookmark.Response.Error {
  public init(code: Anytype_Rpc.Object.ToBookmark.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Object.ToSet.Request {
  public init(contextID: String = String(), source: [String] = []) {
    self.contextID = contextID
    self.source = source
  }
}

extension Anytype_Rpc.Object.ToSet.Response {
  public init(error: Anytype_Rpc.Object.ToSet.Response.Error, setID: String = String()) {
    self.error = error
    self.setID = setID
  }
}

extension Anytype_Rpc.Object.ToSet.Response.Error {
  public init(code: Anytype_Rpc.Object.ToSet.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Object.Undo.Request {
  public init(contextID: String = String()) {
    self.contextID = contextID
  }
}

extension Anytype_Rpc.Object.Undo.Response {
  public init(error: Anytype_Rpc.Object.Undo.Response.Error, event: Anytype_ResponseEvent, counters: Anytype_Rpc.Object.UndoRedoCounter) {
    self.error = error
    self.event = event
    self.counters = counters
  }
}

extension Anytype_Rpc.Object.Undo.Response.Error {
  public init(code: Anytype_Rpc.Object.Undo.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Object.UndoRedoCounter {
  public init(undo: Int32 = 0, redo: Int32 = 0) {
    self.undo = undo
    self.redo = redo
  }
}

extension Anytype_Rpc.ObjectRelation.Add.Request {
  public init(contextID: String = String(), relation: Anytype_Model_Relation) {
    self.contextID = contextID
    self.relation = relation
  }
}

extension Anytype_Rpc.ObjectRelation.Add.Response {
  public init(error: Anytype_Rpc.ObjectRelation.Add.Response.Error, event: Anytype_ResponseEvent, relationKey: String, relation: Anytype_Model_Relation) {
    self.error = error
    self.event = event
    self.relationKey = relationKey
    self.relation = relation
  }
}

extension Anytype_Rpc.ObjectRelation.Add.Response.Error {
  public init(code: Anytype_Rpc.ObjectRelation.Add.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.ObjectRelation.AddFeatured.Request {
  public init(contextID: String = String(), relations: [String] = []) {
    self.contextID = contextID
    self.relations = relations
  }
}

extension Anytype_Rpc.ObjectRelation.AddFeatured.Response {
  public init(error: Anytype_Rpc.ObjectRelation.AddFeatured.Response.Error, event: Anytype_ResponseEvent) {
    self.error = error
    self.event = event
  }
}

extension Anytype_Rpc.ObjectRelation.AddFeatured.Response.Error {
  public init(code: Anytype_Rpc.ObjectRelation.AddFeatured.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.ObjectRelation.Delete.Request {
  public init(contextID: String = String(), relationKey: String = String()) {
    self.contextID = contextID
    self.relationKey = relationKey
  }
}

extension Anytype_Rpc.ObjectRelation.Delete.Response {
  public init(error: Anytype_Rpc.ObjectRelation.Delete.Response.Error, event: Anytype_ResponseEvent) {
    self.error = error
    self.event = event
  }
}

extension Anytype_Rpc.ObjectRelation.Delete.Response.Error {
  public init(code: Anytype_Rpc.ObjectRelation.Delete.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.ObjectRelation.ListAvailable.Request {
  public init(contextID: String = String()) {
    self.contextID = contextID
  }
}

extension Anytype_Rpc.ObjectRelation.ListAvailable.Response {
  public init(error: Anytype_Rpc.ObjectRelation.ListAvailable.Response.Error, relations: [Anytype_Model_Relation] = []) {
    self.error = error
    self.relations = relations
  }
}

extension Anytype_Rpc.ObjectRelation.ListAvailable.Response.Error {
  public init(code: Anytype_Rpc.ObjectRelation.ListAvailable.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.ObjectRelation.RemoveFeatured.Request {
  public init(contextID: String = String(), relations: [String] = []) {
    self.contextID = contextID
    self.relations = relations
  }
}

extension Anytype_Rpc.ObjectRelation.RemoveFeatured.Response {
  public init(error: Anytype_Rpc.ObjectRelation.RemoveFeatured.Response.Error, event: Anytype_ResponseEvent) {
    self.error = error
    self.event = event
  }
}

extension Anytype_Rpc.ObjectRelation.RemoveFeatured.Response.Error {
  public init(code: Anytype_Rpc.ObjectRelation.RemoveFeatured.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.ObjectRelation.Update.Request {
  public init(contextID: String, relationKey: String, relation: Anytype_Model_Relation) {
    self.contextID = contextID
    self.relationKey = relationKey
    self.relation = relation
  }
}

extension Anytype_Rpc.ObjectRelation.Update.Response {
  public init(error: Anytype_Rpc.ObjectRelation.Update.Response.Error, event: Anytype_ResponseEvent) {
    self.error = error
    self.event = event
  }
}

extension Anytype_Rpc.ObjectRelation.Update.Response.Error {
  public init(code: Anytype_Rpc.ObjectRelation.Update.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.ObjectRelationOption.Add.Request {
  public init(contextID: String = String(), relationKey: String = String(), option: Anytype_Model_Relation.Option) {
    self.contextID = contextID
    self.relationKey = relationKey
    self.option = option
  }
}

extension Anytype_Rpc.ObjectRelationOption.Add.Response {
  public init(error: Anytype_Rpc.ObjectRelationOption.Add.Response.Error, event: Anytype_ResponseEvent, option: Anytype_Model_Relation.Option) {
    self.error = error
    self.event = event
    self.option = option
  }
}

extension Anytype_Rpc.ObjectRelationOption.Add.Response.Error {
  public init(code: Anytype_Rpc.ObjectRelationOption.Add.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.ObjectRelationOption.Delete.Request {
  public init(contextID: String = String(), relationKey: String = String(), optionID: String = String(), confirmRemoveAllValuesInRecords: Bool = false) {
    self.contextID = contextID
    self.relationKey = relationKey
    self.optionID = optionID
    self.confirmRemoveAllValuesInRecords = confirmRemoveAllValuesInRecords
  }
}

extension Anytype_Rpc.ObjectRelationOption.Delete.Response {
  public init(error: Anytype_Rpc.ObjectRelationOption.Delete.Response.Error, event: Anytype_ResponseEvent) {
    self.error = error
    self.event = event
  }
}

extension Anytype_Rpc.ObjectRelationOption.Delete.Response.Error {
  public init(code: Anytype_Rpc.ObjectRelationOption.Delete.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.ObjectRelationOption.Update.Request {
  public init(contextID: String = String(), relationKey: String = String(), option: Anytype_Model_Relation.Option) {
    self.contextID = contextID
    self.relationKey = relationKey
    self.option = option
  }
}

extension Anytype_Rpc.ObjectRelationOption.Update.Response {
  public init(error: Anytype_Rpc.ObjectRelationOption.Update.Response.Error, event: Anytype_ResponseEvent) {
    self.error = error
    self.event = event
  }
}

extension Anytype_Rpc.ObjectRelationOption.Update.Response.Error {
  public init(code: Anytype_Rpc.ObjectRelationOption.Update.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.ObjectType.Create.Request {
  public init(objectType: Anytype_Model_ObjectType) {
    self.objectType = objectType
  }
}

extension Anytype_Rpc.ObjectType.Create.Response {
  public init(error: Anytype_Rpc.ObjectType.Create.Response.Error, objectType: Anytype_Model_ObjectType) {
    self.error = error
    self.objectType = objectType
  }
}

extension Anytype_Rpc.ObjectType.Create.Response.Error {
  public init(code: Anytype_Rpc.ObjectType.Create.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.ObjectType.List.Response {
  public init(error: Anytype_Rpc.ObjectType.List.Response.Error, objectTypes: [Anytype_Model_ObjectType] = []) {
    self.error = error
    self.objectTypes = objectTypes
  }
}

extension Anytype_Rpc.ObjectType.List.Response.Error {
  public init(code: Anytype_Rpc.ObjectType.List.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.ObjectType.Relation.Add.Request {
  public init(objectTypeURL: String = String(), relations: [Anytype_Model_Relation] = []) {
    self.objectTypeURL = objectTypeURL
    self.relations = relations
  }
}

extension Anytype_Rpc.ObjectType.Relation.Add.Response {
  public init(error: Anytype_Rpc.ObjectType.Relation.Add.Response.Error, relations: [Anytype_Model_Relation] = []) {
    self.error = error
    self.relations = relations
  }
}

extension Anytype_Rpc.ObjectType.Relation.Add.Response.Error {
  public init(code: Anytype_Rpc.ObjectType.Relation.Add.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.ObjectType.Relation.List.Request {
  public init(objectTypeURL: String = String(), appendRelationsFromOtherTypes: Bool = false) {
    self.objectTypeURL = objectTypeURL
    self.appendRelationsFromOtherTypes = appendRelationsFromOtherTypes
  }
}

extension Anytype_Rpc.ObjectType.Relation.List.Response {
  public init(error: Anytype_Rpc.ObjectType.Relation.List.Response.Error, relations: [Anytype_Model_Relation] = []) {
    self.error = error
    self.relations = relations
  }
}

extension Anytype_Rpc.ObjectType.Relation.List.Response.Error {
  public init(code: Anytype_Rpc.ObjectType.Relation.List.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.ObjectType.Relation.Remove.Request {
  public init(objectTypeURL: String = String(), relationKey: String = String()) {
    self.objectTypeURL = objectTypeURL
    self.relationKey = relationKey
  }
}

extension Anytype_Rpc.ObjectType.Relation.Remove.Response {
  public init(error: Anytype_Rpc.ObjectType.Relation.Remove.Response.Error) {
    self.error = error
  }
}

extension Anytype_Rpc.ObjectType.Relation.Remove.Response.Error {
  public init(code: Anytype_Rpc.ObjectType.Relation.Remove.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.ObjectType.Relation.Update.Request {
  public init(objectTypeURL: String = String(), relation: Anytype_Model_Relation) {
    self.objectTypeURL = objectTypeURL
    self.relation = relation
  }
}

extension Anytype_Rpc.ObjectType.Relation.Update.Response {
  public init(error: Anytype_Rpc.ObjectType.Relation.Update.Response.Error) {
    self.error = error
  }
}

extension Anytype_Rpc.ObjectType.Relation.Update.Response.Error {
  public init(code: Anytype_Rpc.ObjectType.Relation.Update.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Process.Cancel.Request {
  public init(id: String = String()) {
    self.id = id
  }
}

extension Anytype_Rpc.Process.Cancel.Response {
  public init(error: Anytype_Rpc.Process.Cancel.Response.Error) {
    self.error = error
  }
}

extension Anytype_Rpc.Process.Cancel.Response.Error {
  public init(code: Anytype_Rpc.Process.Cancel.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Template.Clone.Request {
  public init(contextID: String = String()) {
    self.contextID = contextID
  }
}

extension Anytype_Rpc.Template.Clone.Response {
  public init(error: Anytype_Rpc.Template.Clone.Response.Error, id: String = String()) {
    self.error = error
    self.id = id
  }
}

extension Anytype_Rpc.Template.Clone.Response.Error {
  public init(code: Anytype_Rpc.Template.Clone.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Template.CreateFromObject.Request {
  public init(contextID: String = String()) {
    self.contextID = contextID
  }
}

extension Anytype_Rpc.Template.CreateFromObject.Response {
  public init(error: Anytype_Rpc.Template.CreateFromObject.Response.Error, id: String = String()) {
    self.error = error
    self.id = id
  }
}

extension Anytype_Rpc.Template.CreateFromObject.Response.Error {
  public init(code: Anytype_Rpc.Template.CreateFromObject.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Template.CreateFromObjectType.Request {
  public init(objectType: String = String()) {
    self.objectType = objectType
  }
}

extension Anytype_Rpc.Template.CreateFromObjectType.Response {
  public init(error: Anytype_Rpc.Template.CreateFromObjectType.Response.Error, id: String = String()) {
    self.error = error
    self.id = id
  }
}

extension Anytype_Rpc.Template.CreateFromObjectType.Response.Error {
  public init(code: Anytype_Rpc.Template.CreateFromObjectType.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Template.ExportAll.Request {
  public init(path: String = String()) {
    self.path = path
  }
}

extension Anytype_Rpc.Template.ExportAll.Response {
  public init(error: Anytype_Rpc.Template.ExportAll.Response.Error, path: String = String(), event: Anytype_ResponseEvent) {
    self.error = error
    self.path = path
    self.event = event
  }
}

extension Anytype_Rpc.Template.ExportAll.Response.Error {
  public init(code: Anytype_Rpc.Template.ExportAll.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Unsplash.Download.Request {
  public init(pictureID: String = String()) {
    self.pictureID = pictureID
  }
}

extension Anytype_Rpc.Unsplash.Download.Response {
  public init(error: Anytype_Rpc.Unsplash.Download.Response.Error, hash: String = String()) {
    self.error = error
    self.hash = hash
  }
}

extension Anytype_Rpc.Unsplash.Download.Response.Error {
  public init(code: Anytype_Rpc.Unsplash.Download.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Unsplash.Search.Request {
  public init(query: String = String(), limit: Int32 = 0) {
    self.query = query
    self.limit = limit
  }
}

extension Anytype_Rpc.Unsplash.Search.Response {
  public init(error: Anytype_Rpc.Unsplash.Search.Response.Error, pictures: [Anytype_Rpc.Unsplash.Search.Response.Picture] = []) {
    self.error = error
    self.pictures = pictures
  }
}

extension Anytype_Rpc.Unsplash.Search.Response.Error {
  public init(code: Anytype_Rpc.Unsplash.Search.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Unsplash.Search.Response.Picture {
  public init(id: String = String(), url: String = String(), artist: String = String(), artistURL: String = String()) {
    self.id = id
    self.url = url
    self.artist = artist
    self.artistURL = artistURL
  }
}

extension Anytype_Rpc.Wallet.Convert.Request {
  public init(mnemonic: String = String(), entropy: String = String()) {
    self.mnemonic = mnemonic
    self.entropy = entropy
  }
}

extension Anytype_Rpc.Wallet.Convert.Response {
  public init(error: Anytype_Rpc.Wallet.Convert.Response.Error, entropy: String = String(), mnemonic: String = String()) {
    self.error = error
    self.entropy = entropy
    self.mnemonic = mnemonic
  }
}

extension Anytype_Rpc.Wallet.Convert.Response.Error {
  public init(code: Anytype_Rpc.Wallet.Convert.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Wallet.Create.Request {
  public init(rootPath: String = String()) {
    self.rootPath = rootPath
  }
}

extension Anytype_Rpc.Wallet.Create.Response {
  public init(error: Anytype_Rpc.Wallet.Create.Response.Error, mnemonic: String = String()) {
    self.error = error
    self.mnemonic = mnemonic
  }
}

extension Anytype_Rpc.Wallet.Create.Response.Error {
  public init(code: Anytype_Rpc.Wallet.Create.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Wallet.Recover.Request {
  public init(rootPath: String = String(), mnemonic: String = String()) {
    self.rootPath = rootPath
    self.mnemonic = mnemonic
  }
}

extension Anytype_Rpc.Wallet.Recover.Response {
  public init(error: Anytype_Rpc.Wallet.Recover.Response.Error) {
    self.error = error
  }
}

extension Anytype_Rpc.Wallet.Recover.Response.Error {
  public init(code: Anytype_Rpc.Wallet.Recover.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Workspace.Create.Request {
  public init(name: String = String()) {
    self.name = name
  }
}

extension Anytype_Rpc.Workspace.Create.Response {
  public init(error: Anytype_Rpc.Workspace.Create.Response.Error, workspaceID: String = String()) {
    self.error = error
    self.workspaceID = workspaceID
  }
}

extension Anytype_Rpc.Workspace.Create.Response.Error {
  public init(code: Anytype_Rpc.Workspace.Create.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Workspace.Export.Request {
  public init(path: String = String(), workspaceID: String = String()) {
    self.path = path
    self.workspaceID = workspaceID
  }
}

extension Anytype_Rpc.Workspace.Export.Response {
  public init(error: Anytype_Rpc.Workspace.Export.Response.Error, path: String = String(), event: Anytype_ResponseEvent) {
    self.error = error
    self.path = path
    self.event = event
  }
}

extension Anytype_Rpc.Workspace.Export.Response.Error {
  public init(code: Anytype_Rpc.Workspace.Export.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Workspace.GetAll.Response {
  public init(error: Anytype_Rpc.Workspace.GetAll.Response.Error, workspaceIds: [String] = []) {
    self.error = error
    self.workspaceIds = workspaceIds
  }
}

extension Anytype_Rpc.Workspace.GetAll.Response.Error {
  public init(code: Anytype_Rpc.Workspace.GetAll.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Workspace.GetCurrent.Response {
  public init(error: Anytype_Rpc.Workspace.GetCurrent.Response.Error, workspaceID: String = String()) {
    self.error = error
    self.workspaceID = workspaceID
  }
}

extension Anytype_Rpc.Workspace.GetCurrent.Response.Error {
  public init(code: Anytype_Rpc.Workspace.GetCurrent.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Workspace.Select.Request {
  public init(workspaceID: String = String()) {
    self.workspaceID = workspaceID
  }
}

extension Anytype_Rpc.Workspace.Select.Response {
  public init(error: Anytype_Rpc.Workspace.Select.Response.Error) {
    self.error = error
  }
}

extension Anytype_Rpc.Workspace.Select.Response.Error {
  public init(code: Anytype_Rpc.Workspace.Select.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}

extension Anytype_Rpc.Workspace.SetIsHighlighted.Request {
  public init(objectID: String = String(), isHighlighted: Bool = false) {
    self.objectID = objectID
    self.isHighlighted = isHighlighted
  }
}

extension Anytype_Rpc.Workspace.SetIsHighlighted.Response {
  public init(error: Anytype_Rpc.Workspace.SetIsHighlighted.Response.Error) {
    self.error = error
  }
}

extension Anytype_Rpc.Workspace.SetIsHighlighted.Response.Error {
  public init(code: Anytype_Rpc.Workspace.SetIsHighlighted.Response.Error.Code = .null, description_p: String = String()) {
    self.code = code
    self.description_p = description_p
  }
}
