public extension Anytype_Rpc.BlockLink {
    public struct CreateWithObject {
      // SwiftProtobuf.Message conformance is added in an extension below. See the
      // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
      // methods supported on all messages.

      public var unknownFields = SwiftProtobuf.UnknownStorage()

      public struct Request {
        // SwiftProtobuf.Message conformance is added in an extension below. See the
        // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
        // methods supported on all messages.

        /// id of the context object
        public var contextID: String = String()

        /// new object details
        public var details: SwiftProtobuf.Google_Protobuf_Struct {
          get {
                  return _details ?? SwiftProtobuf.Google_Protobuf_Struct()
              }
          set {
                  _details = newValue
              }
        }
        /// Returns true if `details` has been explicitly set.
        public var hasDetails: Bool {
                return self._details != nil
            }
        /// Clears the value of `details`. Subsequent reads from it will return its default value.
        public mutating func clearDetails() {
                self._details = nil
            }

        /// optional template id for creating from template
        public var templateID: String = String()

        public var internalFlags: [Anytype_Model_InternalFlag] = []

        public var spaceID: String = String()

        public var objectTypeUniqueKey: String = String()

        public var block: Anytype_Model_Block {
          get {
                  return _block ?? Anytype_Model_Block()
              }
          set {
                  _block = newValue
              }
        }
        /// Returns true if `block` has been explicitly set.
        public var hasBlock: Bool {
                return self._block != nil
            }
        /// Clears the value of `block`. Subsequent reads from it will return its default value.
        public mutating func clearBlock() {
                self._block = nil
            }

        /// link block params
        public var targetID: String = String()

        public var position: Anytype_Model_Block.Position = .none

        /// deprecated link block fields
        public var fields: SwiftProtobuf.Google_Protobuf_Struct {
          get {
                  return _fields ?? SwiftProtobuf.Google_Protobuf_Struct()
              }
          set {
                  _fields = newValue
              }
        }
        /// Returns true if `fields` has been explicitly set.
        public var hasFields: Bool {
                return self._fields != nil
            }
        /// Clears the value of `fields`. Subsequent reads from it will return its default value.
        public mutating func clearFields() {
                self._fields = nil
            }

        public var unknownFields = SwiftProtobuf.UnknownStorage()

        public init() {
            }

        fileprivate var _details: SwiftProtobuf.Google_Protobuf_Struct? = nil
        fileprivate var _block: Anytype_Model_Block? = nil
        fileprivate var _fields: SwiftProtobuf.Google_Protobuf_Struct? = nil
      }

      public struct Response {
        // SwiftProtobuf.Message conformance is added in an extension below. See the
        // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
        // methods supported on all messages.

        public var error: Anytype_Rpc.BlockLink.CreateWithObject.Response.Error {
          get {
                  return _error ?? Anytype_Rpc.BlockLink.CreateWithObject.Response.Error()
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

        public var blockID: String = String()

        public var targetID: String = String()

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

        public var details: SwiftProtobuf.Google_Protobuf_Struct {
          get {
                  return _details ?? SwiftProtobuf.Google_Protobuf_Struct()
              }
          set {
                  _details = newValue
              }
        }
        /// Returns true if `details` has been explicitly set.
        public var hasDetails: Bool {
                return self._details != nil
            }
        /// Clears the value of `details`. Subsequent reads from it will return its default value.
        public mutating func clearDetails() {
                self._details = nil
            }

        public var unknownFields = SwiftProtobuf.UnknownStorage()

        public struct Error {
          // SwiftProtobuf.Message conformance is added in an extension below. See the
          // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
          // methods supported on all messages.

          public var code: Anytype_Rpc.BlockLink.CreateWithObject.Response.Error.Code = .null

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

        fileprivate var _error: Anytype_Rpc.BlockLink.CreateWithObject.Response.Error? = nil
        fileprivate var _event: Anytype_ResponseEvent? = nil
        fileprivate var _details: SwiftProtobuf.Google_Protobuf_Struct? = nil
      }

      public init() {
          }
    }
}