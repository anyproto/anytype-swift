import UIKit

@MainActor
protocol CursorModeAccessoryViewDelegate: AnyObject {
    func showSlashMenuView()
    func showMentionsView()
}
