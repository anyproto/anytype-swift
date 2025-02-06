public extension Anytype_Rpc.Object {
    public struct ListExport {
      // SwiftProtobuf.Message conformance is added in an extension below. See the
      // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
      // methods supported on all messages.

      public var unknownFields = SwiftProtobuf.UnknownStorage()

      public struct Request {
        // SwiftProtobuf.Message conformance is added in an extension below. See the
        // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
        // methods supported on all messages.

        public var spaceID: String = String()

        /// the path where export files will place
        public var path: String = String()

        /// ids of documents for export, when empty - will export all available docs
        public var objectIds: [String] = []

        /// export format
        public var format: Anytype_Model_Export.Format = .markdown

        /// save as zip file
        public var zip: Bool = false

        /// include all nested
        public var includeNested: Bool = false

        /// include all files
        public var includeFiles: Bool = false

        /// for protobuf export
        public var isJson: Bool = false

        /// for migration
        public var includeArchived: Bool = false

        /// for integrations like raycast and web publishing
        public var noProgress: Bool = false

        public var linksStateFilters: Anytype_Rpc.Object.ListExport.StateFilters {
          get {
                  return _linksStateFilters ?? Anytype_Rpc.Object.ListExport.StateFilters()
              }
          set {
                  _linksStateFilters = newValue
              }
        }
        /// Returns true if `linksStateFilters` has been explicitly set.
        public var hasLinksStateFilters: Bool {
                return self._linksStateFilters != nil
            }
        /// Clears the value of `linksStateFilters`. Subsequent reads from it will return its default value.
        public mutating func clearLinksStateFilters() {
                self._linksStateFilters = nil
            }

        public var includeBacklinks: Bool = false

        public var unknownFields = SwiftProtobuf.UnknownStorage()

        public init() {
            }

        fileprivate var _linksStateFilters: Anytype_Rpc.Object.ListExport.StateFilters? = nil
      }

      public struct StateFilters {
        // SwiftProtobuf.Message conformance is added in an extension below. See the
        // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
        // methods supported on all messages.

        public var relationsWhiteList: [Anytype_Rpc.Object.ListExport.RelationsWhiteList] = []

        public var removeBlocks: Bool = false

        public var unknownFields = SwiftProtobuf.UnknownStorage()

        public init() {
            }
      }

      public struct RelationsWhiteList {
        // SwiftProtobuf.Message conformance is added in an extension below. See the
        // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
        // methods supported on all messages.

        public var layout: Anytype_Model_ObjectType.Layout = .basic

        public var allowedRelations: [String] = []

        public var unknownFields = SwiftProtobuf.UnknownStorage()

        public init() {
            }
      }

      public struct Response {
        // SwiftProtobuf.Message conformance is added in an extension below. See the
        // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
        // methods supported on all messages.

        public var error: Anytype_Rpc.Object.ListExport.Response.Error {
          get {
                  return _error ?? Anytype_Rpc.Object.ListExport.Response.Error()
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

        public var path: String = String()

        public var succeed: Int32 = 0

        public var event: Anytype_ResponseEvent {
          get {
                  return _event ?? Anytype_ResponseEvent()
              }
          set {
                  _event = newValue
              }
        }
        /// Returns true if `event` has been explicitly set.
        public var hasEvent: Bool {
                return self._event != nil
            }
        /// Clears the value of `event`. Subsequent reads from it will return its default value.
        public mutating func clearEvent() {
                self._event = nil
            }

        public var unknownFields = SwiftProtobuf.UnknownStorage()

        public struct Error {
          // SwiftProtobuf.Message conformance is added in an extension below. See the
          // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
          // methods supported on all messages.

          public var code: Anytype_Rpc.Object.ListExport.Response.Error.Code = .null

          public var description_p: String = String()

          public var unknownFields = SwiftProtobuf.UnknownStorage()

          public enum Code: SwiftProtobuf.Enum {
            public typealias RawValue = Int
            case null // = 0
            case unknownError // = 1

            /// ...
            case badInput // = 2
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

        fileprivate var _error: Anytype_Rpc.Object.ListExport.Response.Error? = nil
        fileprivate var _event: Anytype_ResponseEvent? = nil
      }

      public init() {
          }
    }
}