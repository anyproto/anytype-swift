import UIKit
import SwiftUI

final class SlashMenuContentConfigurationFactory {
    @MainActor
    func dividerConfiguration(title: String) -> any UIContentConfiguration {
        UIHostingConfiguration {
            SectionHeaderView(title: title)
        }
        .minSize(height: 0)
        .margins(.vertical, 0)
    }
    
    func configuration(displayData: SlashMenuItemDisplayData) -> any UIContentConfiguration {
        EditorSearchCellConfiguration(
            cellData: EditorSearchCellData(
                title: displayData.title,
                subtitle: "",
                icon: displayData.iconData,
                expandedIcon: displayData.expandedIcon,
                showDecoration: displayData.showDecoration
            )
        )
    }

    func configuration(relation: Property) -> any UIContentConfiguration {
        SlashMenuPropertyContentConfiguration(property: PropertyItemModel(property: relation))
    }
}
