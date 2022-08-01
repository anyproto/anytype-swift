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
    public static func invocation() -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init())
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
    public static func invocation(deviceState: Anytype_Rpc.App.SetDeviceState.Request.DeviceState = .background) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(deviceState: deviceState))
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
    public static func invocation() -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init())
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
    public static func invocation(rootPath: String = String()) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(rootPath: rootPath))
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
    public static func invocation(rootPath: String = String(), mnemonic: String = String()) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(rootPath: rootPath, mnemonic: mnemonic))
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
    public static func invocation(mnemonic: String = String(), entropy: String = String()) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(mnemonic: mnemonic, entropy: entropy))
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceWalletConvert(try? request.serializedData()).flatMap {
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
    public static func invocation(name: String = String(), avatar: Anytype_Rpc.Account.Create.Request.OneOf_Avatar? = nil, storePath: String = String(), alphaInviteCode: String = String()) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(name: name, avatar: avatar, storePath: storePath, alphaInviteCode: alphaInviteCode))
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
    public static func invocation() -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init())
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
    public static func invocation(revert: Bool = false) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(revert: revert))
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
    public static func invocation(id: String = String(), rootPath: String = String()) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(id: id, rootPath: rootPath))
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
    public static func invocation(removeData: Bool = false) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(removeData: removeData))
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
    public static func invocation(newPath: String = String()) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(newPath: newPath))
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
    public static func invocation() -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init())
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
    public static func invocation() -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init())
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
    public static func invocation(name: String = String()) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(name: name))
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
    public static func invocation(objectID: String = String(), isHighlighted: Bool = false) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(objectID: objectID, isHighlighted: isHighlighted))
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
    public static func invocation(workspaceID: String = String()) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(workspaceID: workspaceID))
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
    public static func invocation(path: String = String(), workspaceID: String = String()) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(path: path, workspaceID: workspaceID))
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
    public static func invoke(contextID: String = String(), objectID: String = String(), traceID: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, objectID: objectID, traceID: traceID).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), objectID: String = String(), traceID: String = String()) -> Result<Response, Error> {
        return invocation(contextID: contextID, objectID: objectID, traceID: traceID).invoke()
    }
    public static func invocation(contextID: String = String(), objectID: String = String(), traceID: String = String()) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, objectID: objectID, traceID: traceID))
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
    public static func invocation(contextID: String = String(), objectID: String = String()) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, objectID: objectID))
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
    public static func invoke(contextID: String = String(), objectID: String = String(), traceID: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, objectID: objectID, traceID: traceID).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), objectID: String = String(), traceID: String = String()) -> Result<Response, Error> {
        return invocation(contextID: contextID, objectID: objectID, traceID: traceID).invoke()
    }
    public static func invocation(contextID: String = String(), objectID: String = String(), traceID: String = String()) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, objectID: objectID, traceID: traceID))
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
    public static func invocation(details: SwiftProtobuf.Google_Protobuf_Struct, internalFlags: [Anytype_Model_InternalFlag] = [], templateID: String = String()) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(details: details, internalFlags: internalFlags, templateID: templateID))
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
    public static func invoke(url: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(url: url).invoke(on: queue)
    }
    public static func invoke(url: String = String()) -> Result<Response, Error> {
        return invocation(url: url).invoke()
    }
    public static func invocation(url: String = String()) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(url: url))
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceObjectCreateBookmark(try? request.serializedData()).flatMap {
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
    public static func invocation(contextID: String = String(), url: String = String()) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, url: url))
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
    public static func invocation(contextID: String = String(), url: String = String()) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, url: url))
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceObjectToBookmark(try? request.serializedData()).flatMap {
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
    public static func invocation(source: [String] = [], details: SwiftProtobuf.Google_Protobuf_Struct, templateID: String = String(), internalFlags: [Anytype_Model_InternalFlag] = []) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(source: source, details: details, templateID: templateID, internalFlags: internalFlags))
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceObjectCreateSet(try? request.serializedData()).flatMap {
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
    public static func invocation(contextID: String = String()) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID))
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
    public static func invocation(contextID: String = String(), traceID: String = String()) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, traceID: traceID))
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
    public static func invocation(breadcrumbsID: String = String(), ids: [String] = []) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(breadcrumbsID: breadcrumbsID, ids: ids))
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
    public static func invocation(contextID: String = String(), importPath: String = String()) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, importPath: importPath))
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
    public static func invocation(objectID: String = String()) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(objectID: objectID))
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
    public static func invocation(objectID: String = String(), payload: String = String()) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(objectID: objectID, payload: payload))
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
    public static func invocation(filters: [Anytype_Model_Block.Content.Dataview.Filter] = [], sorts: [Anytype_Model_Block.Content.Dataview.Sort] = [], fullText: String = String(), offset: Int32 = 0, limit: Int32 = 0, objectTypeFilter: [String] = [], keys: [String] = []) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(filters: filters, sorts: sorts, fullText: fullText, offset: offset, limit: limit, objectTypeFilter: objectTypeFilter, keys: keys))
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
    public static func invocation(filters: [Anytype_Model_Block.Content.Dataview.Filter] = [], limit: Int32 = 0, objectTypeFilter: [String] = [], keys: [String] = []) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(filters: filters, limit: limit, objectTypeFilter: objectTypeFilter, keys: keys))
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
    public static func invocation(subID: String = String(), filters: [Anytype_Model_Block.Content.Dataview.Filter] = [], sorts: [Anytype_Model_Block.Content.Dataview.Sort] = [], limit: Int64 = 0, offset: Int64 = 0, keys: [String] = [], afterID: String = String(), beforeID: String = String(), source: [String] = [], ignoreWorkspace: String = String(), noDepSubscription: Bool = false) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(subID: subID, filters: filters, sorts: sorts, limit: limit, offset: offset, keys: keys, afterID: afterID, beforeID: beforeID, source: source, ignoreWorkspace: ignoreWorkspace, noDepSubscription: noDepSubscription))
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
    public static func invocation(relationKey: String = String(), filters: [Anytype_Model_Block.Content.Dataview.Filter] = []) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(relationKey: relationKey, filters: filters))
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
    public static func invocation(subID: String = String(), ids: [String] = [], keys: [String] = [], ignoreWorkspace: String = String()) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(subID: subID, ids: ids, keys: keys, ignoreWorkspace: ignoreWorkspace))
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
    public static func invocation(subIds: [String] = []) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(subIds: subIds))
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
    public static func invocation(contextID: String = String(), layout: Anytype_Model_ObjectType.Layout = .basic) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, layout: layout))
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
    public static func invocation(contextID: String = String(), isFavorite: Bool = false) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, isFavorite: isFavorite))
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
    public static func invocation(contextID: String = String(), isArchived: Bool = false) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, isArchived: isArchived))
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
    public static func invocation(contextID: String = String(), objectTypeURL: String = String()) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, objectTypeURL: objectTypeURL))
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
    public static func invocation(contextID: String = String(), details: [Anytype_Rpc.Object.SetDetails.Detail] = []) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, details: details))
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
    public static func invocation(contextID: String = String(), source: [String] = []) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, source: source))
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
    public static func invocation(contextID: String = String()) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID))
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
    public static func invocation(contextID: String = String()) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID))
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
    public static func invocation(objectIds: [String] = []) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(objectIds: objectIds))
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
    public static func invocation(objectIds: [String] = []) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(objectIds: objectIds))
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
    public static func invocation(objectIds: [String] = [], isArchived: Bool = false) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(objectIds: objectIds, isArchived: isArchived))
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
    public static func invocation(objectIds: [String] = [], isFavorite: Bool = false) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(objectIds: objectIds, isFavorite: isFavorite))
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
    public static func invocation(contextID: String = String(), templateID: String = String()) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, templateID: templateID))
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
    public static func invocation(path: String = String(), objectIds: [String] = [], format: Anytype_Rpc.Object.ListExport.Format = .markdown, zip: Bool = false, includeNested: Bool = false, includeFiles: Bool = false) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(path: path, objectIds: objectIds, format: format, zip: zip, includeNested: includeNested, includeFiles: includeFiles))
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
    public static func invoke(contextID: String = String(), relation: Anytype_Model_Relation, queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, relation: relation).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), relation: Anytype_Model_Relation) -> Result<Response, Error> {
        return invocation(contextID: contextID, relation: relation).invoke()
    }
    public static func invocation(contextID: String = String(), relation: Anytype_Model_Relation) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, relation: relation))
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceObjectRelationAdd(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.ObjectRelation.Update {
  public enum Service {
    public static func invoke(contextID: String, relationKey: String, relation: Anytype_Model_Relation, queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, relationKey: relationKey, relation: relation).invoke(on: queue)
    }
    public static func invoke(contextID: String, relationKey: String, relation: Anytype_Model_Relation) -> Result<Response, Error> {
        return invocation(contextID: contextID, relationKey: relationKey, relation: relation).invoke()
    }
    public static func invocation(contextID: String, relationKey: String, relation: Anytype_Model_Relation) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, relationKey: relationKey, relation: relation))
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceObjectRelationUpdate(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.ObjectRelation.Delete {
  public enum Service {
    public static func invoke(contextID: String = String(), relationKey: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, relationKey: relationKey).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), relationKey: String = String()) -> Result<Response, Error> {
        return invocation(contextID: contextID, relationKey: relationKey).invoke()
    }
    public static func invocation(contextID: String = String(), relationKey: String = String()) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, relationKey: relationKey))
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
    public static func invocation(contextID: String = String()) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID))
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
    public static func invocation(contextID: String = String(), relations: [String] = []) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, relations: relations))
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
    public static func invocation(contextID: String = String(), relations: [String] = []) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, relations: relations))
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceObjectRelationRemoveFeatured(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.ObjectRelationOption.Add {
  public enum Service {
    public static func invoke(contextID: String = String(), relationKey: String = String(), option: Anytype_Model_Relation.Option, queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, relationKey: relationKey, option: option).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), relationKey: String = String(), option: Anytype_Model_Relation.Option) -> Result<Response, Error> {
        return invocation(contextID: contextID, relationKey: relationKey, option: option).invoke()
    }
    public static func invocation(contextID: String = String(), relationKey: String = String(), option: Anytype_Model_Relation.Option) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, relationKey: relationKey, option: option))
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceObjectRelationOptionAdd(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.ObjectRelationOption.Update {
  public enum Service {
    public static func invoke(contextID: String = String(), relationKey: String = String(), option: Anytype_Model_Relation.Option, queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, relationKey: relationKey, option: option).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), relationKey: String = String(), option: Anytype_Model_Relation.Option) -> Result<Response, Error> {
        return invocation(contextID: contextID, relationKey: relationKey, option: option).invoke()
    }
    public static func invocation(contextID: String = String(), relationKey: String = String(), option: Anytype_Model_Relation.Option) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, relationKey: relationKey, option: option))
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceObjectRelationOptionUpdate(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.ObjectRelationOption.Delete {
  public enum Service {
    public static func invoke(contextID: String = String(), relationKey: String = String(), optionID: String = String(), confirmRemoveAllValuesInRecords: Bool = false, queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, relationKey: relationKey, optionID: optionID, confirmRemoveAllValuesInRecords: confirmRemoveAllValuesInRecords).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), relationKey: String = String(), optionID: String = String(), confirmRemoveAllValuesInRecords: Bool = false) -> Result<Response, Error> {
        return invocation(contextID: contextID, relationKey: relationKey, optionID: optionID, confirmRemoveAllValuesInRecords: confirmRemoveAllValuesInRecords).invoke()
    }
    public static func invocation(contextID: String = String(), relationKey: String = String(), optionID: String = String(), confirmRemoveAllValuesInRecords: Bool = false) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, relationKey: relationKey, optionID: optionID, confirmRemoveAllValuesInRecords: confirmRemoveAllValuesInRecords))
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceObjectRelationOptionDelete(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.ObjectType.List {
  public enum Service {
    public static func invoke(queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation().invoke(on: queue)
    }
    public static func invoke() -> Result<Response, Error> {
        return invocation().invoke()
    }
    public static func invocation() -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init())
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceObjectTypeList(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.ObjectType.Create {
  public enum Service {
    public static func invoke(objectType: Anytype_Model_ObjectType, queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(objectType: objectType).invoke(on: queue)
    }
    public static func invoke(objectType: Anytype_Model_ObjectType) -> Result<Response, Error> {
        return invocation(objectType: objectType).invoke()
    }
    public static func invocation(objectType: Anytype_Model_ObjectType) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(objectType: objectType))
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceObjectTypeCreate(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.ObjectType.Relation.Add {
  public enum Service {
    public static func invoke(objectTypeURL: String = String(), relations: [Anytype_Model_Relation] = [], queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(objectTypeURL: objectTypeURL, relations: relations).invoke(on: queue)
    }
    public static func invoke(objectTypeURL: String = String(), relations: [Anytype_Model_Relation] = []) -> Result<Response, Error> {
        return invocation(objectTypeURL: objectTypeURL, relations: relations).invoke()
    }
    public static func invocation(objectTypeURL: String = String(), relations: [Anytype_Model_Relation] = []) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(objectTypeURL: objectTypeURL, relations: relations))
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
    public static func invoke(objectTypeURL: String = String(), relationKey: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(objectTypeURL: objectTypeURL, relationKey: relationKey).invoke(on: queue)
    }
    public static func invoke(objectTypeURL: String = String(), relationKey: String = String()) -> Result<Response, Error> {
        return invocation(objectTypeURL: objectTypeURL, relationKey: relationKey).invoke()
    }
    public static func invocation(objectTypeURL: String = String(), relationKey: String = String()) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(objectTypeURL: objectTypeURL, relationKey: relationKey))
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceObjectTypeRelationRemove(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.ObjectType.Relation.Update {
  public enum Service {
    public static func invoke(objectTypeURL: String = String(), relation: Anytype_Model_Relation, queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(objectTypeURL: objectTypeURL, relation: relation).invoke(on: queue)
    }
    public static func invoke(objectTypeURL: String = String(), relation: Anytype_Model_Relation) -> Result<Response, Error> {
        return invocation(objectTypeURL: objectTypeURL, relation: relation).invoke()
    }
    public static func invocation(objectTypeURL: String = String(), relation: Anytype_Model_Relation) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(objectTypeURL: objectTypeURL, relation: relation))
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceObjectTypeRelationUpdate(try? request.serializedData()).flatMap {
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
    public static func invocation(objectTypeURL: String = String(), appendRelationsFromOtherTypes: Bool = false) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(objectTypeURL: objectTypeURL, appendRelationsFromOtherTypes: appendRelationsFromOtherTypes))
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceObjectTypeRelationList(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.History.GetVersions {
  public enum Service {
    public static func invoke(pageID: String = String(), lastVersionID: String = String(), limit: Int32 = 0, queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(pageID: pageID, lastVersionID: lastVersionID, limit: limit).invoke(on: queue)
    }
    public static func invoke(pageID: String = String(), lastVersionID: String = String(), limit: Int32 = 0) -> Result<Response, Error> {
        return invocation(pageID: pageID, lastVersionID: lastVersionID, limit: limit).invoke()
    }
    public static func invocation(pageID: String = String(), lastVersionID: String = String(), limit: Int32 = 0) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(pageID: pageID, lastVersionID: lastVersionID, limit: limit))
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
    public static func invoke(pageID: String = String(), versionID: String = String(), traceID: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(pageID: pageID, versionID: versionID, traceID: traceID).invoke(on: queue)
    }
    public static func invoke(pageID: String = String(), versionID: String = String(), traceID: String = String()) -> Result<Response, Error> {
        return invocation(pageID: pageID, versionID: versionID, traceID: traceID).invoke()
    }
    public static func invocation(pageID: String = String(), versionID: String = String(), traceID: String = String()) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(pageID: pageID, versionID: versionID, traceID: traceID))
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
    public static func invoke(pageID: String = String(), versionID: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(pageID: pageID, versionID: versionID).invoke(on: queue)
    }
    public static func invoke(pageID: String = String(), versionID: String = String()) -> Result<Response, Error> {
        return invocation(pageID: pageID, versionID: versionID).invoke()
    }
    public static func invocation(pageID: String = String(), versionID: String = String()) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(pageID: pageID, versionID: versionID))
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
    public static func invocation(id: String = String(), includeNotPinned: Bool = false) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(id: id, includeNotPinned: includeNotPinned))
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
    public static func invocation(onlyIds: [String] = [], includeNotPinned: Bool = false) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(onlyIds: onlyIds, includeNotPinned: includeNotPinned))
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
    public static func invocation(url: String = String(), localPath: String = String(), type: Anytype_Model_Block.Content.File.TypeEnum = .none, disableEncryption: Bool = false, style: Anytype_Model_Block.Content.File.Style = .auto) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(url: url, localPath: localPath, type: type, disableEncryption: disableEncryption, style: style))
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
    public static func invocation(hash: String = String(), path: String = String()) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(hash: hash, path: path))
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
    public static func invocation(contextID: String = String(), dropTargetID: String = String(), position: Anytype_Model_Block.Position = .none, localFilePaths: [String] = []) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, dropTargetID: dropTargetID, position: position, localFilePaths: localFilePaths))
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
    public static func invocation(context: Anytype_Rpc.Navigation.Context = .navigation, fullText: String = String(), limit: Int32 = 0, offset: Int32 = 0) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(context: context, fullText: fullText, limit: limit, offset: offset))
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
    public static func invocation(objectID: String = String(), context: Anytype_Rpc.Navigation.Context = .navigation) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(objectID: objectID, context: context))
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
    public static func invocation(contextID: String = String()) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID))
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
    public static func invocation(objectType: String = String()) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(objectType: objectType))
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
    public static func invocation(contextID: String = String()) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID))
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
    public static func invocation(path: String = String()) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(path: path))
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
    public static func invocation(url: String = String()) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(url: url))
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
    public static func invocation(query: String = String(), limit: Int32 = 0) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(query: query, limit: limit))
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
    public static func invocation(pictureID: String = String()) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(pictureID: pictureID))
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
    public static func invocation(contextID: String = String(), blockID: String = String(), block: Anytype_Model_Block) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, blockID: blockID, block: block))
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
    public static func invocation(contextID: String = String(), blockID: String = String(), range: Anytype_Model_Range, style: Anytype_Model_Block.Content.Text.Style = .paragraph, mode: Anytype_Rpc.Block.Split.Request.Mode = .bottom) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, blockID: blockID, range: range, style: style, mode: mode))
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
    public static func invocation(contextID: String = String(), firstBlockID: String = String(), secondBlockID: String = String()) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, firstBlockID: firstBlockID, secondBlockID: secondBlockID))
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
    public static func invocation(contextID: String = String(), blocks: [Anytype_Model_Block] = [], selectedTextRange: Anytype_Model_Range) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, blocks: blocks, selectedTextRange: selectedTextRange))
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
    public static func invocation(contextID: String = String(), focusedBlockID: String = String(), selectedTextRange: Anytype_Model_Range, selectedBlockIds: [String] = [], isPartOfBlock: Bool = false, textSlot: String = String(), htmlSlot: String = String(), anySlot: [Anytype_Model_Block] = [], fileSlot: [Anytype_Rpc.Block.Paste.Request.File] = []) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, focusedBlockID: focusedBlockID, selectedTextRange: selectedTextRange, selectedBlockIds: selectedBlockIds, isPartOfBlock: isPartOfBlock, textSlot: textSlot, htmlSlot: htmlSlot, anySlot: anySlot, fileSlot: fileSlot))
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
    public static func invocation(contextID: String = String(), blocks: [Anytype_Model_Block] = [], selectedTextRange: Anytype_Model_Range) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, blocks: blocks, selectedTextRange: selectedTextRange))
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
    public static func invocation(contextID: String = String(), blockID: String = String(), filePath: String = String(), url: String = String()) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, blockID: blockID, filePath: filePath, url: url))
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
    public static func invocation(contextID: String = String(), targetID: String = String(), block: Anytype_Model_Block, position: Anytype_Model_Block.Position = .none) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, targetID: targetID, block: block, position: position))
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
    public static func invocation(contextID: String = String(), blockIds: [String] = []) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, blockIds: blockIds))
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
    public static func invocation(contextID: String = String(), blockID: String = String(), fields: SwiftProtobuf.Google_Protobuf_Struct) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, blockID: blockID, fields: fields))
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
    public static func invocation(contextID: String = String(), blockIds: [String] = [], align: Anytype_Model_Block.Align = .left) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, blockIds: blockIds, align: align))
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
    public static func invocation(contextID: String = String(), blockIds: [String] = [], verticalAlign: Anytype_Model_Block.VerticalAlign = .top) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, blockIds: blockIds, verticalAlign: verticalAlign))
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
    public static func invocation(contextID: String = String(), blockFields: [Anytype_Rpc.Block.ListSetFields.Request.BlockField] = []) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, blockFields: blockFields))
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
    public static func invoke(contextID: String = String(), targetID: String = String(), blockIds: [String] = [], position: Anytype_Model_Block.Position = .none, queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, targetID: targetID, blockIds: blockIds, position: position).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), targetID: String = String(), blockIds: [String] = [], position: Anytype_Model_Block.Position = .none) -> Result<Response, Error> {
        return invocation(contextID: contextID, targetID: targetID, blockIds: blockIds, position: position).invoke()
    }
    public static func invocation(contextID: String = String(), targetID: String = String(), blockIds: [String] = [], position: Anytype_Model_Block.Position = .none) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, targetID: targetID, blockIds: blockIds, position: position))
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
    public static func invocation(contextID: String = String(), blockIds: [String] = [], objectType: String = String()) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, blockIds: blockIds, objectType: objectType))
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
    public static func invocation(contextID: String = String(), blockIds: [String] = [], targetContextID: String = String(), dropTargetID: String = String(), position: Anytype_Model_Block.Position = .none) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, blockIds: blockIds, targetContextID: targetContextID, dropTargetID: dropTargetID, position: position))
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
    public static func invocation(contextID: String = String(), blockIds: [String] = [], details: SwiftProtobuf.Google_Protobuf_Struct, dropTargetID: String = String(), position: Anytype_Model_Block.Position = .none) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, blockIds: blockIds, details: details, dropTargetID: dropTargetID, position: position))
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
    public static func invocation(contextID: String = String(), blockIds: [String] = [], style: Anytype_Model_Block.Content.Text.Style = .paragraph) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, blockIds: blockIds, style: style))
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
    public static func invocation(contextID: String = String(), blockIds: [String] = [], color: String = String()) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, blockIds: blockIds, color: color))
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
    public static func invocation(contextID: String = String(), blocks: [Anytype_Model_Block] = []) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, blocks: blocks))
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
    public static func invocation(contextID: String = String(), blockID: String = String(), text: String = String()) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, blockID: blockID, text: text))
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
    public static func invocation(contextID: String = String(), blockID: String = String(), text: String = String(), marks: Anytype_Model_Block.Content.Text.Marks) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, blockID: blockID, text: text, marks: marks))
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
    public static func invocation(contextID: String = String(), blockID: String = String(), color: String = String()) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, blockID: blockID, color: color))
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
    public static func invocation(contextID: String = String(), blockID: String = String(), style: Anytype_Model_Block.Content.Text.Style = .paragraph) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, blockID: blockID, style: style))
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
    public static func invocation(contextID: String = String(), blockID: String = String(), checked: Bool = false) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, blockID: blockID, checked: checked))
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
    public static func invocation(contextID: String = String(), blockID: String = String(), iconImage: String = String(), iconEmoji: String = String()) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, blockID: blockID, iconImage: iconImage, iconEmoji: iconEmoji))
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
    public static func invocation(contextID: String = String(), blockIds: [String] = [], style: Anytype_Model_Block.Content.Text.Style = .paragraph) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, blockIds: blockIds, style: style))
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
    public static func invocation(contextID: String = String(), blockIds: [String] = [], color: String = String()) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, blockIds: blockIds, color: color))
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
    public static func invocation(contextID: String = String(), blockIds: [String] = [], mark: Anytype_Model_Block.Content.Text.Mark) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, blockIds: blockIds, mark: mark))
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
    public static func invocation(contextID: String = String(), blockIds: [String] = []) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, blockIds: blockIds))
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
    public static func invocation(contextID: String = String(), blockIds: [String] = []) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, blockIds: blockIds))
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
    public static func invocation(contextID: String = String(), targetID: String = String(), position: Anytype_Model_Block.Position = .none, rows: UInt32 = 0, columns: UInt32 = 0, withHeaderRow: Bool = false) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, targetID: targetID, position: position, rows: rows, columns: columns, withHeaderRow: withHeaderRow))
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
    public static func invocation(contextID: String = String(), targetID: String = String(), position: Anytype_Model_Block.Position = .none) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, targetID: targetID, position: position))
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
    public static func invocation(contextID: String = String(), targetID: String = String(), isHeader: Bool = false) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, targetID: targetID, isHeader: isHeader))
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
    public static func invocation(contextID: String = String(), blockIds: [String] = []) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, blockIds: blockIds))
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
    public static func invocation(contextID: String = String(), blockIds: [String] = []) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, blockIds: blockIds))
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
    public static func invocation(contextID: String = String(), blockIds: [String] = []) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, blockIds: blockIds))
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
    public static func invocation(contextID: String = String(), targetID: String = String(), position: Anytype_Model_Block.Position = .none) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, targetID: targetID, position: position))
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
    public static func invocation(contextID: String = String(), targetID: String = String()) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, targetID: targetID))
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
    public static func invocation(contextID: String = String(), targetID: String = String()) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, targetID: targetID))
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
    public static func invocation(contextID: String = String(), targetID: String = String(), dropTargetID: String = String(), position: Anytype_Model_Block.Position = .none) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, targetID: targetID, dropTargetID: dropTargetID, position: position))
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
    public static func invocation(contextID: String = String(), targetID: String = String(), blockID: String = String(), position: Anytype_Model_Block.Position = .none) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, targetID: targetID, blockID: blockID, position: position))
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
    public static func invocation(contextID: String = String(), targetID: String = String(), blockID: String = String(), position: Anytype_Model_Block.Position = .none) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, targetID: targetID, blockID: blockID, position: position))
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
    public static func invocation(contextID: String = String(), targetID: String = String(), columns: UInt32 = 0, rows: UInt32 = 0) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, targetID: targetID, columns: columns, rows: rows))
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
    public static func invocation(contextID: String = String(), columnID: String = String(), type: Anytype_Model_Block.Content.Dataview.Sort.TypeEnum = .asc) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, columnID: columnID, type: type))
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
    public static func invocation(contextID: String = String(), blockID: String = String(), name: String = String()) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, blockID: blockID, name: name))
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
    public static func invocation(contextID: String = String(), targetID: String = String(), position: Anytype_Model_Block.Position = .none, url: String = String(), localPath: String = String(), fileType: Anytype_Model_Block.Content.File.TypeEnum = .none) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, targetID: targetID, position: position, url: url, localPath: localPath, fileType: fileType))
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
    public static func invocation(contextID: String = String(), blockIds: [String] = [], style: Anytype_Model_Block.Content.File.Style = .auto) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, blockIds: blockIds, style: style))
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
    public static func invocation(contextID: String = String(), blockID: String = String(), name: String = String()) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, blockID: blockID, name: name))
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
    public static func invocation(contextID: String = String(), blockID: String = String(), name: String = String()) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, blockID: blockID, name: name))
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
    public static func invocation(contextID: String = String(), details: SwiftProtobuf.Google_Protobuf_Struct, templateID: String = String(), internalFlags: [Anytype_Model_InternalFlag] = [], targetID: String = String(), position: Anytype_Model_Block.Position = .none, fields: SwiftProtobuf.Google_Protobuf_Struct) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, details: details, templateID: templateID, internalFlags: internalFlags, targetID: targetID, position: position, fields: fields))
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
    public static func invocation(contextID: String = String(), blockIds: [String] = [], iconSize: Anytype_Model_Block.Content.Link.IconSize = .sizeNone, cardStyle: Anytype_Model_Block.Content.Link.CardStyle = .text, description_p: Anytype_Model_Block.Content.Link.Description = .none, relations: [String] = []) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, blockIds: blockIds, iconSize: iconSize, cardStyle: cardStyle, description_p: description_p, relations: relations))
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
    public static func invocation(contextID: String = String(), blockID: String = String(), key: String = String()) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, blockID: blockID, key: key))
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
    public static func invoke(contextID: String, blockID: String, relation: Anytype_Model_Relation, queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, blockID: blockID, relation: relation).invoke(on: queue)
    }
    public static func invoke(contextID: String, blockID: String, relation: Anytype_Model_Relation) -> Result<Response, Error> {
        return invocation(contextID: contextID, blockID: blockID, relation: relation).invoke()
    }
    public static func invocation(contextID: String, blockID: String, relation: Anytype_Model_Relation) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, blockID: blockID, relation: relation))
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
    public static func invocation(contextID: String = String(), blockID: String = String(), url: String = String()) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, blockID: blockID, url: url))
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
    public static func invocation(contextID: String = String(), targetID: String = String(), position: Anytype_Model_Block.Position = .none, url: String = String()) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, targetID: targetID, position: position, url: url))
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
    public static func invocation(contextID: String = String(), blockIds: [String] = [], style: Anytype_Model_Block.Content.Div.Style = .line) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, blockIds: blockIds, style: style))
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
    public static func invocation(contextID: String = String(), blockID: String = String(), view: Anytype_Model_Block.Content.Dataview.View) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, blockID: blockID, view: view))
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
    public static func invocation(contextID: String = String(), blockID: String = String(), viewID: String = String(), view: Anytype_Model_Block.Content.Dataview.View) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, blockID: blockID, viewID: viewID, view: view))
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
    public static func invocation(contextID: String = String(), blockID: String = String(), viewID: String = String()) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, blockID: blockID, viewID: viewID))
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
    public static func invocation(contextID: String = String(), blockID: String = String(), viewID: String = String(), offset: UInt32 = 0, limit: UInt32 = 0) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, blockID: blockID, viewID: viewID, offset: offset, limit: limit))
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
    public static func invoke(contextID: String, blockID: String, relation: Anytype_Model_Relation, queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, blockID: blockID, relation: relation).invoke(on: queue)
    }
    public static func invoke(contextID: String, blockID: String, relation: Anytype_Model_Relation) -> Result<Response, Error> {
        return invocation(contextID: contextID, blockID: blockID, relation: relation).invoke()
    }
    public static func invocation(contextID: String, blockID: String, relation: Anytype_Model_Relation) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, blockID: blockID, relation: relation))
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceBlockDataviewRelationAdd(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.BlockDataview.Relation.Update {
  public enum Service {
    public static func invoke(contextID: String, blockID: String, relationKey: String, relation: Anytype_Model_Relation, queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, blockID: blockID, relationKey: relationKey, relation: relation).invoke(on: queue)
    }
    public static func invoke(contextID: String, blockID: String, relationKey: String, relation: Anytype_Model_Relation) -> Result<Response, Error> {
        return invocation(contextID: contextID, blockID: blockID, relationKey: relationKey, relation: relation).invoke()
    }
    public static func invocation(contextID: String, blockID: String, relationKey: String, relation: Anytype_Model_Relation) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, blockID: blockID, relationKey: relationKey, relation: relation))
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceBlockDataviewRelationUpdate(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.BlockDataview.Relation.Delete {
  public enum Service {
    public static func invoke(contextID: String = String(), blockID: String = String(), relationKey: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, blockID: blockID, relationKey: relationKey).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), blockID: String = String(), relationKey: String = String()) -> Result<Response, Error> {
        return invocation(contextID: contextID, blockID: blockID, relationKey: relationKey).invoke()
    }
    public static func invocation(contextID: String = String(), blockID: String = String(), relationKey: String = String()) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, blockID: blockID, relationKey: relationKey))
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
    public static func invocation(contextID: String = String(), blockID: String = String()) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, blockID: blockID))
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
    public static func invocation(contextID: String = String(), blockID: String = String(), source: [String] = []) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, blockID: blockID, source: source))
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
    public static func invocation(contextID: String = String(), blockID: String = String(), groupOrder: Anytype_Model_Block.Content.Dataview.GroupOrder) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, blockID: blockID, groupOrder: groupOrder))
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
    public static func invocation(contextID: String = String(), blockID: String = String(), objectOrders: [Anytype_Model_Block.Content.Dataview.ObjectOrder] = []) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, blockID: blockID, objectOrders: objectOrders))
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceBlockDataviewObjectOrderUpdate(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.BlockDataviewRecord.Update {
  public enum Service {
    public static func invoke(contextID: String = String(), blockID: String = String(), recordID: String = String(), record: SwiftProtobuf.Google_Protobuf_Struct, queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, blockID: blockID, recordID: recordID, record: record).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), blockID: String = String(), recordID: String = String(), record: SwiftProtobuf.Google_Protobuf_Struct) -> Result<Response, Error> {
        return invocation(contextID: contextID, blockID: blockID, recordID: recordID, record: record).invoke()
    }
    public static func invocation(contextID: String = String(), blockID: String = String(), recordID: String = String(), record: SwiftProtobuf.Google_Protobuf_Struct) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, blockID: blockID, recordID: recordID, record: record))
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceBlockDataviewRecordUpdate(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.BlockDataviewRecord.Delete {
  public enum Service {
    public static func invoke(contextID: String = String(), blockID: String = String(), recordID: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, blockID: blockID, recordID: recordID).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), blockID: String = String(), recordID: String = String()) -> Result<Response, Error> {
        return invocation(contextID: contextID, blockID: blockID, recordID: recordID).invoke()
    }
    public static func invocation(contextID: String = String(), blockID: String = String(), recordID: String = String()) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, blockID: blockID, recordID: recordID))
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceBlockDataviewRecordDelete(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.BlockDataviewRecord.Create {
  public enum Service {
    public static func invoke(contextID: String = String(), blockID: String = String(), record: SwiftProtobuf.Google_Protobuf_Struct, templateID: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, blockID: blockID, record: record, templateID: templateID).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), blockID: String = String(), record: SwiftProtobuf.Google_Protobuf_Struct, templateID: String = String()) -> Result<Response, Error> {
        return invocation(contextID: contextID, blockID: blockID, record: record, templateID: templateID).invoke()
    }
    public static func invocation(contextID: String = String(), blockID: String = String(), record: SwiftProtobuf.Google_Protobuf_Struct, templateID: String = String()) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, blockID: blockID, record: record, templateID: templateID))
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceBlockDataviewRecordCreate(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.BlockDataviewRecord.RelationOption.Add {
  public enum Service {
    public static func invoke(contextID: String = String(), blockID: String = String(), relationKey: String = String(), option: Anytype_Model_Relation.Option, recordID: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, blockID: blockID, relationKey: relationKey, option: option, recordID: recordID).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), blockID: String = String(), relationKey: String = String(), option: Anytype_Model_Relation.Option, recordID: String = String()) -> Result<Response, Error> {
        return invocation(contextID: contextID, blockID: blockID, relationKey: relationKey, option: option, recordID: recordID).invoke()
    }
    public static func invocation(contextID: String = String(), blockID: String = String(), relationKey: String = String(), option: Anytype_Model_Relation.Option, recordID: String = String()) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, blockID: blockID, relationKey: relationKey, option: option, recordID: recordID))
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceBlockDataviewRecordRelationOptionAdd(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.BlockDataviewRecord.RelationOption.Update {
  public enum Service {
    public static func invoke(contextID: String = String(), blockID: String = String(), relationKey: String = String(), option: Anytype_Model_Relation.Option, recordID: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, blockID: blockID, relationKey: relationKey, option: option, recordID: recordID).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), blockID: String = String(), relationKey: String = String(), option: Anytype_Model_Relation.Option, recordID: String = String()) -> Result<Response, Error> {
        return invocation(contextID: contextID, blockID: blockID, relationKey: relationKey, option: option, recordID: recordID).invoke()
    }
    public static func invocation(contextID: String = String(), blockID: String = String(), relationKey: String = String(), option: Anytype_Model_Relation.Option, recordID: String = String()) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, blockID: blockID, relationKey: relationKey, option: option, recordID: recordID))
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceBlockDataviewRecordRelationOptionUpdate(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

extension Anytype_Rpc.BlockDataviewRecord.RelationOption.Delete {
  public enum Service {
    public static func invoke(contextID: String = String(), blockID: String = String(), relationKey: String = String(), optionID: String = String(), recordID: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return invocation(contextID: contextID, blockID: blockID, relationKey: relationKey, optionID: optionID, recordID: recordID).invoke(on: queue)
    }
    public static func invoke(contextID: String = String(), blockID: String = String(), relationKey: String = String(), optionID: String = String(), recordID: String = String()) -> Result<Response, Error> {
        return invocation(contextID: contextID, blockID: blockID, relationKey: relationKey, optionID: optionID, recordID: recordID).invoke()
    }
    public static func invocation(contextID: String = String(), blockID: String = String(), relationKey: String = String(), optionID: String = String(), recordID: String = String()) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(contextID: contextID, blockID: blockID, relationKey: relationKey, optionID: optionID, recordID: recordID))
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceBlockDataviewRecordRelationOptionDelete(try? request.serializedData()).flatMap {
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
    public static func invocation(recordsTraverseLimit: Int32 = 0, skipEmptyLogs: Bool = false, tryToDownloadRemoteRecords: Bool = false) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(recordsTraverseLimit: recordsTraverseLimit, skipEmptyLogs: skipEmptyLogs, tryToDownloadRemoteRecords: tryToDownloadRemoteRecords))
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
    public static func invocation(threadID: String = String(), skipEmptyLogs: Bool = false, tryToDownloadRemoteRecords: Bool = false) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(threadID: threadID, skipEmptyLogs: skipEmptyLogs, tryToDownloadRemoteRecords: tryToDownloadRemoteRecords))
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
    public static func invocation(objectID: String = String(), path: String = String(), unanonymized: Bool = false, generateSvg: Bool = false) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(objectID: objectID, path: path, unanonymized: unanonymized, generateSvg: generateSvg))
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
    public static func invocation(path: String = String(), docIds: [String] = []) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(path: path, docIds: docIds))
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
    public static func invocation(index: Int32 = 0, numberOfEventsToSend: Int32 = 0) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(index: index, numberOfEventsToSend: numberOfEventsToSend))
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
    public static func invocation(platform: String = String()) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(platform: platform))
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
    public static func invocation(message: String = String(), level: Anytype_Rpc.Log.Send.Request.Level = .debug) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(message: message, level: level))
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
    public static func invocation(id: String = String()) -> ProtobufMessages.Invocation<Response> {
        return Invocation<Response> {
            return self.invoke(.init(id: id))
        }
    }
    private static func invoke(_ request: Request) -> Response? {
        return Lib.ServiceProcessCancel(try? request.serializedData()).flatMap {
            try? Response(serializedData: $0)
        }
    }
  }
}

