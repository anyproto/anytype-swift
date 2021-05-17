

import Foundation

struct BlockMenuItemSimpleDisplayData {
    let imageName: String
    let title: String
    let subtitle: String?
    
    init(imageName: String, title: String, subtitle: String? = nil) {
        self.imageName = imageName
        self.title = title
        self.subtitle = subtitle
    }
    
    func matchBy(string: String) -> BlockMenuItemSimpleDisplayDataFilterMatch? {
        let lowecasedTitle = title.lowercased()
        let subtitle = self.subtitle?.lowercased()
        let comparators = [BlockActionDisplayDataFilterComparator(predicate: { lowecasedTitle == $0 },
                                                                  result: .fullTitle),
                           BlockActionDisplayDataFilterComparator(predicate: { lowecasedTitle.contains($0) },
                                                                  result: .titleSubstring),
                           BlockActionDisplayDataFilterComparator(predicate: { subtitle == $0 },
                                                                  result: .fullSubtitle),
                           BlockActionDisplayDataFilterComparator(predicate: { subtitle?.contains($0) ?? false },
                                                                  result: .subtitleSubstring)]
        return comparators.first { $0.predicate(string.lowercased()) }?.result
    }
}
