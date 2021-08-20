
import Combine
import ProtobufMessages

final class MentionObjectsService {
    
    private lazy var accessQueue = DispatchQueue(label: "com.anytype.mentionAccessQueue")
    private let pageObjectsCount: Int32
    private var offset = Int32(0)
    var filterString = "" {
        didSet {
            offset = 0
            possibleToObtainNextPage = true
        }
    }
    private let parser: MentionsParser
    private(set) var possibleToObtainNextPage = true
    
    init(pageObjectsCount: Int32 = 100, parser: MentionsParser = MentionsParser()) {
        self.parser = parser
        self.pageObjectsCount = pageObjectsCount
    }
    
    func obtainMentionsPublisher() -> AnyPublisher<[MentionObject], Error> {
        let service = Anytype_Rpc.Navigation.ListObjects.Service.self
        let publisher = service.invoke(
            context: .navigation,
            fullText: filterString,
            limit: pageObjectsCount,
            offset: offset,
            queue: accessQueue
        )
        .compactMap { [weak self] response -> [MentionObject]? in
            guard let self = self else { return nil }
            self.possibleToObtainNextPage = response.objects.count == self.pageObjectsCount
            return self.parser
                .parseMentions(from: response)
                .filter { ObjectTypeProvider.isSupported(typeUrl: $0.type?.url) }
        }
        .eraseToAnyPublisher()
        
        offset += pageObjectsCount
        return publisher
    }
}
