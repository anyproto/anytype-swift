import UIKit

final class SlashMenuContentConfigurationFactory {
    func dividerConfiguration(title: String) -> UIContentConfiguration {
        var configuration = UIListContentConfiguration.subtitleCell()
        configuration.textProperties.font = .uxTitle2Regular
        configuration.text = title
        return configuration
    }
    
    func configuration(displayData: SlashMenuItemDisplayData) -> UIContentConfiguration {
        EditorSearchCellConfiguration(
            cellData: EditorSearchCellData(
                title: displayData.title,
                subtitle: displayData.subtitle ?? "",
                icon: displayData.iconData,
                expandedIcon: displayData.expandedIcon
            )
        )
    }

    func configuration(relationValue: RelationValue) -> UIContentConfiguration {
        SlashMenuRealtionContentConfiguration(relation: RelationItemModel(relationValue: relationValue))
    }
}
