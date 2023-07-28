
// Layout in go https://github.com/anytypeio/go-anytype-middleware/blob/master/pkg/lib/pb/model/models.pb.go#L1172

public enum DetailsLayout: Int, CaseIterable, Codable {
    case basic = 0
    case profile = 1
    case todo = 2
    case set = 3
    case objectType = 4
    case relation = 5
    case file = 6
    case image = 8
    case note = 9
    case space = 10
    case bookmark = 11
    case relationOption = 13
    case collection = 14
    case audio = 15
    case video = 16
    case date = 17
    
    case unknown = -1
}
