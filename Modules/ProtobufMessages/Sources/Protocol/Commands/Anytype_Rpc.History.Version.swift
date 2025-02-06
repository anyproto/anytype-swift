public extension Anytype_Rpc.History {
    public struct Version {
      // SwiftProtobuf.Message conformance is added in an extension below. See the
      // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
      // methods supported on all messages.

      public var id: String = String()

      public var previousIds: [String] = []

      public var authorID: String = String()

      public var authorName: String = String()

      public var time: Int64 = 0

      public var groupID: Int64 = 0

      public var unknownFields = SwiftProtobuf.UnknownStorage()

      public init() {
          }
    }
}