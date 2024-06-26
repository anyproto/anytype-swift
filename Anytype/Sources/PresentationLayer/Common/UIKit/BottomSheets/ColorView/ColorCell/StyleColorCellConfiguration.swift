import UIKit


struct StyleColorCellContentConfiguration: UIContentConfiguration, Hashable {
    let colorItem: ColorView.ColorItem
    var isSelected: Bool = false

    func makeContentView() -> any UIView & UIContentView {
        return StyleColorContentView(configuration: self)
    }

    func updated(for state: any UIConfigurationState) -> Self {
        guard let state = state as? UICellConfigurationState else { return self }
        var updatedConfig = self

        updatedConfig.isSelected = state.isSelected
        return updatedConfig
    }
}
