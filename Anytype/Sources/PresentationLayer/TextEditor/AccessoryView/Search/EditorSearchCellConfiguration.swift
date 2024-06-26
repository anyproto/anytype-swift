import UIKit

struct EditorSearchCellConfiguration: UIContentConfiguration, Hashable {
    let cellData: EditorSearchCellData
    
    func makeContentView() -> any UIView & UIContentView {
        EditorSearchCell(configuration: self)
    }
    
    func updated(for state: any UIConfigurationState) -> EditorSearchCellConfiguration {
        self
    }
}
