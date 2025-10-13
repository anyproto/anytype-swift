import Services
import Foundation

final class SegmentInfoBuilder {
    
    @Injected(\.workspaceStorage)
    private var workspaceStorage: any WorkspacesStorageProtocol
    @Injected(\.participantSpacesStorage)
    private var participantSpacesStorage: any ParticipantSpacesStorageProtocol
    
    
    private let byteCountFormatter = ByteCountFormatter.fileFormatter
    
    func build(spaceId: String, nodeUsage: NodeUsageInfo) -> RemoteStorageSegmentInfo {
        let bytesLimit = nodeUsage.node.bytesLimit
        var segmentInfo = RemoteStorageSegmentInfo()
        
        if let spaceView = workspaceStorage.spaceView(spaceId: spaceId) {
            let spaceBytesUsage = nodeUsage.spaces.first(where: { $0.spaceID == spaceId })?.bytesUsage ?? 0
            segmentInfo.currentUsage = Double(spaceBytesUsage) / Double(bytesLimit)
            segmentInfo.currentLegend = Loc.FileStorage.LimitLegend.current(spaceView.title, byteCountFormatter.string(fromByteCount: spaceBytesUsage))
        }
       
        let otherSpaces = participantSpacesStorage.activeParticipantSpaces
            .filter(\.isOwner)
            .map(\.spaceView)
            .filter { $0.targetSpaceId != spaceId }
        
        if otherSpaces.isNotEmpty {
            let otherUsageBytes = nodeUsage.spaces.filter { $0.spaceID != spaceId }.reduce(Int64(0), { $0 + $1.bytesUsage })

            if otherSpaces.count > 10 {
                segmentInfo.otherUsages = [Double(otherUsageBytes) / Double(bytesLimit)]
            } else {
                segmentInfo.otherUsages = otherSpaces.map { spaceView in
                    let spaceBytesUsage = nodeUsage.spaces.first(where: { $0.spaceID == spaceView.targetSpaceId })?.bytesUsage ?? 0
                    return Double(spaceBytesUsage) / Double(bytesLimit)
                }
            }

            segmentInfo.otherLegend = Loc.FileStorage.LimitLegend.other(byteCountFormatter.string(fromByteCount: otherUsageBytes))
        }
        
        segmentInfo.free = Double(nodeUsage.node.bytesLeft) / Double(bytesLimit)
        segmentInfo.freeLegend = Loc.FileStorage.LimitLegend.free(byteCountFormatter.string(fromByteCount: nodeUsage.node.bytesLeft))
        
        return segmentInfo
    }
}
