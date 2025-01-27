import Services
import Combine

final class MockSetObjectCreationSettingsInteractor: SetObjectCreationSettingsInteractorProtocol {
    
    var objectTypesAvailabilityPublisher: AnyPublisher<Bool, Never> { $canChangeObjectType.eraseToAnyPublisher() }
    @Published var canChangeObjectType = false
    
    var objectTypeId: String { fatalError() }
    var objectTypesConfigPublisher: AnyPublisher<ObjectTypesConfiguration, Never> { $objectTypesConfig.eraseToAnyPublisher()
    }
    @Published private var objectTypesConfig = ObjectTypesConfiguration.empty
    
    var userTemplates: AnyPublisher<[TemplatePreviewModel], Never> { $templates.eraseToAnyPublisher() }

    @Published private var templates = MockTemplatePreviewModel.allPreviews.map { $0.model }
    
    func setDefaultObjectType(objectTypeId: String) async throws {
        fatalError()
    }
    
    func setDefaultTemplate(templateId: String) async throws {
        fatalError()
    }
    
    func setObjectTypeId(_ objectTypeId: String) {
        fatalError()
    }
}

struct MockTemplatePreviewModel: Identifiable {
    var id: String { model.id }
    let title: String
    let model: TemplatePreviewModel
}

extension MockTemplatePreviewModel {
    static let allPreviews = [
        templateWithTitle,
        onlyIcon,
        iconCoverTitle,
        coverTitle
    ]
    
    static let templateWithTitle = MockTemplatePreviewModel(
        title: "Template with title",
        model: .init(
            mode: .installed(
                .init(
                    id: "id",
                    title: "Awesome template",
                    header: .none,
                    isBundled: false,
                    style: .todo(false)
                )
            ),
            alignment: .left
        )
    )
    
    static let onlyIcon = MockTemplatePreviewModel(
        title: "Only icon",
        model: .init(
            mode: .installed(
                .init(
                    id: "id",
                    title: "Awesome template",
                    header: .filled(
                        state: .iconOnly(
                            .init(
                                icon: .init(
                                    icon: .init(
                                        mode: .icon(.emoji(.lamp)),
                                        usecase: .templatePreview)
                                    ,
                                    layoutAlignment: .left,
                                    onTap: {}
                                ),
                                onCoverTap: {}
                            )
                        )
                    ),
                    isBundled: false,
                    style: .todo(false)
                )
            ),
            alignment: .left
        )
    )
    
    static let iconCoverTitle = MockTemplatePreviewModel(
        title: "Preview icon cover title",
        model: .init(
            mode: .installed(
                .init(
                    id: "Id",
                    title: "Awesome template",
                    header: .filled(
                        state: .iconAndCover(
                            icon: .init(
                                icon: .init(
                                    mode: .icon(.emoji(.lamp)),
                                    usecase: .templatePreview
                                ),
                                layoutAlignment: .left,
                                onTap: {}
                            ),
                            cover: .init(
                                coverType: .cover(.gradient(.init(start: .red, end: .blue))),
                                onTap: {}))
                    ),
                    isBundled: false,
                    style: .todo(false)
                )
            ),
            alignment: .left
        )
    )
    
    static let coverTitle = MockTemplatePreviewModel(
        title: "Preview cover title",
        model: .init(
            mode: .installed(
                .init(
                    id: "Id",
                    title: "Awesome template",
                    header: .filled(
                        state: .coverOnly(
                            .init(
                                coverType: .cover(.gradient(.init(start: .red, end: .blue))),
                                onTap: {}
                            )
                        )
                    ),
                    isBundled: false,
                    style: .todo(false)
                )
            ),
            alignment: .left
        )
    )
}
