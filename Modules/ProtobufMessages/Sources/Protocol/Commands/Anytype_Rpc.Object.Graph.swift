public extension Anytype_Rpc.Object {
    public struct Graph {
      // SwiftProtobuf.Message conformance is added in an extension below. See the
      // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
      // methods supported on all messages.

      public var unknownFields = SwiftProtobuf.UnknownStorage()

      public struct Request {
        // SwiftProtobuf.Message conformance is added in an extension below. See the
        // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
        // methods supported on all messages.

        public var filters: [Anytype_Model_Block.Content.Dataview.Filter] = []

        public var limit: Int32 = 0

        /// additional filter by objectTypes
        public var objectTypeFilter: [String] = []

        public var keys: [String] = []

        public var spaceID: String = String()

        public var collectionID: String = String()

        public var setSource: [String] = []

        public var unknownFields = SwiftProtobuf.UnknownStorage()

        public init() {
            }
      }

      public struct Edge {
        // SwiftProtobuf.Message conformance is added in an extension below. See the
        // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
        // methods supported on all messages.

        public var source: String = String()

        public var target: String = String()

        public var name: String = String()

        public var type: Anytype_Rpc.Object.Graph.Edge.TypeEnum = .link

        public var description_p: String = String()

        public var iconImage: String = String()

        public var iconEmoji: String = String()

        public var hidden: Bool = false

        public var unknownFields = SwiftProtobuf.UnknownStorage()

        public enum TypeEnum: SwiftProtobuf.Enum {
          public typealias RawValue = Int
          case link // = 0
          case relation // = 1
          case UNRECOGNIZED(Int)

          public init() {
            self = .link
          }

          public init?(rawValue: Int) {
            switch rawValue {
            case 0:
                    self = .link
            case 1:
                    self = .relation
            default:
                    self = .UNRECOGNIZED(rawValue)
            }
          }

          public var rawValue: Int {
            switch self {
            case .link:
                    return 0
            case .relation:
                    return 1
            case .UNRECOGNIZED(let i):
                    return i
            }
          }

        }

        public init() {
            }
      }

      public struct Response {
        // SwiftProtobuf.Message conformance is added in an extension below. See the
        // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
        // methods supported on all messages.

        public var error: Anytype_Rpc.Object.Graph.Response.Error {
          get {
                  return _error ?? Anytype_Rpc.Object.Graph.Response.Error()
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

        public var nodes: [SwiftProtobuf.Google_Protobuf_Struct] = []

        public var edges: [Anytype_Rpc.Object.Graph.Edge] = []

        public var unknownFields = SwiftProtobuf.UnknownStorage()

        public struct Error {
          // SwiftProtobuf.Message conformance is added in an extension below. See the
          // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
          // methods supported on all messages.

          public var code: Anytype_Rpc.Object.Graph.Response.Error.Code = .null

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

        fileprivate var _error: Anytype_Rpc.Object.Graph.Response.Error? = nil
      }

      public init() {
          }
    }
}