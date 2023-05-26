import Foundation
import AnytypeCore

struct FeatureFlagSection {
    let title: String
    let rows: [FeatureFlagViewModel]
}

struct FeatureFlagViewModel {
    let description: FeatureDescription
    let value: Bool
    let onChange: (_ newValue: Bool) -> Void
}
