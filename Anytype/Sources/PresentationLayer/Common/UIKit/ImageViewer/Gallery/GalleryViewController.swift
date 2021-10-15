import UIKit

final class GalleryViewController: UIViewController {

    private struct Constants {
        static let spacingBetweenImages: CGFloat = 40
    }

    // MARK: - Properties
    private let viewModel: GalleryViewModel

    private var pageViewController: UIPageViewController

    init(viewModel: GalleryViewModel) {
        self.viewModel = viewModel
        pageViewController = UIPageViewController(transitionStyle: .scroll,
                                                  navigationOrientation: .horizontal,
                                                  options: [UIPageViewController.OptionsKey.interPageSpacing : Constants.spacingBetweenImages])

        super.init(nibName: nil, bundle: nil)

        setupPageViewController()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Override functions

    override func viewDidLoad() {
        super.viewDidLoad()

        setupDesign()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { (_) in
            self.pageViewController.view.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        }, completion: nil)
    }

    // MARK: - Private functions

    private func setupDesign() {
        view.backgroundColor = UIColor.black

        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        didMove(toParent: pageViewController)
    }

    private func setupPageViewController() {
        pageViewController.dataSource = self
        pageViewController.delegate = self

        if let imageViewController = imageViewController(forIndex: viewModel.initialImageDisplayIndex) {
            pageViewController.setViewControllers([imageViewController],
                                                  direction: .forward,
                                                  animated: false,
                                                  completion: nil)
        }
    }

    fileprivate func imageViewController(forIndex index: Int) -> ImageViewerViewController? {
        guard let imageSource = viewModel.imageSources[safe: index] else { return nil }

        let viewModel = ImageViewerViewModel(imageSource: imageSource)
        let viewController = ImageViewerViewController(viewModel: viewModel)
        viewController.view.tag = index

        return viewController
    }
}

extension GalleryViewController: UIPageViewControllerDataSource {

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        imageViewController(forIndex: viewController.view.tag - 1)
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        imageViewController(forIndex: viewController.view.tag + 1)
    }
}

extension GalleryViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        guard completed else { return }

        if previousViewControllers.count > 0 {
            previousViewControllers
                .map { $0 as? ImageViewerViewController }
                .forEach { $0?.reloadImageView() }
        }
    }
}
