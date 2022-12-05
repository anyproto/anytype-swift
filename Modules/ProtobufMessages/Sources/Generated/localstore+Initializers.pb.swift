// DO NOT EDIT
//
// Generated automatically by the AnytypeSwiftCodegen.
//
// For more info see:
// https://github.com/anytypeio/anytype-swift-codegen

import Foundation
import SwiftProtobuf
import Combine

extension Anytype_Model_ObjectDetails {
    public init(details: SwiftProtobuf.Google_Protobuf_Struct) {
        self.details = details
    }
}

extension Anytype_Model_ObjectInfo {
    public init(id: String = String(), objectTypeUrls: [String] = [], details: SwiftProtobuf.Google_Protobuf_Struct, relations: [Anytype_Model_Relation] = [], snippet: String = String(), hasInboundLinks_p: Bool = false, objectType: Anytype_Model_SmartBlockType = .accountOld) {
        self.id = id
        self.objectTypeUrls = objectTypeUrls
        self.details = details
        self.relations = relations
        self.snippet = snippet
        self.hasInboundLinks_p = hasInboundLinks_p
        self.objectType = objectType
    }
}

extension Anytype_Model_ObjectInfoWithLinks {
    public init(id: String = String(), info: Anytype_Model_ObjectInfo, links: Anytype_Model_ObjectLinksInfo) {
        self.id = id
        self.info = info
        self.links = links
    }
}

extension Anytype_Model_ObjectInfoWithOutboundLinks {
    public init(id: String = String(), info: Anytype_Model_ObjectInfo, outboundLinks: [Anytype_Model_ObjectInfo] = []) {
        self.id = id
        self.info = info
        self.outboundLinks = outboundLinks
    }
}

extension Anytype_Model_ObjectInfoWithOutboundLinksIDs {
    public init(id: String = String(), info: Anytype_Model_ObjectInfo, outboundLinks: [String] = []) {
        self.id = id
        self.info = info
        self.outboundLinks = outboundLinks
    }
}

extension Anytype_Model_ObjectLinks {
    public init(inboundIds: [String] = [], outboundIds: [String] = []) {
        self.inboundIds = inboundIds
        self.outboundIds = outboundIds
    }
}

extension Anytype_Model_ObjectLinksInfo {
    public init(inbound: [Anytype_Model_ObjectInfo] = [], outbound: [Anytype_Model_ObjectInfo] = []) {
        self.inbound = inbound
        self.outbound = outbound
    }
}

extension Anytype_Model_ObjectStoreChecksums {
    public init(bundledObjectTypes: String = String(), bundledRelations: String = String(), bundledLayouts: String = String(), objectsForceReindexCounter: Int32 = 0, filesForceReindexCounter: Int32 = 0, idxRebuildCounter: Int32 = 0, fulltextRebuild: Int32 = 0, bundledTemplates: String = String(), bundledObjects: Int32 = 0, filestoreKeysForceReindexCounter: Int32 = 0) {
        self.bundledObjectTypes = bundledObjectTypes
        self.bundledRelations = bundledRelations
        self.bundledLayouts = bundledLayouts
        self.objectsForceReindexCounter = objectsForceReindexCounter
        self.filesForceReindexCounter = filesForceReindexCounter
        self.idxRebuildCounter = idxRebuildCounter
        self.fulltextRebuild = fulltextRebuild
        self.bundledTemplates = bundledTemplates
        self.bundledObjects = bundledObjects
        self.filestoreKeysForceReindexCounter = filestoreKeysForceReindexCounter
    }
}

