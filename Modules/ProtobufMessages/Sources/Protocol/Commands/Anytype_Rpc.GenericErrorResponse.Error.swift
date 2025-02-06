public extension Anytype_Rpc.GenericErrorResponse {
    public struct Error {
      // SwiftProtobuf.Message conformance is added in an extension below. See the
      // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
      // methods supported on all messages.

      public var code: Anytype_Rpc.GenericErrorResponse.Error.Code = .null

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
}