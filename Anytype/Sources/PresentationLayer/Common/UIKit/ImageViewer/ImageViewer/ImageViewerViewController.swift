import UIKit
import Combine

final class ImageViewerViewController: UIViewController {
    private struct Constants {
        static let animationDuration = 0.35
        static let minZoomScale = 1.0
        static let maxZoomScale = 3.0
    }

    let viewModel: ImageViewerViewModel
    private var effectiveImageSize: CGSize?

    private lazy var scrollView = UIScrollView(frame: view.bounds)
    private(set) lazy var imageView = UIImageView(frame: scrollView.bounds)
    private lazy var activityIndicator = ActivityIndicatorView(frame: .zero)

    private var cancellables = [AnyCancellable]()

    init(viewModel: ImageViewerViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: .main)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupScrollView()
        setupGestureRecognizer()
        bindViewModel()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        resetScrollView(to: view.bounds.size)
    }

    func reloadImageView() {
        scrollView.zoomScale = Constants.minZoomScale

        calculateEffectiveImageSize()
        if let effectiveImageSize = effectiveImageSize, effectiveImageSize.width > 0, effectiveImageSize.height > 0 {
            imageView.frame = CGRect(x: 0, y: 0, width: effectiveImageSize.width, height: effectiveImageSize.height)
            scrollView.contentSize = effectiveImageSize
        }

        centerImage()
    }

    // MARK: - Private

    private func bindViewModel() {
        viewModel.$image.sink { [weak self] image in
            self?.imageView.image = image
            self?.reloadImageView()
        }.store(in: &cancellables)

        viewModel.$isLoading.sink { [weak self] isLoading in
            isLoading ? self?.activityIndicator.show() : self?.activityIndicator.hide()
        }.store(in: &cancellables)
    }

    private func setupScrollView() {
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false

        scrollView.maximumZoomScale = Constants.maxZoomScale
        scrollView.minimumZoomScale = Constants.minZoomScale

        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.delegate = self
    }

    private func setupUI() {
        view.addSubview(scrollView)

        scrollView.addSubview(imageView)

        view.addSubview(activityIndicator) {
            $0.centerX.equal(to: view.centerXAnchor)
            $0.centerY.equal(to: view.centerYAnchor)
        }
        reloadImageView()
    }

    private func setupGestureRecognizer() {
        let gestureRecognizer = BindableGestureRecognizer { [unowned self] in
            didDoubleTap($0)
        }

        gestureRecognizer.numberOfTouchesRequired = 1
        gestureRecognizer.numberOfTapsRequired = 2

        view.addGestureRecognizer(gestureRecognizer)
    }

    private func resetScrollView(to bounds: CGSize) {
        let oldSize = scrollView.bounds.size

        scrollView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)

        if oldSize != bounds { reloadImageView() }
    }

    private func didDoubleTap(_ sender: UITapGestureRecognizer) {
        guard let effectiveImageSize = effectiveImageSize else { return }

        let tapPointInContainer = sender.location(in: view)
        let scrollViewSize = scrollView.frame.size
        let scaledImageSize = CGSize(width: effectiveImageSize.width * scrollView.zoomScale,
                                     height: effectiveImageSize.height * scrollView.zoomScale)
        let scaledImageRect = CGRect(x: (scrollViewSize.width - scaledImageSize.width) / 2,
                                     y: (scrollViewSize.height - scaledImageSize.height) / 2,
                                     width: scaledImageSize.width,
                                     height: scaledImageSize.height)

        guard scaledImageRect.contains(tapPointInContainer) else {
            return
        }

        if scrollView.zoomScale > scrollView.minimumZoomScale {
            UIView.animate(
                withDuration: Constants.animationDuration,
                delay: 0,
                options: [],
                animations: { [weak self] in
                    guard let self = self else { return }
                    self.scrollView.zoomScale = self.scrollView.minimumZoomScale
                    self.centerImage()
                },
                completion: nil
            )
        } else {
            let width = scrollViewSize.width / scrollView.maximumZoomScale
            let height = scrollViewSize.height / scrollView.maximumZoomScale

            let tapPointInImageView = sender.location(in: imageView)
            let originX = tapPointInImageView.x - (width / 2)
            let originY = tapPointInImageView.y - (height / 2)

            let zoomRect = CGRect(x: originX, y: originY, width: width, height: height)

            UIView.animate(
                withDuration: Constants.animationDuration,
                delay: 0,
                options: [],
                animations: { [weak self] in
                    guard let self = self else { return }
                    self.scrollView.zoom(to: zoomRect.enclose(self.imageView.bounds), animated: false)
                },
                completion: { (_) in
                    self.centerImage()
                }
            )
        }
    }

    private func calculateEffectiveImageSize() {
        guard let imageSize = imageView.image?.size else { return }

        let imageViewSize = scrollView.frame.size
        let widthFactor = imageViewSize.width / imageSize.width
        let heightFactor = imageViewSize.height / imageSize.height
        let scaleFactor = (widthFactor < heightFactor) ? widthFactor : heightFactor

        effectiveImageSize = CGSize(width: scaleFactor * imageSize.width, height: scaleFactor * imageSize.height)
    }

    func centerImage() {
        guard let effectiveImageSize = effectiveImageSize else {
            return
        }

        let scaledImageSize = CGSize(width: effectiveImageSize.width * scrollView.zoomScale,
                                     height: effectiveImageSize.height * scrollView.zoomScale)

        let verticalInset: CGFloat
        let horizontalInset: CGFloat

        if scrollView.frame.size.width > scaledImageSize.width {
            horizontalInset = (scrollView.frame.size.width - scrollView.contentSize.width) / 2
        } else {
            horizontalInset = 0
        }

        if scrollView.frame.size.height > scaledImageSize.height {
            verticalInset = (scrollView.frame.size.height - scrollView.contentSize.height) / 2
        } else {
            verticalInset = 0
        }

        scrollView.contentInset = UIEdgeInsets(top: verticalInset, left: horizontalInset, bottom: verticalInset, right: horizontalInset)
    }
}

extension ImageViewerViewController: UIScrollViewDelegate {

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImage()
    }

    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        UIView.animate(withDuration: Constants.animationDuration, animations: {
            self.centerImage()
        })
    }
}

extension CGRect {
    func enclose(_ surroundingRect: CGRect) -> CGRect {
        guard surroundingRect.width > width && surroundingRect.height > height else {
            return self
        }

        var enclosedRect = self

        if enclosedRect.origin.x < surroundingRect.origin.x {
            enclosedRect.origin.x = surroundingRect.origin.x
        }
        if enclosedRect.origin.y < surroundingRect.origin.y {
            enclosedRect.origin.y = surroundingRect.origin.y
        }

        if maxX > surroundingRect.maxX {
            enclosedRect.origin.x -= (maxX - surroundingRect.maxX)
        }
        if maxY > surroundingRect.maxY {
            enclosedRect.origin.y -= (maxY - surroundingRect.maxY)
        }

        return enclosedRect
    }
}
