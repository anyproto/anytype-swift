import Foundation
import AnytypeCore

protocol PushNotificationsAlertHandlerProtocol: AnyObject, Sendable {
    func shouldShowAlert() async -> Bool
    func storeAlertShowDate()
}

final class PushNotificationsAlertHandler: PushNotificationsAlertHandlerProtocol, @unchecked Sendable {
    
    private let pushNotificationsPermissionService: any PushNotificationsPermissionServiceProtocol = Container.shared.pushNotificationsPermissionService()
    
    // [Date]
    @UserDefault("UserData.PushNotificationsAlertDates", defaultValue: [])
    private var pushNotificationsAlertDates: [Date]
    
    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        return dateFormatter
    }()
    
    private let minIntervalInDays = 1
    private let maxAttemptsCount = 3
    
    // MARK: - PushNotificationsAlertHandlerProtocol
    
    func shouldShowAlert() async -> Bool {
        let status = await pushNotificationsPermissionService.authorizationStatus()
        
        switch status {
        case .notDetermined:
            return limitationsHasPassed()
        case .denied, .authorized, .unknown:
            return false
        }
    }
    
    func storeAlertShowDate() {
        pushNotificationsAlertDates.append(Date())
    }
    
    // MARK: - Private
    
    private func limitationsHasPassed() -> Bool {        
        if pushNotificationsAlertDates.isEmpty {
            return true
        }
        
        if pushNotificationsAlertDates.count >= maxAttemptsCount {
            return false
        }
        
        if let lastDate = pushNotificationsAlertDates.last, minIntervalInDaysHasPassed(date1: lastDate, date2: Date()) {
            return true
        } else {
            return false
        }
    }
    
    private func minIntervalInDaysHasPassed(date1: Date, date2: Date) -> Bool {
        let daytInterval = dateFormatter.calendar.dateComponents([.day], from: date1, to: date2).day ?? 0
        return daytInterval >= minIntervalInDays
    }
}
