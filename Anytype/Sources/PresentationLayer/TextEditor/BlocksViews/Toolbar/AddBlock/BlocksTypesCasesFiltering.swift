struct BlocksTypesCasesFiltering {
    static func text(_ value: [BlockToolbarBlocksTypes.Text]) -> Self { .init(text: value) }
    static func list(_ value: [BlockToolbarBlocksTypes.List]) -> Self { .init(list: value) }
    static func objects(_ value: [BlockToolbarBlocksTypes.Objects]) -> Self { .init(objects: value) }
    static func tool(_ value: [BlockToolbarBlocksTypes.Tool]) -> Self { .init(tool: value) }
    static func other(_ value: [BlockToolbarBlocksTypes.Other]) -> Self { .init(other: value) }
    static func empty() -> Self { .init(text: [], list: [], objects: [], tool: [], other: []) }
    static func all() -> Self { .init(
        text: BlockToolbarBlocksTypes.Text.allCases,
        list: BlockToolbarBlocksTypes.List.allCases,
        objects: BlockToolbarBlocksTypes.Objects.allCases,
        tool: BlockToolbarBlocksTypes.Tool.allCases,
        other: BlockToolbarBlocksTypes.Other.allCases
    ) }
    
    static func allText() -> [BlockToolbarBlocksTypes.Text] { BlockToolbarBlocksTypes.Text.allCases }
    static func allList() -> [BlockToolbarBlocksTypes.List] { BlockToolbarBlocksTypes.List.allCases }
    static func allObjects() -> [BlockToolbarBlocksTypes.Objects] { BlockToolbarBlocksTypes.Objects.allCases }
    static func allTool() -> [BlockToolbarBlocksTypes.Tool] { BlockToolbarBlocksTypes.Tool.allCases }
    static func allOther() -> [BlockToolbarBlocksTypes.Other] { BlockToolbarBlocksTypes.Other.allCases }
    
    var text: [BlockToolbarBlocksTypes.Text] = []
    var list: [BlockToolbarBlocksTypes.List] = []
    var objects: [BlockToolbarBlocksTypes.Objects] = []
    var tool: [BlockToolbarBlocksTypes.Tool] = []
    var other: [BlockToolbarBlocksTypes.Other] = []
                            
    func availableCategories() -> [BlockToolbarBlocksTypes] {
        BlockToolbarBlocksTypes.allCases.filter { (value) -> Bool in
            switch value {
            case .text: return !self.text.isEmpty
            case .list: return !self.list.isEmpty
            case .objects: return !self.objects.isEmpty
            case .tool: return !self.tool.isEmpty
            case .other: return !self.other.isEmpty
            }
        }
    }
    
    @discardableResult mutating func allText() -> Self { self.text(Self.allText()) }
    @discardableResult mutating func allList() -> Self { self.list(Self.allList()) }
    @discardableResult mutating func allObjects() -> Self { self.objects(Self.allObjects()) }
    @discardableResult mutating func allTool() -> Self { self.tool(Self.allTool()) }
    @discardableResult mutating func allOther() -> Self { self.other(Self.allOther()) }

    mutating func text(_ value: [BlockToolbarBlocksTypes.Text]) -> Self {
        self.text = value
        return self
    }
    mutating func list(_ value: [BlockToolbarBlocksTypes.List]) -> Self {
        self.list = value
        return self
    }
    mutating func objects(_ value: [BlockToolbarBlocksTypes.Objects]) -> Self {
        self.objects = value
        return self
    }

    mutating func tool(_ value: [BlockToolbarBlocksTypes.Tool]) -> Self {
        self.tool = value
        return self
    }
    mutating func other(_ value: [BlockToolbarBlocksTypes.Other]) -> Self {
        self.other = value
        return self
    }
    
    mutating func append(_ values: [BlockToolbarBlocksTypes]) {
        values.forEach {
            switch $0 {
            case let .text(text):
                self.text.append(text)
            case let .list(list):
                self.list.append(list)
            case let .objects(object):
                self.objects.append(object)
            case let .tool(tool):
                self.tool.append(tool)
            case let.other(other):
                self.other.append(other)
            
            }
        }
    }
}
