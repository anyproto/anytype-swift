
import BlocksModels

enum BlockActionType {
    case style(BlockStyleAction)
    case media(BlockMediaAction)
    case objects
    case relations
    case other(BlockOtherAction)
    case actions(BlockAction)
    case color(BlockColorAction)
    case background(BlockBackgroundColorAction)
    case alignment(BlockInformation.Alignment)
    
    var displayData: BlockMenuItemSimpleDisplayData {
        switch self {
        case let .actions(action):
            return BlockMenuItemSimpleDisplayData(imageName: action.iconName, title: action.title)
        default:
            return BlockMenuItemSimpleDisplayData(imageName: "", title: "")
        }
    }
}
