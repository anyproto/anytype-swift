struct LoadingAlertData {
    let text: String
    var showAlert: Bool
    
    static var empty: LoadingAlertData {
        LoadingAlertData(text: "", showAlert: false)
    }
}
