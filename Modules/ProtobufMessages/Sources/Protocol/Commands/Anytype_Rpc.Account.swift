public extension Anytype_Rpc {
    public struct Account {
    // SwiftProtobuf.Message conformance is added in an extension below. See the
    // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
    // methods supported on all messages.

    public var unknownFields = SwiftProtobuf.UnknownStorage()

    public enum NetworkMode: SwiftProtobuf.Enum {
      public typealias RawValue = Int

      /// use network config that embedded in binary
      case defaultConfig // = 0

      /// disable any-sync network and use only local p2p nodes
      case localOnly // = 1

      /// use config provided in networkConfigFilePath
      case customConfig // = 2
      case UNRECOGNIZED(Int)

      public init() {
        self = .defaultConfig
      }

      public init?(rawValue: Int) {
        switch rawValue {
        case 0:
                self = .defaultConfig
        case 1:
                self = .localOnly
        case 2:
                self = .customConfig
        default:
                self = .UNRECOGNIZED(rawValue)
        }
      }

      public var rawValue: Int {
        switch self {
        case .defaultConfig:
                return 0
        case .localOnly:
                return 1
        case .customConfig:
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