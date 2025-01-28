import Foundation
import ProtobufMessages

extension BundledRelationsValueProvider {
    
    public var isDone: Bool { done }
    
    public var layoutValue: DetailsLayout {
        guard let number = resolvedLayout, let layout = DetailsLayout(rawValue: number) else {
            return .UNRECOGNIZED(resolvedLayout ?? -1)
        }
        
        return layout
    }
    
    public var recommendedLayoutValue: DetailsLayout? {
        recommendedLayout.flatMap { DetailsLayout(rawValue: $0) }
    }
    
    public var coverTypeValue: CoverType {
        guard let number = coverType, let coverType = CoverType(rawValue: number) else {
            return .none
        }
        
        return coverType
    }
    
    public var layoutAlignValue: LayoutAlignment {
        guard let number = layoutAlign, let layout = LayoutAlignment(rawValue: number) else {
            return .left
        }
        
        return layout
    }
    
    public var objectName: String {
        let title: String

        if layoutValue.isNote {
            title = snippet
        } else if layoutValue.isFileOrMedia {
            title = FileDetails.formattedFileName(name, fileExt: fileExt)
        } else if layoutValue.isDate, let timestamp {
            title = DateFormatter.relativeDateFormatter.string(from: timestamp)
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
    
    public var internalFlagsValue: [InternalFlag] {
        internalFlags.compactMap { InternalFlag(rawValue: $0) }
    }
}
