import Foundation
import UIKit

final class OpenObjectActivity: UIActivity {
    
    let onTap: () -> Void
    
    init(onTap: @escaping () -> Void) {
        self.onTap = onTap
    }
    
    override var activityTitle: String? {
        return "Open As Object"
    }
    
    override var activityImage: UIImage? {
        return UIImage(systemName: "star.fill")
    }
    
    override var activityType: UIActivity.ActivityType? {
        return UIActivity.ActivityType("com.example.custom")
    }
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true
    }
    
    override func prepare(withActivityItems activityItems: [Any]) {
        onTap()
    }
    
    override func perform() {
        activityDidFinish(true)
    }
}
