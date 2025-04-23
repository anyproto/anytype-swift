public struct ToastBarData: Equatable {
    public let text: String
    public let showSnackBar: Bool
    public let messageType: ToastMessageType
    
    public init(
        text: String,
        showSnackBar: Bool,
        messageType: ToastMessageType = .success
    ) {
        self.text = text
        self.showSnackBar = showSnackBar
        self.messageType = messageType
    }
    
    public static var empty: ToastBarData {
        ToastBarData(text: "", showSnackBar: false)
    }
}
