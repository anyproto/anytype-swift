import Services

extension MembershipTier {
    // Legacy enum to match desktop values, use tierId instead
    var analyticsName: String {
        switch type.id {
        case 0:
            "None"
        case 1:
            "Explorer"
        case 2:
            "BuilderTest"
        case 3:
            "CoCreatorTest"
        case 4:
            "Builder"
        case 5:
            "CoCreator"
        case 6:
            "BuilderPlus"
        case 7:
            "AnytypeTeam"
        case 8:
            "AnytypeBetaUsers"
        case 9:
            "Builder2for1"
        case 16:
            "AnyPioneer"
        case 20:
            "NewExplorer"
        case 21:
            "Starter"
        case 22:
            "Pioneer"
        default:
            name
        }
    }
}



