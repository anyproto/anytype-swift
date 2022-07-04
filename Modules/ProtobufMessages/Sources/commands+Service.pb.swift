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

enum Anytype_Middleware_Error {
  static let domain: String = "org.anytype.middleware.services"
}

extension Anytype_Rpc.App.GetVersion {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceAppGetVersion(data) }
  }

  public enum Service {
    public static func invoke(queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(), on: queue)
    }
    public static func invoke() -> Result<Response, Error> {
      self.result(.init())
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.App.SetDeviceState {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceAppSetDeviceState(data) }
  }

  public enum Service {
    public static func invoke(deviceState: Anytype_Rpc.App.SetDeviceState.Request.DeviceState = .background, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(deviceState: deviceState), on: queue)
    }
    public static func invoke(deviceState: Anytype_Rpc.App.SetDeviceState.Request.DeviceState = .background) -> Result<Response, Error> {
      self.result(.init(deviceState: deviceState))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.App.Shutdown {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceAppShutdown(data) }
  }

  public enum Service {
    public static func invoke(queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(), on: queue)
    }
    public static func invoke() -> Result<Response, Error> {
      self.result(.init())
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Wallet.Create {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceWalletCreate(data) }
  }

  public enum Service {
    public static func invoke(rootPath: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(rootPath: rootPath), on: queue)
    }
    public static func invoke(rootPath: String = String()) -> Result<Response, Error> {
      self.result(.init(rootPath: rootPath))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Wallet.Recover {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceWalletRecover(data) }
  }

  public enum Service {
    public static func invoke(rootPath: String = String(), mnemonic: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(rootPath: rootPath, mnemonic: mnemonic), on: queue)
    }
    public static func invoke(rootPath: String = String(), mnemonic: String = String()) -> Result<Response, Error> {
      self.result(.init(rootPath: rootPath, mnemonic: mnemonic))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Wallet.Convert {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceWalletConvert(data) }
  }

  public enum Service {
    public static func invoke(mnemonic: String = String(), entropy: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(mnemonic: mnemonic, entropy: entropy), on: queue)
    }
    public static func invoke(mnemonic: String = String(), entropy: String = String()) -> Result<Response, Error> {
      self.result(.init(mnemonic: mnemonic, entropy: entropy))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Account.Create {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceAccountCreate(data) }
  }

  public enum Service {
    public static func invoke(
      name: String = String(), avatar: Anytype_Rpc.Account.Create.Request.OneOf_Avatar? = nil, storePath: String = String(), alphaInviteCode: String = String(), queue: DispatchQueue? = nil
    ) -> Future<Response, Error> {
      self.invoke(request: .init(name: name, avatar: avatar, storePath: storePath, alphaInviteCode: alphaInviteCode), on: queue)
    }
    public static func invoke(name: String = String(), avatar: Anytype_Rpc.Account.Create.Request.OneOf_Avatar? = nil, storePath: String = String(), alphaInviteCode: String = String()) -> Result<
      Response, Error
    > {
      self.result(.init(name: name, avatar: avatar, storePath: storePath, alphaInviteCode: alphaInviteCode))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Account.Recover {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceAccountRecover(data) }
  }

  public enum Service {
    public static func invoke(queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(), on: queue)
    }
    public static func invoke() -> Result<Response, Error> {
      self.result(.init())
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Account.Delete {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceAccountDelete(data) }
  }

  public enum Service {
    public static func invoke(revert: Bool = false, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(revert: revert), on: queue)
    }
    public static func invoke(revert: Bool = false) -> Result<Response, Error> {
      self.result(.init(revert: revert))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Account.Select {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceAccountSelect(data) }
  }

  public enum Service {
    public static func invoke(id: String = String(), rootPath: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(id: id, rootPath: rootPath), on: queue)
    }
    public static func invoke(id: String = String(), rootPath: String = String()) -> Result<Response, Error> {
      self.result(.init(id: id, rootPath: rootPath))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Account.Stop {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceAccountStop(data) }
  }

  public enum Service {
    public static func invoke(removeData: Bool = false, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(removeData: removeData), on: queue)
    }
    public static func invoke(removeData: Bool = false) -> Result<Response, Error> {
      self.result(.init(removeData: removeData))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Account.Move {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceAccountMove(data) }
  }

  public enum Service {
    public static func invoke(newPath: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(newPath: newPath), on: queue)
    }
    public static func invoke(newPath: String = String()) -> Result<Response, Error> {
      self.result(.init(newPath: newPath))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Workspace.GetCurrent {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceWorkspaceGetCurrent(data) }
  }

  public enum Service {
    public static func invoke(queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(), on: queue)
    }
    public static func invoke() -> Result<Response, Error> {
      self.result(.init())
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Workspace.GetAll {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceWorkspaceGetAll(data) }
  }

  public enum Service {
    public static func invoke(queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(), on: queue)
    }
    public static func invoke() -> Result<Response, Error> {
      self.result(.init())
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Workspace.Create {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceWorkspaceCreate(data) }
  }

  public enum Service {
    public static func invoke(name: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(name: name), on: queue)
    }
    public static func invoke(name: String = String()) -> Result<Response, Error> {
      self.result(.init(name: name))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Workspace.SetIsHighlighted {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceWorkspaceSetIsHighlighted(data) }
  }

  public enum Service {
    public static func invoke(objectID: String = String(), isHighlighted: Bool = false, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(objectID: objectID, isHighlighted: isHighlighted), on: queue)
    }
    public static func invoke(objectID: String = String(), isHighlighted: Bool = false) -> Result<Response, Error> {
      self.result(.init(objectID: objectID, isHighlighted: isHighlighted))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Workspace.Select {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceWorkspaceSelect(data) }
  }

  public enum Service {
    public static func invoke(workspaceID: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(workspaceID: workspaceID), on: queue)
    }
    public static func invoke(workspaceID: String = String()) -> Result<Response, Error> {
      self.result(.init(workspaceID: workspaceID))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Workspace.Export {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceWorkspaceExport(data) }
  }

  public enum Service {
    public static func invoke(path: String = String(), workspaceID: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(path: path, workspaceID: workspaceID), on: queue)
    }
    public static func invoke(path: String = String(), workspaceID: String = String()) -> Result<Response, Error> {
      self.result(.init(path: path, workspaceID: workspaceID))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Object.Open {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceObjectOpen(data) }
  }

  public enum Service {
    public static func invoke(contextID: String = String(), objectID: String = String(), traceID: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(contextID: contextID, objectID: objectID, traceID: traceID), on: queue)
    }
    public static func invoke(contextID: String = String(), objectID: String = String(), traceID: String = String()) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, objectID: objectID, traceID: traceID))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Object.Close {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceObjectClose(data) }
  }

  public enum Service {
    public static func invoke(contextID: String = String(), objectID: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(contextID: contextID, objectID: objectID), on: queue)
    }
    public static func invoke(contextID: String = String(), objectID: String = String()) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, objectID: objectID))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Object.Show {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceObjectShow(data) }
  }

  public enum Service {
    public static func invoke(contextID: String = String(), objectID: String = String(), traceID: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(contextID: contextID, objectID: objectID, traceID: traceID), on: queue)
    }
    public static func invoke(contextID: String = String(), objectID: String = String(), traceID: String = String()) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, objectID: objectID, traceID: traceID))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Object.Create {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceObjectCreate(data) }
  }

  public enum Service {
    public static func invoke(details: SwiftProtobuf.Google_Protobuf_Struct, internalFlags: [Anytype_Model_InternalFlag] = [], templateID: String = String(), queue: DispatchQueue? = nil) -> Future<
      Response, Error
    > {
      self.invoke(request: .init(details: details, internalFlags: internalFlags, templateID: templateID), on: queue)
    }
    public static func invoke(details: SwiftProtobuf.Google_Protobuf_Struct, internalFlags: [Anytype_Model_InternalFlag] = [], templateID: String = String()) -> Result<Response, Error> {
      self.result(.init(details: details, internalFlags: internalFlags, templateID: templateID))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Object.CreateBookmark {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceObjectCreateBookmark(data) }
  }

  public enum Service {
    public static func invoke(url: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(url: url), on: queue)
    }
    public static func invoke(url: String = String()) -> Result<Response, Error> {
      self.result(.init(url: url))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Object.BookmarkFetch {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceObjectBookmarkFetch(data) }
  }

  public enum Service {
    public static func invoke(contextID: String = String(), url: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(contextID: contextID, url: url), on: queue)
    }
    public static func invoke(contextID: String = String(), url: String = String()) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, url: url))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Object.ToBookmark {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceObjectToBookmark(data) }
  }

  public enum Service {
    public static func invoke(contextID: String = String(), url: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(contextID: contextID, url: url), on: queue)
    }
    public static func invoke(contextID: String = String(), url: String = String()) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, url: url))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Object.CreateSet {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceObjectCreateSet(data) }
  }

  public enum Service {
    public static func invoke(
      source: [String] = [], details: SwiftProtobuf.Google_Protobuf_Struct, templateID: String = String(), internalFlags: [Anytype_Model_InternalFlag] = [], queue: DispatchQueue? = nil
    ) -> Future<Response, Error> {
      self.invoke(request: .init(source: source, details: details, templateID: templateID, internalFlags: internalFlags), on: queue)
    }
    public static func invoke(source: [String] = [], details: SwiftProtobuf.Google_Protobuf_Struct, templateID: String = String(), internalFlags: [Anytype_Model_InternalFlag] = []) -> Result<
      Response, Error
    > {
      self.result(.init(source: source, details: details, templateID: templateID, internalFlags: internalFlags))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Object.Duplicate {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceObjectDuplicate(data) }
  }

  public enum Service {
    public static func invoke(contextID: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(contextID: contextID), on: queue)
    }
    public static func invoke(contextID: String = String()) -> Result<Response, Error> {
      self.result(.init(contextID: contextID))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Object.OpenBreadcrumbs {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceObjectOpenBreadcrumbs(data) }
  }

  public enum Service {
    public static func invoke(contextID: String = String(), traceID: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(contextID: contextID, traceID: traceID), on: queue)
    }
    public static func invoke(contextID: String = String(), traceID: String = String()) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, traceID: traceID))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Object.SetBreadcrumbs {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceObjectSetBreadcrumbs(data) }
  }

  public enum Service {
    public static func invoke(breadcrumbsID: String = String(), ids: [String] = [], queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(breadcrumbsID: breadcrumbsID, ids: ids), on: queue)
    }
    public static func invoke(breadcrumbsID: String = String(), ids: [String] = []) -> Result<Response, Error> {
      self.result(.init(breadcrumbsID: breadcrumbsID, ids: ids))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Object.ImportMarkdown {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceObjectImportMarkdown(data) }
  }

  public enum Service {
    public static func invoke(contextID: String = String(), importPath: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(contextID: contextID, importPath: importPath), on: queue)
    }
    public static func invoke(contextID: String = String(), importPath: String = String()) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, importPath: importPath))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Object.ShareByLink {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceObjectShareByLink(data) }
  }

  public enum Service {
    public static func invoke(objectID: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(objectID: objectID), on: queue)
    }
    public static func invoke(objectID: String = String()) -> Result<Response, Error> {
      self.result(.init(objectID: objectID))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Object.AddWithObjectId {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceObjectAddWithObjectId(data) }
  }

  public enum Service {
    public static func invoke(objectID: String = String(), payload: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(objectID: objectID, payload: payload), on: queue)
    }
    public static func invoke(objectID: String = String(), payload: String = String()) -> Result<Response, Error> {
      self.result(.init(objectID: objectID, payload: payload))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Object.Search {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceObjectSearch(data) }
  }

  public enum Service {
    public static func invoke(
      filters: [Anytype_Model_Block.Content.Dataview.Filter] = [], sorts: [Anytype_Model_Block.Content.Dataview.Sort] = [], fullText: String = String(), offset: Int32 = 0, limit: Int32 = 0,
      objectTypeFilter: [String] = [], keys: [String] = [], queue: DispatchQueue? = nil
    ) -> Future<Response, Error> {
      self.invoke(request: .init(filters: filters, sorts: sorts, fullText: fullText, offset: offset, limit: limit, objectTypeFilter: objectTypeFilter, keys: keys), on: queue)
    }
    public static func invoke(
      filters: [Anytype_Model_Block.Content.Dataview.Filter] = [], sorts: [Anytype_Model_Block.Content.Dataview.Sort] = [], fullText: String = String(), offset: Int32 = 0, limit: Int32 = 0,
      objectTypeFilter: [String] = [], keys: [String] = []
    ) -> Result<Response, Error> {
      self.result(.init(filters: filters, sorts: sorts, fullText: fullText, offset: offset, limit: limit, objectTypeFilter: objectTypeFilter, keys: keys))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Object.Graph {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceObjectGraph(data) }
  }

  public enum Service {
    public static func invoke(filters: [Anytype_Model_Block.Content.Dataview.Filter] = [], limit: Int32 = 0, objectTypeFilter: [String] = [], keys: [String] = [], queue: DispatchQueue? = nil)
      -> Future<Response, Error>
    {
      self.invoke(request: .init(filters: filters, limit: limit, objectTypeFilter: objectTypeFilter, keys: keys), on: queue)
    }
    public static func invoke(filters: [Anytype_Model_Block.Content.Dataview.Filter] = [], limit: Int32 = 0, objectTypeFilter: [String] = [], keys: [String] = []) -> Result<Response, Error> {
      self.result(.init(filters: filters, limit: limit, objectTypeFilter: objectTypeFilter, keys: keys))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Object.SearchSubscribe {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceObjectSearchSubscribe(data) }
  }

  public enum Service {
    public static func invoke(
      subID: String = String(), filters: [Anytype_Model_Block.Content.Dataview.Filter] = [], sorts: [Anytype_Model_Block.Content.Dataview.Sort] = [], limit: Int64 = 0, offset: Int64 = 0,
      keys: [String] = [], afterID: String = String(), beforeID: String = String(), source: [String] = [], ignoreWorkspace: String = String(), noDepSubscription: Bool = false,
      queue: DispatchQueue? = nil
    ) -> Future<Response, Error> {
      self.invoke(
        request: .init(
          subID: subID, filters: filters, sorts: sorts, limit: limit, offset: offset, keys: keys, afterID: afterID, beforeID: beforeID, source: source, ignoreWorkspace: ignoreWorkspace,
          noDepSubscription: noDepSubscription), on: queue)
    }
    public static func invoke(
      subID: String = String(), filters: [Anytype_Model_Block.Content.Dataview.Filter] = [], sorts: [Anytype_Model_Block.Content.Dataview.Sort] = [], limit: Int64 = 0, offset: Int64 = 0,
      keys: [String] = [], afterID: String = String(), beforeID: String = String(), source: [String] = [], ignoreWorkspace: String = String(), noDepSubscription: Bool = false
    ) -> Result<Response, Error> {
      self.result(
        .init(
          subID: subID, filters: filters, sorts: sorts, limit: limit, offset: offset, keys: keys, afterID: afterID, beforeID: beforeID, source: source, ignoreWorkspace: ignoreWorkspace,
          noDepSubscription: noDepSubscription))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Object.SubscribeIds {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceObjectSubscribeIds(data) }
  }

  public enum Service {
    public static func invoke(subID: String = String(), ids: [String] = [], keys: [String] = [], ignoreWorkspace: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(subID: subID, ids: ids, keys: keys, ignoreWorkspace: ignoreWorkspace), on: queue)
    }
    public static func invoke(subID: String = String(), ids: [String] = [], keys: [String] = [], ignoreWorkspace: String = String()) -> Result<Response, Error> {
      self.result(.init(subID: subID, ids: ids, keys: keys, ignoreWorkspace: ignoreWorkspace))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Object.SearchUnsubscribe {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceObjectSearchUnsubscribe(data) }
  }

  public enum Service {
    public static func invoke(subIds: [String] = [], queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(subIds: subIds), on: queue)
    }
    public static func invoke(subIds: [String] = []) -> Result<Response, Error> {
      self.result(.init(subIds: subIds))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Object.SetLayout {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceObjectSetLayout(data) }
  }

  public enum Service {
    public static func invoke(contextID: String = String(), layout: Anytype_Model_ObjectType.Layout = .basic, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(contextID: contextID, layout: layout), on: queue)
    }
    public static func invoke(contextID: String = String(), layout: Anytype_Model_ObjectType.Layout = .basic) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, layout: layout))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Object.SetIsFavorite {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceObjectSetIsFavorite(data) }
  }

  public enum Service {
    public static func invoke(contextID: String = String(), isFavorite: Bool = false, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(contextID: contextID, isFavorite: isFavorite), on: queue)
    }
    public static func invoke(contextID: String = String(), isFavorite: Bool = false) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, isFavorite: isFavorite))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Object.SetIsArchived {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceObjectSetIsArchived(data) }
  }

  public enum Service {
    public static func invoke(contextID: String = String(), isArchived: Bool = false, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(contextID: contextID, isArchived: isArchived), on: queue)
    }
    public static func invoke(contextID: String = String(), isArchived: Bool = false) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, isArchived: isArchived))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Object.SetObjectType {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceObjectSetObjectType(data) }
  }

  public enum Service {
    public static func invoke(contextID: String = String(), objectTypeURL: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(contextID: contextID, objectTypeURL: objectTypeURL), on: queue)
    }
    public static func invoke(contextID: String = String(), objectTypeURL: String = String()) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, objectTypeURL: objectTypeURL))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Object.SetDetails {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceObjectSetDetails(data) }
  }

  public enum Service {
    public static func invoke(contextID: String = String(), details: [Anytype_Rpc.Object.SetDetails.Detail] = [], queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(contextID: contextID, details: details), on: queue)
    }
    public static func invoke(contextID: String = String(), details: [Anytype_Rpc.Object.SetDetails.Detail] = []) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, details: details))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Object.ToSet {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceObjectToSet(data) }
  }

  public enum Service {
    public static func invoke(contextID: String = String(), source: [String] = [], queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(contextID: contextID, source: source), on: queue)
    }
    public static func invoke(contextID: String = String(), source: [String] = []) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, source: source))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Object.Undo {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceObjectUndo(data) }
  }

  public enum Service {
    public static func invoke(contextID: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(contextID: contextID), on: queue)
    }
    public static func invoke(contextID: String = String()) -> Result<Response, Error> {
      self.result(.init(contextID: contextID))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Object.Redo {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceObjectRedo(data) }
  }

  public enum Service {
    public static func invoke(contextID: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(contextID: contextID), on: queue)
    }
    public static func invoke(contextID: String = String()) -> Result<Response, Error> {
      self.result(.init(contextID: contextID))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Object.ListDuplicate {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceObjectListDuplicate(data) }
  }

  public enum Service {
    public static func invoke(objectIds: [String] = [], queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(objectIds: objectIds), on: queue)
    }
    public static func invoke(objectIds: [String] = []) -> Result<Response, Error> {
      self.result(.init(objectIds: objectIds))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Object.ListDelete {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceObjectListDelete(data) }
  }

  public enum Service {
    public static func invoke(objectIds: [String] = [], queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(objectIds: objectIds), on: queue)
    }
    public static func invoke(objectIds: [String] = []) -> Result<Response, Error> {
      self.result(.init(objectIds: objectIds))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Object.ListSetIsArchived {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceObjectListSetIsArchived(data) }
  }

  public enum Service {
    public static func invoke(objectIds: [String] = [], isArchived: Bool = false, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(objectIds: objectIds, isArchived: isArchived), on: queue)
    }
    public static func invoke(objectIds: [String] = [], isArchived: Bool = false) -> Result<Response, Error> {
      self.result(.init(objectIds: objectIds, isArchived: isArchived))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Object.ListSetIsFavorite {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceObjectListSetIsFavorite(data) }
  }

  public enum Service {
    public static func invoke(objectIds: [String] = [], isFavorite: Bool = false, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(objectIds: objectIds, isFavorite: isFavorite), on: queue)
    }
    public static func invoke(objectIds: [String] = [], isFavorite: Bool = false) -> Result<Response, Error> {
      self.result(.init(objectIds: objectIds, isFavorite: isFavorite))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Object.ApplyTemplate {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceObjectApplyTemplate(data) }
  }

  public enum Service {
    public static func invoke(contextID: String = String(), templateID: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(contextID: contextID, templateID: templateID), on: queue)
    }
    public static func invoke(contextID: String = String(), templateID: String = String()) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, templateID: templateID))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Object.ListExport {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceObjectListExport(data) }
  }

  public enum Service {
    public static func invoke(
      path: String = String(), objectIds: [String] = [], format: Anytype_Rpc.Object.ListExport.Format = .markdown, zip: Bool = false, includeNested: Bool = false, includeFiles: Bool = false,
      queue: DispatchQueue? = nil
    ) -> Future<Response, Error> {
      self.invoke(request: .init(path: path, objectIds: objectIds, format: format, zip: zip, includeNested: includeNested, includeFiles: includeFiles), on: queue)
    }
    public static func invoke(
      path: String = String(), objectIds: [String] = [], format: Anytype_Rpc.Object.ListExport.Format = .markdown, zip: Bool = false, includeNested: Bool = false, includeFiles: Bool = false
    ) -> Result<Response, Error> {
      self.result(.init(path: path, objectIds: objectIds, format: format, zip: zip, includeNested: includeNested, includeFiles: includeFiles))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.ObjectRelation.Add {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceObjectRelationAdd(data) }
  }

  public enum Service {
    public static func invoke(contextID: String = String(), relation: Anytype_Model_Relation, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(contextID: contextID, relation: relation), on: queue)
    }
    public static func invoke(contextID: String = String(), relation: Anytype_Model_Relation) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, relation: relation))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.ObjectRelation.Update {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceObjectRelationUpdate(data) }
  }

  public enum Service {
    public static func invoke(contextID: String, relationKey: String, relation: Anytype_Model_Relation, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(contextID: contextID, relationKey: relationKey, relation: relation), on: queue)
    }
    public static func invoke(contextID: String, relationKey: String, relation: Anytype_Model_Relation) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, relationKey: relationKey, relation: relation))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.ObjectRelation.Delete {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceObjectRelationDelete(data) }
  }

  public enum Service {
    public static func invoke(contextID: String = String(), relationKey: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(contextID: contextID, relationKey: relationKey), on: queue)
    }
    public static func invoke(contextID: String = String(), relationKey: String = String()) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, relationKey: relationKey))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.ObjectRelation.ListAvailable {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceObjectRelationListAvailable(data) }
  }

  public enum Service {
    public static func invoke(contextID: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(contextID: contextID), on: queue)
    }
    public static func invoke(contextID: String = String()) -> Result<Response, Error> {
      self.result(.init(contextID: contextID))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.ObjectRelation.AddFeatured {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceObjectRelationAddFeatured(data) }
  }

  public enum Service {
    public static func invoke(contextID: String = String(), relations: [String] = [], queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(contextID: contextID, relations: relations), on: queue)
    }
    public static func invoke(contextID: String = String(), relations: [String] = []) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, relations: relations))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.ObjectRelation.RemoveFeatured {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceObjectRelationRemoveFeatured(data) }
  }

  public enum Service {
    public static func invoke(contextID: String = String(), relations: [String] = [], queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(contextID: contextID, relations: relations), on: queue)
    }
    public static func invoke(contextID: String = String(), relations: [String] = []) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, relations: relations))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.ObjectRelationOption.Add {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceObjectRelationOptionAdd(data) }
  }

  public enum Service {
    public static func invoke(contextID: String = String(), relationKey: String = String(), option: Anytype_Model_Relation.Option, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(contextID: contextID, relationKey: relationKey, option: option), on: queue)
    }
    public static func invoke(contextID: String = String(), relationKey: String = String(), option: Anytype_Model_Relation.Option) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, relationKey: relationKey, option: option))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.ObjectRelationOption.Update {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceObjectRelationOptionUpdate(data) }
  }

  public enum Service {
    public static func invoke(contextID: String = String(), relationKey: String = String(), option: Anytype_Model_Relation.Option, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(contextID: contextID, relationKey: relationKey, option: option), on: queue)
    }
    public static func invoke(contextID: String = String(), relationKey: String = String(), option: Anytype_Model_Relation.Option) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, relationKey: relationKey, option: option))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.ObjectRelationOption.Delete {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceObjectRelationOptionDelete(data) }
  }

  public enum Service {
    public static func invoke(contextID: String = String(), relationKey: String = String(), optionID: String = String(), confirmRemoveAllValuesInRecords: Bool = false, queue: DispatchQueue? = nil)
      -> Future<Response, Error>
    {
      self.invoke(request: .init(contextID: contextID, relationKey: relationKey, optionID: optionID, confirmRemoveAllValuesInRecords: confirmRemoveAllValuesInRecords), on: queue)
    }
    public static func invoke(contextID: String = String(), relationKey: String = String(), optionID: String = String(), confirmRemoveAllValuesInRecords: Bool = false) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, relationKey: relationKey, optionID: optionID, confirmRemoveAllValuesInRecords: confirmRemoveAllValuesInRecords))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.ObjectType.List {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceObjectTypeList(data) }
  }

  public enum Service {
    public static func invoke(queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(), on: queue)
    }
    public static func invoke() -> Result<Response, Error> {
      self.result(.init())
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.ObjectType.Create {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceObjectTypeCreate(data) }
  }

  public enum Service {
    public static func invoke(objectType: Anytype_Model_ObjectType, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(objectType: objectType), on: queue)
    }
    public static func invoke(objectType: Anytype_Model_ObjectType) -> Result<Response, Error> {
      self.result(.init(objectType: objectType))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.ObjectType.Relation.Add {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceObjectTypeRelationAdd(data) }
  }

  public enum Service {
    public static func invoke(objectTypeURL: String = String(), relations: [Anytype_Model_Relation] = [], queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(objectTypeURL: objectTypeURL, relations: relations), on: queue)
    }
    public static func invoke(objectTypeURL: String = String(), relations: [Anytype_Model_Relation] = []) -> Result<Response, Error> {
      self.result(.init(objectTypeURL: objectTypeURL, relations: relations))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.ObjectType.Relation.Remove {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceObjectTypeRelationRemove(data) }
  }

  public enum Service {
    public static func invoke(objectTypeURL: String = String(), relationKey: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(objectTypeURL: objectTypeURL, relationKey: relationKey), on: queue)
    }
    public static func invoke(objectTypeURL: String = String(), relationKey: String = String()) -> Result<Response, Error> {
      self.result(.init(objectTypeURL: objectTypeURL, relationKey: relationKey))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.ObjectType.Relation.Update {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceObjectTypeRelationUpdate(data) }
  }

  public enum Service {
    public static func invoke(objectTypeURL: String = String(), relation: Anytype_Model_Relation, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(objectTypeURL: objectTypeURL, relation: relation), on: queue)
    }
    public static func invoke(objectTypeURL: String = String(), relation: Anytype_Model_Relation) -> Result<Response, Error> {
      self.result(.init(objectTypeURL: objectTypeURL, relation: relation))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.ObjectType.Relation.List {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceObjectTypeRelationList(data) }
  }

  public enum Service {
    public static func invoke(objectTypeURL: String = String(), appendRelationsFromOtherTypes: Bool = false, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(objectTypeURL: objectTypeURL, appendRelationsFromOtherTypes: appendRelationsFromOtherTypes), on: queue)
    }
    public static func invoke(objectTypeURL: String = String(), appendRelationsFromOtherTypes: Bool = false) -> Result<Response, Error> {
      self.result(.init(objectTypeURL: objectTypeURL, appendRelationsFromOtherTypes: appendRelationsFromOtherTypes))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.History.GetVersions {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceHistoryGetVersions(data) }
  }

  public enum Service {
    public static func invoke(pageID: String = String(), lastVersionID: String = String(), limit: Int32 = 0, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(pageID: pageID, lastVersionID: lastVersionID, limit: limit), on: queue)
    }
    public static func invoke(pageID: String = String(), lastVersionID: String = String(), limit: Int32 = 0) -> Result<Response, Error> {
      self.result(.init(pageID: pageID, lastVersionID: lastVersionID, limit: limit))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.History.ShowVersion {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceHistoryShowVersion(data) }
  }

  public enum Service {
    public static func invoke(pageID: String = String(), versionID: String = String(), traceID: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(pageID: pageID, versionID: versionID, traceID: traceID), on: queue)
    }
    public static func invoke(pageID: String = String(), versionID: String = String(), traceID: String = String()) -> Result<Response, Error> {
      self.result(.init(pageID: pageID, versionID: versionID, traceID: traceID))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.History.SetVersion {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceHistorySetVersion(data) }
  }

  public enum Service {
    public static func invoke(pageID: String = String(), versionID: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(pageID: pageID, versionID: versionID), on: queue)
    }
    public static func invoke(pageID: String = String(), versionID: String = String()) -> Result<Response, Error> {
      self.result(.init(pageID: pageID, versionID: versionID))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.File.Offload {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceFileOffload(data) }
  }

  public enum Service {
    public static func invoke(id: String = String(), includeNotPinned: Bool = false, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(id: id, includeNotPinned: includeNotPinned), on: queue)
    }
    public static func invoke(id: String = String(), includeNotPinned: Bool = false) -> Result<Response, Error> {
      self.result(.init(id: id, includeNotPinned: includeNotPinned))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.File.ListOffload {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceFileListOffload(data) }
  }

  public enum Service {
    public static func invoke(onlyIds: [String] = [], includeNotPinned: Bool = false, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(onlyIds: onlyIds, includeNotPinned: includeNotPinned), on: queue)
    }
    public static func invoke(onlyIds: [String] = [], includeNotPinned: Bool = false) -> Result<Response, Error> {
      self.result(.init(onlyIds: onlyIds, includeNotPinned: includeNotPinned))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.File.Upload {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceFileUpload(data) }
  }

  public enum Service {
    public static func invoke(
      url: String = String(), localPath: String = String(), type: Anytype_Model_Block.Content.File.TypeEnum = .none, disableEncryption: Bool = false,
      style: Anytype_Model_Block.Content.File.Style = .auto, queue: DispatchQueue? = nil
    ) -> Future<Response, Error> {
      self.invoke(request: .init(url: url, localPath: localPath, type: type, disableEncryption: disableEncryption, style: style), on: queue)
    }
    public static func invoke(
      url: String = String(), localPath: String = String(), type: Anytype_Model_Block.Content.File.TypeEnum = .none, disableEncryption: Bool = false,
      style: Anytype_Model_Block.Content.File.Style = .auto
    ) -> Result<Response, Error> {
      self.result(.init(url: url, localPath: localPath, type: type, disableEncryption: disableEncryption, style: style))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.File.Download {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceFileDownload(data) }
  }

  public enum Service {
    public static func invoke(hash: String = String(), path: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(hash: hash, path: path), on: queue)
    }
    public static func invoke(hash: String = String(), path: String = String()) -> Result<Response, Error> {
      self.result(.init(hash: hash, path: path))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.File.Drop {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceFileDrop(data) }
  }

  public enum Service {
    public static func invoke(contextID: String = String(), dropTargetID: String = String(), position: Anytype_Model_Block.Position = .none, localFilePaths: [String] = [], queue: DispatchQueue? = nil)
      -> Future<Response, Error>
    {
      self.invoke(request: .init(contextID: contextID, dropTargetID: dropTargetID, position: position, localFilePaths: localFilePaths), on: queue)
    }
    public static func invoke(contextID: String = String(), dropTargetID: String = String(), position: Anytype_Model_Block.Position = .none, localFilePaths: [String] = []) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, dropTargetID: dropTargetID, position: position, localFilePaths: localFilePaths))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Navigation.ListObjects {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceNavigationListObjects(data) }
  }

  public enum Service {
    public static func invoke(context: Anytype_Rpc.Navigation.Context = .navigation, fullText: String = String(), limit: Int32 = 0, offset: Int32 = 0, queue: DispatchQueue? = nil) -> Future<
      Response, Error
    > {
      self.invoke(request: .init(context: context, fullText: fullText, limit: limit, offset: offset), on: queue)
    }
    public static func invoke(context: Anytype_Rpc.Navigation.Context = .navigation, fullText: String = String(), limit: Int32 = 0, offset: Int32 = 0) -> Result<Response, Error> {
      self.result(.init(context: context, fullText: fullText, limit: limit, offset: offset))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Navigation.GetObjectInfoWithLinks {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceNavigationGetObjectInfoWithLinks(data) }
  }

  public enum Service {
    public static func invoke(objectID: String = String(), context: Anytype_Rpc.Navigation.Context = .navigation, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(objectID: objectID, context: context), on: queue)
    }
    public static func invoke(objectID: String = String(), context: Anytype_Rpc.Navigation.Context = .navigation) -> Result<Response, Error> {
      self.result(.init(objectID: objectID, context: context))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Template.CreateFromObject {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceTemplateCreateFromObject(data) }
  }

  public enum Service {
    public static func invoke(contextID: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(contextID: contextID), on: queue)
    }
    public static func invoke(contextID: String = String()) -> Result<Response, Error> {
      self.result(.init(contextID: contextID))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Template.CreateFromObjectType {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceTemplateCreateFromObjectType(data) }
  }

  public enum Service {
    public static func invoke(objectType: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(objectType: objectType), on: queue)
    }
    public static func invoke(objectType: String = String()) -> Result<Response, Error> {
      self.result(.init(objectType: objectType))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Template.Clone {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceTemplateClone(data) }
  }

  public enum Service {
    public static func invoke(contextID: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(contextID: contextID), on: queue)
    }
    public static func invoke(contextID: String = String()) -> Result<Response, Error> {
      self.result(.init(contextID: contextID))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Template.ExportAll {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceTemplateExportAll(data) }
  }

  public enum Service {
    public static func invoke(path: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(path: path), on: queue)
    }
    public static func invoke(path: String = String()) -> Result<Response, Error> {
      self.result(.init(path: path))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.LinkPreview {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceLinkPreview(data) }
  }

  public enum Service {
    public static func invoke(url: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(url: url), on: queue)
    }
    public static func invoke(url: String = String()) -> Result<Response, Error> {
      self.result(.init(url: url))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Unsplash.Search {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceUnsplashSearch(data) }
  }

  public enum Service {
    public static func invoke(query: String = String(), limit: Int32 = 0, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(query: query, limit: limit), on: queue)
    }
    public static func invoke(query: String = String(), limit: Int32 = 0) -> Result<Response, Error> {
      self.result(.init(query: query, limit: limit))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Unsplash.Download {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceUnsplashDownload(data) }
  }

  public enum Service {
    public static func invoke(pictureID: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(pictureID: pictureID), on: queue)
    }
    public static func invoke(pictureID: String = String()) -> Result<Response, Error> {
      self.result(.init(pictureID: pictureID))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Block.Replace {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockReplace(data) }
  }

  public enum Service {
    public static func invoke(contextID: String = String(), blockID: String = String(), block: Anytype_Model_Block, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(contextID: contextID, blockID: blockID, block: block), on: queue)
    }
    public static func invoke(contextID: String = String(), blockID: String = String(), block: Anytype_Model_Block) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockID: blockID, block: block))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Block.Split {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockSplit(data) }
  }

  public enum Service {
    public static func invoke(
      contextID: String = String(), blockID: String = String(), range: Anytype_Model_Range, style: Anytype_Model_Block.Content.Text.Style = .paragraph,
      mode: Anytype_Rpc.Block.Split.Request.Mode = .bottom, queue: DispatchQueue? = nil
    ) -> Future<Response, Error> {
      self.invoke(request: .init(contextID: contextID, blockID: blockID, range: range, style: style, mode: mode), on: queue)
    }
    public static func invoke(
      contextID: String = String(), blockID: String = String(), range: Anytype_Model_Range, style: Anytype_Model_Block.Content.Text.Style = .paragraph,
      mode: Anytype_Rpc.Block.Split.Request.Mode = .bottom
    ) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockID: blockID, range: range, style: style, mode: mode))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Block.Merge {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockMerge(data) }
  }

  public enum Service {
    public static func invoke(contextID: String = String(), firstBlockID: String = String(), secondBlockID: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(contextID: contextID, firstBlockID: firstBlockID, secondBlockID: secondBlockID), on: queue)
    }
    public static func invoke(contextID: String = String(), firstBlockID: String = String(), secondBlockID: String = String()) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, firstBlockID: firstBlockID, secondBlockID: secondBlockID))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Block.Copy {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockCopy(data) }
  }

  public enum Service {
    public static func invoke(contextID: String = String(), blocks: [Anytype_Model_Block] = [], selectedTextRange: Anytype_Model_Range, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(contextID: contextID, blocks: blocks, selectedTextRange: selectedTextRange), on: queue)
    }
    public static func invoke(contextID: String = String(), blocks: [Anytype_Model_Block] = [], selectedTextRange: Anytype_Model_Range) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blocks: blocks, selectedTextRange: selectedTextRange))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Block.Paste {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockPaste(data) }
  }

  public enum Service {
    public static func invoke(
      contextID: String = String(), focusedBlockID: String = String(), selectedTextRange: Anytype_Model_Range, selectedBlockIds: [String] = [], isPartOfBlock: Bool = false,
      textSlot: String = String(), htmlSlot: String = String(), anySlot: [Anytype_Model_Block] = [], fileSlot: [Anytype_Rpc.Block.Paste.Request.File] = [], queue: DispatchQueue? = nil
    ) -> Future<Response, Error> {
      self.invoke(
        request: .init(
          contextID: contextID, focusedBlockID: focusedBlockID, selectedTextRange: selectedTextRange, selectedBlockIds: selectedBlockIds, isPartOfBlock: isPartOfBlock, textSlot: textSlot,
          htmlSlot: htmlSlot, anySlot: anySlot, fileSlot: fileSlot), on: queue)
    }
    public static func invoke(
      contextID: String = String(), focusedBlockID: String = String(), selectedTextRange: Anytype_Model_Range, selectedBlockIds: [String] = [], isPartOfBlock: Bool = false,
      textSlot: String = String(), htmlSlot: String = String(), anySlot: [Anytype_Model_Block] = [], fileSlot: [Anytype_Rpc.Block.Paste.Request.File] = []
    ) -> Result<Response, Error> {
      self.result(
        .init(
          contextID: contextID, focusedBlockID: focusedBlockID, selectedTextRange: selectedTextRange, selectedBlockIds: selectedBlockIds, isPartOfBlock: isPartOfBlock, textSlot: textSlot,
          htmlSlot: htmlSlot, anySlot: anySlot, fileSlot: fileSlot))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Block.Cut {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockCut(data) }
  }

  public enum Service {
    public static func invoke(contextID: String = String(), blocks: [Anytype_Model_Block] = [], selectedTextRange: Anytype_Model_Range, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(contextID: contextID, blocks: blocks, selectedTextRange: selectedTextRange), on: queue)
    }
    public static func invoke(contextID: String = String(), blocks: [Anytype_Model_Block] = [], selectedTextRange: Anytype_Model_Range) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blocks: blocks, selectedTextRange: selectedTextRange))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Block.Upload {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockUpload(data) }
  }

  public enum Service {
    public static func invoke(contextID: String = String(), blockID: String = String(), filePath: String = String(), url: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(contextID: contextID, blockID: blockID, filePath: filePath, url: url), on: queue)
    }
    public static func invoke(contextID: String = String(), blockID: String = String(), filePath: String = String(), url: String = String()) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockID: blockID, filePath: filePath, url: url))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Block.Create {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockCreate(data) }
  }

  public enum Service {
    public static func invoke(contextID: String = String(), targetID: String = String(), block: Anytype_Model_Block, position: Anytype_Model_Block.Position = .none, queue: DispatchQueue? = nil)
      -> Future<Response, Error>
    {
      self.invoke(request: .init(contextID: contextID, targetID: targetID, block: block, position: position), on: queue)
    }
    public static func invoke(contextID: String = String(), targetID: String = String(), block: Anytype_Model_Block, position: Anytype_Model_Block.Position = .none) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, targetID: targetID, block: block, position: position))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Block.ListDelete {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockListDelete(data) }
  }

  public enum Service {
    public static func invoke(contextID: String = String(), blockIds: [String] = [], queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(contextID: contextID, blockIds: blockIds), on: queue)
    }
    public static func invoke(contextID: String = String(), blockIds: [String] = []) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockIds: blockIds))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Block.SetFields {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockSetFields(data) }
  }

  public enum Service {
    public static func invoke(contextID: String = String(), blockID: String = String(), fields: SwiftProtobuf.Google_Protobuf_Struct, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(contextID: contextID, blockID: blockID, fields: fields), on: queue)
    }
    public static func invoke(contextID: String = String(), blockID: String = String(), fields: SwiftProtobuf.Google_Protobuf_Struct) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockID: blockID, fields: fields))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Block.ListSetAlign {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockListSetAlign(data) }
  }

  public enum Service {
    public static func invoke(contextID: String = String(), blockIds: [String] = [], align: Anytype_Model_Block.Align = .left, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(contextID: contextID, blockIds: blockIds, align: align), on: queue)
    }
    public static func invoke(contextID: String = String(), blockIds: [String] = [], align: Anytype_Model_Block.Align = .left) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockIds: blockIds, align: align))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Block.ListSetFields {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockListSetFields(data) }
  }

  public enum Service {
    public static func invoke(contextID: String = String(), blockFields: [Anytype_Rpc.Block.ListSetFields.Request.BlockField] = [], queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(contextID: contextID, blockFields: blockFields), on: queue)
    }
    public static func invoke(contextID: String = String(), blockFields: [Anytype_Rpc.Block.ListSetFields.Request.BlockField] = []) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockFields: blockFields))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Block.ListDuplicate {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockListDuplicate(data) }
  }

  public enum Service {
    public static func invoke(contextID: String = String(), targetID: String = String(), blockIds: [String] = [], position: Anytype_Model_Block.Position = .none, queue: DispatchQueue? = nil)
      -> Future<Response, Error>
    {
      self.invoke(request: .init(contextID: contextID, targetID: targetID, blockIds: blockIds, position: position), on: queue)
    }
    public static func invoke(contextID: String = String(), targetID: String = String(), blockIds: [String] = [], position: Anytype_Model_Block.Position = .none) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, targetID: targetID, blockIds: blockIds, position: position))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Block.ListConvertToObjects {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockListConvertToObjects(data) }
  }

  public enum Service {
    public static func invoke(contextID: String = String(), blockIds: [String] = [], objectType: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(contextID: contextID, blockIds: blockIds, objectType: objectType), on: queue)
    }
    public static func invoke(contextID: String = String(), blockIds: [String] = [], objectType: String = String()) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockIds: blockIds, objectType: objectType))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Block.ListMoveToExistingObject {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockListMoveToExistingObject(data) }
  }

  public enum Service {
    public static func invoke(
      contextID: String = String(), blockIds: [String] = [], targetContextID: String = String(), dropTargetID: String = String(), position: Anytype_Model_Block.Position = .none,
      queue: DispatchQueue? = nil
    ) -> Future<Response, Error> {
      self.invoke(request: .init(contextID: contextID, blockIds: blockIds, targetContextID: targetContextID, dropTargetID: dropTargetID, position: position), on: queue)
    }
    public static func invoke(
      contextID: String = String(), blockIds: [String] = [], targetContextID: String = String(), dropTargetID: String = String(), position: Anytype_Model_Block.Position = .none
    ) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockIds: blockIds, targetContextID: targetContextID, dropTargetID: dropTargetID, position: position))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Block.ListMoveToNewObject {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockListMoveToNewObject(data) }
  }

  public enum Service {
    public static func invoke(
      contextID: String = String(), blockIds: [String] = [], details: SwiftProtobuf.Google_Protobuf_Struct, dropTargetID: String = String(), position: Anytype_Model_Block.Position = .none,
      queue: DispatchQueue? = nil
    ) -> Future<Response, Error> {
      self.invoke(request: .init(contextID: contextID, blockIds: blockIds, details: details, dropTargetID: dropTargetID, position: position), on: queue)
    }
    public static func invoke(
      contextID: String = String(), blockIds: [String] = [], details: SwiftProtobuf.Google_Protobuf_Struct, dropTargetID: String = String(), position: Anytype_Model_Block.Position = .none
    ) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockIds: blockIds, details: details, dropTargetID: dropTargetID, position: position))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Block.ListTurnInto {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockListTurnInto(data) }
  }

  public enum Service {
    public static func invoke(contextID: String = String(), blockIds: [String] = [], style: Anytype_Model_Block.Content.Text.Style = .paragraph, queue: DispatchQueue? = nil) -> Future<Response, Error>
    {
      self.invoke(request: .init(contextID: contextID, blockIds: blockIds, style: style), on: queue)
    }
    public static func invoke(contextID: String = String(), blockIds: [String] = [], style: Anytype_Model_Block.Content.Text.Style = .paragraph) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockIds: blockIds, style: style))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Block.ListSetBackgroundColor {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockListSetBackgroundColor(data) }
  }

  public enum Service {
    public static func invoke(contextID: String = String(), blockIds: [String] = [], color: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(contextID: contextID, blockIds: blockIds, color: color), on: queue)
    }
    public static func invoke(contextID: String = String(), blockIds: [String] = [], color: String = String()) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockIds: blockIds, color: color))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Block.Export {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockExport(data) }
  }

  public enum Service {
    public static func invoke(contextID: String = String(), blocks: [Anytype_Model_Block] = [], queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(contextID: contextID, blocks: blocks), on: queue)
    }
    public static func invoke(contextID: String = String(), blocks: [Anytype_Model_Block] = []) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blocks: blocks))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.BlockLatex.SetText {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockLatexSetText(data) }
  }

  public enum Service {
    public static func invoke(contextID: String = String(), blockID: String = String(), text: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(contextID: contextID, blockID: blockID, text: text), on: queue)
    }
    public static func invoke(contextID: String = String(), blockID: String = String(), text: String = String()) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockID: blockID, text: text))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.BlockText.SetText {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockTextSetText(data) }
  }

  public enum Service {
    public static func invoke(contextID: String = String(), blockID: String = String(), text: String = String(), marks: Anytype_Model_Block.Content.Text.Marks, queue: DispatchQueue? = nil) -> Future<
      Response, Error
    > {
      self.invoke(request: .init(contextID: contextID, blockID: blockID, text: text, marks: marks), on: queue)
    }
    public static func invoke(contextID: String = String(), blockID: String = String(), text: String = String(), marks: Anytype_Model_Block.Content.Text.Marks) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockID: blockID, text: text, marks: marks))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.BlockText.SetColor {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockTextSetColor(data) }
  }

  public enum Service {
    public static func invoke(contextID: String = String(), blockID: String = String(), color: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(contextID: contextID, blockID: blockID, color: color), on: queue)
    }
    public static func invoke(contextID: String = String(), blockID: String = String(), color: String = String()) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockID: blockID, color: color))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.BlockText.SetStyle {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockTextSetStyle(data) }
  }

  public enum Service {
    public static func invoke(contextID: String = String(), blockID: String = String(), style: Anytype_Model_Block.Content.Text.Style = .paragraph, queue: DispatchQueue? = nil) -> Future<
      Response, Error
    > {
      self.invoke(request: .init(contextID: contextID, blockID: blockID, style: style), on: queue)
    }
    public static func invoke(contextID: String = String(), blockID: String = String(), style: Anytype_Model_Block.Content.Text.Style = .paragraph) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockID: blockID, style: style))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.BlockText.SetChecked {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockTextSetChecked(data) }
  }

  public enum Service {
    public static func invoke(contextID: String = String(), blockID: String = String(), checked: Bool = false, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(contextID: contextID, blockID: blockID, checked: checked), on: queue)
    }
    public static func invoke(contextID: String = String(), blockID: String = String(), checked: Bool = false) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockID: blockID, checked: checked))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.BlockText.SetIcon {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockTextSetIcon(data) }
  }

  public enum Service {
    public static func invoke(contextID: String = String(), blockID: String = String(), iconImage: String = String(), iconEmoji: String = String(), queue: DispatchQueue? = nil) -> Future<
      Response, Error
    > {
      self.invoke(request: .init(contextID: contextID, blockID: blockID, iconImage: iconImage, iconEmoji: iconEmoji), on: queue)
    }
    public static func invoke(contextID: String = String(), blockID: String = String(), iconImage: String = String(), iconEmoji: String = String()) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockID: blockID, iconImage: iconImage, iconEmoji: iconEmoji))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.BlockText.ListSetStyle {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockTextListSetStyle(data) }
  }

  public enum Service {
    public static func invoke(contextID: String = String(), blockIds: [String] = [], style: Anytype_Model_Block.Content.Text.Style = .paragraph, queue: DispatchQueue? = nil) -> Future<Response, Error>
    {
      self.invoke(request: .init(contextID: contextID, blockIds: blockIds, style: style), on: queue)
    }
    public static func invoke(contextID: String = String(), blockIds: [String] = [], style: Anytype_Model_Block.Content.Text.Style = .paragraph) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockIds: blockIds, style: style))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.BlockText.ListSetColor {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockTextListSetColor(data) }
  }

  public enum Service {
    public static func invoke(contextID: String = String(), blockIds: [String] = [], color: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(contextID: contextID, blockIds: blockIds, color: color), on: queue)
    }
    public static func invoke(contextID: String = String(), blockIds: [String] = [], color: String = String()) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockIds: blockIds, color: color))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.BlockText.ListSetMark {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockTextListSetMark(data) }
  }

  public enum Service {
    public static func invoke(contextID: String = String(), blockIds: [String] = [], mark: Anytype_Model_Block.Content.Text.Mark, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(contextID: contextID, blockIds: blockIds, mark: mark), on: queue)
    }
    public static func invoke(contextID: String = String(), blockIds: [String] = [], mark: Anytype_Model_Block.Content.Text.Mark) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockIds: blockIds, mark: mark))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.BlockFile.SetName {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockFileSetName(data) }
  }

  public enum Service {
    public static func invoke(contextID: String = String(), blockID: String = String(), name: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(contextID: contextID, blockID: blockID, name: name), on: queue)
    }
    public static func invoke(contextID: String = String(), blockID: String = String(), name: String = String()) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockID: blockID, name: name))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.BlockFile.CreateAndUpload {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockFileCreateAndUpload(data) }
  }

  public enum Service {
    public static func invoke(
      contextID: String = String(), targetID: String = String(), position: Anytype_Model_Block.Position = .none, url: String = String(), localPath: String = String(),
      fileType: Anytype_Model_Block.Content.File.TypeEnum = .none, queue: DispatchQueue? = nil
    ) -> Future<Response, Error> {
      self.invoke(request: .init(contextID: contextID, targetID: targetID, position: position, url: url, localPath: localPath, fileType: fileType), on: queue)
    }
    public static func invoke(
      contextID: String = String(), targetID: String = String(), position: Anytype_Model_Block.Position = .none, url: String = String(), localPath: String = String(),
      fileType: Anytype_Model_Block.Content.File.TypeEnum = .none
    ) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, targetID: targetID, position: position, url: url, localPath: localPath, fileType: fileType))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.BlockFile.ListSetStyle {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockFileListSetStyle(data) }
  }

  public enum Service {
    public static func invoke(contextID: String = String(), blockIds: [String] = [], style: Anytype_Model_Block.Content.File.Style = .auto, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(contextID: contextID, blockIds: blockIds, style: style), on: queue)
    }
    public static func invoke(contextID: String = String(), blockIds: [String] = [], style: Anytype_Model_Block.Content.File.Style = .auto) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockIds: blockIds, style: style))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.BlockImage.SetName {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockImageSetName(data) }
  }

  public enum Service {
    public static func invoke(contextID: String = String(), blockID: String = String(), name: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(contextID: contextID, blockID: blockID, name: name), on: queue)
    }
    public static func invoke(contextID: String = String(), blockID: String = String(), name: String = String()) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockID: blockID, name: name))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.BlockVideo.SetName {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockVideoSetName(data) }
  }

  public enum Service {
    public static func invoke(contextID: String = String(), blockID: String = String(), name: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(contextID: contextID, blockID: blockID, name: name), on: queue)
    }
    public static func invoke(contextID: String = String(), blockID: String = String(), name: String = String()) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockID: blockID, name: name))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.BlockLink.CreateWithObject {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockLinkCreateWithObject(data) }
  }

  public enum Service {
    public static func invoke(
      contextID: String = String(), details: SwiftProtobuf.Google_Protobuf_Struct, templateID: String = String(), internalFlags: [Anytype_Model_InternalFlag] = [], targetID: String = String(),
      position: Anytype_Model_Block.Position = .none, fields: SwiftProtobuf.Google_Protobuf_Struct, queue: DispatchQueue? = nil
    ) -> Future<Response, Error> {
      self.invoke(request: .init(contextID: contextID, details: details, templateID: templateID, internalFlags: internalFlags, targetID: targetID, position: position, fields: fields), on: queue)
    }
    public static func invoke(
      contextID: String = String(), details: SwiftProtobuf.Google_Protobuf_Struct, templateID: String = String(), internalFlags: [Anytype_Model_InternalFlag] = [], targetID: String = String(),
      position: Anytype_Model_Block.Position = .none, fields: SwiftProtobuf.Google_Protobuf_Struct
    ) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, details: details, templateID: templateID, internalFlags: internalFlags, targetID: targetID, position: position, fields: fields))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.BlockLink.ListSetAppearance {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockLinkListSetAppearance(data) }
  }

  public enum Service {
    public static func invoke(
      contextID: String = String(), blockIds: [String] = [], iconSize: Anytype_Model_Block.Content.Link.IconSize = .sizeNone, cardStyle: Anytype_Model_Block.Content.Link.CardStyle = .text,
      description_p: Anytype_Model_Block.Content.Link.Description = .none, relations: [String] = [], queue: DispatchQueue? = nil
    ) -> Future<Response, Error> {
      self.invoke(request: .init(contextID: contextID, blockIds: blockIds, iconSize: iconSize, cardStyle: cardStyle, description_p: description_p, relations: relations), on: queue)
    }
    public static func invoke(
      contextID: String = String(), blockIds: [String] = [], iconSize: Anytype_Model_Block.Content.Link.IconSize = .sizeNone, cardStyle: Anytype_Model_Block.Content.Link.CardStyle = .text,
      description_p: Anytype_Model_Block.Content.Link.Description = .none, relations: [String] = []
    ) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockIds: blockIds, iconSize: iconSize, cardStyle: cardStyle, description_p: description_p, relations: relations))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.BlockRelation.SetKey {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockRelationSetKey(data) }
  }

  public enum Service {
    public static func invoke(contextID: String = String(), blockID: String = String(), key: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(contextID: contextID, blockID: blockID, key: key), on: queue)
    }
    public static func invoke(contextID: String = String(), blockID: String = String(), key: String = String()) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockID: blockID, key: key))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.BlockRelation.Add {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockRelationAdd(data) }
  }

  public enum Service {
    public static func invoke(contextID: String, blockID: String, relation: Anytype_Model_Relation, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(contextID: contextID, blockID: blockID, relation: relation), on: queue)
    }
    public static func invoke(contextID: String, blockID: String, relation: Anytype_Model_Relation) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockID: blockID, relation: relation))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.BlockBookmark.Fetch {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockBookmarkFetch(data) }
  }

  public enum Service {
    public static func invoke(contextID: String = String(), blockID: String = String(), url: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(contextID: contextID, blockID: blockID, url: url), on: queue)
    }
    public static func invoke(contextID: String = String(), blockID: String = String(), url: String = String()) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockID: blockID, url: url))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.BlockBookmark.CreateAndFetch {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockBookmarkCreateAndFetch(data) }
  }

  public enum Service {
    public static func invoke(contextID: String = String(), targetID: String = String(), position: Anytype_Model_Block.Position = .none, url: String = String(), queue: DispatchQueue? = nil) -> Future<
      Response, Error
    > {
      self.invoke(request: .init(contextID: contextID, targetID: targetID, position: position, url: url), on: queue)
    }
    public static func invoke(contextID: String = String(), targetID: String = String(), position: Anytype_Model_Block.Position = .none, url: String = String()) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, targetID: targetID, position: position, url: url))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.BlockDiv.ListSetStyle {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockDivListSetStyle(data) }
  }

  public enum Service {
    public static func invoke(contextID: String = String(), blockIds: [String] = [], style: Anytype_Model_Block.Content.Div.Style = .line, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(contextID: contextID, blockIds: blockIds, style: style), on: queue)
    }
    public static func invoke(contextID: String = String(), blockIds: [String] = [], style: Anytype_Model_Block.Content.Div.Style = .line) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockIds: blockIds, style: style))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.BlockDataview.View.Create {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockDataviewViewCreate(data) }
  }

  public enum Service {
    public static func invoke(contextID: String = String(), blockID: String = String(), view: Anytype_Model_Block.Content.Dataview.View, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(contextID: contextID, blockID: blockID, view: view), on: queue)
    }
    public static func invoke(contextID: String = String(), blockID: String = String(), view: Anytype_Model_Block.Content.Dataview.View) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockID: blockID, view: view))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.BlockDataview.View.Update {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockDataviewViewUpdate(data) }
  }

  public enum Service {
    public static func invoke(contextID: String = String(), blockID: String = String(), viewID: String = String(), view: Anytype_Model_Block.Content.Dataview.View, queue: DispatchQueue? = nil)
      -> Future<Response, Error>
    {
      self.invoke(request: .init(contextID: contextID, blockID: blockID, viewID: viewID, view: view), on: queue)
    }
    public static func invoke(contextID: String = String(), blockID: String = String(), viewID: String = String(), view: Anytype_Model_Block.Content.Dataview.View) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockID: blockID, viewID: viewID, view: view))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.BlockDataview.View.Delete {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockDataviewViewDelete(data) }
  }

  public enum Service {
    public static func invoke(contextID: String = String(), blockID: String = String(), viewID: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(contextID: contextID, blockID: blockID, viewID: viewID), on: queue)
    }
    public static func invoke(contextID: String = String(), blockID: String = String(), viewID: String = String()) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockID: blockID, viewID: viewID))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.BlockDataview.View.SetActive {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockDataviewViewSetActive(data) }
  }

  public enum Service {
    public static func invoke(contextID: String = String(), blockID: String = String(), viewID: String = String(), offset: UInt32 = 0, limit: UInt32 = 0, queue: DispatchQueue? = nil) -> Future<
      Response, Error
    > {
      self.invoke(request: .init(contextID: contextID, blockID: blockID, viewID: viewID, offset: offset, limit: limit), on: queue)
    }
    public static func invoke(contextID: String = String(), blockID: String = String(), viewID: String = String(), offset: UInt32 = 0, limit: UInt32 = 0) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockID: blockID, viewID: viewID, offset: offset, limit: limit))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.BlockDataview.Relation.Add {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockDataviewRelationAdd(data) }
  }

  public enum Service {
    public static func invoke(contextID: String, blockID: String, relation: Anytype_Model_Relation, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(contextID: contextID, blockID: blockID, relation: relation), on: queue)
    }
    public static func invoke(contextID: String, blockID: String, relation: Anytype_Model_Relation) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockID: blockID, relation: relation))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.BlockDataview.Relation.Update {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockDataviewRelationUpdate(data) }
  }

  public enum Service {
    public static func invoke(contextID: String, blockID: String, relationKey: String, relation: Anytype_Model_Relation, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(contextID: contextID, blockID: blockID, relationKey: relationKey, relation: relation), on: queue)
    }
    public static func invoke(contextID: String, blockID: String, relationKey: String, relation: Anytype_Model_Relation) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockID: blockID, relationKey: relationKey, relation: relation))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.BlockDataview.Relation.Delete {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockDataviewRelationDelete(data) }
  }

  public enum Service {
    public static func invoke(contextID: String = String(), blockID: String = String(), relationKey: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(contextID: contextID, blockID: blockID, relationKey: relationKey), on: queue)
    }
    public static func invoke(contextID: String = String(), blockID: String = String(), relationKey: String = String()) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockID: blockID, relationKey: relationKey))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.BlockDataview.Relation.ListAvailable {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockDataviewRelationListAvailable(data) }
  }

  public enum Service {
    public static func invoke(contextID: String = String(), blockID: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(contextID: contextID, blockID: blockID), on: queue)
    }
    public static func invoke(contextID: String = String(), blockID: String = String()) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockID: blockID))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.BlockDataview.SetSource {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockDataviewSetSource(data) }
  }

  public enum Service {
    public static func invoke(contextID: String = String(), blockID: String = String(), source: [String] = [], queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(contextID: contextID, blockID: blockID, source: source), on: queue)
    }
    public static func invoke(contextID: String = String(), blockID: String = String(), source: [String] = []) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockID: blockID, source: source))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.BlockDataviewRecord.Update {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockDataviewRecordUpdate(data) }
  }

  public enum Service {
    public static func invoke(contextID: String = String(), blockID: String = String(), recordID: String = String(), record: SwiftProtobuf.Google_Protobuf_Struct, queue: DispatchQueue? = nil)
      -> Future<Response, Error>
    {
      self.invoke(request: .init(contextID: contextID, blockID: blockID, recordID: recordID, record: record), on: queue)
    }
    public static func invoke(contextID: String = String(), blockID: String = String(), recordID: String = String(), record: SwiftProtobuf.Google_Protobuf_Struct) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockID: blockID, recordID: recordID, record: record))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.BlockDataviewRecord.Delete {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockDataviewRecordDelete(data) }
  }

  public enum Service {
    public static func invoke(contextID: String = String(), blockID: String = String(), recordID: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(contextID: contextID, blockID: blockID, recordID: recordID), on: queue)
    }
    public static func invoke(contextID: String = String(), blockID: String = String(), recordID: String = String()) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockID: blockID, recordID: recordID))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.BlockDataviewRecord.Create {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockDataviewRecordCreate(data) }
  }

  public enum Service {
    public static func invoke(contextID: String = String(), blockID: String = String(), record: SwiftProtobuf.Google_Protobuf_Struct, templateID: String = String(), queue: DispatchQueue? = nil)
      -> Future<Response, Error>
    {
      self.invoke(request: .init(contextID: contextID, blockID: blockID, record: record, templateID: templateID), on: queue)
    }
    public static func invoke(contextID: String = String(), blockID: String = String(), record: SwiftProtobuf.Google_Protobuf_Struct, templateID: String = String()) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockID: blockID, record: record, templateID: templateID))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.BlockDataviewRecord.RelationOption.Add {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockDataviewRecordRelationOptionAdd(data) }
  }

  public enum Service {
    public static func invoke(
      contextID: String = String(), blockID: String = String(), relationKey: String = String(), option: Anytype_Model_Relation.Option, recordID: String = String(), queue: DispatchQueue? = nil
    ) -> Future<Response, Error> {
      self.invoke(request: .init(contextID: contextID, blockID: blockID, relationKey: relationKey, option: option, recordID: recordID), on: queue)
    }
    public static func invoke(contextID: String = String(), blockID: String = String(), relationKey: String = String(), option: Anytype_Model_Relation.Option, recordID: String = String()) -> Result<
      Response, Error
    > {
      self.result(.init(contextID: contextID, blockID: blockID, relationKey: relationKey, option: option, recordID: recordID))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.BlockDataviewRecord.RelationOption.Update {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockDataviewRecordRelationOptionUpdate(data) }
  }

  public enum Service {
    public static func invoke(
      contextID: String = String(), blockID: String = String(), relationKey: String = String(), option: Anytype_Model_Relation.Option, recordID: String = String(), queue: DispatchQueue? = nil
    ) -> Future<Response, Error> {
      self.invoke(request: .init(contextID: contextID, blockID: blockID, relationKey: relationKey, option: option, recordID: recordID), on: queue)
    }
    public static func invoke(contextID: String = String(), blockID: String = String(), relationKey: String = String(), option: Anytype_Model_Relation.Option, recordID: String = String()) -> Result<
      Response, Error
    > {
      self.result(.init(contextID: contextID, blockID: blockID, relationKey: relationKey, option: option, recordID: recordID))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.BlockDataviewRecord.RelationOption.Delete {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockDataviewRecordRelationOptionDelete(data) }
  }

  public enum Service {
    public static func invoke(
      contextID: String = String(), blockID: String = String(), relationKey: String = String(), optionID: String = String(), recordID: String = String(), queue: DispatchQueue? = nil
    ) -> Future<Response, Error> {
      self.invoke(request: .init(contextID: contextID, blockID: blockID, relationKey: relationKey, optionID: optionID, recordID: recordID), on: queue)
    }
    public static func invoke(contextID: String = String(), blockID: String = String(), relationKey: String = String(), optionID: String = String(), recordID: String = String()) -> Result<
      Response, Error
    > {
      self.result(.init(contextID: contextID, blockID: blockID, relationKey: relationKey, optionID: optionID, recordID: recordID))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Debug.Sync {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceDebugSync(data) }
  }

  public enum Service {
    public static func invoke(recordsTraverseLimit: Int32 = 0, skipEmptyLogs: Bool = false, tryToDownloadRemoteRecords: Bool = false, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(recordsTraverseLimit: recordsTraverseLimit, skipEmptyLogs: skipEmptyLogs, tryToDownloadRemoteRecords: tryToDownloadRemoteRecords), on: queue)
    }
    public static func invoke(recordsTraverseLimit: Int32 = 0, skipEmptyLogs: Bool = false, tryToDownloadRemoteRecords: Bool = false) -> Result<Response, Error> {
      self.result(.init(recordsTraverseLimit: recordsTraverseLimit, skipEmptyLogs: skipEmptyLogs, tryToDownloadRemoteRecords: tryToDownloadRemoteRecords))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Debug.Thread {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceDebugThread(data) }
  }

  public enum Service {
    public static func invoke(threadID: String = String(), skipEmptyLogs: Bool = false, tryToDownloadRemoteRecords: Bool = false, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(threadID: threadID, skipEmptyLogs: skipEmptyLogs, tryToDownloadRemoteRecords: tryToDownloadRemoteRecords), on: queue)
    }
    public static func invoke(threadID: String = String(), skipEmptyLogs: Bool = false, tryToDownloadRemoteRecords: Bool = false) -> Result<Response, Error> {
      self.result(.init(threadID: threadID, skipEmptyLogs: skipEmptyLogs, tryToDownloadRemoteRecords: tryToDownloadRemoteRecords))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Debug.Tree {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceDebugTree(data) }
  }

  public enum Service {
    public static func invoke(objectID: String = String(), path: String = String(), unanonymized: Bool = false, generateSvg: Bool = false, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(objectID: objectID, path: path, unanonymized: unanonymized, generateSvg: generateSvg), on: queue)
    }
    public static func invoke(objectID: String = String(), path: String = String(), unanonymized: Bool = false, generateSvg: Bool = false) -> Result<Response, Error> {
      self.result(.init(objectID: objectID, path: path, unanonymized: unanonymized, generateSvg: generateSvg))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Debug.ExportLocalstore {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceDebugExportLocalstore(data) }
  }

  public enum Service {
    public static func invoke(path: String = String(), docIds: [String] = [], queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(path: path, docIds: docIds), on: queue)
    }
    public static func invoke(path: String = String(), docIds: [String] = []) -> Result<Response, Error> {
      self.result(.init(path: path, docIds: docIds))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Debug.Ping {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceDebugPing(data) }
  }

  public enum Service {
    public static func invoke(index: Int32 = 0, numberOfEventsToSend: Int32 = 0, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(index: index, numberOfEventsToSend: numberOfEventsToSend), on: queue)
    }
    public static func invoke(index: Int32 = 0, numberOfEventsToSend: Int32 = 0) -> Result<Response, Error> {
      self.result(.init(index: index, numberOfEventsToSend: numberOfEventsToSend))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Metrics.SetParameters {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceMetricsSetParameters(data) }
  }

  public enum Service {
    public static func invoke(platform: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(platform: platform), on: queue)
    }
    public static func invoke(platform: String = String()) -> Result<Response, Error> {
      self.result(.init(platform: platform))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Log.Send {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceLogSend(data) }
  }

  public enum Service {
    public static func invoke(message: String = String(), level: Anytype_Rpc.Log.Send.Request.Level = .debug, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(message: message, level: level), on: queue)
    }
    public static func invoke(message: String = String(), level: Anytype_Rpc.Log.Send.Request.Level = .debug) -> Result<Response, Error> {
      self.result(.init(message: message, level: level))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}

extension Anytype_Rpc.Process.Cancel {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceProcessCancel(data) }
  }

  public enum Service {
    public static func invoke(id: String = String(), queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(request: .init(id: id), on: queue)
    }
    public static func invoke(id: String = String()) -> Result<Response, Error> {
      self.result(.init(id: id))
    }
    private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(request))
          }
        } else {
          promise(self.result(request))
        }
      }
    }
    private static func result(_ request: Request) -> Result<Response, Error> {
      guard let result = self.invoke(request) else {
        // get first Not Null (not equal 0) case.
        return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
      }
      // get first zero case.
      if result.error.code != .null {
        let domain = Anytype_Middleware_Error.domain
        let code = result.error.code.rawValue
        let description = result.error.description_p
        return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
      } else {
        return .success(result)
      }
    }
    private static func invoke(_ request: Request) -> Response? {
      Invocation.invoke(try? request.serializedData()).flatMap {
        try? Response(serializedData: $0)
      }
    }
  }
}
