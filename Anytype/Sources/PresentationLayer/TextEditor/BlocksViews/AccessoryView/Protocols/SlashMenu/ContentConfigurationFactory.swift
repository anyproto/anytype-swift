import UIKit

final class ContentConfigurationFactory {
    private let imageSize = CGSize(width: 24, height: 24)
    private let imageToTextPadding: CGFloat = 22
    
    func dividerConfiguration(title: String) -> UIContentConfiguration {
        var configuration = UIListContentConfiguration.subtitleCell()
        configuration.textProperties.font = .uxTitle2Regular
        configuration.text = title
        return configuration
    }
    
    func configuration(displayData: SlashMenuItemDisplayData) -> UIContentConfiguration {
        switch displayData.iconData {
        case let .imageNamed(imageName):
            return makeConfiguration(
                with: displayData.title,
                subtitle: displayData.subtitle,
                imageName: imageName
            )
        case let .emoji(emoji):
            return ContentConfigurationWithEmoji(
                emoji: emoji,
                name: displayData.title,
                description: displayData.subtitle
            )
        }
    }
    
    private func makeConfiguration(
        with title: String,
        subtitle: String?,
        imageName: String
    ) -> UIContentConfiguration {
        var configuration = UIListContentConfiguration.subtitleCell()
        configuration.text = title
        configuration.textProperties.font = .uxTitle2Regular
        configuration.textProperties.color = .textPrimary
        configuration.image = UIImage(named: imageName)
        configuration.imageToTextPadding = imageToTextPadding
        configuration.imageProperties.reservedLayoutSize = imageSize
        configuration.imageProperties.maximumSize = imageSize
        if let subtitle = subtitle {
            configuration.secondaryText = subtitle
            configuration.secondaryTextProperties.font = .caption1Regular
            configuration.secondaryTextProperties.color = .textSecondary
        }
        return configuration
    }
}
