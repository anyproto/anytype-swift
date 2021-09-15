import UIKit

struct EditorSearchCellConfiguration: UIContentConfiguration, Hashable {
    let cellData: EditorSearchCellData
    
    func makeContentView() -> UIView & UIContentView {
        EditorSearchCell(configuration: self)
    }
    
    func updated(for state: UIConfigurationState) -> EditorSearchCellConfiguration {
        self
    }
}
