public extension Anytype_Rpc.Object {
    public struct ImportList {
      // SwiftProtobuf.Message conformance is added in an extension below. See the
      // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
      // methods supported on all messages.

      public var unknownFields = SwiftProtobuf.UnknownStorage()

      public struct Request {
        // SwiftProtobuf.Message conformance is added in an extension below. See the
        // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
        // methods supported on all messages.

        public var unknownFields = SwiftProtobuf.UnknownStorage()

        public init() {
            }
      }

      public struct Response {
        // SwiftProtobuf.Message conformance is added in an extension below. See the
        // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
        // methods supported on all messages.

        public var error: Anytype_Rpc.Object.ImportList.Response.Error {
          get {
                  return _error ?? Anytype_Rpc.Object.ImportList.Response.Error()
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

        public var response: [Anytype_Rpc.Object.ImportList.ImportResponse] = []

        public var unknownFields = SwiftProtobuf.UnknownStorage()

        public struct Error {
          // SwiftProtobuf.Message conformance is added in an extension below. See the
          // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
          // methods supported on all messages.

          public var code: Anytype_Rpc.Object.ImportList.Response.Error.Code = .null

          public var description_p: String = String()

          public var unknownFields = SwiftProtobuf.UnknownStorage()

          public enum Code: SwiftProtobuf.Enum {
            public typealias RawValue = Int
            case null // = 0
            case unknownError // = 1
            case badInput // = 2
            case internalError // = 3
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

        fileprivate var _error: Anytype_Rpc.Object.ImportList.Response.Error? = nil
      }

      public struct ImportResponse {
        // SwiftProtobuf.Message conformance is added in an extension below. See the
        // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
        // methods supported on all messages.

        public var type: Anytype_Rpc.Object.ImportList.ImportResponse.TypeEnum = .notion

        public var unknownFields = SwiftProtobuf.UnknownStorage()

        public enum TypeEnum: SwiftProtobuf.Enum {
          public typealias RawValue = Int
          case notion // = 0
          case markdown // = 1
          case html // = 2
          case txt // = 3
          case UNRECOGNIZED(Int)

          public init() {
            self = .notion
          }

          public init?(rawValue: Int) {
            switch rawValue {
            case 0:
                    self = .notion
            case 1:
                    self = .markdown
            case 2:
                    self = .html
            case 3:
                    self = .txt
            default:
                    self = .UNRECOGNIZED(rawValue)
            }
          }

          public var rawValue: Int {
            switch self {
            case .notion:
                    return 0
            case .markdown:
                    return 1
            case .html:
                    return 2
            case .txt:
                    return 3
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
    }
}