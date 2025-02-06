public extension Anytype_Rpc {
    public struct GenericErrorResponse {
    // SwiftProtobuf.Message conformance is added in an extension below. See the
    // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
    // methods supported on all messages.

    public var error: Anytype_Rpc.GenericErrorResponse.Error {
      get {
              return _error ?? Anytype_Rpc.GenericErrorResponse.Error()
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

    public init() {
        }

    fileprivate var _error: Anytype_Rpc.GenericErrorResponse.Error? = nil
  }
}