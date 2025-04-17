import Foundation
import UIKit

final class OpenObjectActivity: UIActivity {
    
    let onTap: () -> Void
    
    init(onTap: @escaping () -> Void) {
        self.onTap = onTap
    }
    
    override var activityTitle: String? {
        return Loc.openAsObject
    }
    
    override var activityImage: UIImage? {
        return UIImage(
            systemName: "arrow.up.left.and.arrow.down.right",
            withConfiguration: UIImage.SymbolConfiguration(weight: .light)
        )
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
