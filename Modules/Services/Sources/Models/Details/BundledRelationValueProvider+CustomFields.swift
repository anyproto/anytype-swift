import Foundation
import AnytypeCore
import ProtobufMessages

extension BundledRelationsValueProvider {
    
    public var isDone: Bool {
        return done
    }
    
    public var layoutValue: DetailsLayout {
        guard
            let number = layout,
            let layout = DetailsLayout(rawValue: number)
        else { return .UNRECOGNIZED(layout ?? -1) }
        
        return layout
    }
    
    public var recommendedLayoutValue: DetailsLayout? {
        return recommendedLayout.flatMap { DetailsLayout(rawValue: $0) }
    }
    
    public var coverTypeValue: CoverType {
        guard
            let number = coverType,
            let coverType = CoverType(rawValue: number)
        else {
            return .none
        }
        
        return coverType
    }
    
    public var layoutAlignValue: LayoutAlignment {
        guard
            let number = layoutAlign,
            let layout = LayoutAlignment(rawValue: number)
        else {
            return .left
        }
        
        return layout
    }
    
    public var objectName: String {
        let title: String

        if layoutValue == .note {
            title = snippet
        } else if DetailsLayout.fileLayouts.contains(layoutValue) {
            title = "\(name).\(fileExt)"
        } else {
            title = name
        }
        
        return title.replacedNewlinesWithSpaces
    }
    
    public var isSelectTemplate: Bool {
        let flag = Anytype_Model_InternalFlag.Value.editorSelectTemplate.rawValue
        return internalFlags.contains(flag)
    }
    
    public var isSelectType: Bool {
        let flag = Anytype_Model_InternalFlag.Value.editorSelectType.rawValue
        return internalFlags.contains(flag)
    }

    var relationFormatValue: RelationFormat {
        relationFormat.map { RelationFormat(rawValue: $0) } ?? .unrecognized
    }
    
    public var spaceAccessTypeValue: SpaceAccessType? {
        return spaceAccessType.flatMap { SpaceAccessType(rawValue: $0) }
    }
    
    public var iconOptionValue: GradientId? {
        return iconOption.flatMap { GradientId($0) }
    }
    
    public var uniqueKeyValue: ObjectTypeUniqueKey {
        return ObjectTypeUniqueKey(value: uniqueKey)
    }
    
    public var spaceAccountStatusValue: SpaceStatus? {
        guard let spaceAccountStatus else { return nil }
        return SpaceStatus(rawValue: spaceAccountStatus)
    }
    
    public var spaceLocalStatusValue: SpaceStatus? {
        guard let spaceLocalStatus else { return nil }
        return SpaceStatus(rawValue: spaceLocalStatus)
    }
    
    public var participantPermissionsValue: ParticipantPermissions? {
        guard let participantPermissions else { return nil }
        return ParticipantPermissions(rawValue: participantPermissions)
    }
    
    public var participantStatusValue: ParticipantStatus? {
        guard let participantStatus else { return nil }
        return ParticipantStatus(rawValue: participantStatus)
    }
    
    public var restrictionsValue: [ObjectRestriction] {
        restrictions.compactMap { ObjectRestriction(rawValue: $0) }
    }
}
