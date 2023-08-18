enum LoginLoadingRoute {
    case none
    case login
    case qr
    case keychain
    
    var isLoadingInProgress: Bool {
        self != .none
    }
    
    var isLoginInProgress: Bool {
        self == .login
    }
    
    var isQRInProgress: Bool {
        self == .qr
    }
    
    var isKeychainInProgress: Bool {
        self == .keychain
    }
}
