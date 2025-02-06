public extension Anytype_Rpc.Log {
    public struct Send {
      // SwiftProtobuf.Message conformance is added in an extension below. See the
      // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
      // methods supported on all messages.

      public var unknownFields = SwiftProtobuf.UnknownStorage()

      public struct Request {
        // SwiftProtobuf.Message conformance is added in an extension below. See the
        // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
        // methods supported on all messages.

        public var message: String = String()

        public var level: Anytype_Rpc.Log.Send.Request.Level = .debug

        public var unknownFields = SwiftProtobuf.UnknownStorage()

        public enum Level: SwiftProtobuf.Enum {
          public typealias RawValue = Int
          case debug // = 0
          case error // = 1
          case fatal // = 2
          case info // = 3
          case panic // = 4
          case warning // = 5
          case UNRECOGNIZED(Int)

          public init() {
            self = .debug
          }

          public init?(rawValue: Int) {
            switch rawValue {
            case 0:
                    self = .debug
            case 1:
                    self = .error
            case 2:
                    self = .fatal
            case 3:
                    self = .info
            case 4:
                    self = .panic
            case 5:
                    self = .warning
            default:
                    self = .UNRECOGNIZED(rawValue)
            }
          }

          public var rawValue: Int {
            switch self {
            case .debug:
                    return 0
            case .error:
                    return 1
            case .fatal:
                    return 2
            case .info:
                    return 3
            case .panic:
                    return 4
            case .warning:
                    return 5
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

        public var error: Anytype_Rpc.Log.Send.Response.Error {
          get {
                  return _error ?? Anytype_Rpc.Log.Send.Response.Error()
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

          public var code: Anytype_Rpc.Log.Send.Response.Error.Code = .null

          public var description_p: String = String()

          public var unknownFields = SwiftProtobuf.UnknownStorage()

          public enum Code: SwiftProtobuf.Enum {
            public typealias RawValue = Int
            case null // = 0
            case unknownError // = 1
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

        fileprivate var _error: Anytype_Rpc.Log.Send.Response.Error? = nil
      }

      public init() {
          }
    }
}