import UIKit

struct SlashMenuRealtionContentConfiguration: UIContentConfiguration, Hashable {
    var relation: Relation

    func makeContentView() -> UIView & UIContentView {
        return SlashMenuRealtionView(configuration: self)
    }

    func updated(for state: UIConfigurationState) -> SlashMenuRealtionContentConfiguration {
        self
    }
}
