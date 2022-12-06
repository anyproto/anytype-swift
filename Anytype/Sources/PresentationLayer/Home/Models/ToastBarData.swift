struct ToastBarData: Equatable {
    let text: String
    let showSnackBar: Bool
    let messageType: ToastAlert.MessageType
    
    init(
        text: String,
        showSnackBar: Bool,
        messageType: ToastAlert.MessageType = .success
    ) {
        self.text = text
        self.showSnackBar = showSnackBar
        self.messageType = messageType
    }
    
    static var empty: ToastBarData {
        ToastBarData(text: "", showSnackBar: false)
    }
}
