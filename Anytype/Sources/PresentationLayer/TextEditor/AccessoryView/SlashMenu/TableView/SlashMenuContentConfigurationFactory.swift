import UIKit

final class SlashMenuContentConfigurationFactory {
    func dividerConfiguration(title: String) -> any UIContentConfiguration {
        var configuration = UIListContentConfiguration.subtitleCell()
        configuration.textProperties.font = .uxTitle2Regular
        configuration.text = title
        return configuration
    }
    
    func configuration(displayData: SlashMenuItemDisplayData) -> any UIContentConfiguration {
        EditorSearchCellConfiguration(
            cellData: EditorSearchCellData(
                title: displayData.title,
                subtitle: displayData.subtitle ?? "",
                icon: displayData.iconData,
                expandedIcon: displayData.expandedIcon
            )
        )
    }

    func configuration(relation: Relation) -> any UIContentConfiguration {
        SlashMenuRealtionContentConfiguration(relation: RelationItemModel(relation: relation))
    }
}
