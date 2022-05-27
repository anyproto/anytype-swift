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

extension Anytype_Rpc.Metrics.SetParameters {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceMetricsSetParameters(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(platform: String, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(platform: platform), on: queue)
    }
    public static func invoke(platform: String) -> Result<Response, Error> {
      self.result(.init(platform: platform))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.ExternalDrop.Files {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceExternalDropFiles(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, dropTargetID: String, position: Anytype_Model_Block.Position, localFilePaths: [String], queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, dropTargetID: dropTargetID, position: position, localFilePaths: localFilePaths), on: queue)
    }
    public static func invoke(contextID: String, dropTargetID: String, position: Anytype_Model_Block.Position, localFilePaths: [String]) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, dropTargetID: dropTargetID, position: position, localFilePaths: localFilePaths))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.ExternalDrop.Content {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceExternalDropContent(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, focusedBlockID: String, content: Data, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, focusedBlockID: focusedBlockID, content: content), on: queue)
    }
    public static func invoke(contextID: String, focusedBlockID: String, content: Data) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, focusedBlockID: focusedBlockID, content: content))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.BlockList.ConvertChildrenToPages {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockListConvertChildrenToPages(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, blockIds: [String], objectType: String, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, blockIds: blockIds, objectType: objectType), on: queue)
    }
    public static func invoke(contextID: String, blockIds: [String], objectType: String) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockIds: blockIds, objectType: objectType))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.BlockList.Move {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockListMove(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, blockIds: [String], targetContextID: String, dropTargetID: String, position: Anytype_Model_Block.Position, queue: DispatchQueue? = nil) -> Future<
      Response, Error
    > {
      self.invoke(parameters: .init(contextID: contextID, blockIds: blockIds, targetContextID: targetContextID, dropTargetID: dropTargetID, position: position), on: queue)
    }
    public static func invoke(contextID: String, blockIds: [String], targetContextID: String, dropTargetID: String, position: Anytype_Model_Block.Position) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockIds: blockIds, targetContextID: targetContextID, dropTargetID: dropTargetID, position: position))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.BlockList.MoveToNewPage {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockListMoveToNewPage(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(
      contextID: String, blockIds: [String], details: SwiftProtobuf.Google_Protobuf_Struct, dropTargetID: String, position: Anytype_Model_Block.Position, queue: DispatchQueue? = nil
    ) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, blockIds: blockIds, details: details, dropTargetID: dropTargetID, position: position), on: queue)
    }
    public static func invoke(contextID: String, blockIds: [String], details: SwiftProtobuf.Google_Protobuf_Struct, dropTargetID: String, position: Anytype_Model_Block.Position) -> Result<
      Response, Error
    > {
      self.result(.init(contextID: contextID, blockIds: blockIds, details: details, dropTargetID: dropTargetID, position: position))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.BlockList.Duplicate {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockListDuplicate(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, targetID: String, blockIds: [String], position: Anytype_Model_Block.Position, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, targetID: targetID, blockIds: blockIds, position: position), on: queue)
    }
    public static func invoke(contextID: String, targetID: String, blockIds: [String], position: Anytype_Model_Block.Position) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, targetID: targetID, blockIds: blockIds, position: position))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.BlockList.Set.Text.Style {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockListSetTextStyle(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, blockIds: [String], style: Anytype_Model_Block.Content.Text.Style, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, blockIds: blockIds, style: style), on: queue)
    }
    public static func invoke(contextID: String, blockIds: [String], style: Anytype_Model_Block.Content.Text.Style) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockIds: blockIds, style: style))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.BlockList.Set.Text.Color {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockListSetTextColor(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, blockIds: [String], color: String, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, blockIds: blockIds, color: color), on: queue)
    }
    public static func invoke(contextID: String, blockIds: [String], color: String) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockIds: blockIds, color: color))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.BlockList.Set.Text.Mark {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockListSetTextMark(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, blockIds: [String], mark: Anytype_Model_Block.Content.Text.Mark, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, blockIds: blockIds, mark: mark), on: queue)
    }
    public static func invoke(contextID: String, blockIds: [String], mark: Anytype_Model_Block.Content.Text.Mark) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockIds: blockIds, mark: mark))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.BlockList.Set.BackgroundColor {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockListSetBackgroundColor(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, blockIds: [String], color: String, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, blockIds: blockIds, color: color), on: queue)
    }
    public static func invoke(contextID: String, blockIds: [String], color: String) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockIds: blockIds, color: color))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.BlockList.Set.Align {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockListSetAlign(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, blockIds: [String], align: Anytype_Model_Block.Align, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, blockIds: blockIds, align: align), on: queue)
    }
    public static func invoke(contextID: String, blockIds: [String], align: Anytype_Model_Block.Align) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockIds: blockIds, align: align))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.BlockList.Set.Fields {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockListSetFields(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, blockFields: [Anytype_Rpc.BlockList.Set.Fields.Request.BlockField], queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, blockFields: blockFields), on: queue)
    }
    public static func invoke(contextID: String, blockFields: [Anytype_Rpc.BlockList.Set.Fields.Request.BlockField]) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockFields: blockFields))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.BlockList.Set.Div.Style {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockListSetDivStyle(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, blockIds: [String], style: Anytype_Model_Block.Content.Div.Style, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, blockIds: blockIds, style: style), on: queue)
    }
    public static func invoke(contextID: String, blockIds: [String], style: Anytype_Model_Block.Content.Div.Style) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockIds: blockIds, style: style))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.BlockList.Set.File.Style {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockListSetFileStyle(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, blockIds: [String], style: Anytype_Model_Block.Content.File.Style, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, blockIds: blockIds, style: style), on: queue)
    }
    public static func invoke(contextID: String, blockIds: [String], style: Anytype_Model_Block.Content.File.Style) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockIds: blockIds, style: style))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.BlockList.Set.Link.Appearance {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockListSetLinkAppearance(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(
      contextID: String, blockIds: [String], iconSize: Anytype_Model_Block.Content.Link.IconSize, cardStyle: Anytype_Model_Block.Content.Link.CardStyle,
      description_p: Anytype_Model_Block.Content.Link.Description, relations: [String], queue: DispatchQueue? = nil
    ) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, blockIds: blockIds, iconSize: iconSize, cardStyle: cardStyle, description_p: description_p, relations: relations), on: queue)
    }
    public static func invoke(
      contextID: String, blockIds: [String], iconSize: Anytype_Model_Block.Content.Link.IconSize, cardStyle: Anytype_Model_Block.Content.Link.CardStyle,
      description_p: Anytype_Model_Block.Content.Link.Description, relations: [String]
    ) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockIds: blockIds, iconSize: iconSize, cardStyle: cardStyle, description_p: description_p, relations: relations))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.BlockList.TurnInto {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockListTurnInto(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, blockIds: [String], style: Anytype_Model_Block.Content.Text.Style, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, blockIds: blockIds, style: style), on: queue)
    }
    public static func invoke(contextID: String, blockIds: [String], style: Anytype_Model_Block.Content.Text.Style) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockIds: blockIds, style: style))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, blockID: String, block: Anytype_Model_Block, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, blockID: blockID, block: block), on: queue)
    }
    public static func invoke(contextID: String, blockID: String, block: Anytype_Model_Block) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockID: blockID, block: block))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.Block.UpdateContent {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockUpdateContent(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, blockID: String, block: Anytype_Model_Block, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, blockID: blockID, block: block), on: queue)
    }
    public static func invoke(contextID: String, blockID: String, block: Anytype_Model_Block) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockID: blockID, block: block))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(
      contextID: String, blockID: String, range: Anytype_Model_Range, style: Anytype_Model_Block.Content.Text.Style, mode: Anytype_Rpc.Block.Split.Request.Mode, queue: DispatchQueue? = nil
    ) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, blockID: blockID, range: range, style: style, mode: mode), on: queue)
    }
    public static func invoke(contextID: String, blockID: String, range: Anytype_Model_Range, style: Anytype_Model_Block.Content.Text.Style, mode: Anytype_Rpc.Block.Split.Request.Mode) -> Result<
      Response, Error
    > {
      self.result(.init(contextID: contextID, blockID: blockID, range: range, style: style, mode: mode))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, firstBlockID: String, secondBlockID: String, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, firstBlockID: firstBlockID, secondBlockID: secondBlockID), on: queue)
    }
    public static func invoke(contextID: String, firstBlockID: String, secondBlockID: String) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, firstBlockID: firstBlockID, secondBlockID: secondBlockID))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, blocks: [Anytype_Model_Block], selectedTextRange: Anytype_Model_Range, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, blocks: blocks, selectedTextRange: selectedTextRange), on: queue)
    }
    public static func invoke(contextID: String, blocks: [Anytype_Model_Block], selectedTextRange: Anytype_Model_Range) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blocks: blocks, selectedTextRange: selectedTextRange))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(
      contextID: String, focusedBlockID: String, selectedTextRange: Anytype_Model_Range, selectedBlockIds: [String], isPartOfBlock: Bool, textSlot: String, htmlSlot: String,
      anySlot: [Anytype_Model_Block], fileSlot: [Anytype_Rpc.Block.Paste.Request.File], queue: DispatchQueue? = nil
    ) -> Future<Response, Error> {
      self.invoke(
        parameters: .init(
          contextID: contextID, focusedBlockID: focusedBlockID, selectedTextRange: selectedTextRange, selectedBlockIds: selectedBlockIds, isPartOfBlock: isPartOfBlock, textSlot: textSlot,
          htmlSlot: htmlSlot, anySlot: anySlot, fileSlot: fileSlot), on: queue)
    }
    public static func invoke(
      contextID: String, focusedBlockID: String, selectedTextRange: Anytype_Model_Range, selectedBlockIds: [String], isPartOfBlock: Bool, textSlot: String, htmlSlot: String,
      anySlot: [Anytype_Model_Block], fileSlot: [Anytype_Rpc.Block.Paste.Request.File]
    ) -> Result<Response, Error> {
      self.result(
        .init(
          contextID: contextID, focusedBlockID: focusedBlockID, selectedTextRange: selectedTextRange, selectedBlockIds: selectedBlockIds, isPartOfBlock: isPartOfBlock, textSlot: textSlot,
          htmlSlot: htmlSlot, anySlot: anySlot, fileSlot: fileSlot))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, blocks: [Anytype_Model_Block], selectedTextRange: Anytype_Model_Range, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, blocks: blocks, selectedTextRange: selectedTextRange), on: queue)
    }
    public static func invoke(contextID: String, blocks: [Anytype_Model_Block], selectedTextRange: Anytype_Model_Range) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blocks: blocks, selectedTextRange: selectedTextRange))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.Block.ImportMarkdown {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockImportMarkdown(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, importPath: String, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, importPath: importPath), on: queue)
    }
    public static func invoke(contextID: String, importPath: String) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, importPath: importPath))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, blocks: [Anytype_Model_Block], queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, blocks: blocks), on: queue)
    }
    public static func invoke(contextID: String, blocks: [Anytype_Model_Block]) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blocks: blocks))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, blockID: String, filePath: String, url: String, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, blockID: blockID, filePath: filePath, url: url), on: queue)
    }
    public static func invoke(contextID: String, blockID: String, filePath: String, url: String) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockID: blockID, filePath: filePath, url: url))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.Block.Download {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockDownload(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, blockID: String, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, blockID: blockID), on: queue)
    }
    public static func invoke(contextID: String, blockID: String) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockID: blockID))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.Block.Set.Fields {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockSetFields(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, blockID: String, fields: SwiftProtobuf.Google_Protobuf_Struct, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, blockID: blockID, fields: fields), on: queue)
    }
    public static func invoke(contextID: String, blockID: String, fields: SwiftProtobuf.Google_Protobuf_Struct) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockID: blockID, fields: fields))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.Block.Set.Details {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockSetDetails(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, details: [Anytype_Rpc.Block.Set.Details.Detail], queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, details: details), on: queue)
    }
    public static func invoke(contextID: String, details: [Anytype_Rpc.Block.Set.Details.Detail]) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, details: details))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.Block.Set.Restrictions {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockSetRestrictions(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, blockID: String, restrictions: Anytype_Model_Block.Restrictions, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, blockID: blockID, restrictions: restrictions), on: queue)
    }
    public static func invoke(contextID: String, blockID: String, restrictions: Anytype_Model_Block.Restrictions) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockID: blockID, restrictions: restrictions))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.Block.Set.Latex.Text {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockSetLatexText(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, blockID: String, text: String, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, blockID: blockID, text: text), on: queue)
    }
    public static func invoke(contextID: String, blockID: String, text: String) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockID: blockID, text: text))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.Block.Set.Text.Text {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockSetTextText(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, blockID: String, text: String, marks: Anytype_Model_Block.Content.Text.Marks, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, blockID: blockID, text: text, marks: marks), on: queue)
    }
    public static func invoke(contextID: String, blockID: String, text: String, marks: Anytype_Model_Block.Content.Text.Marks) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockID: blockID, text: text, marks: marks))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.Block.Set.Text.Color {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockSetTextColor(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, blockID: String, color: String, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, blockID: blockID, color: color), on: queue)
    }
    public static func invoke(contextID: String, blockID: String, color: String) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockID: blockID, color: color))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.Block.Set.Text.Style {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockSetTextStyle(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, blockID: String, style: Anytype_Model_Block.Content.Text.Style, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, blockID: blockID, style: style), on: queue)
    }
    public static func invoke(contextID: String, blockID: String, style: Anytype_Model_Block.Content.Text.Style) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockID: blockID, style: style))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.Block.Set.Text.Checked {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockSetTextChecked(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, blockID: String, checked: Bool, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, blockID: blockID, checked: checked), on: queue)
    }
    public static func invoke(contextID: String, blockID: String, checked: Bool) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockID: blockID, checked: checked))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.Block.Set.Text.Icon {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockSetTextIcon(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, blockID: String, iconImage: String, iconEmoji: String, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, blockID: blockID, iconImage: iconImage, iconEmoji: iconEmoji), on: queue)
    }
    public static func invoke(contextID: String, blockID: String, iconImage: String, iconEmoji: String) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockID: blockID, iconImage: iconImage, iconEmoji: iconEmoji))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.Block.Set.File.Name {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockSetFileName(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, blockID: String, name: String, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, blockID: blockID, name: name), on: queue)
    }
    public static func invoke(contextID: String, blockID: String, name: String) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockID: blockID, name: name))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.Block.Set.Image.Name {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockSetImageName(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, blockID: String, name: String, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, blockID: blockID, name: name), on: queue)
    }
    public static func invoke(contextID: String, blockID: String, name: String) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockID: blockID, name: name))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.Block.Set.Image.Width {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockSetImageWidth(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, blockID: String, width: Int32, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, blockID: blockID, width: width), on: queue)
    }
    public static func invoke(contextID: String, blockID: String, width: Int32) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockID: blockID, width: width))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.Block.Set.Video.Name {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockSetVideoName(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, blockID: String, name: String, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, blockID: blockID, name: name), on: queue)
    }
    public static func invoke(contextID: String, blockID: String, name: String) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockID: blockID, name: name))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.Block.Set.Video.Width {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockSetVideoWidth(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, blockID: String, width: Int32, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, blockID: blockID, width: width), on: queue)
    }
    public static func invoke(contextID: String, blockID: String, width: Int32) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockID: blockID, width: width))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.Block.Set.Link.TargetBlockId {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockSetLinkTargetBlockId(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, blockID: String, targetBlockID: String, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, blockID: blockID, targetBlockID: targetBlockID), on: queue)
    }
    public static func invoke(contextID: String, blockID: String, targetBlockID: String) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockID: blockID, targetBlockID: targetBlockID))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.Block.Relation.SetKey {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockRelationSetKey(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, blockID: String, key: String, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, blockID: blockID, key: key), on: queue)
    }
    public static func invoke(contextID: String, blockID: String, key: String) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockID: blockID, key: key))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.Block.Relation.Add {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockRelationAdd(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, blockID: String, relation: Anytype_Model_Relation, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, blockID: blockID, relation: relation), on: queue)
    }
    public static func invoke(contextID: String, blockID: String, relation: Anytype_Model_Relation) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockID: blockID, relation: relation))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.Block.ObjectType.Set {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockObjectTypeSet(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, objectTypeURL: String, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, objectTypeURL: objectTypeURL), on: queue)
    }
    public static func invoke(contextID: String, objectTypeURL: String) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, objectTypeURL: objectTypeURL))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.Block.Bookmark.Fetch {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockBookmarkFetch(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, blockID: String, url: String, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, blockID: blockID, url: url), on: queue)
    }
    public static func invoke(contextID: String, blockID: String, url: String) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockID: blockID, url: url))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.Block.Bookmark.CreateAndFetch {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockBookmarkCreateAndFetch(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, targetID: String, position: Anytype_Model_Block.Position, url: String, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, targetID: targetID, position: position, url: url), on: queue)
    }
    public static func invoke(contextID: String, targetID: String, position: Anytype_Model_Block.Position, url: String) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, targetID: targetID, position: position, url: url))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.Block.File.CreateAndUpload {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockFileCreateAndUpload(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(
      contextID: String, targetID: String, position: Anytype_Model_Block.Position, url: String, localPath: String, fileType: Anytype_Model_Block.Content.File.TypeEnum, queue: DispatchQueue? = nil
    ) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, targetID: targetID, position: position, url: url, localPath: localPath, fileType: fileType), on: queue)
    }
    public static func invoke(contextID: String, targetID: String, position: Anytype_Model_Block.Position, url: String, localPath: String, fileType: Anytype_Model_Block.Content.File.TypeEnum)
      -> Result<Response, Error>
    {
      self.result(.init(contextID: contextID, targetID: targetID, position: position, url: url, localPath: localPath, fileType: fileType))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.Block.Dataview.ViewCreate {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockDataviewViewCreate(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, blockID: String, view: Anytype_Model_Block.Content.Dataview.View, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, blockID: blockID, view: view), on: queue)
    }
    public static func invoke(contextID: String, blockID: String, view: Anytype_Model_Block.Content.Dataview.View) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockID: blockID, view: view))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.Block.Dataview.ViewUpdate {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockDataviewViewUpdate(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, blockID: String, viewID: String, view: Anytype_Model_Block.Content.Dataview.View, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, blockID: blockID, viewID: viewID, view: view), on: queue)
    }
    public static func invoke(contextID: String, blockID: String, viewID: String, view: Anytype_Model_Block.Content.Dataview.View) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockID: blockID, viewID: viewID, view: view))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.Block.Dataview.ViewDelete {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockDataviewViewDelete(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, blockID: String, viewID: String, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, blockID: blockID, viewID: viewID), on: queue)
    }
    public static func invoke(contextID: String, blockID: String, viewID: String) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockID: blockID, viewID: viewID))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.Block.Dataview.ViewSetActive {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockDataviewViewSetActive(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, blockID: String, viewID: String, offset: UInt32, limit: UInt32, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, blockID: blockID, viewID: viewID, offset: offset, limit: limit), on: queue)
    }
    public static func invoke(contextID: String, blockID: String, viewID: String, offset: UInt32, limit: UInt32) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockID: blockID, viewID: viewID, offset: offset, limit: limit))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.Block.Dataview.RecordUpdate {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockDataviewRecordUpdate(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, blockID: String, recordID: String, record: SwiftProtobuf.Google_Protobuf_Struct, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, blockID: blockID, recordID: recordID, record: record), on: queue)
    }
    public static func invoke(contextID: String, blockID: String, recordID: String, record: SwiftProtobuf.Google_Protobuf_Struct) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockID: blockID, recordID: recordID, record: record))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.Block.Dataview.RecordDelete {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockDataviewRecordDelete(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, blockID: String, recordID: String, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, blockID: blockID, recordID: recordID), on: queue)
    }
    public static func invoke(contextID: String, blockID: String, recordID: String) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockID: blockID, recordID: recordID))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.Block.Dataview.RecordCreate {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockDataviewRecordCreate(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, blockID: String, record: SwiftProtobuf.Google_Protobuf_Struct, templateID: String, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, blockID: blockID, record: record, templateID: templateID), on: queue)
    }
    public static func invoke(contextID: String, blockID: String, record: SwiftProtobuf.Google_Protobuf_Struct, templateID: String) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockID: blockID, record: record, templateID: templateID))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.Block.Dataview.RelationAdd {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockDataviewRelationAdd(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, blockID: String, relation: Anytype_Model_Relation, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, blockID: blockID, relation: relation), on: queue)
    }
    public static func invoke(contextID: String, blockID: String, relation: Anytype_Model_Relation) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockID: blockID, relation: relation))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.Block.Dataview.RelationUpdate {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockDataviewRelationUpdate(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, blockID: String, relationKey: String, relation: Anytype_Model_Relation, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, blockID: blockID, relationKey: relationKey, relation: relation), on: queue)
    }
    public static func invoke(contextID: String, blockID: String, relationKey: String, relation: Anytype_Model_Relation) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockID: blockID, relationKey: relationKey, relation: relation))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.Block.Dataview.RelationDelete {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockDataviewRelationDelete(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, blockID: String, relationKey: String, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, blockID: blockID, relationKey: relationKey), on: queue)
    }
    public static func invoke(contextID: String, blockID: String, relationKey: String) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockID: blockID, relationKey: relationKey))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.Block.Dataview.RecordRelationOptionAdd {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockDataviewRecordRelationOptionAdd(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, blockID: String, relationKey: String, option: Anytype_Model_Relation.Option, recordID: String, queue: DispatchQueue? = nil) -> Future<Response, Error>
    {
      self.invoke(parameters: .init(contextID: contextID, blockID: blockID, relationKey: relationKey, option: option, recordID: recordID), on: queue)
    }
    public static func invoke(contextID: String, blockID: String, relationKey: String, option: Anytype_Model_Relation.Option, recordID: String) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockID: blockID, relationKey: relationKey, option: option, recordID: recordID))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.Block.Dataview.RecordRelationOptionUpdate {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockDataviewRecordRelationOptionUpdate(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, blockID: String, relationKey: String, option: Anytype_Model_Relation.Option, recordID: String, queue: DispatchQueue? = nil) -> Future<Response, Error>
    {
      self.invoke(parameters: .init(contextID: contextID, blockID: blockID, relationKey: relationKey, option: option, recordID: recordID), on: queue)
    }
    public static func invoke(contextID: String, blockID: String, relationKey: String, option: Anytype_Model_Relation.Option, recordID: String) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockID: blockID, relationKey: relationKey, option: option, recordID: recordID))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.Block.Dataview.RecordRelationOptionDelete {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockDataviewRecordRelationOptionDelete(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, blockID: String, relationKey: String, optionID: String, recordID: String, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, blockID: blockID, relationKey: relationKey, optionID: optionID, recordID: recordID), on: queue)
    }
    public static func invoke(contextID: String, blockID: String, relationKey: String, optionID: String, recordID: String) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockID: blockID, relationKey: relationKey, optionID: optionID, recordID: recordID))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.Block.Dataview.RelationListAvailable {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockDataviewRelationListAvailable(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, blockID: String, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, blockID: blockID), on: queue)
    }
    public static func invoke(contextID: String, blockID: String) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockID: blockID))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.Block.Dataview.SetSource {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockDataviewSetSource(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, blockID: String, source: [String], queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, blockID: blockID, source: source), on: queue)
    }
    public static func invoke(contextID: String, blockID: String, source: [String]) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockID: blockID, source: source))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.Block.Get.Marks {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockGetMarks(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, blockID: String, range: Anytype_Model_Range, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, blockID: blockID, range: range), on: queue)
    }
    public static func invoke(contextID: String, blockID: String, range: Anytype_Model_Range) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockID: blockID, range: range))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.Block.Undo {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockUndo(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID), on: queue)
    }
    public static func invoke(contextID: String) -> Result<Response, Error> {
      self.result(.init(contextID: contextID))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.Block.Redo {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockRedo(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID), on: queue)
    }
    public static func invoke(contextID: String) -> Result<Response, Error> {
      self.result(.init(contextID: contextID))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.Block.Open {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockOpen(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, blockID: String, traceID: String, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, blockID: blockID, traceID: traceID), on: queue)
    }
    public static func invoke(contextID: String, blockID: String, traceID: String) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockID: blockID, traceID: traceID))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.Block.Show {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockShow(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, blockID: String, traceID: String, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, blockID: blockID, traceID: traceID), on: queue)
    }
    public static func invoke(contextID: String, blockID: String, traceID: String) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockID: blockID, traceID: traceID))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.Block.GetPublicWebURL {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockGetPublicWebURL(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(blockID: String, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(blockID: blockID), on: queue)
    }
    public static func invoke(blockID: String) -> Result<Response, Error> {
      self.result(.init(blockID: blockID))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.Block.OpenBreadcrumbs {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockOpenBreadcrumbs(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, traceID: String, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, traceID: traceID), on: queue)
    }
    public static func invoke(contextID: String, traceID: String) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, traceID: traceID))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.Block.SetBreadcrumbs {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockSetBreadcrumbs(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(breadcrumbsID: String, ids: [String], queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(breadcrumbsID: breadcrumbsID, ids: ids), on: queue)
    }
    public static func invoke(breadcrumbsID: String, ids: [String]) -> Result<Response, Error> {
      self.result(.init(breadcrumbsID: breadcrumbsID, ids: ids))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, targetID: String, block: Anytype_Model_Block, position: Anytype_Model_Block.Position, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, targetID: targetID, block: block, position: position), on: queue)
    }
    public static func invoke(contextID: String, targetID: String, block: Anytype_Model_Block, position: Anytype_Model_Block.Position) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, targetID: targetID, block: block, position: position))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.Block.CreatePage {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockCreatePage(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(
      contextID: String, details: SwiftProtobuf.Google_Protobuf_Struct, templateID: String, targetID: String, position: Anytype_Model_Block.Position, fields: SwiftProtobuf.Google_Protobuf_Struct,
      queue: DispatchQueue? = nil
    ) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, details: details, templateID: templateID, targetID: targetID, position: position, fields: fields), on: queue)
    }
    public static func invoke(
      contextID: String, details: SwiftProtobuf.Google_Protobuf_Struct, templateID: String, targetID: String, position: Anytype_Model_Block.Position, fields: SwiftProtobuf.Google_Protobuf_Struct
    ) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, details: details, templateID: templateID, targetID: targetID, position: position, fields: fields))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.Block.CreateSet {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockCreateSet(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, targetID: String, source: [String], details: SwiftProtobuf.Google_Protobuf_Struct, position: Anytype_Model_Block.Position, queue: DispatchQueue? = nil)
      -> Future<Response, Error>
    {
      self.invoke(parameters: .init(contextID: contextID, targetID: targetID, source: source, details: details, position: position), on: queue)
    }
    public static func invoke(contextID: String, targetID: String, source: [String], details: SwiftProtobuf.Google_Protobuf_Struct, position: Anytype_Model_Block.Position) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, targetID: targetID, source: source, details: details, position: position))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.Block.Unlink {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockUnlink(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, blockIds: [String], queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, blockIds: blockIds), on: queue)
    }
    public static func invoke(contextID: String, blockIds: [String]) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockIds: blockIds))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.Block.Close {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceBlockClose(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, blockID: String, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, blockID: blockID), on: queue)
    }
    public static func invoke(contextID: String, blockID: String) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, blockID: blockID))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(), on: queue)
    }
    public static func invoke() -> Result<Response, Error> {
      self.result(.init())
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(), on: queue)
    }
    public static func invoke() -> Result<Response, Error> {
      self.result(.init())
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(name: String, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(name: name), on: queue)
    }
    public static func invoke(name: String) -> Result<Response, Error> {
      self.result(.init(name: name))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(objectID: String, isHighlighted: Bool, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(objectID: objectID, isHighlighted: isHighlighted), on: queue)
    }
    public static func invoke(objectID: String, isHighlighted: Bool) -> Result<Response, Error> {
      self.result(.init(objectID: objectID, isHighlighted: isHighlighted))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(workspaceID: String, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(workspaceID: workspaceID), on: queue)
    }
    public static func invoke(workspaceID: String) -> Result<Response, Error> {
      self.result(.init(workspaceID: workspaceID))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(rootPath: String, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(rootPath: rootPath), on: queue)
    }
    public static func invoke(rootPath: String) -> Result<Response, Error> {
      self.result(.init(rootPath: rootPath))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(rootPath: String, mnemonic: String, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(rootPath: rootPath, mnemonic: mnemonic), on: queue)
    }
    public static func invoke(rootPath: String, mnemonic: String) -> Result<Response, Error> {
      self.result(.init(rootPath: rootPath, mnemonic: mnemonic))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(mnemonic: String, entropy: String, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(mnemonic: mnemonic, entropy: entropy), on: queue)
    }
    public static func invoke(mnemonic: String, entropy: String) -> Result<Response, Error> {
      self.result(.init(mnemonic: mnemonic, entropy: entropy))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(name: String, avatar: Anytype_Rpc.Account.Create.Request.OneOf_Avatar?, alphaInviteCode: String, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(name: name, avatar: avatar, alphaInviteCode: alphaInviteCode), on: queue)
    }
    public static func invoke(name: String, avatar: Anytype_Rpc.Account.Create.Request.OneOf_Avatar?, alphaInviteCode: String) -> Result<Response, Error> {
      self.result(.init(name: name, avatar: avatar, alphaInviteCode: alphaInviteCode))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(), on: queue)
    }
    public static func invoke() -> Result<Response, Error> {
      self.result(.init())
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(revert: Bool, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(revert: revert), on: queue)
    }
    public static func invoke(revert: Bool) -> Result<Response, Error> {
      self.result(.init(revert: revert))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(id: String, rootPath: String, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(id: id, rootPath: rootPath), on: queue)
    }
    public static func invoke(id: String, rootPath: String) -> Result<Response, Error> {
      self.result(.init(id: id, rootPath: rootPath))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(removeData: Bool, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(removeData: removeData), on: queue)
    }
    public static func invoke(removeData: Bool) -> Result<Response, Error> {
      self.result(.init(removeData: removeData))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(message: String, level: Anytype_Rpc.Log.Send.Request.Level, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(message: message, level: level), on: queue)
    }
    public static func invoke(message: String, level: Anytype_Rpc.Log.Send.Request.Level) -> Result<Response, Error> {
      self.result(.init(message: message, level: level))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.Version.Get {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceVersionGet(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(), on: queue)
    }
    public static func invoke() -> Result<Response, Error> {
      self.result(.init())
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(id: String, includeNotPinned: Bool, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(id: id, includeNotPinned: includeNotPinned), on: queue)
    }
    public static func invoke(id: String, includeNotPinned: Bool) -> Result<Response, Error> {
      self.result(.init(id: id, includeNotPinned: includeNotPinned))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.FileList.Offload {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceFileListOffload(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(onlyIds: [String], includeNotPinned: Bool, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(onlyIds: onlyIds, includeNotPinned: includeNotPinned), on: queue)
    }
    public static func invoke(onlyIds: [String], includeNotPinned: Bool) -> Result<Response, Error> {
      self.result(.init(onlyIds: onlyIds, includeNotPinned: includeNotPinned))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.Shutdown {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceShutdown(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(), on: queue)
    }
    public static func invoke() -> Result<Response, Error> {
      self.result(.init())
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.DeviceState {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceSetDeviceState(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(deviceState: Anytype_Rpc.DeviceState.Request.DeviceState, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(deviceState: deviceState), on: queue)
    }
    public static func invoke(deviceState: Anytype_Rpc.DeviceState.Request.DeviceState) -> Result<Response, Error> {
      self.result(.init(deviceState: deviceState))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.Config.Get {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceConfigGet(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(), on: queue)
    }
    public static func invoke() -> Result<Response, Error> {
      self.result(.init())
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.Ping {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServicePing(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(index: Int32, numberOfEventsToSend: Int32, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(index: index, numberOfEventsToSend: numberOfEventsToSend), on: queue)
    }
    public static func invoke(index: Int32, numberOfEventsToSend: Int32) -> Result<Response, Error> {
      self.result(.init(index: index, numberOfEventsToSend: numberOfEventsToSend))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(id: String, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(id: id), on: queue)
    }
    public static func invoke(id: String) -> Result<Response, Error> {
      self.result(.init(id: id))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(url: String, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(url: url), on: queue)
    }
    public static func invoke(url: String) -> Result<Response, Error> {
      self.result(.init(url: url))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.UploadFile {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceUploadFile(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(
      url: String, localPath: String, type: Anytype_Model_Block.Content.File.TypeEnum, disableEncryption: Bool, style: Anytype_Model_Block.Content.File.Style, queue: DispatchQueue? = nil
    ) -> Future<Response, Error> {
      self.invoke(parameters: .init(url: url, localPath: localPath, type: type, disableEncryption: disableEncryption, style: style), on: queue)
    }
    public static func invoke(url: String, localPath: String, type: Anytype_Model_Block.Content.File.TypeEnum, disableEncryption: Bool, style: Anytype_Model_Block.Content.File.Style) -> Result<
      Response, Error
    > {
      self.result(.init(url: url, localPath: localPath, type: type, disableEncryption: disableEncryption, style: style))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.DownloadFile {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceDownloadFile(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(hash: String, path: String, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(hash: hash, path: path), on: queue)
    }
    public static func invoke(hash: String, path: String) -> Result<Response, Error> {
      self.result(.init(hash: hash, path: path))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(context: Anytype_Rpc.Navigation.Context, fullText: String, limit: Int32, offset: Int32, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(context: context, fullText: fullText, limit: limit, offset: offset), on: queue)
    }
    public static func invoke(context: Anytype_Rpc.Navigation.Context, fullText: String, limit: Int32, offset: Int32) -> Result<Response, Error> {
      self.result(.init(context: context, fullText: fullText, limit: limit, offset: offset))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(objectID: String, context: Anytype_Rpc.Navigation.Context, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(objectID: objectID, context: context), on: queue)
    }
    public static func invoke(objectID: String, context: Anytype_Rpc.Navigation.Context) -> Result<Response, Error> {
      self.result(.init(objectID: objectID, context: context))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.History.Versions {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceHistoryVersions(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(pageID: String, lastVersionID: String, limit: Int32, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(pageID: pageID, lastVersionID: lastVersionID, limit: limit), on: queue)
    }
    public static func invoke(pageID: String, lastVersionID: String, limit: Int32) -> Result<Response, Error> {
      self.result(.init(pageID: pageID, lastVersionID: lastVersionID, limit: limit))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.History.Show {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceHistoryShow(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(pageID: String, versionID: String, traceID: String, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(pageID: pageID, versionID: versionID, traceID: traceID), on: queue)
    }
    public static func invoke(pageID: String, versionID: String, traceID: String) -> Result<Response, Error> {
      self.result(.init(pageID: pageID, versionID: versionID, traceID: traceID))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(pageID: String, versionID: String, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(pageID: pageID, versionID: versionID), on: queue)
    }
    public static func invoke(pageID: String, versionID: String) -> Result<Response, Error> {
      self.result(.init(pageID: pageID, versionID: versionID))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.Page.Create {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServicePageCreate(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(details: SwiftProtobuf.Google_Protobuf_Struct, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(details: details), on: queue)
    }
    public static func invoke(details: SwiftProtobuf.Google_Protobuf_Struct) -> Result<Response, Error> {
      self.result(.init(details: details))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.Set.Create {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceSetCreate(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(source: [String], details: SwiftProtobuf.Google_Protobuf_Struct, templateID: String, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(source: source, details: details, templateID: templateID), on: queue)
    }
    public static func invoke(source: [String], details: SwiftProtobuf.Google_Protobuf_Struct, templateID: String) -> Result<Response, Error> {
      self.result(.init(source: source, details: details, templateID: templateID))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(), on: queue)
    }
    public static func invoke() -> Result<Response, Error> {
      self.result(.init())
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(objectType: Anytype_Model_ObjectType, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(objectType: objectType), on: queue)
    }
    public static func invoke(objectType: Anytype_Model_ObjectType) -> Result<Response, Error> {
      self.result(.init(objectType: objectType))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(objectTypeURL: String, relations: [Anytype_Model_Relation], queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(objectTypeURL: objectTypeURL, relations: relations), on: queue)
    }
    public static func invoke(objectTypeURL: String, relations: [Anytype_Model_Relation]) -> Result<Response, Error> {
      self.result(.init(objectTypeURL: objectTypeURL, relations: relations))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(objectTypeURL: String, relationKey: String, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(objectTypeURL: objectTypeURL, relationKey: relationKey), on: queue)
    }
    public static func invoke(objectTypeURL: String, relationKey: String) -> Result<Response, Error> {
      self.result(.init(objectTypeURL: objectTypeURL, relationKey: relationKey))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(objectTypeURL: String, relation: Anytype_Model_Relation, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(objectTypeURL: objectTypeURL, relation: relation), on: queue)
    }
    public static func invoke(objectTypeURL: String, relation: Anytype_Model_Relation) -> Result<Response, Error> {
      self.result(.init(objectTypeURL: objectTypeURL, relation: relation))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(objectTypeURL: String, appendRelationsFromOtherTypes: Bool, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(objectTypeURL: objectTypeURL, appendRelationsFromOtherTypes: appendRelationsFromOtherTypes), on: queue)
    }
    public static func invoke(objectTypeURL: String, appendRelationsFromOtherTypes: Bool) -> Result<Response, Error> {
      self.result(.init(objectTypeURL: objectTypeURL, appendRelationsFromOtherTypes: appendRelationsFromOtherTypes))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(objectID: String, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(objectID: objectID), on: queue)
    }
    public static func invoke(objectID: String) -> Result<Response, Error> {
      self.result(.init(objectID: objectID))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(objectID: String, payload: String, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(objectID: objectID, payload: payload), on: queue)
    }
    public static func invoke(objectID: String, payload: String) -> Result<Response, Error> {
      self.result(.init(objectID: objectID, payload: payload))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.Object.RelationAdd {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceObjectRelationAdd(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, relation: Anytype_Model_Relation, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, relation: relation), on: queue)
    }
    public static func invoke(contextID: String, relation: Anytype_Model_Relation) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, relation: relation))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.Object.RelationUpdate {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceObjectRelationUpdate(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, relationKey: String, relation: Anytype_Model_Relation, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, relationKey: relationKey, relation: relation), on: queue)
    }
    public static func invoke(contextID: String, relationKey: String, relation: Anytype_Model_Relation) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, relationKey: relationKey, relation: relation))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.Object.RelationDelete {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceObjectRelationDelete(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, relationKey: String, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, relationKey: relationKey), on: queue)
    }
    public static func invoke(contextID: String, relationKey: String) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, relationKey: relationKey))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.Object.RelationOptionAdd {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceObjectRelationOptionAdd(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, relationKey: String, option: Anytype_Model_Relation.Option, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, relationKey: relationKey, option: option), on: queue)
    }
    public static func invoke(contextID: String, relationKey: String, option: Anytype_Model_Relation.Option) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, relationKey: relationKey, option: option))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.Object.RelationOptionUpdate {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceObjectRelationOptionUpdate(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, relationKey: String, option: Anytype_Model_Relation.Option, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, relationKey: relationKey, option: option), on: queue)
    }
    public static func invoke(contextID: String, relationKey: String, option: Anytype_Model_Relation.Option) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, relationKey: relationKey, option: option))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.Object.RelationOptionDelete {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceObjectRelationOptionDelete(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, relationKey: String, optionID: String, confirmRemoveAllValuesInRecords: Bool, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, relationKey: relationKey, optionID: optionID, confirmRemoveAllValuesInRecords: confirmRemoveAllValuesInRecords), on: queue)
    }
    public static func invoke(contextID: String, relationKey: String, optionID: String, confirmRemoveAllValuesInRecords: Bool) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, relationKey: relationKey, optionID: optionID, confirmRemoveAllValuesInRecords: confirmRemoveAllValuesInRecords))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.Object.RelationListAvailable {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceObjectRelationListAvailable(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID), on: queue)
    }
    public static func invoke(contextID: String) -> Result<Response, Error> {
      self.result(.init(contextID: contextID))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(
      filters: [Anytype_Model_Block.Content.Dataview.Filter], sorts: [Anytype_Model_Block.Content.Dataview.Sort], fullText: String, offset: Int32, limit: Int32, objectTypeFilter: [String],
      keys: [String], queue: DispatchQueue? = nil
    ) -> Future<Response, Error> {
      self.invoke(parameters: .init(filters: filters, sorts: sorts, fullText: fullText, offset: offset, limit: limit, objectTypeFilter: objectTypeFilter, keys: keys), on: queue)
    }
    public static func invoke(
      filters: [Anytype_Model_Block.Content.Dataview.Filter], sorts: [Anytype_Model_Block.Content.Dataview.Sort], fullText: String, offset: Int32, limit: Int32, objectTypeFilter: [String],
      keys: [String]
    ) -> Result<Response, Error> {
      self.result(.init(filters: filters, sorts: sorts, fullText: fullText, offset: offset, limit: limit, objectTypeFilter: objectTypeFilter, keys: keys))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(filters: [Anytype_Model_Block.Content.Dataview.Filter], limit: Int32, objectTypeFilter: [String], keys: [String], queue: DispatchQueue? = nil) -> Future<Response, Error>
    {
      self.invoke(parameters: .init(filters: filters, limit: limit, objectTypeFilter: objectTypeFilter, keys: keys), on: queue)
    }
    public static func invoke(filters: [Anytype_Model_Block.Content.Dataview.Filter], limit: Int32, objectTypeFilter: [String], keys: [String]) -> Result<Response, Error> {
      self.result(.init(filters: filters, limit: limit, objectTypeFilter: objectTypeFilter, keys: keys))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(
      subID: String, filters: [Anytype_Model_Block.Content.Dataview.Filter], sorts: [Anytype_Model_Block.Content.Dataview.Sort], limit: Int64, offset: Int64, keys: [String], afterID: String,
      beforeID: String, source: [String], ignoreWorkspace: String, noDepSubscription: Bool, queue: DispatchQueue? = nil
    ) -> Future<Response, Error> {
      self.invoke(
        parameters: .init(
          subID: subID, filters: filters, sorts: sorts, limit: limit, offset: offset, keys: keys, afterID: afterID, beforeID: beforeID, source: source, ignoreWorkspace: ignoreWorkspace,
          noDepSubscription: noDepSubscription), on: queue)
    }
    public static func invoke(
      subID: String, filters: [Anytype_Model_Block.Content.Dataview.Filter], sorts: [Anytype_Model_Block.Content.Dataview.Sort], limit: Int64, offset: Int64, keys: [String], afterID: String,
      beforeID: String, source: [String], ignoreWorkspace: String, noDepSubscription: Bool
    ) -> Result<Response, Error> {
      self.result(
        .init(
          subID: subID, filters: filters, sorts: sorts, limit: limit, offset: offset, keys: keys, afterID: afterID, beforeID: beforeID, source: source, ignoreWorkspace: ignoreWorkspace,
          noDepSubscription: noDepSubscription))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.Object.IdsSubscribe {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceObjectIdsSubscribe(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(subID: String, ids: [String], keys: [String], ignoreWorkspace: String, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(subID: subID, ids: ids, keys: keys, ignoreWorkspace: ignoreWorkspace), on: queue)
    }
    public static func invoke(subID: String, ids: [String], keys: [String], ignoreWorkspace: String) -> Result<Response, Error> {
      self.result(.init(subID: subID, ids: ids, keys: keys, ignoreWorkspace: ignoreWorkspace))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(subIds: [String], queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(subIds: subIds), on: queue)
    }
    public static func invoke(subIds: [String]) -> Result<Response, Error> {
      self.result(.init(subIds: subIds))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, layout: Anytype_Model_ObjectType.Layout, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, layout: layout), on: queue)
    }
    public static func invoke(contextID: String, layout: Anytype_Model_ObjectType.Layout) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, layout: layout))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, isFavorite: Bool, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, isFavorite: isFavorite), on: queue)
    }
    public static func invoke(contextID: String, isFavorite: Bool) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, isFavorite: isFavorite))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, isArchived: Bool, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, isArchived: isArchived), on: queue)
    }
    public static func invoke(contextID: String, isArchived: Bool) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, isArchived: isArchived))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.Object.FeaturedRelation.Add {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceObjectFeaturedRelationAdd(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, relations: [String], queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, relations: relations), on: queue)
    }
    public static func invoke(contextID: String, relations: [String]) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, relations: relations))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.Object.FeaturedRelation.Remove {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceObjectFeaturedRelationRemove(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, relations: [String], queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, relations: relations), on: queue)
    }
    public static func invoke(contextID: String, relations: [String]) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, relations: relations))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, source: [String], queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, source: source), on: queue)
    }
    public static func invoke(contextID: String, source: [String]) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, source: source))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.ObjectList.Duplicate {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceObjectListDuplicate(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(objectIds: [String], queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(objectIds: objectIds), on: queue)
    }
    public static func invoke(objectIds: [String]) -> Result<Response, Error> {
      self.result(.init(objectIds: objectIds))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.ObjectList.Delete {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceObjectListDelete(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(objectIds: [String], queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(objectIds: objectIds), on: queue)
    }
    public static func invoke(objectIds: [String]) -> Result<Response, Error> {
      self.result(.init(objectIds: objectIds))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.ObjectList.Set.IsArchived {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceObjectListSetIsArchived(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(objectIds: [String], isArchived: Bool, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(objectIds: objectIds, isArchived: isArchived), on: queue)
    }
    public static func invoke(objectIds: [String], isArchived: Bool) -> Result<Response, Error> {
      self.result(.init(objectIds: objectIds, isArchived: isArchived))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.ObjectList.Set.IsFavorite {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceObjectListSetIsFavorite(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(objectIds: [String], isFavorite: Bool, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(objectIds: objectIds, isFavorite: isFavorite), on: queue)
    }
    public static func invoke(objectIds: [String], isFavorite: Bool) -> Result<Response, Error> {
      self.result(.init(objectIds: objectIds, isFavorite: isFavorite))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.Export {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceExport(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(path: String, docIds: [String], format: Anytype_Rpc.Export.Format, zip: Bool, includeNested: Bool, includeFiles: Bool, queue: DispatchQueue? = nil) -> Future<
      Response, Error
    > {
      self.invoke(parameters: .init(path: path, docIds: docIds, format: format, zip: zip, includeNested: includeNested, includeFiles: includeFiles), on: queue)
    }
    public static func invoke(path: String, docIds: [String], format: Anytype_Rpc.Export.Format, zip: Bool, includeNested: Bool, includeFiles: Bool) -> Result<Response, Error> {
      self.result(.init(path: path, docIds: docIds, format: format, zip: zip, includeNested: includeNested, includeFiles: includeFiles))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.ExportWorkspace {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceExportWorkspace(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(path: String, workspaceID: String, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(path: path, workspaceID: workspaceID), on: queue)
    }
    public static func invoke(path: String, workspaceID: String) -> Result<Response, Error> {
      self.result(.init(path: path, workspaceID: workspaceID))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.ExportTemplates {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceExportTemplates(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(path: String, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(path: path), on: queue)
    }
    public static func invoke(path: String) -> Result<Response, Error> {
      self.result(.init(path: path))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.ExportLocalstore {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceExportLocalstore(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(path: String, docIds: [String], queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(path: path, docIds: docIds), on: queue)
    }
    public static func invoke(path: String, docIds: [String]) -> Result<Response, Error> {
      self.result(.init(path: path, docIds: docIds))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.MakeTemplate {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceMakeTemplate(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID), on: queue)
    }
    public static func invoke(contextID: String) -> Result<Response, Error> {
      self.result(.init(contextID: contextID))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.MakeTemplateByObjectType {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceMakeTemplateByObjectType(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(objectType: String, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(objectType: objectType), on: queue)
    }
    public static func invoke(objectType: String) -> Result<Response, Error> {
      self.result(.init(objectType: objectType))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.CloneTemplate {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceCloneTemplate(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID), on: queue)
    }
    public static func invoke(contextID: String) -> Result<Response, Error> {
      self.result(.init(contextID: contextID))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.ObjectDuplicate {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceObjectDuplicate(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID), on: queue)
    }
    public static func invoke(contextID: String) -> Result<Response, Error> {
      self.result(.init(contextID: contextID))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.UnsplashSearch {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceUnsplashSearch(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(query: String, limit: Int32, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(query: query, limit: limit), on: queue)
    }
    public static func invoke(query: String, limit: Int32) -> Result<Response, Error> {
      self.result(.init(query: query, limit: limit))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.UnsplashDownload {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceUnsplashDownload(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(pictureID: String, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(pictureID: pictureID), on: queue)
    }
    public static func invoke(pictureID: String) -> Result<Response, Error> {
      self.result(.init(pictureID: pictureID))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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

extension Anytype_Rpc.ApplyTemplate {
  private struct Invocation {
    static func invoke(_ data: Data?) -> Data? { Lib.ServiceApplyTemplate(data) }
  }

  public enum Service {
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(contextID: String, templateID: String, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(contextID: contextID, templateID: templateID), on: queue)
    }
    public static func invoke(contextID: String, templateID: String) -> Result<Response, Error> {
      self.result(.init(contextID: contextID, templateID: templateID))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(recordsTraverseLimit: Int32, skipEmptyLogs: Bool, tryToDownloadRemoteRecords: Bool, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(recordsTraverseLimit: recordsTraverseLimit, skipEmptyLogs: skipEmptyLogs, tryToDownloadRemoteRecords: tryToDownloadRemoteRecords), on: queue)
    }
    public static func invoke(recordsTraverseLimit: Int32, skipEmptyLogs: Bool, tryToDownloadRemoteRecords: Bool) -> Result<Response, Error> {
      self.result(.init(recordsTraverseLimit: recordsTraverseLimit, skipEmptyLogs: skipEmptyLogs, tryToDownloadRemoteRecords: tryToDownloadRemoteRecords))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(threadID: String, skipEmptyLogs: Bool, tryToDownloadRemoteRecords: Bool, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(threadID: threadID, skipEmptyLogs: skipEmptyLogs, tryToDownloadRemoteRecords: tryToDownloadRemoteRecords), on: queue)
    }
    public static func invoke(threadID: String, skipEmptyLogs: Bool, tryToDownloadRemoteRecords: Bool) -> Result<Response, Error> {
      self.result(.init(threadID: threadID, skipEmptyLogs: skipEmptyLogs, tryToDownloadRemoteRecords: tryToDownloadRemoteRecords))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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
    public typealias RequestParameters = Request
    private static func request(_ parameters: RequestParameters) -> Request {
      parameters
    }
    public static func invoke(blockID: String, path: String, unanonymized: Bool, generateSvg: Bool, queue: DispatchQueue? = nil) -> Future<Response, Error> {
      self.invoke(parameters: .init(blockID: blockID, path: path, unanonymized: unanonymized, generateSvg: generateSvg), on: queue)
    }
    public static func invoke(blockID: String, path: String, unanonymized: Bool, generateSvg: Bool) -> Result<Response, Error> {
      self.result(.init(blockID: blockID, path: path, unanonymized: unanonymized, generateSvg: generateSvg))
    }
    private static func invoke(parameters: RequestParameters, on queue: DispatchQueue?) -> Future<Response, Error> {
      .init { promise in
        if let queue = queue {
          queue.async {
            promise(self.result(self.request(parameters)))
          }
        } else {
          promise(self.result(self.request(parameters)))
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
