import Foundation
import UIKit

extension String {
    var replacingHTMLEntities: String {
        guard let data = data(using: .utf8) else { return self }
        do {
            // Some links can contains html entities.
            // For example, wher user tap link in slack, it is replace & to &amp; .
            // Uses WebKit for parsing text and replace html entities to normal symbols.
            let attributedString = try NSAttributedString(
                data: data,
                options: [
                    .documentType: NSAttributedString.DocumentType.html,
                    .characterEncoding: String.Encoding.utf8.rawValue
                ],
                documentAttributes: nil
            )
            return attributedString.string
        } catch {
            return self
        }
    }
}
