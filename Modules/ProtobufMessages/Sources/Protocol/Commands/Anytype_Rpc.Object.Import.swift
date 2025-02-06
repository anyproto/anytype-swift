public extension Anytype_Rpc.Object {
    public struct Import {
      // SwiftProtobuf.Message conformance is added in an extension below. See the
      // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
      // methods supported on all messages.

      public var unknownFields = SwiftProtobuf.UnknownStorage()

      public struct Request {
        // SwiftProtobuf.Message conformance is added in an extension below. See the
        // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
        // methods supported on all messages.

        public var spaceID: String = String()

        public var params: Anytype_Rpc.Object.Import.Request.OneOf_Params? = nil

        public var notionParams: Anytype_Rpc.Object.Import.Request.NotionParams {
          get {
            if case .notionParams(let v)? = params {
                    return v
                }
            return Anytype_Rpc.Object.Import.Request.NotionParams()
          }
          set {
                  params = .notionParams(newValue)
              }
        }

        ///for internal use
        public var bookmarksParams: Anytype_Rpc.Object.Import.Request.BookmarksParams {
          get {
            if case .bookmarksParams(let v)? = params {
                    return v
                }
            return Anytype_Rpc.Object.Import.Request.BookmarksParams()
          }
          set {
                  params = .bookmarksParams(newValue)
              }
        }

        public var markdownParams: Anytype_Rpc.Object.Import.Request.MarkdownParams {
          get {
            if case .markdownParams(let v)? = params {
                    return v
                }
            return Anytype_Rpc.Object.Import.Request.MarkdownParams()
          }
          set {
                  params = .markdownParams(newValue)
              }
        }

        public var htmlParams: Anytype_Rpc.Object.Import.Request.HtmlParams {
          get {
            if case .htmlParams(let v)? = params {
                    return v
                }
            return Anytype_Rpc.Object.Import.Request.HtmlParams()
          }
          set {
                  params = .htmlParams(newValue)
              }
        }

        public var txtParams: Anytype_Rpc.Object.Import.Request.TxtParams {
          get {
            if case .txtParams(let v)? = params {
                    return v
                }
            return Anytype_Rpc.Object.Import.Request.TxtParams()
          }
          set {
                  params = .txtParams(newValue)
              }
        }

        public var pbParams: Anytype_Rpc.Object.Import.Request.PbParams {
          get {
            if case .pbParams(let v)? = params {
                    return v
                }
            return Anytype_Rpc.Object.Import.Request.PbParams()
          }
          set {
                  params = .pbParams(newValue)
              }
        }

        public var csvParams: Anytype_Rpc.Object.Import.Request.CsvParams {
          get {
            if case .csvParams(let v)? = params {
                    return v
                }
            return Anytype_Rpc.Object.Import.Request.CsvParams()
          }
          set {
                  params = .csvParams(newValue)
              }
        }

        /// optional, for external developers usage
        public var snapshots: [Anytype_Rpc.Object.Import.Request.Snapshot] = []

        public var updateExistingObjects: Bool = false

        public var type: Anytype_Model_Import.TypeEnum = .notion

        public var mode: Anytype_Rpc.Object.Import.Request.Mode = .allOrNothing

        public var noProgress: Bool = false

        public var isMigration: Bool = false

        public var isNewSpace: Bool = false

        public var unknownFields = SwiftProtobuf.UnknownStorage()

        public enum OneOf_Params: Equatable {
          case notionParams(Anytype_Rpc.Object.Import.Request.NotionParams)
          ///for internal use
          case bookmarksParams(Anytype_Rpc.Object.Import.Request.BookmarksParams)
          case markdownParams(Anytype_Rpc.Object.Import.Request.MarkdownParams)
          case htmlParams(Anytype_Rpc.Object.Import.Request.HtmlParams)
          case txtParams(Anytype_Rpc.Object.Import.Request.TxtParams)
          case pbParams(Anytype_Rpc.Object.Import.Request.PbParams)
          case csvParams(Anytype_Rpc.Object.Import.Request.CsvParams)

        #if !swift(>=4.1)
          public static func ==(lhs: Anytype_Rpc.Object.Import.Request.OneOf_Params, rhs: Anytype_Rpc.Object.Import.Request.OneOf_Params) -> Bool {
            // The use of inline closures is to circumvent an issue where the compiler
            // allocates stack space for every case branch when no optimizations are
            // enabled. https://github.com/apple/swift-protobuf/issues/1034
            switch (lhs, rhs) {
            case (.notionParams, .notionParams):
                    return {
                                  guard case .notionParams(let l) = lhs, case .notionParams(let r) = rhs else {
                                      preconditionFailure()
                                  }
                                  return l == r
                                }()
            case (.bookmarksParams, .bookmarksParams):
                    return {
                                  guard case .bookmarksParams(let l) = lhs, case .bookmarksParams(let r) = rhs else {
                                      preconditionFailure()
                                  }
                                  return l == r
                                }()
            case (.markdownParams, .markdownParams):
                    return {
                                  guard case .markdownParams(let l) = lhs, case .markdownParams(let r) = rhs else {
                                      preconditionFailure()
                                  }
                                  return l == r
                                }()
            case (.htmlParams, .htmlParams):
                    return {
                                  guard case .htmlParams(let l) = lhs, case .htmlParams(let r) = rhs else {
                                      preconditionFailure()
                                  }
                                  return l == r
                                }()
            case (.txtParams, .txtParams):
                    return {
                                  guard case .txtParams(let l) = lhs, case .txtParams(let r) = rhs else {
                                      preconditionFailure()
                                  }
                                  return l == r
                                }()
            case (.pbParams, .pbParams):
                    return {
                                  guard case .pbParams(let l) = lhs, case .pbParams(let r) = rhs else {
                                      preconditionFailure()
                                  }
                                  return l == r
                                }()
            case (.csvParams, .csvParams):
                    return {
                                  guard case .csvParams(let l) = lhs, case .csvParams(let r) = rhs else {
                                      preconditionFailure()
                                  }
                                  return l == r
                                }()
            default:
                    return false
            }
          }
        #endif
        }

        public enum Mode: SwiftProtobuf.Enum {
          public typealias RawValue = Int
          case allOrNothing // = 0
          case ignoreErrors // = 1
          case UNRECOGNIZED(Int)

          public init() {
            self = .allOrNothing
          }

          public init?(rawValue: Int) {
            switch rawValue {
            case 0:
                    self = .allOrNothing
            case 1:
                    self = .ignoreErrors
            default:
                    self = .UNRECOGNIZED(rawValue)
            }
          }

          public var rawValue: Int {
            switch self {
            case .allOrNothing:
                    return 0
            case .ignoreErrors:
                    return 1
            case .UNRECOGNIZED(let i):
                    return i
            }
          }

        }

        public struct NotionParams {
          // SwiftProtobuf.Message conformance is added in an extension below. See the
          // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
          // methods supported on all messages.

          public var apiKey: String = String()

          public var unknownFields = SwiftProtobuf.UnknownStorage()

          public init() {
              }
        }

        public struct MarkdownParams {
          // SwiftProtobuf.Message conformance is added in an extension below. See the
          // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
          // methods supported on all messages.

          public var path: [String] = []

          public var unknownFields = SwiftProtobuf.UnknownStorage()

          public init() {
              }
        }

        public struct BookmarksParams {
          // SwiftProtobuf.Message conformance is added in an extension below. See the
          // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
          // methods supported on all messages.

          public var url: String = String()

          public var unknownFields = SwiftProtobuf.UnknownStorage()

          public init() {
              }
        }

        public struct HtmlParams {
          // SwiftProtobuf.Message conformance is added in an extension below. See the
          // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
          // methods supported on all messages.

          public var path: [String] = []

          public var unknownFields = SwiftProtobuf.UnknownStorage()

          public init() {
              }
        }

        public struct TxtParams {
          // SwiftProtobuf.Message conformance is added in an extension below. See the
          // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
          // methods supported on all messages.

          public var path: [String] = []

          public var unknownFields = SwiftProtobuf.UnknownStorage()

          public init() {
              }
        }

        public struct PbParams {
          // SwiftProtobuf.Message conformance is added in an extension below. See the
          // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
          // methods supported on all messages.

          public var path: [String] = []

          public var noCollection: Bool = false

          public var collectionTitle: String = String()

          public var importType: Anytype_Rpc.Object.Import.Request.PbParams.TypeEnum = .space

          public var unknownFields = SwiftProtobuf.UnknownStorage()

          public enum TypeEnum: SwiftProtobuf.Enum {
            public typealias RawValue = Int
            case space // = 0
            case experience // = 1
            case UNRECOGNIZED(Int)

            public init() {
              self = .space
            }

            public init?(rawValue: Int) {
              switch rawValue {
              case 0:
                      self = .space
              case 1:
                      self = .experience
              default:
                      self = .UNRECOGNIZED(rawValue)
              }
            }

            public var rawValue: Int {
              switch self {
              case .space:
                      return 0
              case .experience:
                      return 1
              case .UNRECOGNIZED(let i):
                      return i
              }
            }

          }

          public init() {
              }
        }

        public struct CsvParams {
          // SwiftProtobuf.Message conformance is added in an extension below. See the
          // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
          // methods supported on all messages.

          public var path: [String] = []

          public var mode: Anytype_Rpc.Object.Import.Request.CsvParams.Mode = .collection

          public var useFirstRowForRelations: Bool = false

          public var delimiter: String = String()

          public var transposeRowsAndColumns: Bool = false

          public var unknownFields = SwiftProtobuf.UnknownStorage()

          public enum Mode: SwiftProtobuf.Enum {
            public typealias RawValue = Int
            case collection // = 0
            case table // = 1
            case UNRECOGNIZED(Int)

            public init() {
              self = .collection
            }

            public init?(rawValue: Int) {
              switch rawValue {
              case 0:
                      self = .collection
              case 1:
                      self = .table
              default:
                      self = .UNRECOGNIZED(rawValue)
              }
            }

            public var rawValue: Int {
              switch self {
              case .collection:
                      return 0
              case .table:
                      return 1
              case .UNRECOGNIZED(let i):
                      return i
              }
            }

          }

          public init() {
              }
        }

        public struct Snapshot {
          // SwiftProtobuf.Message conformance is added in an extension below. See the
          // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
          // methods supported on all messages.

          public var id: String = String()

          public var snapshot: Anytype_Model_SmartBlockSnapshotBase {
            get {
                    return _snapshot ?? Anytype_Model_SmartBlockSnapshotBase()
                }
            set {
                    _snapshot = newValue
                }
          }
          /// Returns true if `snapshot` has been explicitly set.
          public var hasSnapshot: Bool {
                  return self._snapshot != nil
              }
          /// Clears the value of `snapshot`. Subsequent reads from it will return its default value.
          public mutating func clearSnapshot() {
                  self._snapshot = nil
              }

          public var unknownFields = SwiftProtobuf.UnknownStorage()

          public init() {
              }

          fileprivate var _snapshot: Anytype_Model_SmartBlockSnapshotBase? = nil
        }

        public init() {
            }
      }

      public struct Response {
        // SwiftProtobuf.Message conformance is added in an extension below. See the
        // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
        // methods supported on all messages.

        /// deprecated
        public var error: Anytype_Rpc.Object.Import.Response.Error {
          get {
                  return _error ?? Anytype_Rpc.Object.Import.Response.Error()
              }
          set {
                  _error = newValue
              }
        }
        /// Returns true if `error` has been explicitly set.
        public var hasError: Bool {
                return self._error != nil
            }
        /// Clears the value of `error`. Subsequent reads from it will return its default value.
        public mutating func clearError() {
                self._error = nil
            }

        /// deprecated
        public var collectionID: String = String()

        /// deprecated
        public var objectsCount: Int64 = 0

        public var unknownFields = SwiftProtobuf.UnknownStorage()

        public struct Error {
          // SwiftProtobuf.Message conformance is added in an extension below. See the
          // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
          // methods supported on all messages.

          public var code: Anytype_Rpc.Object.Import.Response.Error.Code = .null

          public var description_p: String = String()

          public var unknownFields = SwiftProtobuf.UnknownStorage()

          public enum Code: SwiftProtobuf.Enum {
            public typealias RawValue = Int
            case null // = 0
            case unknownError // = 1
            case badInput // = 2
            case internalError // = 3
            case noObjectsToImport // = 5
            case importIsCanceled // = 6
            case limitOfRowsOrRelationsExceeded // = 7
            case fileLoadError // = 8
            case insufficientPermissions // = 9
            case UNRECOGNIZED(Int)

            public init() {
              self = .null
            }

            public init?(rawValue: Int) {
              switch rawValue {
              case 0:
                      self = .null
              case 1:
                      self = .unknownError
              case 2:
                      self = .badInput
              case 3:
                      self = .internalError
              case 5:
                      self = .noObjectsToImport
              case 6:
                      self = .importIsCanceled
              case 7:
                      self = .limitOfRowsOrRelationsExceeded
              case 8:
                      self = .fileLoadError
              case 9:
                      self = .insufficientPermissions
              default:
                      self = .UNRECOGNIZED(rawValue)
              }
            }

            public var rawValue: Int {
              switch self {
              case .null:
                      return 0
              case .unknownError:
                      return 1
              case .badInput:
                      return 2
              case .internalError:
                      return 3
              case .noObjectsToImport:
                      return 5
              case .importIsCanceled:
                      return 6
              case .limitOfRowsOrRelationsExceeded:
                      return 7
              case .fileLoadError:
                      return 8
              case .insufficientPermissions:
                      return 9
              case .UNRECOGNIZED(let i):
                      return i
              }
            }

          }

          public init() {
              }
        }

        public init() {
            }

        fileprivate var _error: Anytype_Rpc.Object.Import.Response.Error? = nil
      }

      public struct Notion {
        // SwiftProtobuf.Message conformance is added in an extension below. See the
        // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
        // methods supported on all messages.

        public var unknownFields = SwiftProtobuf.UnknownStorage()

        public struct ValidateToken {
          // SwiftProtobuf.Message conformance is added in an extension below. See the
          // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
          // methods supported on all messages.

          public var unknownFields = SwiftProtobuf.UnknownStorage()

          public struct Request {
            // SwiftProtobuf.Message conformance is added in an extension below. See the
            // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
            // methods supported on all messages.

            public var token: String = String()

            public var unknownFields = SwiftProtobuf.UnknownStorage()

            public init() {
                }
          }

          public struct Response {
            // SwiftProtobuf.Message conformance is added in an extension below. See the
            // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
            // methods supported on all messages.

            public var error: Anytype_Rpc.Object.Import.Notion.ValidateToken.Response.Error {
              get {
                      return _error ?? Anytype_Rpc.Object.Import.Notion.ValidateToken.Response.Error()
                  }
              set {
                      _error = newValue
                  }
            }
            /// Returns true if `error` has been explicitly set.
            public var hasError: Bool {
                    return self._error != nil
                }
            /// Clears the value of `error`. Subsequent reads from it will return its default value.
            public mutating func clearError() {
                    self._error = nil
                }

            public var unknownFields = SwiftProtobuf.UnknownStorage()

            public struct Error {
              // SwiftProtobuf.Message conformance is added in an extension below. See the
              // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
              // methods supported on all messages.

              public var code: Anytype_Rpc.Object.Import.Notion.ValidateToken.Response.Error.Code = .null

              public var description_p: String = String()

              public var unknownFields = SwiftProtobuf.UnknownStorage()

              public enum Code: SwiftProtobuf.Enum {
                public typealias RawValue = Int
                case null // = 0
                case unknownError // = 1
                case badInput // = 2
                case internalError // = 3
                case unauthorized // = 4
                case forbidden // = 5
                case serviceUnavailable // = 6
                case accountIsNotRunning // = 7
                case UNRECOGNIZED(Int)

                public init() {
                  self = .null
                }

                public init?(rawValue: Int) {
                  switch rawValue {
                  case 0:
                          self = .null
                  case 1:
                          self = .unknownError
                  case 2:
                          self = .badInput
                  case 3:
                          self = .internalError
                  case 4:
                          self = .unauthorized
                  case 5:
                          self = .forbidden
                  case 6:
                          self = .serviceUnavailable
                  case 7:
                          self = .accountIsNotRunning
                  default:
                          self = .UNRECOGNIZED(rawValue)
                  }
                }

                public var rawValue: Int {
                  switch self {
                  case .null:
                          return 0
                  case .unknownError:
                          return 1
                  case .badInput:
                          return 2
                  case .internalError:
                          return 3
                  case .unauthorized:
                          return 4
                  case .forbidden:
                          return 5
                  case .serviceUnavailable:
                          return 6
                  case .accountIsNotRunning:
                          return 7
                  case .UNRECOGNIZED(let i):
                          return i
                  }
                }

              }

              public init() {
                  }
            }

            public init() {
                }

            fileprivate var _error: Anytype_Rpc.Object.Import.Notion.ValidateToken.Response.Error? = nil
          }

          public init() {
              }
        }

        public init() {
            }
      }

      public init() {
          }
    }
}