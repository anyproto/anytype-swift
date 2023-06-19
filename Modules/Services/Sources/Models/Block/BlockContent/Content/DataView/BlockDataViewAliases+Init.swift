import SwiftProtobuf
import ProtobufMessages

extension DataviewObjectOrder {
    public init(viewID: String = String(), groupID: String = String(), objectIds: [String] = []) {
        self.init()
        self.viewID = viewID
        self.groupID = groupID
        self.objectIds = objectIds
    }
}

extension DataviewSort {
    public init(
        id: String = String(),
        relationKey: String = String(),
        type: Anytype_Model_Block.Content.Dataview.Sort.TypeEnum = .asc,
        customOrder: [SwiftProtobuf.Google_Protobuf_Value] = [],
        format: Anytype_Model_RelationFormat = .longtext,
        includeTime: Bool = false
    ) {
        self.init()
        self.id = id
        self.relationKey = relationKey
        self.type = type
        self.customOrder = customOrder
        self.format = format
        self.includeTime = includeTime
    }
}

extension DataviewFilter {
    public init(
        id: String = String(),
        `operator`: Anytype_Model_Block.Content.Dataview.Filter.Operator = .and,
        relationKey: String = String(),
        relationProperty: String = String(),
        condition: Anytype_Model_Block.Content.Dataview.Filter.Condition = .none,
        value: SwiftProtobuf.Google_Protobuf_Value,
        quickOption: Anytype_Model_Block.Content.Dataview.Filter.QuickOption = .exactDate,
        format: Anytype_Model_RelationFormat = .longtext,
        includeTime: Bool = false
    ) {
        self.init()
        self.id = id
        self.`operator` = `operator`
        self.relationKey = relationKey
        self.relationProperty = relationProperty
        self.condition = condition
        self.value = value
        self.quickOption = quickOption
        self.format = format
        self.includeTime = includeTime
    }
}

extension DataviewViewGroup {
    public init(
        groupID: String = String(),
        index: Int32 = 0,
        hidden: Bool = false,
        backgroundColor: String = String()
    ) {
        self.init()
        self.groupID = groupID
        self.index = index
        self.hidden = hidden
        self.backgroundColor = backgroundColor
    }
}

extension DataviewGroupOrder {
    public init(
        viewID: String = String(),
        viewGroups: [Anytype_Model_Block.Content.Dataview.ViewGroup] = []
    ) {
        self.init()
        self.viewID = viewID
        self.viewGroups = viewGroups
    }
}
