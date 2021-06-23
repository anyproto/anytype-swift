import Combine
import ProtobufMessages

final class ObjectTypeService {
    
    private enum Constants {
        static let pageObjectURL = "_otpage"
    }
    
    static let shared = ObjectTypeService()
    
    private(set) var objects = [ObjectType]()
    private let parser: ObjectTypesParser
    private lazy var accessQueue = DispatchQueue(label: "com.anytype.mentionAccessQueue")
    private var subscription: AnyCancellable?
    
    init(parser: ObjectTypesParser = ObjectTypesParser()) {
        self.parser = parser
    }
    
    func loadObjects() {
        let service = Anytype_Rpc.ObjectType.List.Service.self
        subscription = service.invoke(queue: accessQueue).sinkWithDefaultCompletion("loading object types") { [weak self] response in
            guard let self = self else { return }
            // Currently we load only Page
            let objects = self.parser.objectTypes(from: response)
            if let page = objects.first(where: { $0.url == Constants.pageObjectURL }) {
                self.objects = [page]
            }
        }
    }
}
