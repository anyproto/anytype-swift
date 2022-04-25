import UIKit

final class GalleryViewController: UIViewController {

    private struct Constants {
        static let spacingBetweenImages: CGFloat = 40
    }

    // MARK: - Properties

    private let viewModel: GalleryViewModel
    private let pageViewController: UIPageViewController
    private let transitionViewController = GalleryViewTransitionController()

    init(
        viewModel: GalleryViewModel,
        initialImageView: UIImageView? = nil
    ) {
        self.viewModel = viewModel
        pageViewController = UIPageViewController(transitionStyle: .scroll,
                                                  navigationOrientation: .horizontal,
                                                  options: [UIPageViewController.OptionsKey.interPageSpacing : Constants.spacingBetweenImages])
        super.init(nibName: nil, bundle: nil)

        setupPageViewController()

        initialImageView.map(setupTransitionViewController)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Override functions

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()

        setupPanGestureRecognizer()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { (_) in
            self.pageViewController.view.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        }, completion: nil)
    }

    // MARK: - Private functions

    private func setupUI() {
        view.backgroundColor = UIColor.black

        embedChild(pageViewController, into: view)
    }

    private func setupTransitionViewController(with initialImageView: UIImageView) {
        modalPresentationStyle = .overFullScreen
        transitioningDelegate = transitionViewController
        transitionViewController.galleryViewController = self
        transitionViewController.imageViewerImageView = { [weak self] in
            guard let viewControllers = self?.pageViewController.viewControllers, viewControllers.count == 1 else {
                return nil
            }

            return (viewControllers.first as? ImageViewerViewController)?.imageView
        }

        transitionViewController.presenterImageView = initialImageView
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

    private func imageViewController(forIndex index: Int) -> ImageViewerViewController? {
        guard let item = viewModel.items[safe: index] else { return nil }

        let viewModel = ImageViewerViewModel(item: item)
        let viewController = ImageViewerViewController(viewModel: viewModel)

        return viewController
    }

    private func setupPanGestureRecognizer() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(GalleryViewController.didPan(_:)))
        panGestureRecognizer.maximumNumberOfTouches = 1

        view.addGestureRecognizer(panGestureRecognizer)
    }

    @objc private func didPan(_ sender: UIPanGestureRecognizer) {
        transitionViewController.didPan(withGestureRecognizer: sender, sourceView: view)
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
