//
//  ServiceLayerModule.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 19.06.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//
import ProtobufMessages

fileprivate typealias Namespace = ServiceLayerModule

/// TODO:
/// Add concrete `Success` types for protocols.
/// Most of the time we need `ServiceLayerModule.Success` type.
/// In other cases we could provide concrete type.
/// For that we could add `Success` type for appropriate namespace in this nested enum `ServiceLayerModule`.
///
enum ServiceLayerModule {
    struct Success {
        var contextID: String
        var messages: [Anytype_Event.Message]
        init(_ value: Anytype_ResponseEvent) {
            self.contextID = value.contextID
            self.messages = value.messages
        }
    }
}

extension Namespace {
    enum Single {}
    enum List {}
    enum Text {}
    enum File {}
    enum Bookmark {}
    enum Other {}
}
