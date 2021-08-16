enum SmartBlockType: Int {
    case breadcrumbs = 0

    case page = 0x10
    case profilePage = 0x11
    case home = 0x20
    case archive = 0x30
    case database = 0x40
    case set = 0x41
    case objectType = 0x60

    case file = 0x100
    case template = 0x120

    case marketplaceType = 0x110
    case marketplaceRelation = 0x111
    case marketplaceTemplate = 0x112

    case bundledRelation = 0x200
    case indexedRelation = 0x201
    case bundledObjectType = 0x202
    case anytypeProfile = 0x203
};
