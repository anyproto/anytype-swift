import Loc

enum AutoDownloadSizeLimit: Int, CaseIterable, Identifiable {
    case off = -1
    case mb20 = 20
    case mb100 = 100
    case mb250 = 250
    case gb1 = 1024
    case unlimited = 0

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .off: return Loc.FileStorage.AutoDownload.off
        case .mb20: return Loc.FileStorage.AutoDownload.mb20
        case .mb100: return Loc.FileStorage.AutoDownload.mb100
        case .mb250: return Loc.FileStorage.AutoDownload.mb250
        case .gb1: return Loc.FileStorage.AutoDownload.gb1
        case .unlimited: return Loc.FileStorage.AutoDownload.unlimited
        }
    }

    var isEnabled: Bool { self != .off }

    /// Value to send to middleware (mebibytes, 0 = unlimited)
    var middlewareSizeLimitMebibytes: Int64 {
        switch self {
        case .off: return 0
        case .unlimited: return 0
        case .mb20: return 20
        case .mb100: return 100
        case .mb250: return 250
        case .gb1: return 1024
        }
    }
}
