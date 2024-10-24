import Foundation


public enum BuildType: String {
    case debug
    case testflight
    case appStore
}

// https://github.com/getsentry/sentry-cocoa/blob/main/Sources/SentryCrash/Recording/Monitors/SentryCrashMonitor_System.m#L443
public final class BuildTypeProvider {
    public static var buidType: BuildType {
        if isTestflight {
            return .testflight
        } else if isAppStore {
            return .appStore
        } else {
            return .debug
        }
    }
    
    
    public static var isTestflight: Bool {
        Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
    }
    
    
    public static var isAppStore: Bool {
        guard let appStoreReceiptURL = Bundle.main.appStoreReceiptURL else { return false }
        
        let isAppStoreReceipt = appStoreReceiptURL.lastPathComponent == "receipt"
        let receiptExists = FileManager.default.fileExists(atPath: appStoreReceiptURL.path)

        return isAppStoreReceipt && receiptExists
    }
}
