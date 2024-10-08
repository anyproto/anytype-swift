import Foundation
import AnytypeCore

protocol UserWarningAlertsHandlerProtocol {
    func nextUserWarningAlert() async -> UserWarningAlert?
}

final class UserWarningAlertsHandler: UserWarningAlertsHandlerProtocol {
    
    private let activeUserWarningAlerts = UserWarningAlert.allCases
    private let minIntervalInDays = 3
    
    @Injected(\.appVersionTracker)
    private var appVersionTracker: any AppVersionTrackerProtocol
    
    // [UserWarningAlert : Date]
    @UserDefault("UserData.ShownUserWarningAlerts", defaultValue: [:])
    private var shownAlerts: [UserWarningAlert: Date]
    
    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        return dateFormatter
    }()
    
    func nextUserWarningAlert() async -> UserWarningAlert? {
        let todayDate = Date()
        var prevAlertShownDate: Date? = nil
        
        for alert in activeUserWarningAlerts {
            if let shownDate = shownAlerts[alert] {
                prevAlertShownDate = shownDate
                continue
            }
            if let prevAlertShownDate {
                let minIntervalInDaysHasPassed = minIntervalInDaysHasPassed(
                    date1: prevAlertShownDate,
                    date2: todayDate
                )
                let reachedVersion = await appVersionTracker.reachedVersion(alert.version)
                if minIntervalInDaysHasPassed, reachedVersion {
                    storeToShownAlert(alert, date: todayDate)
                    return alert
                }
            } else {
                if await firstVersionLaunch(for: alert) {
                    storeToShownAlert(alert, date: todayDate)
                    return alert
                }
            }
        }
        
        return nil
    }
    
    private func firstVersionLaunch(for alert: UserWarningAlert) async -> Bool {
        await appVersionTracker.firstVersionLaunch(
            alert.version,
            ignoreForNewUser: alert.ignoreForNewUser
        )
    }
    
    private func minIntervalInDaysHasPassed(date1: Date, date2: Date) -> Bool {
        let daytInterval = dateFormatter.calendar.dateComponents([.day], from: date1, to: date2).day ?? 0
        return daytInterval >= minIntervalInDays
    }
    
    private func storeToShownAlert(_ alert: UserWarningAlert, date: Date) {
        shownAlerts[alert] = date
    }
}
