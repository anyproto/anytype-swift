// DO NOT EDIT
//
// Generated automatically by the AnytypeSwiftCodegen.
//
// For more info see:
// https://github.com/anytypeio/anytype-swift-codegen

import Combine
import Foundation
import Lib
import SwiftProtobuf

extension Anytype_Rpc.App.GetVersion {
  public enum Service {
    public static func invoke(queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation().invoke(on: queue)
    }
    public static func invoke() -> Result<Response, Error> {
        return invocation().invoke()
    }
    public static func invocation() -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request()
        return Invocation<Request,Response>(messageName: "AppGetVersion", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceAppGetVersion(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.App.SetDeviceState {
  public enum Service {
    public static func invoke(deviceState: Anytype_Rpc.App.SetDeviceState.Request.DeviceState = .background, queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(deviceState: deviceState).invoke(on: queue)
    }
    public static func invoke(deviceState: Anytype_Rpc.App.SetDeviceState.Request.DeviceState = .background) -> Result<Response, Error> {
        return invocation(deviceState: deviceState).invoke()
    }
    public static func invocation(deviceState: Anytype_Rpc.App.SetDeviceState.Request.DeviceState = .background) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(deviceState: deviceState)
        return Invocation<Request,Response>(messageName: "AppSetDeviceState", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceAppSetDeviceState(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.App.Shutdown {
  public enum Service {
    public static func invoke(queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation().invoke(on: queue)
    }
    public static func invoke() -> Result<Response, Error> {
        return invocation().invoke()
    }
    public static func invocation() -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request()
        return Invocation<Request,Response>(messageName: "AppShutdown", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceAppShutdown(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Wallet.Create {
  public enum Service {
    public static func invoke(rootPath: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(rootPath: rootPath).invoke(on: queue)
    }
    public static func invoke(rootPath: String = String()) -> Result<Response, Error> {
        return invocation(rootPath: rootPath).invoke()
    }
    public static func invocation(rootPath: String = String()) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(rootPath: rootPath)
        return Invocation<Request,Response>(messageName: "WalletCreate", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceWalletCreate(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Wallet.Recover {
  public enum Service {
    public static func invoke(rootPath: String = String(), mnemonic: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(rootPath: rootPath, mnemonic: mnemonic).invoke(on: queue)
    }
    public static func invoke(rootPath: String = String(), mnemonic: String = String()) -> Result<Response, Error> {
        return invocation(rootPath: rootPath, mnemonic: mnemonic).invoke()
    }
    public static func invocation(rootPath: String = String(), mnemonic: String = String()) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(rootPath: rootPath, mnemonic: mnemonic)
        return Invocation<Request,Response>(messageName: "WalletRecover", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceWalletRecover(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Wallet.Convert {
  public enum Service {
    public static func invoke(mnemonic: String = String(), entropy: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(mnemonic: mnemonic, entropy: entropy).invoke(on: queue)
    }
    public static func invoke(mnemonic: String = String(), entropy: String = String()) -> Result<Response, Error> {
        return invocation(mnemonic: mnemonic, entropy: entropy).invoke()
    }
    public static func invocation(mnemonic: String = String(), entropy: String = String()) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(mnemonic: mnemonic, entropy: entropy)
        return Invocation<Request,Response>(messageName: "WalletConvert", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceWalletConvert(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Wallet.CreateSession {
  public enum Service {
    public static func invoke(mnemonic: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(mnemonic: mnemonic).invoke(on: queue)
    }
    public static func invoke(mnemonic: String = String()) -> Result<Response, Error> {
        return invocation(mnemonic: mnemonic).invoke()
    }
    public static func invocation(mnemonic: String = String()) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(mnemonic: mnemonic)
        return Invocation<Request,Response>(messageName: "WalletCreateSession", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceWalletCreateSession(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Wallet.CloseSession {
  public enum Service {
    public static func invoke(token: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(token: token).invoke(on: queue)
    }
    public static func invoke(token: String = String()) -> Result<Response, Error> {
        return invocation(token: token).invoke()
    }
    public static func invocation(token: String = String()) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(token: token)
        return Invocation<Request,Response>(messageName: "WalletCloseSession", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceWalletCloseSession(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Account.Create {
  public enum Service {
    public static func invoke(name: String = String(), avatar: Anytype_Rpc.Account.Create.Request.OneOf_Avatar? = nil, storePath: String = String(), alphaInviteCode: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(name: name, avatar: avatar, storePath: storePath, alphaInviteCode: alphaInviteCode).invoke(on: queue)
    }
    public static func invoke(name: String = String(), avatar: Anytype_Rpc.Account.Create.Request.OneOf_Avatar? = nil, storePath: String = String(), alphaInviteCode: String = String()) -> Result<Response, Error> {
        return invocation(name: name, avatar: avatar, storePath: storePath, alphaInviteCode: alphaInviteCode).invoke()
    }
    public static func invocation(name: String = String(), avatar: Anytype_Rpc.Account.Create.Request.OneOf_Avatar? = nil, storePath: String = String(), alphaInviteCode: String = String()) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(name: name, avatar: avatar, storePath: storePath, alphaInviteCode: alphaInviteCode)
        return Invocation<Request,Response>(messageName: "AccountCreate", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceAccountCreate(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Account.Recover {
  public enum Service {
    public static func invoke(queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation().invoke(on: queue)
    }
    public static func invoke() -> Result<Response, Error> {
        return invocation().invoke()
    }
    public static func invocation() -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request()
        return Invocation<Request,Response>(messageName: "AccountRecover", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceAccountRecover(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Account.Delete {
  public enum Service {
    public static func invoke(revert: Bool = false, queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(revert: revert).invoke(on: queue)
    }
    public static func invoke(revert: Bool = false) -> Result<Response, Error> {
        return invocation(revert: revert).invoke()
    }
    public static func invocation(revert: Bool = false) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(revert: revert)
        return Invocation<Request,Response>(messageName: "AccountDelete", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceAccountDelete(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Account.Select {
  public enum Service {
    public static func invoke(id: String = String(), rootPath: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(id: id, rootPath: rootPath).invoke(on: queue)
    }
    public static func invoke(id: String = String(), rootPath: String = String()) -> Result<Response, Error> {
        return invocation(id: id, rootPath: rootPath).invoke()
    }
    public static func invocation(id: String = String(), rootPath: String = String()) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(id: id, rootPath: rootPath)
        return Invocation<Request,Response>(messageName: "AccountSelect", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceAccountSelect(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Account.Stop {
  public enum Service {
    public static func invoke(removeData: Bool = false, queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(removeData: removeData).invoke(on: queue)
    }
    public static func invoke(removeData: Bool = false) -> Result<Response, Error> {
        return invocation(removeData: removeData).invoke()
    }
    public static func invocation(removeData: Bool = false) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(removeData: removeData)
        return Invocation<Request,Response>(messageName: "AccountStop", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceAccountStop(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Account.Move {
  public enum Service {
    public static func invoke(newPath: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(newPath: newPath).invoke(on: queue)
    }
    public static func invoke(newPath: String = String()) -> Result<Response, Error> {
        return invocation(newPath: newPath).invoke()
    }
    public static func invocation(newPath: String = String()) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(newPath: newPath)
        return Invocation<Request,Response>(messageName: "AccountMove", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceAccountMove(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Workspace.GetCurrent {
  public enum Service {
    public static func invoke(queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation().invoke(on: queue)
    }
    public static func invoke() -> Result<Response, Error> {
        return invocation().invoke()
    }
    public static func invocation() -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request()
        return Invocation<Request,Response>(messageName: "WorkspaceGetCurrent", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceWorkspaceGetCurrent(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Workspace.GetAll {
  public enum Service {
    public static func invoke(queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation().invoke(on: queue)
    }
    public static func invoke() -> Result<Response, Error> {
        return invocation().invoke()
    }
    public static func invocation() -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request()
        return Invocation<Request,Response>(messageName: "WorkspaceGetAll", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceWorkspaceGetAll(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Workspace.Create {
  public enum Service {
    public static func invoke(name: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(name: name).invoke(on: queue)
    }
    public static func invoke(name: String = String()) -> Result<Response, Error> {
        return invocation(name: name).invoke()
    }
    public static func invocation(name: String = String()) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(name: name)
        return Invocation<Request,Response>(messageName: "WorkspaceCreate", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceWorkspaceCreate(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Workspace.SetIsHighlighted {
  public enum Service {
    public static func invoke(objectID: String = String(), isHighlighted: Bool = false, queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(objectID: objectID, isHighlighted: isHighlighted).invoke(on: queue)
    }
    public static func invoke(objectID: String = String(), isHighlighted: Bool = false) -> Result<Response, Error> {
        return invocation(objectID: objectID, isHighlighted: isHighlighted).invoke()
    }
    public static func invocation(objectID: String = String(), isHighlighted: Bool = false) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(objectID: objectID, isHighlighted: isHighlighted)
        return Invocation<Request,Response>(messageName: "WorkspaceSetIsHighlighted", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceWorkspaceSetIsHighlighted(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Workspace.Select {
  public enum Service {
    public static func invoke(workspaceID: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(workspaceID: workspaceID).invoke(on: queue)
    }
    public static func invoke(workspaceID: String = String()) -> Result<Response, Error> {
        return invocation(workspaceID: workspaceID).invoke()
    }
    public static func invocation(workspaceID: String = String()) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(workspaceID: workspaceID)
        return Invocation<Request,Response>(messageName: "WorkspaceSelect", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceWorkspaceSelect(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Workspace.Export {
  public enum Service {
    public static func invoke(path: String = String(), workspaceID: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(path: path, workspaceID: workspaceID).invoke(on: queue)
    }
    public static func invoke(path: String = String(), workspaceID: String = String()) -> Result<Response, Error> {
        return invocation(path: path, workspaceID: workspaceID).invoke()
    }
    public static func invocation(path: String = String(), workspaceID: String = String()) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(path: path, workspaceID: workspaceID)
        return Invocation<Request,Response>(messageName: "WorkspaceExport", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceWorkspaceExport(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Object.Open {
  public enum Service {
    public static func invoke(contextID: String = String(), objectID: String = String(), traceID: String = String(), includeRelationsAsDependentObjects: Bool = false, queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, objectID: objectID, traceID: traceID, includeRelationsAsDependentObjects: includeRelationsAsDependentObjects).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), objectID: String = String(), traceID: String = String(), includeRelationsAsDependentObjects: Bool = false) -> Result<Response, Error> {
        return invocation(contextID: contextID, objectID: objectID, traceID: traceID, includeRelationsAsDependentObjects: includeRelationsAsDependentObjects).invoke()
    }
    public static func invocation(contextID: String = String(), objectID: String = String(), traceID: String = String(), includeRelationsAsDependentObjects: Bool = false) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, objectID: objectID, traceID: traceID, includeRelationsAsDependentObjects: includeRelationsAsDependentObjects)
        return Invocation<Request,Response>(messageName: "ObjectOpen", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceObjectOpen(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Object.Close {
  public enum Service {
    public static func invoke(contextID: String = String(), objectID: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, objectID: objectID).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), objectID: String = String()) -> Result<Response, Error> {
        return invocation(contextID: contextID, objectID: objectID).invoke()
    }
    public static func invocation(contextID: String = String(), objectID: String = String()) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, objectID: objectID)
        return Invocation<Request,Response>(messageName: "ObjectClose", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceObjectClose(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Object.Show {
  public enum Service {
    public static func invoke(contextID: String = String(), objectID: String = String(), traceID: String = String(), includeRelationsAsDependentObjects: Bool = false, queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, objectID: objectID, traceID: traceID, includeRelationsAsDependentObjects: includeRelationsAsDependentObjects).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), objectID: String = String(), traceID: String = String(), includeRelationsAsDependentObjects: Bool = false) -> Result<Response, Error> {
        return invocation(contextID: contextID, objectID: objectID, traceID: traceID, includeRelationsAsDependentObjects: includeRelationsAsDependentObjects).invoke()
    }
    public static func invocation(contextID: String = String(), objectID: String = String(), traceID: String = String(), includeRelationsAsDependentObjects: Bool = false) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, objectID: objectID, traceID: traceID, includeRelationsAsDependentObjects: includeRelationsAsDependentObjects)
        return Invocation<Request,Response>(messageName: "ObjectShow", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceObjectShow(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Object.Create {
  public enum Service {
    public static func invoke(details: SwiftProtobuf.Google_Protobuf_Struct, internalFlags: [Anytype_Model_InternalFlag] = [], templateID: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(details: details, internalFlags: internalFlags, templateID: templateID).invoke(on: queue)
    }
    public static func invoke(details: SwiftProtobuf.Google_Protobuf_Struct, internalFlags: [Anytype_Model_InternalFlag] = [], templateID: String = String()) -> Result<Response, Error> {
        return invocation(details: details, internalFlags: internalFlags, templateID: templateID).invoke()
    }
    public static func invocation(details: SwiftProtobuf.Google_Protobuf_Struct, internalFlags: [Anytype_Model_InternalFlag] = [], templateID: String = String()) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(details: details, internalFlags: internalFlags, templateID: templateID)
        return Invocation<Request,Response>(messageName: "ObjectCreate", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceObjectCreate(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Object.CreateBookmark {
  public enum Service {
    public static func invoke(details: SwiftProtobuf.Google_Protobuf_Struct, queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(details: details).invoke(on: queue)
    }
    public static func invoke(details: SwiftProtobuf.Google_Protobuf_Struct) -> Result<Response, Error> {
        return invocation(details: details).invoke()
    }
    public static func invocation(details: SwiftProtobuf.Google_Protobuf_Struct) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(details: details)
        return Invocation<Request,Response>(messageName: "ObjectCreateBookmark", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceObjectCreateBookmark(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Object.CreateRelation {
  public enum Service {
    public static func invoke(details: SwiftProtobuf.Google_Protobuf_Struct, queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(details: details).invoke(on: queue)
    }
    public static func invoke(details: SwiftProtobuf.Google_Protobuf_Struct) -> Result<Response, Error> {
        return invocation(details: details).invoke()
    }
    public static func invocation(details: SwiftProtobuf.Google_Protobuf_Struct) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(details: details)
        return Invocation<Request,Response>(messageName: "ObjectCreateRelation", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceObjectCreateRelation(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Object.CreateRelationOption {
  public enum Service {
    public static func invoke(details: SwiftProtobuf.Google_Protobuf_Struct, queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(details: details).invoke(on: queue)
    }
    public static func invoke(details: SwiftProtobuf.Google_Protobuf_Struct) -> Result<Response, Error> {
        return invocation(details: details).invoke()
    }
    public static func invocation(details: SwiftProtobuf.Google_Protobuf_Struct) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(details: details)
        return Invocation<Request,Response>(messageName: "ObjectCreateRelationOption", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceObjectCreateRelationOption(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Object.CreateSet {
  public enum Service {
    public static func invoke(source: [String] = [], details: SwiftProtobuf.Google_Protobuf_Struct, templateID: String = String(), internalFlags: [Anytype_Model_InternalFlag] = [], queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(source: source, details: details, templateID: templateID, internalFlags: internalFlags).invoke(on: queue)
    }
    public static func invoke(source: [String] = [], details: SwiftProtobuf.Google_Protobuf_Struct, templateID: String = String(), internalFlags: [Anytype_Model_InternalFlag] = []) -> Result<Response, Error> {
        return invocation(source: source, details: details, templateID: templateID, internalFlags: internalFlags).invoke()
    }
    public static func invocation(source: [String] = [], details: SwiftProtobuf.Google_Protobuf_Struct, templateID: String = String(), internalFlags: [Anytype_Model_InternalFlag] = []) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(source: source, details: details, templateID: templateID, internalFlags: internalFlags)
        return Invocation<Request,Response>(messageName: "ObjectCreateSet", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceObjectCreateSet(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Object.CreateObjectType {
  public enum Service {
    public static func invoke(details: SwiftProtobuf.Google_Protobuf_Struct, internalFlags: [Anytype_Model_InternalFlag] = [], queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(details: details, internalFlags: internalFlags).invoke(on: queue)
    }
    public static func invoke(details: SwiftProtobuf.Google_Protobuf_Struct, internalFlags: [Anytype_Model_InternalFlag] = []) -> Result<Response, Error> {
        return invocation(details: details, internalFlags: internalFlags).invoke()
    }
    public static func invocation(details: SwiftProtobuf.Google_Protobuf_Struct, internalFlags: [Anytype_Model_InternalFlag] = []) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(details: details, internalFlags: internalFlags)
        return Invocation<Request,Response>(messageName: "ObjectCreateObjectType", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceObjectCreateObjectType(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Object.BookmarkFetch {
  public enum Service {
    public static func invoke(contextID: String = String(), url: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, url: url).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), url: String = String()) -> Result<Response, Error> {
        return invocation(contextID: contextID, url: url).invoke()
    }
    public static func invocation(contextID: String = String(), url: String = String()) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, url: url)
        return Invocation<Request,Response>(messageName: "ObjectBookmarkFetch", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceObjectBookmarkFetch(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Object.ToBookmark {
  public enum Service {
    public static func invoke(contextID: String = String(), url: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, url: url).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), url: String = String()) -> Result<Response, Error> {
        return invocation(contextID: contextID, url: url).invoke()
    }
    public static func invocation(contextID: String = String(), url: String = String()) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, url: url)
        return Invocation<Request,Response>(messageName: "ObjectToBookmark", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceObjectToBookmark(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Object.Duplicate {
  public enum Service {
    public static func invoke(contextID: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID).invoke(on: queue)
    }
    public static func invoke(contextID: String = String()) -> Result<Response, Error> {
        return invocation(contextID: contextID).invoke()
    }
    public static func invocation(contextID: String = String()) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID)
        return Invocation<Request,Response>(messageName: "ObjectDuplicate", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceObjectDuplicate(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Object.OpenBreadcrumbs {
  public enum Service {
    public static func invoke(contextID: String = String(), traceID: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, traceID: traceID).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), traceID: String = String()) -> Result<Response, Error> {
        return invocation(contextID: contextID, traceID: traceID).invoke()
    }
    public static func invocation(contextID: String = String(), traceID: String = String()) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, traceID: traceID)
        return Invocation<Request,Response>(messageName: "ObjectOpenBreadcrumbs", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceObjectOpenBreadcrumbs(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Object.SetBreadcrumbs {
  public enum Service {
    public static func invoke(breadcrumbsID: String = String(), ids: [String] = [], queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(breadcrumbsID: breadcrumbsID, ids: ids).invoke(on: queue)
    }
    public static func invoke(breadcrumbsID: String = String(), ids: [String] = []) -> Result<Response, Error> {
        return invocation(breadcrumbsID: breadcrumbsID, ids: ids).invoke()
    }
    public static func invocation(breadcrumbsID: String = String(), ids: [String] = []) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(breadcrumbsID: breadcrumbsID, ids: ids)
        return Invocation<Request,Response>(messageName: "ObjectSetBreadcrumbs", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceObjectSetBreadcrumbs(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Object.ImportMarkdown {
  public enum Service {
    public static func invoke(contextID: String = String(), importPath: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, importPath: importPath).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), importPath: String = String()) -> Result<Response, Error> {
        return invocation(contextID: contextID, importPath: importPath).invoke()
    }
    public static func invocation(contextID: String = String(), importPath: String = String()) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, importPath: importPath)
        return Invocation<Request,Response>(messageName: "ObjectImportMarkdown", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceObjectImportMarkdown(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Object.ShareByLink {
  public enum Service {
    public static func invoke(objectID: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(objectID: objectID).invoke(on: queue)
    }
    public static func invoke(objectID: String = String()) -> Result<Response, Error> {
        return invocation(objectID: objectID).invoke()
    }
    public static func invocation(objectID: String = String()) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(objectID: objectID)
        return Invocation<Request,Response>(messageName: "ObjectShareByLink", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceObjectShareByLink(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Object.AddWithObjectId {
  public enum Service {
    public static func invoke(objectID: String = String(), payload: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(objectID: objectID, payload: payload).invoke(on: queue)
    }
    public static func invoke(objectID: String = String(), payload: String = String()) -> Result<Response, Error> {
        return invocation(objectID: objectID, payload: payload).invoke()
    }
    public static func invocation(objectID: String = String(), payload: String = String()) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(objectID: objectID, payload: payload)
        return Invocation<Request,Response>(messageName: "ObjectAddWithObjectId", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceObjectAddWithObjectId(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Object.Search {
  public enum Service {
    public static func invoke(filters: [Anytype_Model_Block.Content.Dataview.Filter] = [], sorts: [Anytype_Model_Block.Content.Dataview.Sort] = [], fullText: String = String(), offset: Int32 = 0, limit: Int32 = 0, objectTypeFilter: [String] = [], keys: [String] = [], queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(filters: filters, sorts: sorts, fullText: fullText, offset: offset, limit: limit, objectTypeFilter: objectTypeFilter, keys: keys).invoke(on: queue)
    }
    public static func invoke(filters: [Anytype_Model_Block.Content.Dataview.Filter] = [], sorts: [Anytype_Model_Block.Content.Dataview.Sort] = [], fullText: String = String(), offset: Int32 = 0, limit: Int32 = 0, objectTypeFilter: [String] = [], keys: [String] = []) -> Result<Response, Error> {
        return invocation(filters: filters, sorts: sorts, fullText: fullText, offset: offset, limit: limit, objectTypeFilter: objectTypeFilter, keys: keys).invoke()
    }
    public static func invocation(filters: [Anytype_Model_Block.Content.Dataview.Filter] = [], sorts: [Anytype_Model_Block.Content.Dataview.Sort] = [], fullText: String = String(), offset: Int32 = 0, limit: Int32 = 0, objectTypeFilter: [String] = [], keys: [String] = []) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(filters: filters, sorts: sorts, fullText: fullText, offset: offset, limit: limit, objectTypeFilter: objectTypeFilter, keys: keys)
        return Invocation<Request,Response>(messageName: "ObjectSearch", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceObjectSearch(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Object.Graph {
  public enum Service {
    public static func invoke(filters: [Anytype_Model_Block.Content.Dataview.Filter] = [], limit: Int32 = 0, objectTypeFilter: [String] = [], keys: [String] = [], queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(filters: filters, limit: limit, objectTypeFilter: objectTypeFilter, keys: keys).invoke(on: queue)
    }
    public static func invoke(filters: [Anytype_Model_Block.Content.Dataview.Filter] = [], limit: Int32 = 0, objectTypeFilter: [String] = [], keys: [String] = []) -> Result<Response, Error> {
        return invocation(filters: filters, limit: limit, objectTypeFilter: objectTypeFilter, keys: keys).invoke()
    }
    public static func invocation(filters: [Anytype_Model_Block.Content.Dataview.Filter] = [], limit: Int32 = 0, objectTypeFilter: [String] = [], keys: [String] = []) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(filters: filters, limit: limit, objectTypeFilter: objectTypeFilter, keys: keys)
        return Invocation<Request,Response>(messageName: "ObjectGraph", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceObjectGraph(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Object.SearchSubscribe {
  public enum Service {
    public static func invoke(subID: String = String(), filters: [Anytype_Model_Block.Content.Dataview.Filter] = [], sorts: [Anytype_Model_Block.Content.Dataview.Sort] = [], limit: Int64 = 0, offset: Int64 = 0, keys: [String] = [], afterID: String = String(), beforeID: String = String(), source: [String] = [], ignoreWorkspace: String = String(), noDepSubscription: Bool = false, queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(subID: subID, filters: filters, sorts: sorts, limit: limit, offset: offset, keys: keys, afterID: afterID, beforeID: beforeID, source: source, ignoreWorkspace: ignoreWorkspace, noDepSubscription: noDepSubscription).invoke(on: queue)
    }
    public static func invoke(subID: String = String(), filters: [Anytype_Model_Block.Content.Dataview.Filter] = [], sorts: [Anytype_Model_Block.Content.Dataview.Sort] = [], limit: Int64 = 0, offset: Int64 = 0, keys: [String] = [], afterID: String = String(), beforeID: String = String(), source: [String] = [], ignoreWorkspace: String = String(), noDepSubscription: Bool = false) -> Result<Response, Error> {
        return invocation(subID: subID, filters: filters, sorts: sorts, limit: limit, offset: offset, keys: keys, afterID: afterID, beforeID: beforeID, source: source, ignoreWorkspace: ignoreWorkspace, noDepSubscription: noDepSubscription).invoke()
    }
    public static func invocation(subID: String = String(), filters: [Anytype_Model_Block.Content.Dataview.Filter] = [], sorts: [Anytype_Model_Block.Content.Dataview.Sort] = [], limit: Int64 = 0, offset: Int64 = 0, keys: [String] = [], afterID: String = String(), beforeID: String = String(), source: [String] = [], ignoreWorkspace: String = String(), noDepSubscription: Bool = false) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(subID: subID, filters: filters, sorts: sorts, limit: limit, offset: offset, keys: keys, afterID: afterID, beforeID: beforeID, source: source, ignoreWorkspace: ignoreWorkspace, noDepSubscription: noDepSubscription)
        return Invocation<Request,Response>(messageName: "ObjectSearchSubscribe", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceObjectSearchSubscribe(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Object.RelationSearchDistinct {
  public enum Service {
    public static func invoke(relationKey: String = String(), filters: [Anytype_Model_Block.Content.Dataview.Filter] = [], queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(relationKey: relationKey, filters: filters).invoke(on: queue)
    }
    public static func invoke(relationKey: String = String(), filters: [Anytype_Model_Block.Content.Dataview.Filter] = []) -> Result<Response, Error> {
        return invocation(relationKey: relationKey, filters: filters).invoke()
    }
    public static func invocation(relationKey: String = String(), filters: [Anytype_Model_Block.Content.Dataview.Filter] = []) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(relationKey: relationKey, filters: filters)
        return Invocation<Request,Response>(messageName: "ObjectRelationSearchDistinct", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceObjectRelationSearchDistinct(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Object.SubscribeIds {
  public enum Service {
    public static func invoke(subID: String = String(), ids: [String] = [], keys: [String] = [], ignoreWorkspace: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(subID: subID, ids: ids, keys: keys, ignoreWorkspace: ignoreWorkspace).invoke(on: queue)
    }
    public static func invoke(subID: String = String(), ids: [String] = [], keys: [String] = [], ignoreWorkspace: String = String()) -> Result<Response, Error> {
        return invocation(subID: subID, ids: ids, keys: keys, ignoreWorkspace: ignoreWorkspace).invoke()
    }
    public static func invocation(subID: String = String(), ids: [String] = [], keys: [String] = [], ignoreWorkspace: String = String()) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(subID: subID, ids: ids, keys: keys, ignoreWorkspace: ignoreWorkspace)
        return Invocation<Request,Response>(messageName: "ObjectSubscribeIds", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceObjectSubscribeIds(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Object.SearchUnsubscribe {
  public enum Service {
    public static func invoke(subIds: [String] = [], queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(subIds: subIds).invoke(on: queue)
    }
    public static func invoke(subIds: [String] = []) -> Result<Response, Error> {
        return invocation(subIds: subIds).invoke()
    }
    public static func invocation(subIds: [String] = []) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(subIds: subIds)
        return Invocation<Request,Response>(messageName: "ObjectSearchUnsubscribe", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceObjectSearchUnsubscribe(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Object.SetLayout {
  public enum Service {
    public static func invoke(contextID: String = String(), layout: Anytype_Model_ObjectType.Layout = .basic, queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, layout: layout).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), layout: Anytype_Model_ObjectType.Layout = .basic) -> Result<Response, Error> {
        return invocation(contextID: contextID, layout: layout).invoke()
    }
    public static func invocation(contextID: String = String(), layout: Anytype_Model_ObjectType.Layout = .basic) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, layout: layout)
        return Invocation<Request,Response>(messageName: "ObjectSetLayout", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceObjectSetLayout(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Object.SetIsFavorite {
  public enum Service {
    public static func invoke(contextID: String = String(), isFavorite: Bool = false, queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, isFavorite: isFavorite).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), isFavorite: Bool = false) -> Result<Response, Error> {
        return invocation(contextID: contextID, isFavorite: isFavorite).invoke()
    }
    public static func invocation(contextID: String = String(), isFavorite: Bool = false) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, isFavorite: isFavorite)
        return Invocation<Request,Response>(messageName: "ObjectSetIsFavorite", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceObjectSetIsFavorite(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Object.SetIsArchived {
  public enum Service {
    public static func invoke(contextID: String = String(), isArchived: Bool = false, queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, isArchived: isArchived).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), isArchived: Bool = false) -> Result<Response, Error> {
        return invocation(contextID: contextID, isArchived: isArchived).invoke()
    }
    public static func invocation(contextID: String = String(), isArchived: Bool = false) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, isArchived: isArchived)
        return Invocation<Request,Response>(messageName: "ObjectSetIsArchived", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceObjectSetIsArchived(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Object.SetObjectType {
  public enum Service {
    public static func invoke(contextID: String = String(), objectTypeURL: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, objectTypeURL: objectTypeURL).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), objectTypeURL: String = String()) -> Result<Response, Error> {
        return invocation(contextID: contextID, objectTypeURL: objectTypeURL).invoke()
    }
    public static func invocation(contextID: String = String(), objectTypeURL: String = String()) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, objectTypeURL: objectTypeURL)
        return Invocation<Request,Response>(messageName: "ObjectSetObjectType", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceObjectSetObjectType(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Object.SetDetails {
  public enum Service {
    public static func invoke(contextID: String = String(), details: [Anytype_Rpc.Object.SetDetails.Detail] = [], queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, details: details).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), details: [Anytype_Rpc.Object.SetDetails.Detail] = []) -> Result<Response, Error> {
        return invocation(contextID: contextID, details: details).invoke()
    }
    public static func invocation(contextID: String = String(), details: [Anytype_Rpc.Object.SetDetails.Detail] = []) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, details: details)
        return Invocation<Request,Response>(messageName: "ObjectSetDetails", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceObjectSetDetails(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Object.ToSet {
  public enum Service {
    public static func invoke(contextID: String = String(), source: [String] = [], queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, source: source).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), source: [String] = []) -> Result<Response, Error> {
        return invocation(contextID: contextID, source: source).invoke()
    }
    public static func invocation(contextID: String = String(), source: [String] = []) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, source: source)
        return Invocation<Request,Response>(messageName: "ObjectToSet", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceObjectToSet(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Object.Undo {
  public enum Service {
    public static func invoke(contextID: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID).invoke(on: queue)
    }
    public static func invoke(contextID: String = String()) -> Result<Response, Error> {
        return invocation(contextID: contextID).invoke()
    }
    public static func invocation(contextID: String = String()) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID)
        return Invocation<Request,Response>(messageName: "ObjectUndo", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceObjectUndo(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Object.Redo {
  public enum Service {
    public static func invoke(contextID: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID).invoke(on: queue)
    }
    public static func invoke(contextID: String = String()) -> Result<Response, Error> {
        return invocation(contextID: contextID).invoke()
    }
    public static func invocation(contextID: String = String()) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID)
        return Invocation<Request,Response>(messageName: "ObjectRedo", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceObjectRedo(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Object.ListDuplicate {
  public enum Service {
    public static func invoke(objectIds: [String] = [], queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(objectIds: objectIds).invoke(on: queue)
    }
    public static func invoke(objectIds: [String] = []) -> Result<Response, Error> {
        return invocation(objectIds: objectIds).invoke()
    }
    public static func invocation(objectIds: [String] = []) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(objectIds: objectIds)
        return Invocation<Request,Response>(messageName: "ObjectListDuplicate", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceObjectListDuplicate(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Object.ListDelete {
  public enum Service {
    public static func invoke(objectIds: [String] = [], queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(objectIds: objectIds).invoke(on: queue)
    }
    public static func invoke(objectIds: [String] = []) -> Result<Response, Error> {
        return invocation(objectIds: objectIds).invoke()
    }
    public static func invocation(objectIds: [String] = []) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(objectIds: objectIds)
        return Invocation<Request,Response>(messageName: "ObjectListDelete", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceObjectListDelete(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Object.ListSetIsArchived {
  public enum Service {
    public static func invoke(objectIds: [String] = [], isArchived: Bool = false, queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(objectIds: objectIds, isArchived: isArchived).invoke(on: queue)
    }
    public static func invoke(objectIds: [String] = [], isArchived: Bool = false) -> Result<Response, Error> {
        return invocation(objectIds: objectIds, isArchived: isArchived).invoke()
    }
    public static func invocation(objectIds: [String] = [], isArchived: Bool = false) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(objectIds: objectIds, isArchived: isArchived)
        return Invocation<Request,Response>(messageName: "ObjectListSetIsArchived", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceObjectListSetIsArchived(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Object.ListSetIsFavorite {
  public enum Service {
    public static func invoke(objectIds: [String] = [], isFavorite: Bool = false, queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(objectIds: objectIds, isFavorite: isFavorite).invoke(on: queue)
    }
    public static func invoke(objectIds: [String] = [], isFavorite: Bool = false) -> Result<Response, Error> {
        return invocation(objectIds: objectIds, isFavorite: isFavorite).invoke()
    }
    public static func invocation(objectIds: [String] = [], isFavorite: Bool = false) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(objectIds: objectIds, isFavorite: isFavorite)
        return Invocation<Request,Response>(messageName: "ObjectListSetIsFavorite", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceObjectListSetIsFavorite(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Object.ApplyTemplate {
  public enum Service {
    public static func invoke(contextID: String = String(), templateID: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, templateID: templateID).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), templateID: String = String()) -> Result<Response, Error> {
        return invocation(contextID: contextID, templateID: templateID).invoke()
    }
    public static func invocation(contextID: String = String(), templateID: String = String()) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, templateID: templateID)
        return Invocation<Request,Response>(messageName: "ObjectApplyTemplate", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceObjectApplyTemplate(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Object.ListExport {
  public enum Service {
    public static func invoke(path: String = String(), objectIds: [String] = [], format: Anytype_Rpc.Object.ListExport.Format = .markdown, zip: Bool = false, includeNested: Bool = false, includeFiles: Bool = false, queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(path: path, objectIds: objectIds, format: format, zip: zip, includeNested: includeNested, includeFiles: includeFiles).invoke(on: queue)
    }
    public static func invoke(path: String = String(), objectIds: [String] = [], format: Anytype_Rpc.Object.ListExport.Format = .markdown, zip: Bool = false, includeNested: Bool = false, includeFiles: Bool = false) -> Result<Response, Error> {
        return invocation(path: path, objectIds: objectIds, format: format, zip: zip, includeNested: includeNested, includeFiles: includeFiles).invoke()
    }
    public static func invocation(path: String = String(), objectIds: [String] = [], format: Anytype_Rpc.Object.ListExport.Format = .markdown, zip: Bool = false, includeNested: Bool = false, includeFiles: Bool = false) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(path: path, objectIds: objectIds, format: format, zip: zip, includeNested: includeNested, includeFiles: includeFiles)
        return Invocation<Request,Response>(messageName: "ObjectListExport", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceObjectListExport(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.ObjectRelation.Add {
  public enum Service {
    public static func invoke(contextID: String = String(), relationIds: [String] = [], queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, relationIds: relationIds).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), relationIds: [String] = []) -> Result<Response, Error> {
        return invocation(contextID: contextID, relationIds: relationIds).invoke()
    }
    public static func invocation(contextID: String = String(), relationIds: [String] = []) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, relationIds: relationIds)
        return Invocation<Request,Response>(messageName: "ObjectRelationAdd", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceObjectRelationAdd(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.ObjectRelation.Delete {
  public enum Service {
    public static func invoke(contextID: String = String(), relationID: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, relationID: relationID).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), relationID: String = String()) -> Result<Response, Error> {
        return invocation(contextID: contextID, relationID: relationID).invoke()
    }
    public static func invocation(contextID: String = String(), relationID: String = String()) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, relationID: relationID)
        return Invocation<Request,Response>(messageName: "ObjectRelationDelete", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceObjectRelationDelete(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.ObjectRelation.ListAvailable {
  public enum Service {
    public static func invoke(contextID: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID).invoke(on: queue)
    }
    public static func invoke(contextID: String = String()) -> Result<Response, Error> {
        return invocation(contextID: contextID).invoke()
    }
    public static func invocation(contextID: String = String()) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID)
        return Invocation<Request,Response>(messageName: "ObjectRelationListAvailable", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceObjectRelationListAvailable(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.ObjectRelation.AddFeatured {
  public enum Service {
    public static func invoke(contextID: String = String(), relations: [String] = [], queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, relations: relations).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), relations: [String] = []) -> Result<Response, Error> {
        return invocation(contextID: contextID, relations: relations).invoke()
    }
    public static func invocation(contextID: String = String(), relations: [String] = []) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, relations: relations)
        return Invocation<Request,Response>(messageName: "ObjectRelationAddFeatured", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceObjectRelationAddFeatured(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.ObjectRelation.RemoveFeatured {
  public enum Service {
    public static func invoke(contextID: String = String(), relations: [String] = [], queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, relations: relations).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), relations: [String] = []) -> Result<Response, Error> {
        return invocation(contextID: contextID, relations: relations).invoke()
    }
    public static func invocation(contextID: String = String(), relations: [String] = []) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, relations: relations)
        return Invocation<Request,Response>(messageName: "ObjectRelationRemoveFeatured", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceObjectRelationRemoveFeatured(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.ObjectType.Relation.Add {
  public enum Service {
    public static func invoke(objectTypeURL: String = String(), relationIds: [String] = [], queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(objectTypeURL: objectTypeURL, relationIds: relationIds).invoke(on: queue)
    }
    public static func invoke(objectTypeURL: String = String(), relationIds: [String] = []) -> Result<Response, Error> {
        return invocation(objectTypeURL: objectTypeURL, relationIds: relationIds).invoke()
    }
    public static func invocation(objectTypeURL: String = String(), relationIds: [String] = []) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(objectTypeURL: objectTypeURL, relationIds: relationIds)
        return Invocation<Request,Response>(messageName: "ObjectTypeRelationAdd", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceObjectTypeRelationAdd(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.ObjectType.Relation.Remove {
  public enum Service {
    public static func invoke(objectTypeURL: String = String(), relationID: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(objectTypeURL: objectTypeURL, relationID: relationID).invoke(on: queue)
    }
    public static func invoke(objectTypeURL: String = String(), relationID: String = String()) -> Result<Response, Error> {
        return invocation(objectTypeURL: objectTypeURL, relationID: relationID).invoke()
    }
    public static func invocation(objectTypeURL: String = String(), relationID: String = String()) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(objectTypeURL: objectTypeURL, relationID: relationID)
        return Invocation<Request,Response>(messageName: "ObjectTypeRelationRemove", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceObjectTypeRelationRemove(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.ObjectType.Relation.List {
  public enum Service {
    public static func invoke(objectTypeURL: String = String(), appendRelationsFromOtherTypes: Bool = false, queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(objectTypeURL: objectTypeURL, appendRelationsFromOtherTypes: appendRelationsFromOtherTypes).invoke(on: queue)
    }
    public static func invoke(objectTypeURL: String = String(), appendRelationsFromOtherTypes: Bool = false) -> Result<Response, Error> {
        return invocation(objectTypeURL: objectTypeURL, appendRelationsFromOtherTypes: appendRelationsFromOtherTypes).invoke()
    }
    public static func invocation(objectTypeURL: String = String(), appendRelationsFromOtherTypes: Bool = false) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(objectTypeURL: objectTypeURL, appendRelationsFromOtherTypes: appendRelationsFromOtherTypes)
        return Invocation<Request,Response>(messageName: "ObjectTypeRelationList", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceObjectTypeRelationList(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Relation.ListRemoveOption {
  public enum Service {
    public static func invoke(optionIds: [String] = [], checkInObjects: Bool = false, queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(optionIds: optionIds, checkInObjects: checkInObjects).invoke(on: queue)
    }
    public static func invoke(optionIds: [String] = [], checkInObjects: Bool = false) -> Result<Response, Error> {
        return invocation(optionIds: optionIds, checkInObjects: checkInObjects).invoke()
    }
    public static func invocation(optionIds: [String] = [], checkInObjects: Bool = false) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(optionIds: optionIds, checkInObjects: checkInObjects)
        return Invocation<Request,Response>(messageName: "RelationListRemoveOption", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceRelationListRemoveOption(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Relation.Options {
  public enum Service {
    public static func invoke(relationKey: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(relationKey: relationKey).invoke(on: queue)
    }
    public static func invoke(relationKey: String = String()) -> Result<Response, Error> {
        return invocation(relationKey: relationKey).invoke()
    }
    public static func invocation(relationKey: String = String()) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(relationKey: relationKey)
        return Invocation<Request,Response>(messageName: "RelationOptions", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceRelationOptions(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.History.GetVersions {
  public enum Service {
    public static func invoke(objectID: String = String(), lastVersionID: String = String(), limit: Int32 = 0, queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(objectID: objectID, lastVersionID: lastVersionID, limit: limit).invoke(on: queue)
    }
    public static func invoke(objectID: String = String(), lastVersionID: String = String(), limit: Int32 = 0) -> Result<Response, Error> {
        return invocation(objectID: objectID, lastVersionID: lastVersionID, limit: limit).invoke()
    }
    public static func invocation(objectID: String = String(), lastVersionID: String = String(), limit: Int32 = 0) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(objectID: objectID, lastVersionID: lastVersionID, limit: limit)
        return Invocation<Request,Response>(messageName: "HistoryGetVersions", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceHistoryGetVersions(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.History.ShowVersion {
  public enum Service {
    public static func invoke(objectID: String = String(), versionID: String = String(), traceID: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(objectID: objectID, versionID: versionID, traceID: traceID).invoke(on: queue)
    }
    public static func invoke(objectID: String = String(), versionID: String = String(), traceID: String = String()) -> Result<Response, Error> {
        return invocation(objectID: objectID, versionID: versionID, traceID: traceID).invoke()
    }
    public static func invocation(objectID: String = String(), versionID: String = String(), traceID: String = String()) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(objectID: objectID, versionID: versionID, traceID: traceID)
        return Invocation<Request,Response>(messageName: "HistoryShowVersion", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceHistoryShowVersion(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.History.SetVersion {
  public enum Service {
    public static func invoke(objectID: String = String(), versionID: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(objectID: objectID, versionID: versionID).invoke(on: queue)
    }
    public static func invoke(objectID: String = String(), versionID: String = String()) -> Result<Response, Error> {
        return invocation(objectID: objectID, versionID: versionID).invoke()
    }
    public static func invocation(objectID: String = String(), versionID: String = String()) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(objectID: objectID, versionID: versionID)
        return Invocation<Request,Response>(messageName: "HistorySetVersion", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceHistorySetVersion(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.File.Offload {
  public enum Service {
    public static func invoke(id: String = String(), includeNotPinned: Bool = false, queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(id: id, includeNotPinned: includeNotPinned).invoke(on: queue)
    }
    public static func invoke(id: String = String(), includeNotPinned: Bool = false) -> Result<Response, Error> {
        return invocation(id: id, includeNotPinned: includeNotPinned).invoke()
    }
    public static func invocation(id: String = String(), includeNotPinned: Bool = false) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(id: id, includeNotPinned: includeNotPinned)
        return Invocation<Request,Response>(messageName: "FileOffload", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceFileOffload(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.File.ListOffload {
  public enum Service {
    public static func invoke(onlyIds: [String] = [], includeNotPinned: Bool = false, queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(onlyIds: onlyIds, includeNotPinned: includeNotPinned).invoke(on: queue)
    }
    public static func invoke(onlyIds: [String] = [], includeNotPinned: Bool = false) -> Result<Response, Error> {
        return invocation(onlyIds: onlyIds, includeNotPinned: includeNotPinned).invoke()
    }
    public static func invocation(onlyIds: [String] = [], includeNotPinned: Bool = false) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(onlyIds: onlyIds, includeNotPinned: includeNotPinned)
        return Invocation<Request,Response>(messageName: "FileListOffload", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceFileListOffload(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.File.Upload {
  public enum Service {
    public static func invoke(url: String = String(), localPath: String = String(), type: Anytype_Model_Block.Content.File.TypeEnum = .none, disableEncryption: Bool = false, style: Anytype_Model_Block.Content.File.Style = .auto, queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(url: url, localPath: localPath, type: type, disableEncryption: disableEncryption, style: style).invoke(on: queue)
    }
    public static func invoke(url: String = String(), localPath: String = String(), type: Anytype_Model_Block.Content.File.TypeEnum = .none, disableEncryption: Bool = false, style: Anytype_Model_Block.Content.File.Style = .auto) -> Result<Response, Error> {
        return invocation(url: url, localPath: localPath, type: type, disableEncryption: disableEncryption, style: style).invoke()
    }
    public static func invocation(url: String = String(), localPath: String = String(), type: Anytype_Model_Block.Content.File.TypeEnum = .none, disableEncryption: Bool = false, style: Anytype_Model_Block.Content.File.Style = .auto) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(url: url, localPath: localPath, type: type, disableEncryption: disableEncryption, style: style)
        return Invocation<Request,Response>(messageName: "FileUpload", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceFileUpload(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.File.Download {
  public enum Service {
    public static func invoke(hash: String = String(), path: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(hash: hash, path: path).invoke(on: queue)
    }
    public static func invoke(hash: String = String(), path: String = String()) -> Result<Response, Error> {
        return invocation(hash: hash, path: path).invoke()
    }
    public static func invocation(hash: String = String(), path: String = String()) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(hash: hash, path: path)
        return Invocation<Request,Response>(messageName: "FileDownload", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceFileDownload(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.File.Drop {
  public enum Service {
    public static func invoke(contextID: String = String(), dropTargetID: String = String(), position: Anytype_Model_Block.Position = .none, localFilePaths: [String] = [], queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, dropTargetID: dropTargetID, position: position, localFilePaths: localFilePaths).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), dropTargetID: String = String(), position: Anytype_Model_Block.Position = .none, localFilePaths: [String] = []) -> Result<Response, Error> {
        return invocation(contextID: contextID, dropTargetID: dropTargetID, position: position, localFilePaths: localFilePaths).invoke()
    }
    public static func invocation(contextID: String = String(), dropTargetID: String = String(), position: Anytype_Model_Block.Position = .none, localFilePaths: [String] = []) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, dropTargetID: dropTargetID, position: position, localFilePaths: localFilePaths)
        return Invocation<Request,Response>(messageName: "FileDrop", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceFileDrop(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Navigation.ListObjects {
  public enum Service {
    public static func invoke(context: Anytype_Rpc.Navigation.Context = .navigation, fullText: String = String(), limit: Int32 = 0, offset: Int32 = 0, queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(context: context, fullText: fullText, limit: limit, offset: offset).invoke(on: queue)
    }
    public static func invoke(context: Anytype_Rpc.Navigation.Context = .navigation, fullText: String = String(), limit: Int32 = 0, offset: Int32 = 0) -> Result<Response, Error> {
        return invocation(context: context, fullText: fullText, limit: limit, offset: offset).invoke()
    }
    public static func invocation(context: Anytype_Rpc.Navigation.Context = .navigation, fullText: String = String(), limit: Int32 = 0, offset: Int32 = 0) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(context: context, fullText: fullText, limit: limit, offset: offset)
        return Invocation<Request,Response>(messageName: "NavigationListObjects", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceNavigationListObjects(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Navigation.GetObjectInfoWithLinks {
  public enum Service {
    public static func invoke(objectID: String = String(), context: Anytype_Rpc.Navigation.Context = .navigation, queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(objectID: objectID, context: context).invoke(on: queue)
    }
    public static func invoke(objectID: String = String(), context: Anytype_Rpc.Navigation.Context = .navigation) -> Result<Response, Error> {
        return invocation(objectID: objectID, context: context).invoke()
    }
    public static func invocation(objectID: String = String(), context: Anytype_Rpc.Navigation.Context = .navigation) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(objectID: objectID, context: context)
        return Invocation<Request,Response>(messageName: "NavigationGetObjectInfoWithLinks", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceNavigationGetObjectInfoWithLinks(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Template.CreateFromObject {
  public enum Service {
    public static func invoke(contextID: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID).invoke(on: queue)
    }
    public static func invoke(contextID: String = String()) -> Result<Response, Error> {
        return invocation(contextID: contextID).invoke()
    }
    public static func invocation(contextID: String = String()) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID)
        return Invocation<Request,Response>(messageName: "TemplateCreateFromObject", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceTemplateCreateFromObject(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Template.CreateFromObjectType {
  public enum Service {
    public static func invoke(objectType: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(objectType: objectType).invoke(on: queue)
    }
    public static func invoke(objectType: String = String()) -> Result<Response, Error> {
        return invocation(objectType: objectType).invoke()
    }
    public static func invocation(objectType: String = String()) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(objectType: objectType)
        return Invocation<Request,Response>(messageName: "TemplateCreateFromObjectType", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceTemplateCreateFromObjectType(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Template.Clone {
  public enum Service {
    public static func invoke(contextID: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID).invoke(on: queue)
    }
    public static func invoke(contextID: String = String()) -> Result<Response, Error> {
        return invocation(contextID: contextID).invoke()
    }
    public static func invocation(contextID: String = String()) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID)
        return Invocation<Request,Response>(messageName: "TemplateClone", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceTemplateClone(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Template.ExportAll {
  public enum Service {
    public static func invoke(path: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(path: path).invoke(on: queue)
    }
    public static func invoke(path: String = String()) -> Result<Response, Error> {
        return invocation(path: path).invoke()
    }
    public static func invocation(path: String = String()) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(path: path)
        return Invocation<Request,Response>(messageName: "TemplateExportAll", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceTemplateExportAll(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.LinkPreview {
  public enum Service {
    public static func invoke(url: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(url: url).invoke(on: queue)
    }
    public static func invoke(url: String = String()) -> Result<Response, Error> {
        return invocation(url: url).invoke()
    }
    public static func invocation(url: String = String()) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(url: url)
        return Invocation<Request,Response>(messageName: "LinkPreview", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceLinkPreview(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Unsplash.Search {
  public enum Service {
    public static func invoke(query: String = String(), limit: Int32 = 0, queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(query: query, limit: limit).invoke(on: queue)
    }
    public static func invoke(query: String = String(), limit: Int32 = 0) -> Result<Response, Error> {
        return invocation(query: query, limit: limit).invoke()
    }
    public static func invocation(query: String = String(), limit: Int32 = 0) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(query: query, limit: limit)
        return Invocation<Request,Response>(messageName: "UnsplashSearch", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceUnsplashSearch(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Unsplash.Download {
  public enum Service {
    public static func invoke(pictureID: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(pictureID: pictureID).invoke(on: queue)
    }
    public static func invoke(pictureID: String = String()) -> Result<Response, Error> {
        return invocation(pictureID: pictureID).invoke()
    }
    public static func invocation(pictureID: String = String()) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(pictureID: pictureID)
        return Invocation<Request,Response>(messageName: "UnsplashDownload", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceUnsplashDownload(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Block.Replace {
  public enum Service {
    public static func invoke(contextID: String = String(), blockID: String = String(), block: Anytype_Model_Block, queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, blockID: blockID, block: block).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), blockID: String = String(), block: Anytype_Model_Block) -> Result<Response, Error> {
        return invocation(contextID: contextID, blockID: blockID, block: block).invoke()
    }
    public static func invocation(contextID: String = String(), blockID: String = String(), block: Anytype_Model_Block) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, blockID: blockID, block: block)
        return Invocation<Request,Response>(messageName: "BlockReplace", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceBlockReplace(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Block.Split {
  public enum Service {
    public static func invoke(contextID: String = String(), blockID: String = String(), range: Anytype_Model_Range, style: Anytype_Model_Block.Content.Text.Style = .paragraph, mode: Anytype_Rpc.Block.Split.Request.Mode = .bottom, queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, blockID: blockID, range: range, style: style, mode: mode).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), blockID: String = String(), range: Anytype_Model_Range, style: Anytype_Model_Block.Content.Text.Style = .paragraph, mode: Anytype_Rpc.Block.Split.Request.Mode = .bottom) -> Result<Response, Error> {
        return invocation(contextID: contextID, blockID: blockID, range: range, style: style, mode: mode).invoke()
    }
    public static func invocation(contextID: String = String(), blockID: String = String(), range: Anytype_Model_Range, style: Anytype_Model_Block.Content.Text.Style = .paragraph, mode: Anytype_Rpc.Block.Split.Request.Mode = .bottom) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, blockID: blockID, range: range, style: style, mode: mode)
        return Invocation<Request,Response>(messageName: "BlockSplit", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceBlockSplit(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Block.Merge {
  public enum Service {
    public static func invoke(contextID: String = String(), firstBlockID: String = String(), secondBlockID: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, firstBlockID: firstBlockID, secondBlockID: secondBlockID).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), firstBlockID: String = String(), secondBlockID: String = String()) -> Result<Response, Error> {
        return invocation(contextID: contextID, firstBlockID: firstBlockID, secondBlockID: secondBlockID).invoke()
    }
    public static func invocation(contextID: String = String(), firstBlockID: String = String(), secondBlockID: String = String()) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, firstBlockID: firstBlockID, secondBlockID: secondBlockID)
        return Invocation<Request,Response>(messageName: "BlockMerge", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceBlockMerge(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Block.Copy {
  public enum Service {
    public static func invoke(contextID: String = String(), blocks: [Anytype_Model_Block] = [], selectedTextRange: Anytype_Model_Range, queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, blocks: blocks, selectedTextRange: selectedTextRange).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), blocks: [Anytype_Model_Block] = [], selectedTextRange: Anytype_Model_Range) -> Result<Response, Error> {
        return invocation(contextID: contextID, blocks: blocks, selectedTextRange: selectedTextRange).invoke()
    }
    public static func invocation(contextID: String = String(), blocks: [Anytype_Model_Block] = [], selectedTextRange: Anytype_Model_Range) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, blocks: blocks, selectedTextRange: selectedTextRange)
        return Invocation<Request,Response>(messageName: "BlockCopy", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceBlockCopy(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Block.Paste {
  public enum Service {
    public static func invoke(contextID: String = String(), focusedBlockID: String = String(), selectedTextRange: Anytype_Model_Range, selectedBlockIds: [String] = [], isPartOfBlock: Bool = false, textSlot: String = String(), htmlSlot: String = String(), anySlot: [Anytype_Model_Block] = [], fileSlot: [Anytype_Rpc.Block.Paste.Request.File] = [], queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, focusedBlockID: focusedBlockID, selectedTextRange: selectedTextRange, selectedBlockIds: selectedBlockIds, isPartOfBlock: isPartOfBlock, textSlot: textSlot, htmlSlot: htmlSlot, anySlot: anySlot, fileSlot: fileSlot).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), focusedBlockID: String = String(), selectedTextRange: Anytype_Model_Range, selectedBlockIds: [String] = [], isPartOfBlock: Bool = false, textSlot: String = String(), htmlSlot: String = String(), anySlot: [Anytype_Model_Block] = [], fileSlot: [Anytype_Rpc.Block.Paste.Request.File] = []) -> Result<Response, Error> {
        return invocation(contextID: contextID, focusedBlockID: focusedBlockID, selectedTextRange: selectedTextRange, selectedBlockIds: selectedBlockIds, isPartOfBlock: isPartOfBlock, textSlot: textSlot, htmlSlot: htmlSlot, anySlot: anySlot, fileSlot: fileSlot).invoke()
    }
    public static func invocation(contextID: String = String(), focusedBlockID: String = String(), selectedTextRange: Anytype_Model_Range, selectedBlockIds: [String] = [], isPartOfBlock: Bool = false, textSlot: String = String(), htmlSlot: String = String(), anySlot: [Anytype_Model_Block] = [], fileSlot: [Anytype_Rpc.Block.Paste.Request.File] = []) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, focusedBlockID: focusedBlockID, selectedTextRange: selectedTextRange, selectedBlockIds: selectedBlockIds, isPartOfBlock: isPartOfBlock, textSlot: textSlot, htmlSlot: htmlSlot, anySlot: anySlot, fileSlot: fileSlot)
        return Invocation<Request,Response>(messageName: "BlockPaste", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceBlockPaste(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Block.Cut {
  public enum Service {
    public static func invoke(contextID: String = String(), blocks: [Anytype_Model_Block] = [], selectedTextRange: Anytype_Model_Range, queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, blocks: blocks, selectedTextRange: selectedTextRange).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), blocks: [Anytype_Model_Block] = [], selectedTextRange: Anytype_Model_Range) -> Result<Response, Error> {
        return invocation(contextID: contextID, blocks: blocks, selectedTextRange: selectedTextRange).invoke()
    }
    public static func invocation(contextID: String = String(), blocks: [Anytype_Model_Block] = [], selectedTextRange: Anytype_Model_Range) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, blocks: blocks, selectedTextRange: selectedTextRange)
        return Invocation<Request,Response>(messageName: "BlockCut", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceBlockCut(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Block.Upload {
  public enum Service {
    public static func invoke(contextID: String = String(), blockID: String = String(), filePath: String = String(), url: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, blockID: blockID, filePath: filePath, url: url).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), blockID: String = String(), filePath: String = String(), url: String = String()) -> Result<Response, Error> {
        return invocation(contextID: contextID, blockID: blockID, filePath: filePath, url: url).invoke()
    }
    public static func invocation(contextID: String = String(), blockID: String = String(), filePath: String = String(), url: String = String()) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, blockID: blockID, filePath: filePath, url: url)
        return Invocation<Request,Response>(messageName: "BlockUpload", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceBlockUpload(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Block.Create {
  public enum Service {
    public static func invoke(contextID: String = String(), targetID: String = String(), block: Anytype_Model_Block, position: Anytype_Model_Block.Position = .none, queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, targetID: targetID, block: block, position: position).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), targetID: String = String(), block: Anytype_Model_Block, position: Anytype_Model_Block.Position = .none) -> Result<Response, Error> {
        return invocation(contextID: contextID, targetID: targetID, block: block, position: position).invoke()
    }
    public static func invocation(contextID: String = String(), targetID: String = String(), block: Anytype_Model_Block, position: Anytype_Model_Block.Position = .none) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, targetID: targetID, block: block, position: position)
        return Invocation<Request,Response>(messageName: "BlockCreate", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceBlockCreate(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Block.ListDelete {
  public enum Service {
    public static func invoke(contextID: String = String(), blockIds: [String] = [], queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, blockIds: blockIds).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), blockIds: [String] = []) -> Result<Response, Error> {
        return invocation(contextID: contextID, blockIds: blockIds).invoke()
    }
    public static func invocation(contextID: String = String(), blockIds: [String] = []) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, blockIds: blockIds)
        return Invocation<Request,Response>(messageName: "BlockListDelete", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceBlockListDelete(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Block.SetFields {
  public enum Service {
    public static func invoke(contextID: String = String(), blockID: String = String(), fields: SwiftProtobuf.Google_Protobuf_Struct, queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, blockID: blockID, fields: fields).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), blockID: String = String(), fields: SwiftProtobuf.Google_Protobuf_Struct) -> Result<Response, Error> {
        return invocation(contextID: contextID, blockID: blockID, fields: fields).invoke()
    }
    public static func invocation(contextID: String = String(), blockID: String = String(), fields: SwiftProtobuf.Google_Protobuf_Struct) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, blockID: blockID, fields: fields)
        return Invocation<Request,Response>(messageName: "BlockSetFields", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceBlockSetFields(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Block.ListSetAlign {
  public enum Service {
    public static func invoke(contextID: String = String(), blockIds: [String] = [], align: Anytype_Model_Block.Align = .left, queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, blockIds: blockIds, align: align).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), blockIds: [String] = [], align: Anytype_Model_Block.Align = .left) -> Result<Response, Error> {
        return invocation(contextID: contextID, blockIds: blockIds, align: align).invoke()
    }
    public static func invocation(contextID: String = String(), blockIds: [String] = [], align: Anytype_Model_Block.Align = .left) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, blockIds: blockIds, align: align)
        return Invocation<Request,Response>(messageName: "BlockListSetAlign", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceBlockListSetAlign(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Block.ListSetVerticalAlign {
  public enum Service {
    public static func invoke(contextID: String = String(), blockIds: [String] = [], verticalAlign: Anytype_Model_Block.VerticalAlign = .top, queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, blockIds: blockIds, verticalAlign: verticalAlign).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), blockIds: [String] = [], verticalAlign: Anytype_Model_Block.VerticalAlign = .top) -> Result<Response, Error> {
        return invocation(contextID: contextID, blockIds: blockIds, verticalAlign: verticalAlign).invoke()
    }
    public static func invocation(contextID: String = String(), blockIds: [String] = [], verticalAlign: Anytype_Model_Block.VerticalAlign = .top) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, blockIds: blockIds, verticalAlign: verticalAlign)
        return Invocation<Request,Response>(messageName: "BlockListSetVerticalAlign", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceBlockListSetVerticalAlign(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Block.ListSetFields {
  public enum Service {
    public static func invoke(contextID: String = String(), blockFields: [Anytype_Rpc.Block.ListSetFields.Request.BlockField] = [], queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, blockFields: blockFields).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), blockFields: [Anytype_Rpc.Block.ListSetFields.Request.BlockField] = []) -> Result<Response, Error> {
        return invocation(contextID: contextID, blockFields: blockFields).invoke()
    }
    public static func invocation(contextID: String = String(), blockFields: [Anytype_Rpc.Block.ListSetFields.Request.BlockField] = []) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, blockFields: blockFields)
        return Invocation<Request,Response>(messageName: "BlockListSetFields", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceBlockListSetFields(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Block.ListDuplicate {
  public enum Service {
    public static func invoke(contextID: String = String(), targetID: String = String(), blockIds: [String] = [], position: Anytype_Model_Block.Position = .none, targetContextID: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, targetID: targetID, blockIds: blockIds, position: position, targetContextID: targetContextID).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), targetID: String = String(), blockIds: [String] = [], position: Anytype_Model_Block.Position = .none, targetContextID: String = String()) -> Result<Response, Error> {
        return invocation(contextID: contextID, targetID: targetID, blockIds: blockIds, position: position, targetContextID: targetContextID).invoke()
    }
    public static func invocation(contextID: String = String(), targetID: String = String(), blockIds: [String] = [], position: Anytype_Model_Block.Position = .none, targetContextID: String = String()) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, targetID: targetID, blockIds: blockIds, position: position, targetContextID: targetContextID)
        return Invocation<Request,Response>(messageName: "BlockListDuplicate", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceBlockListDuplicate(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Block.ListConvertToObjects {
  public enum Service {
    public static func invoke(contextID: String = String(), blockIds: [String] = [], objectType: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, blockIds: blockIds, objectType: objectType).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), blockIds: [String] = [], objectType: String = String()) -> Result<Response, Error> {
        return invocation(contextID: contextID, blockIds: blockIds, objectType: objectType).invoke()
    }
    public static func invocation(contextID: String = String(), blockIds: [String] = [], objectType: String = String()) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, blockIds: blockIds, objectType: objectType)
        return Invocation<Request,Response>(messageName: "BlockListConvertToObjects", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceBlockListConvertToObjects(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Block.ListMoveToExistingObject {
  public enum Service {
    public static func invoke(contextID: String = String(), blockIds: [String] = [], targetContextID: String = String(), dropTargetID: String = String(), position: Anytype_Model_Block.Position = .none, queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, blockIds: blockIds, targetContextID: targetContextID, dropTargetID: dropTargetID, position: position).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), blockIds: [String] = [], targetContextID: String = String(), dropTargetID: String = String(), position: Anytype_Model_Block.Position = .none) -> Result<Response, Error> {
        return invocation(contextID: contextID, blockIds: blockIds, targetContextID: targetContextID, dropTargetID: dropTargetID, position: position).invoke()
    }
    public static func invocation(contextID: String = String(), blockIds: [String] = [], targetContextID: String = String(), dropTargetID: String = String(), position: Anytype_Model_Block.Position = .none) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, blockIds: blockIds, targetContextID: targetContextID, dropTargetID: dropTargetID, position: position)
        return Invocation<Request,Response>(messageName: "BlockListMoveToExistingObject", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceBlockListMoveToExistingObject(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Block.ListMoveToNewObject {
  public enum Service {
    public static func invoke(contextID: String = String(), blockIds: [String] = [], details: SwiftProtobuf.Google_Protobuf_Struct, dropTargetID: String = String(), position: Anytype_Model_Block.Position = .none, queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, blockIds: blockIds, details: details, dropTargetID: dropTargetID, position: position).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), blockIds: [String] = [], details: SwiftProtobuf.Google_Protobuf_Struct, dropTargetID: String = String(), position: Anytype_Model_Block.Position = .none) -> Result<Response, Error> {
        return invocation(contextID: contextID, blockIds: blockIds, details: details, dropTargetID: dropTargetID, position: position).invoke()
    }
    public static func invocation(contextID: String = String(), blockIds: [String] = [], details: SwiftProtobuf.Google_Protobuf_Struct, dropTargetID: String = String(), position: Anytype_Model_Block.Position = .none) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, blockIds: blockIds, details: details, dropTargetID: dropTargetID, position: position)
        return Invocation<Request,Response>(messageName: "BlockListMoveToNewObject", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceBlockListMoveToNewObject(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Block.ListTurnInto {
  public enum Service {
    public static func invoke(contextID: String = String(), blockIds: [String] = [], style: Anytype_Model_Block.Content.Text.Style = .paragraph, queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, blockIds: blockIds, style: style).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), blockIds: [String] = [], style: Anytype_Model_Block.Content.Text.Style = .paragraph) -> Result<Response, Error> {
        return invocation(contextID: contextID, blockIds: blockIds, style: style).invoke()
    }
    public static func invocation(contextID: String = String(), blockIds: [String] = [], style: Anytype_Model_Block.Content.Text.Style = .paragraph) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, blockIds: blockIds, style: style)
        return Invocation<Request,Response>(messageName: "BlockListTurnInto", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceBlockListTurnInto(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Block.ListSetBackgroundColor {
  public enum Service {
    public static func invoke(contextID: String = String(), blockIds: [String] = [], color: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, blockIds: blockIds, color: color).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), blockIds: [String] = [], color: String = String()) -> Result<Response, Error> {
        return invocation(contextID: contextID, blockIds: blockIds, color: color).invoke()
    }
    public static func invocation(contextID: String = String(), blockIds: [String] = [], color: String = String()) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, blockIds: blockIds, color: color)
        return Invocation<Request,Response>(messageName: "BlockListSetBackgroundColor", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceBlockListSetBackgroundColor(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Block.Export {
  public enum Service {
    public static func invoke(contextID: String = String(), blocks: [Anytype_Model_Block] = [], queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, blocks: blocks).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), blocks: [Anytype_Model_Block] = []) -> Result<Response, Error> {
        return invocation(contextID: contextID, blocks: blocks).invoke()
    }
    public static func invocation(contextID: String = String(), blocks: [Anytype_Model_Block] = []) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, blocks: blocks)
        return Invocation<Request,Response>(messageName: "BlockExport", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceBlockExport(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.BlockLatex.SetText {
  public enum Service {
    public static func invoke(contextID: String = String(), blockID: String = String(), text: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, blockID: blockID, text: text).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), blockID: String = String(), text: String = String()) -> Result<Response, Error> {
        return invocation(contextID: contextID, blockID: blockID, text: text).invoke()
    }
    public static func invocation(contextID: String = String(), blockID: String = String(), text: String = String()) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, blockID: blockID, text: text)
        return Invocation<Request,Response>(messageName: "BlockLatexSetText", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceBlockLatexSetText(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.BlockText.SetText {
  public enum Service {
    public static func invoke(contextID: String = String(), blockID: String = String(), text: String = String(), marks: Anytype_Model_Block.Content.Text.Marks, queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, blockID: blockID, text: text, marks: marks).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), blockID: String = String(), text: String = String(), marks: Anytype_Model_Block.Content.Text.Marks) -> Result<Response, Error> {
        return invocation(contextID: contextID, blockID: blockID, text: text, marks: marks).invoke()
    }
    public static func invocation(contextID: String = String(), blockID: String = String(), text: String = String(), marks: Anytype_Model_Block.Content.Text.Marks) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, blockID: blockID, text: text, marks: marks)
        return Invocation<Request,Response>(messageName: "BlockTextSetText", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceBlockTextSetText(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.BlockText.SetColor {
  public enum Service {
    public static func invoke(contextID: String = String(), blockID: String = String(), color: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, blockID: blockID, color: color).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), blockID: String = String(), color: String = String()) -> Result<Response, Error> {
        return invocation(contextID: contextID, blockID: blockID, color: color).invoke()
    }
    public static func invocation(contextID: String = String(), blockID: String = String(), color: String = String()) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, blockID: blockID, color: color)
        return Invocation<Request,Response>(messageName: "BlockTextSetColor", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceBlockTextSetColor(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.BlockText.SetStyle {
  public enum Service {
    public static func invoke(contextID: String = String(), blockID: String = String(), style: Anytype_Model_Block.Content.Text.Style = .paragraph, queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, blockID: blockID, style: style).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), blockID: String = String(), style: Anytype_Model_Block.Content.Text.Style = .paragraph) -> Result<Response, Error> {
        return invocation(contextID: contextID, blockID: blockID, style: style).invoke()
    }
    public static func invocation(contextID: String = String(), blockID: String = String(), style: Anytype_Model_Block.Content.Text.Style = .paragraph) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, blockID: blockID, style: style)
        return Invocation<Request,Response>(messageName: "BlockTextSetStyle", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceBlockTextSetStyle(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.BlockText.SetChecked {
  public enum Service {
    public static func invoke(contextID: String = String(), blockID: String = String(), checked: Bool = false, queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, blockID: blockID, checked: checked).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), blockID: String = String(), checked: Bool = false) -> Result<Response, Error> {
        return invocation(contextID: contextID, blockID: blockID, checked: checked).invoke()
    }
    public static func invocation(contextID: String = String(), blockID: String = String(), checked: Bool = false) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, blockID: blockID, checked: checked)
        return Invocation<Request,Response>(messageName: "BlockTextSetChecked", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceBlockTextSetChecked(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.BlockText.SetIcon {
  public enum Service {
    public static func invoke(contextID: String = String(), blockID: String = String(), iconImage: String = String(), iconEmoji: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, blockID: blockID, iconImage: iconImage, iconEmoji: iconEmoji).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), blockID: String = String(), iconImage: String = String(), iconEmoji: String = String()) -> Result<Response, Error> {
        return invocation(contextID: contextID, blockID: blockID, iconImage: iconImage, iconEmoji: iconEmoji).invoke()
    }
    public static func invocation(contextID: String = String(), blockID: String = String(), iconImage: String = String(), iconEmoji: String = String()) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, blockID: blockID, iconImage: iconImage, iconEmoji: iconEmoji)
        return Invocation<Request,Response>(messageName: "BlockTextSetIcon", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceBlockTextSetIcon(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.BlockText.ListSetStyle {
  public enum Service {
    public static func invoke(contextID: String = String(), blockIds: [String] = [], style: Anytype_Model_Block.Content.Text.Style = .paragraph, queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, blockIds: blockIds, style: style).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), blockIds: [String] = [], style: Anytype_Model_Block.Content.Text.Style = .paragraph) -> Result<Response, Error> {
        return invocation(contextID: contextID, blockIds: blockIds, style: style).invoke()
    }
    public static func invocation(contextID: String = String(), blockIds: [String] = [], style: Anytype_Model_Block.Content.Text.Style = .paragraph) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, blockIds: blockIds, style: style)
        return Invocation<Request,Response>(messageName: "BlockTextListSetStyle", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceBlockTextListSetStyle(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.BlockText.ListSetColor {
  public enum Service {
    public static func invoke(contextID: String = String(), blockIds: [String] = [], color: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, blockIds: blockIds, color: color).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), blockIds: [String] = [], color: String = String()) -> Result<Response, Error> {
        return invocation(contextID: contextID, blockIds: blockIds, color: color).invoke()
    }
    public static func invocation(contextID: String = String(), blockIds: [String] = [], color: String = String()) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, blockIds: blockIds, color: color)
        return Invocation<Request,Response>(messageName: "BlockTextListSetColor", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceBlockTextListSetColor(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.BlockText.ListSetMark {
  public enum Service {
    public static func invoke(contextID: String = String(), blockIds: [String] = [], mark: Anytype_Model_Block.Content.Text.Mark, queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, blockIds: blockIds, mark: mark).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), blockIds: [String] = [], mark: Anytype_Model_Block.Content.Text.Mark) -> Result<Response, Error> {
        return invocation(contextID: contextID, blockIds: blockIds, mark: mark).invoke()
    }
    public static func invocation(contextID: String = String(), blockIds: [String] = [], mark: Anytype_Model_Block.Content.Text.Mark) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, blockIds: blockIds, mark: mark)
        return Invocation<Request,Response>(messageName: "BlockTextListSetMark", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceBlockTextListSetMark(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.BlockText.ListClearStyle {
  public enum Service {
    public static func invoke(contextID: String = String(), blockIds: [String] = [], queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, blockIds: blockIds).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), blockIds: [String] = []) -> Result<Response, Error> {
        return invocation(contextID: contextID, blockIds: blockIds).invoke()
    }
    public static func invocation(contextID: String = String(), blockIds: [String] = []) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, blockIds: blockIds)
        return Invocation<Request,Response>(messageName: "BlockTextListClearStyle", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceBlockTextListClearStyle(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.BlockText.ListClearContent {
  public enum Service {
    public static func invoke(contextID: String = String(), blockIds: [String] = [], queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, blockIds: blockIds).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), blockIds: [String] = []) -> Result<Response, Error> {
        return invocation(contextID: contextID, blockIds: blockIds).invoke()
    }
    public static func invocation(contextID: String = String(), blockIds: [String] = []) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, blockIds: blockIds)
        return Invocation<Request,Response>(messageName: "BlockTextListClearContent", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceBlockTextListClearContent(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.BlockTable.Create {
  public enum Service {
    public static func invoke(contextID: String = String(), targetID: String = String(), position: Anytype_Model_Block.Position = .none, rows: UInt32 = 0, columns: UInt32 = 0, withHeaderRow: Bool = false, queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, targetID: targetID, position: position, rows: rows, columns: columns, withHeaderRow: withHeaderRow).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), targetID: String = String(), position: Anytype_Model_Block.Position = .none, rows: UInt32 = 0, columns: UInt32 = 0, withHeaderRow: Bool = false) -> Result<Response, Error> {
        return invocation(contextID: contextID, targetID: targetID, position: position, rows: rows, columns: columns, withHeaderRow: withHeaderRow).invoke()
    }
    public static func invocation(contextID: String = String(), targetID: String = String(), position: Anytype_Model_Block.Position = .none, rows: UInt32 = 0, columns: UInt32 = 0, withHeaderRow: Bool = false) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, targetID: targetID, position: position, rows: rows, columns: columns, withHeaderRow: withHeaderRow)
        return Invocation<Request,Response>(messageName: "BlockTableCreate", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceBlockTableCreate(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.BlockTable.RowCreate {
  public enum Service {
    public static func invoke(contextID: String = String(), targetID: String = String(), position: Anytype_Model_Block.Position = .none, queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, targetID: targetID, position: position).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), targetID: String = String(), position: Anytype_Model_Block.Position = .none) -> Result<Response, Error> {
        return invocation(contextID: contextID, targetID: targetID, position: position).invoke()
    }
    public static func invocation(contextID: String = String(), targetID: String = String(), position: Anytype_Model_Block.Position = .none) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, targetID: targetID, position: position)
        return Invocation<Request,Response>(messageName: "BlockTableRowCreate", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceBlockTableRowCreate(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.BlockTable.RowSetHeader {
  public enum Service {
    public static func invoke(contextID: String = String(), targetID: String = String(), isHeader: Bool = false, queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, targetID: targetID, isHeader: isHeader).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), targetID: String = String(), isHeader: Bool = false) -> Result<Response, Error> {
        return invocation(contextID: contextID, targetID: targetID, isHeader: isHeader).invoke()
    }
    public static func invocation(contextID: String = String(), targetID: String = String(), isHeader: Bool = false) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, targetID: targetID, isHeader: isHeader)
        return Invocation<Request,Response>(messageName: "BlockTableRowSetHeader", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceBlockTableRowSetHeader(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.BlockTable.RowListFill {
  public enum Service {
    public static func invoke(contextID: String = String(), blockIds: [String] = [], queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, blockIds: blockIds).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), blockIds: [String] = []) -> Result<Response, Error> {
        return invocation(contextID: contextID, blockIds: blockIds).invoke()
    }
    public static func invocation(contextID: String = String(), blockIds: [String] = []) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, blockIds: blockIds)
        return Invocation<Request,Response>(messageName: "BlockTableRowListFill", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceBlockTableRowListFill(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.BlockTable.RowListClean {
  public enum Service {
    public static func invoke(contextID: String = String(), blockIds: [String] = [], queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, blockIds: blockIds).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), blockIds: [String] = []) -> Result<Response, Error> {
        return invocation(contextID: contextID, blockIds: blockIds).invoke()
    }
    public static func invocation(contextID: String = String(), blockIds: [String] = []) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, blockIds: blockIds)
        return Invocation<Request,Response>(messageName: "BlockTableRowListClean", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceBlockTableRowListClean(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.BlockTable.ColumnListFill {
  public enum Service {
    public static func invoke(contextID: String = String(), blockIds: [String] = [], queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, blockIds: blockIds).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), blockIds: [String] = []) -> Result<Response, Error> {
        return invocation(contextID: contextID, blockIds: blockIds).invoke()
    }
    public static func invocation(contextID: String = String(), blockIds: [String] = []) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, blockIds: blockIds)
        return Invocation<Request,Response>(messageName: "BlockTableColumnListFill", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceBlockTableColumnListFill(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.BlockTable.ColumnCreate {
  public enum Service {
    public static func invoke(contextID: String = String(), targetID: String = String(), position: Anytype_Model_Block.Position = .none, queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, targetID: targetID, position: position).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), targetID: String = String(), position: Anytype_Model_Block.Position = .none) -> Result<Response, Error> {
        return invocation(contextID: contextID, targetID: targetID, position: position).invoke()
    }
    public static func invocation(contextID: String = String(), targetID: String = String(), position: Anytype_Model_Block.Position = .none) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, targetID: targetID, position: position)
        return Invocation<Request,Response>(messageName: "BlockTableColumnCreate", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceBlockTableColumnCreate(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.BlockTable.RowDelete {
  public enum Service {
    public static func invoke(contextID: String = String(), targetID: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, targetID: targetID).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), targetID: String = String()) -> Result<Response, Error> {
        return invocation(contextID: contextID, targetID: targetID).invoke()
    }
    public static func invocation(contextID: String = String(), targetID: String = String()) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, targetID: targetID)
        return Invocation<Request,Response>(messageName: "BlockTableRowDelete", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceBlockTableRowDelete(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.BlockTable.ColumnDelete {
  public enum Service {
    public static func invoke(contextID: String = String(), targetID: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, targetID: targetID).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), targetID: String = String()) -> Result<Response, Error> {
        return invocation(contextID: contextID, targetID: targetID).invoke()
    }
    public static func invocation(contextID: String = String(), targetID: String = String()) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, targetID: targetID)
        return Invocation<Request,Response>(messageName: "BlockTableColumnDelete", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceBlockTableColumnDelete(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.BlockTable.ColumnMove {
  public enum Service {
    public static func invoke(contextID: String = String(), targetID: String = String(), dropTargetID: String = String(), position: Anytype_Model_Block.Position = .none, queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, targetID: targetID, dropTargetID: dropTargetID, position: position).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), targetID: String = String(), dropTargetID: String = String(), position: Anytype_Model_Block.Position = .none) -> Result<Response, Error> {
        return invocation(contextID: contextID, targetID: targetID, dropTargetID: dropTargetID, position: position).invoke()
    }
    public static func invocation(contextID: String = String(), targetID: String = String(), dropTargetID: String = String(), position: Anytype_Model_Block.Position = .none) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, targetID: targetID, dropTargetID: dropTargetID, position: position)
        return Invocation<Request,Response>(messageName: "BlockTableColumnMove", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceBlockTableColumnMove(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.BlockTable.RowDuplicate {
  public enum Service {
    public static func invoke(contextID: String = String(), targetID: String = String(), blockID: String = String(), position: Anytype_Model_Block.Position = .none, queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, targetID: targetID, blockID: blockID, position: position).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), targetID: String = String(), blockID: String = String(), position: Anytype_Model_Block.Position = .none) -> Result<Response, Error> {
        return invocation(contextID: contextID, targetID: targetID, blockID: blockID, position: position).invoke()
    }
    public static func invocation(contextID: String = String(), targetID: String = String(), blockID: String = String(), position: Anytype_Model_Block.Position = .none) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, targetID: targetID, blockID: blockID, position: position)
        return Invocation<Request,Response>(messageName: "BlockTableRowDuplicate", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceBlockTableRowDuplicate(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.BlockTable.ColumnDuplicate {
  public enum Service {
    public static func invoke(contextID: String = String(), targetID: String = String(), blockID: String = String(), position: Anytype_Model_Block.Position = .none, queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, targetID: targetID, blockID: blockID, position: position).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), targetID: String = String(), blockID: String = String(), position: Anytype_Model_Block.Position = .none) -> Result<Response, Error> {
        return invocation(contextID: contextID, targetID: targetID, blockID: blockID, position: position).invoke()
    }
    public static func invocation(contextID: String = String(), targetID: String = String(), blockID: String = String(), position: Anytype_Model_Block.Position = .none) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, targetID: targetID, blockID: blockID, position: position)
        return Invocation<Request,Response>(messageName: "BlockTableColumnDuplicate", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceBlockTableColumnDuplicate(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.BlockTable.Expand {
  public enum Service {
    public static func invoke(contextID: String = String(), targetID: String = String(), columns: UInt32 = 0, rows: UInt32 = 0, queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, targetID: targetID, columns: columns, rows: rows).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), targetID: String = String(), columns: UInt32 = 0, rows: UInt32 = 0) -> Result<Response, Error> {
        return invocation(contextID: contextID, targetID: targetID, columns: columns, rows: rows).invoke()
    }
    public static func invocation(contextID: String = String(), targetID: String = String(), columns: UInt32 = 0, rows: UInt32 = 0) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, targetID: targetID, columns: columns, rows: rows)
        return Invocation<Request,Response>(messageName: "BlockTableExpand", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceBlockTableExpand(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.BlockTable.Sort {
  public enum Service {
    public static func invoke(contextID: String = String(), columnID: String = String(), type: Anytype_Model_Block.Content.Dataview.Sort.TypeEnum = .asc, queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, columnID: columnID, type: type).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), columnID: String = String(), type: Anytype_Model_Block.Content.Dataview.Sort.TypeEnum = .asc) -> Result<Response, Error> {
        return invocation(contextID: contextID, columnID: columnID, type: type).invoke()
    }
    public static func invocation(contextID: String = String(), columnID: String = String(), type: Anytype_Model_Block.Content.Dataview.Sort.TypeEnum = .asc) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, columnID: columnID, type: type)
        return Invocation<Request,Response>(messageName: "BlockTableSort", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceBlockTableSort(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.BlockFile.SetName {
  public enum Service {
    public static func invoke(contextID: String = String(), blockID: String = String(), name: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, blockID: blockID, name: name).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), blockID: String = String(), name: String = String()) -> Result<Response, Error> {
        return invocation(contextID: contextID, blockID: blockID, name: name).invoke()
    }
    public static func invocation(contextID: String = String(), blockID: String = String(), name: String = String()) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, blockID: blockID, name: name)
        return Invocation<Request,Response>(messageName: "BlockFileSetName", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceBlockFileSetName(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.BlockFile.CreateAndUpload {
  public enum Service {
    public static func invoke(contextID: String = String(), targetID: String = String(), position: Anytype_Model_Block.Position = .none, url: String = String(), localPath: String = String(), fileType: Anytype_Model_Block.Content.File.TypeEnum = .none, queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, targetID: targetID, position: position, url: url, localPath: localPath, fileType: fileType).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), targetID: String = String(), position: Anytype_Model_Block.Position = .none, url: String = String(), localPath: String = String(), fileType: Anytype_Model_Block.Content.File.TypeEnum = .none) -> Result<Response, Error> {
        return invocation(contextID: contextID, targetID: targetID, position: position, url: url, localPath: localPath, fileType: fileType).invoke()
    }
    public static func invocation(contextID: String = String(), targetID: String = String(), position: Anytype_Model_Block.Position = .none, url: String = String(), localPath: String = String(), fileType: Anytype_Model_Block.Content.File.TypeEnum = .none) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, targetID: targetID, position: position, url: url, localPath: localPath, fileType: fileType)
        return Invocation<Request,Response>(messageName: "BlockFileCreateAndUpload", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceBlockFileCreateAndUpload(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.BlockFile.ListSetStyle {
  public enum Service {
    public static func invoke(contextID: String = String(), blockIds: [String] = [], style: Anytype_Model_Block.Content.File.Style = .auto, queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, blockIds: blockIds, style: style).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), blockIds: [String] = [], style: Anytype_Model_Block.Content.File.Style = .auto) -> Result<Response, Error> {
        return invocation(contextID: contextID, blockIds: blockIds, style: style).invoke()
    }
    public static func invocation(contextID: String = String(), blockIds: [String] = [], style: Anytype_Model_Block.Content.File.Style = .auto) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, blockIds: blockIds, style: style)
        return Invocation<Request,Response>(messageName: "BlockFileListSetStyle", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceBlockFileListSetStyle(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.BlockImage.SetName {
  public enum Service {
    public static func invoke(contextID: String = String(), blockID: String = String(), name: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, blockID: blockID, name: name).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), blockID: String = String(), name: String = String()) -> Result<Response, Error> {
        return invocation(contextID: contextID, blockID: blockID, name: name).invoke()
    }
    public static func invocation(contextID: String = String(), blockID: String = String(), name: String = String()) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, blockID: blockID, name: name)
        return Invocation<Request,Response>(messageName: "BlockImageSetName", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceBlockImageSetName(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.BlockVideo.SetName {
  public enum Service {
    public static func invoke(contextID: String = String(), blockID: String = String(), name: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, blockID: blockID, name: name).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), blockID: String = String(), name: String = String()) -> Result<Response, Error> {
        return invocation(contextID: contextID, blockID: blockID, name: name).invoke()
    }
    public static func invocation(contextID: String = String(), blockID: String = String(), name: String = String()) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, blockID: blockID, name: name)
        return Invocation<Request,Response>(messageName: "BlockVideoSetName", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceBlockVideoSetName(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.BlockLink.CreateWithObject {
  public enum Service {
    public static func invoke(contextID: String = String(), details: SwiftProtobuf.Google_Protobuf_Struct, templateID: String = String(), internalFlags: [Anytype_Model_InternalFlag] = [], targetID: String = String(), position: Anytype_Model_Block.Position = .none, fields: SwiftProtobuf.Google_Protobuf_Struct, queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, details: details, templateID: templateID, internalFlags: internalFlags, targetID: targetID, position: position, fields: fields).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), details: SwiftProtobuf.Google_Protobuf_Struct, templateID: String = String(), internalFlags: [Anytype_Model_InternalFlag] = [], targetID: String = String(), position: Anytype_Model_Block.Position = .none, fields: SwiftProtobuf.Google_Protobuf_Struct) -> Result<Response, Error> {
        return invocation(contextID: contextID, details: details, templateID: templateID, internalFlags: internalFlags, targetID: targetID, position: position, fields: fields).invoke()
    }
    public static func invocation(contextID: String = String(), details: SwiftProtobuf.Google_Protobuf_Struct, templateID: String = String(), internalFlags: [Anytype_Model_InternalFlag] = [], targetID: String = String(), position: Anytype_Model_Block.Position = .none, fields: SwiftProtobuf.Google_Protobuf_Struct) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, details: details, templateID: templateID, internalFlags: internalFlags, targetID: targetID, position: position, fields: fields)
        return Invocation<Request,Response>(messageName: "BlockLinkCreateWithObject", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceBlockLinkCreateWithObject(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.BlockLink.ListSetAppearance {
  public enum Service {
    public static func invoke(contextID: String = String(), blockIds: [String] = [], iconSize: Anytype_Model_Block.Content.Link.IconSize = .sizeNone, cardStyle: Anytype_Model_Block.Content.Link.CardStyle = .text, description_p: Anytype_Model_Block.Content.Link.Description = .none, relations: [String] = [], queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, blockIds: blockIds, iconSize: iconSize, cardStyle: cardStyle, description_p: description_p, relations: relations).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), blockIds: [String] = [], iconSize: Anytype_Model_Block.Content.Link.IconSize = .sizeNone, cardStyle: Anytype_Model_Block.Content.Link.CardStyle = .text, description_p: Anytype_Model_Block.Content.Link.Description = .none, relations: [String] = []) -> Result<Response, Error> {
        return invocation(contextID: contextID, blockIds: blockIds, iconSize: iconSize, cardStyle: cardStyle, description_p: description_p, relations: relations).invoke()
    }
    public static func invocation(contextID: String = String(), blockIds: [String] = [], iconSize: Anytype_Model_Block.Content.Link.IconSize = .sizeNone, cardStyle: Anytype_Model_Block.Content.Link.CardStyle = .text, description_p: Anytype_Model_Block.Content.Link.Description = .none, relations: [String] = []) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, blockIds: blockIds, iconSize: iconSize, cardStyle: cardStyle, description_p: description_p, relations: relations)
        return Invocation<Request,Response>(messageName: "BlockLinkListSetAppearance", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceBlockLinkListSetAppearance(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.BlockRelation.SetKey {
  public enum Service {
    public static func invoke(contextID: String = String(), blockID: String = String(), key: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, blockID: blockID, key: key).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), blockID: String = String(), key: String = String()) -> Result<Response, Error> {
        return invocation(contextID: contextID, blockID: blockID, key: key).invoke()
    }
    public static func invocation(contextID: String = String(), blockID: String = String(), key: String = String()) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, blockID: blockID, key: key)
        return Invocation<Request,Response>(messageName: "BlockRelationSetKey", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceBlockRelationSetKey(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.BlockRelation.Add {
  public enum Service {
    public static func invoke(contextID: String = String(), blockID: String = String(), relationID: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, blockID: blockID, relationID: relationID).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), blockID: String = String(), relationID: String = String()) -> Result<Response, Error> {
        return invocation(contextID: contextID, blockID: blockID, relationID: relationID).invoke()
    }
    public static func invocation(contextID: String = String(), blockID: String = String(), relationID: String = String()) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, blockID: blockID, relationID: relationID)
        return Invocation<Request,Response>(messageName: "BlockRelationAdd", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceBlockRelationAdd(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.BlockBookmark.Fetch {
  public enum Service {
    public static func invoke(contextID: String = String(), blockID: String = String(), url: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, blockID: blockID, url: url).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), blockID: String = String(), url: String = String()) -> Result<Response, Error> {
        return invocation(contextID: contextID, blockID: blockID, url: url).invoke()
    }
    public static func invocation(contextID: String = String(), blockID: String = String(), url: String = String()) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, blockID: blockID, url: url)
        return Invocation<Request,Response>(messageName: "BlockBookmarkFetch", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceBlockBookmarkFetch(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.BlockBookmark.CreateAndFetch {
  public enum Service {
    public static func invoke(contextID: String = String(), targetID: String = String(), position: Anytype_Model_Block.Position = .none, url: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, targetID: targetID, position: position, url: url).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), targetID: String = String(), position: Anytype_Model_Block.Position = .none, url: String = String()) -> Result<Response, Error> {
        return invocation(contextID: contextID, targetID: targetID, position: position, url: url).invoke()
    }
    public static func invocation(contextID: String = String(), targetID: String = String(), position: Anytype_Model_Block.Position = .none, url: String = String()) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, targetID: targetID, position: position, url: url)
        return Invocation<Request,Response>(messageName: "BlockBookmarkCreateAndFetch", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceBlockBookmarkCreateAndFetch(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.BlockDiv.ListSetStyle {
  public enum Service {
    public static func invoke(contextID: String = String(), blockIds: [String] = [], style: Anytype_Model_Block.Content.Div.Style = .line, queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, blockIds: blockIds, style: style).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), blockIds: [String] = [], style: Anytype_Model_Block.Content.Div.Style = .line) -> Result<Response, Error> {
        return invocation(contextID: contextID, blockIds: blockIds, style: style).invoke()
    }
    public static func invocation(contextID: String = String(), blockIds: [String] = [], style: Anytype_Model_Block.Content.Div.Style = .line) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, blockIds: blockIds, style: style)
        return Invocation<Request,Response>(messageName: "BlockDivListSetStyle", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceBlockDivListSetStyle(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.BlockDataview.View.Create {
  public enum Service {
    public static func invoke(contextID: String = String(), blockID: String = String(), view: Anytype_Model_Block.Content.Dataview.View, queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, blockID: blockID, view: view).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), blockID: String = String(), view: Anytype_Model_Block.Content.Dataview.View) -> Result<Response, Error> {
        return invocation(contextID: contextID, blockID: blockID, view: view).invoke()
    }
    public static func invocation(contextID: String = String(), blockID: String = String(), view: Anytype_Model_Block.Content.Dataview.View) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, blockID: blockID, view: view)
        return Invocation<Request,Response>(messageName: "BlockDataviewViewCreate", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceBlockDataviewViewCreate(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.BlockDataview.View.Update {
  public enum Service {
    public static func invoke(contextID: String = String(), blockID: String = String(), viewID: String = String(), view: Anytype_Model_Block.Content.Dataview.View, queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, blockID: blockID, viewID: viewID, view: view).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), blockID: String = String(), viewID: String = String(), view: Anytype_Model_Block.Content.Dataview.View) -> Result<Response, Error> {
        return invocation(contextID: contextID, blockID: blockID, viewID: viewID, view: view).invoke()
    }
    public static func invocation(contextID: String = String(), blockID: String = String(), viewID: String = String(), view: Anytype_Model_Block.Content.Dataview.View) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, blockID: blockID, viewID: viewID, view: view)
        return Invocation<Request,Response>(messageName: "BlockDataviewViewUpdate", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceBlockDataviewViewUpdate(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.BlockDataview.View.Delete {
  public enum Service {
    public static func invoke(contextID: String = String(), blockID: String = String(), viewID: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, blockID: blockID, viewID: viewID).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), blockID: String = String(), viewID: String = String()) -> Result<Response, Error> {
        return invocation(contextID: contextID, blockID: blockID, viewID: viewID).invoke()
    }
    public static func invocation(contextID: String = String(), blockID: String = String(), viewID: String = String()) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, blockID: blockID, viewID: viewID)
        return Invocation<Request,Response>(messageName: "BlockDataviewViewDelete", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceBlockDataviewViewDelete(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.BlockDataview.View.SetActive {
  public enum Service {
    public static func invoke(contextID: String = String(), blockID: String = String(), viewID: String = String(), offset: UInt32 = 0, limit: UInt32 = 0, queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, blockID: blockID, viewID: viewID, offset: offset, limit: limit).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), blockID: String = String(), viewID: String = String(), offset: UInt32 = 0, limit: UInt32 = 0) -> Result<Response, Error> {
        return invocation(contextID: contextID, blockID: blockID, viewID: viewID, offset: offset, limit: limit).invoke()
    }
    public static func invocation(contextID: String = String(), blockID: String = String(), viewID: String = String(), offset: UInt32 = 0, limit: UInt32 = 0) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, blockID: blockID, viewID: viewID, offset: offset, limit: limit)
        return Invocation<Request,Response>(messageName: "BlockDataviewViewSetActive", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceBlockDataviewViewSetActive(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.BlockDataview.Relation.Add {
  public enum Service {
    public static func invoke(contextID: String = String(), blockID: String = String(), relationID: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, blockID: blockID, relationID: relationID).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), blockID: String = String(), relationID: String = String()) -> Result<Response, Error> {
        return invocation(contextID: contextID, blockID: blockID, relationID: relationID).invoke()
    }
    public static func invocation(contextID: String = String(), blockID: String = String(), relationID: String = String()) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, blockID: blockID, relationID: relationID)
        return Invocation<Request,Response>(messageName: "BlockDataviewRelationAdd", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceBlockDataviewRelationAdd(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.BlockDataview.Relation.Delete {
  public enum Service {
    public static func invoke(contextID: String = String(), blockID: String = String(), relationID: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, blockID: blockID, relationID: relationID).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), blockID: String = String(), relationID: String = String()) -> Result<Response, Error> {
        return invocation(contextID: contextID, blockID: blockID, relationID: relationID).invoke()
    }
    public static func invocation(contextID: String = String(), blockID: String = String(), relationID: String = String()) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, blockID: blockID, relationID: relationID)
        return Invocation<Request,Response>(messageName: "BlockDataviewRelationDelete", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceBlockDataviewRelationDelete(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.BlockDataview.Relation.ListAvailable {
  public enum Service {
    public static func invoke(contextID: String = String(), blockID: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, blockID: blockID).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), blockID: String = String()) -> Result<Response, Error> {
        return invocation(contextID: contextID, blockID: blockID).invoke()
    }
    public static func invocation(contextID: String = String(), blockID: String = String()) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, blockID: blockID)
        return Invocation<Request,Response>(messageName: "BlockDataviewRelationListAvailable", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceBlockDataviewRelationListAvailable(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.BlockDataview.SetSource {
  public enum Service {
    public static func invoke(contextID: String = String(), blockID: String = String(), source: [String] = [], queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, blockID: blockID, source: source).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), blockID: String = String(), source: [String] = []) -> Result<Response, Error> {
        return invocation(contextID: contextID, blockID: blockID, source: source).invoke()
    }
    public static func invocation(contextID: String = String(), blockID: String = String(), source: [String] = []) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, blockID: blockID, source: source)
        return Invocation<Request,Response>(messageName: "BlockDataviewSetSource", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceBlockDataviewSetSource(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.BlockDataview.GroupOrder.Update {
  public enum Service {
    public static func invoke(contextID: String = String(), blockID: String = String(), groupOrder: Anytype_Model_Block.Content.Dataview.GroupOrder, queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, blockID: blockID, groupOrder: groupOrder).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), blockID: String = String(), groupOrder: Anytype_Model_Block.Content.Dataview.GroupOrder) -> Result<Response, Error> {
        return invocation(contextID: contextID, blockID: blockID, groupOrder: groupOrder).invoke()
    }
    public static func invocation(contextID: String = String(), blockID: String = String(), groupOrder: Anytype_Model_Block.Content.Dataview.GroupOrder) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, blockID: blockID, groupOrder: groupOrder)
        return Invocation<Request,Response>(messageName: "BlockDataviewGroupOrderUpdate", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceBlockDataviewGroupOrderUpdate(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.BlockDataview.ObjectOrder.Update {
  public enum Service {
    public static func invoke(contextID: String = String(), blockID: String = String(), objectOrders: [Anytype_Model_Block.Content.Dataview.ObjectOrder] = [], queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, blockID: blockID, objectOrders: objectOrders).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), blockID: String = String(), objectOrders: [Anytype_Model_Block.Content.Dataview.ObjectOrder] = []) -> Result<Response, Error> {
        return invocation(contextID: contextID, blockID: blockID, objectOrders: objectOrders).invoke()
    }
    public static func invocation(contextID: String = String(), blockID: String = String(), objectOrders: [Anytype_Model_Block.Content.Dataview.ObjectOrder] = []) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(contextID: contextID, blockID: blockID, objectOrders: objectOrders)
        return Invocation<Request,Response>(messageName: "BlockDataviewObjectOrderUpdate", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceBlockDataviewObjectOrderUpdate(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Debug.Sync {
  public enum Service {
    public static func invoke(recordsTraverseLimit: Int32 = 0, skipEmptyLogs: Bool = false, tryToDownloadRemoteRecords: Bool = false, queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(recordsTraverseLimit: recordsTraverseLimit, skipEmptyLogs: skipEmptyLogs, tryToDownloadRemoteRecords: tryToDownloadRemoteRecords).invoke(on: queue)
    }
    public static func invoke(recordsTraverseLimit: Int32 = 0, skipEmptyLogs: Bool = false, tryToDownloadRemoteRecords: Bool = false) -> Result<Response, Error> {
        return invocation(recordsTraverseLimit: recordsTraverseLimit, skipEmptyLogs: skipEmptyLogs, tryToDownloadRemoteRecords: tryToDownloadRemoteRecords).invoke()
    }
    public static func invocation(recordsTraverseLimit: Int32 = 0, skipEmptyLogs: Bool = false, tryToDownloadRemoteRecords: Bool = false) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(recordsTraverseLimit: recordsTraverseLimit, skipEmptyLogs: skipEmptyLogs, tryToDownloadRemoteRecords: tryToDownloadRemoteRecords)
        return Invocation<Request,Response>(messageName: "DebugSync", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceDebugSync(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Debug.Thread {
  public enum Service {
    public static func invoke(threadID: String = String(), skipEmptyLogs: Bool = false, tryToDownloadRemoteRecords: Bool = false, queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(threadID: threadID, skipEmptyLogs: skipEmptyLogs, tryToDownloadRemoteRecords: tryToDownloadRemoteRecords).invoke(on: queue)
    }
    public static func invoke(threadID: String = String(), skipEmptyLogs: Bool = false, tryToDownloadRemoteRecords: Bool = false) -> Result<Response, Error> {
        return invocation(threadID: threadID, skipEmptyLogs: skipEmptyLogs, tryToDownloadRemoteRecords: tryToDownloadRemoteRecords).invoke()
    }
    public static func invocation(threadID: String = String(), skipEmptyLogs: Bool = false, tryToDownloadRemoteRecords: Bool = false) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(threadID: threadID, skipEmptyLogs: skipEmptyLogs, tryToDownloadRemoteRecords: tryToDownloadRemoteRecords)
        return Invocation<Request,Response>(messageName: "DebugThread", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceDebugThread(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Debug.Tree {
  public enum Service {
    public static func invoke(objectID: String = String(), path: String = String(), unanonymized: Bool = false, generateSvg: Bool = false, queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(objectID: objectID, path: path, unanonymized: unanonymized, generateSvg: generateSvg).invoke(on: queue)
    }
    public static func invoke(objectID: String = String(), path: String = String(), unanonymized: Bool = false, generateSvg: Bool = false) -> Result<Response, Error> {
        return invocation(objectID: objectID, path: path, unanonymized: unanonymized, generateSvg: generateSvg).invoke()
    }
    public static func invocation(objectID: String = String(), path: String = String(), unanonymized: Bool = false, generateSvg: Bool = false) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(objectID: objectID, path: path, unanonymized: unanonymized, generateSvg: generateSvg)
        return Invocation<Request,Response>(messageName: "DebugTree", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceDebugTree(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Debug.ExportLocalstore {
  public enum Service {
    public static func invoke(path: String = String(), docIds: [String] = [], queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(path: path, docIds: docIds).invoke(on: queue)
    }
    public static func invoke(path: String = String(), docIds: [String] = []) -> Result<Response, Error> {
        return invocation(path: path, docIds: docIds).invoke()
    }
    public static func invocation(path: String = String(), docIds: [String] = []) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(path: path, docIds: docIds)
        return Invocation<Request,Response>(messageName: "DebugExportLocalstore", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceDebugExportLocalstore(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Debug.Ping {
  public enum Service {
    public static func invoke(index: Int32 = 0, numberOfEventsToSend: Int32 = 0, queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(index: index, numberOfEventsToSend: numberOfEventsToSend).invoke(on: queue)
    }
    public static func invoke(index: Int32 = 0, numberOfEventsToSend: Int32 = 0) -> Result<Response, Error> {
        return invocation(index: index, numberOfEventsToSend: numberOfEventsToSend).invoke()
    }
    public static func invocation(index: Int32 = 0, numberOfEventsToSend: Int32 = 0) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(index: index, numberOfEventsToSend: numberOfEventsToSend)
        return Invocation<Request,Response>(messageName: "DebugPing", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceDebugPing(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Metrics.SetParameters {
  public enum Service {
    public static func invoke(platform: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(platform: platform).invoke(on: queue)
    }
    public static func invoke(platform: String = String()) -> Result<Response, Error> {
        return invocation(platform: platform).invoke()
    }
    public static func invocation(platform: String = String()) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(platform: platform)
        return Invocation<Request,Response>(messageName: "MetricsSetParameters", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceMetricsSetParameters(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Log.Send {
  public enum Service {
    public static func invoke(message: String = String(), level: Anytype_Rpc.Log.Send.Request.Level = .debug, queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(message: message, level: level).invoke(on: queue)
    }
    public static func invoke(message: String = String(), level: Anytype_Rpc.Log.Send.Request.Level = .debug) -> Result<Response, Error> {
        return invocation(message: message, level: level).invoke()
    }
    public static func invocation(message: String = String(), level: Anytype_Rpc.Log.Send.Request.Level = .debug) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(message: message, level: level)
        return Invocation<Request,Response>(messageName: "LogSend", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceLogSend(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.Process.Cancel {
  public enum Service {
    public static func invoke(id: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(id: id).invoke(on: queue)
    }
    public static func invoke(id: String = String()) -> Result<Response, Error> {
        return invocation(id: id).invoke()
    }
    public static func invocation(id: String = String()) -> ProtobufMessages.Invocation<Request, Response> {
        let request = Request(id: id)
        return Invocation<Request,Response>(messageName: "ProcessCancel", request: request) { request in
            return self.invoke(request)
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceProcessCancel(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

