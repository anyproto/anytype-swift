public extension Anytype_Rpc {
    public struct Publishing {
    // SwiftProtobuf.Message conformance is added in an extension below. See the
    // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
    // methods supported on all messages.

    public var unknownFields = SwiftProtobuf.UnknownStorage()

    public enum PublishStatus: SwiftProtobuf.Enum {
      public typealias RawValue = Int

      /// PublishStatusCreated means publish is created but not uploaded yet
      case created // = 0

      /// PublishStatusCreated means publish is active
      case published // = 1
      case UNRECOGNIZED(Int)

      public init() {
        self = .created
      }

      public init?(rawValue: Int) {
        switch rawValue {
        case 0:
                self = .created
        case 1:
                self = .published
        default:
                self = .UNRECOGNIZED(rawValue)
        }
      }

      public var rawValue: Int {
        switch self {
        case .created:
                return 0
        case .published:
                return 1
        case .UNRECOGNIZED(let i):
                return i
        }
      }

    }

    public init() {
        }
  }
}