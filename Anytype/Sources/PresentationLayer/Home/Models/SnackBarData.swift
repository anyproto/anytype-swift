struct SnackBarData {
    let text: String
    var showSnackBar: Bool
    
    static var empty: SnackBarData {
        SnackBarData(text: "", showSnackBar: false)
    }
}
