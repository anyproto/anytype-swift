public struct ToastBarData: Equatable {
    public let text: String
    public let type: ToastMessageType
    
    public init(
        _ text: String,
        type: ToastMessageType = .success
    ) {
        self.text = text
        self.type = type
    }
}
