//
//  ViewController.swift
//  Photo Editor
//
//  Created by Mohamed Hamed on 4/23/17.
//  Copyright © 2017 Mohamed Hamed. All rights reserved.
//

import UIKit

public class PhotoEditorViewController: UIViewController {
    
    /** holding the 2 imageViews original image and drawing & stickers */
//    @IBOutlet weak var canvasView: UIView!
//    //To hold the image
//    @IBOutlet var imageView: UIImageView!
//    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
//    //To hold the drawings and stickers
//    @IBOutlet weak var canvasImageView: UIImageView!
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var mainStackView: UIStackView!
    
    @IBOutlet weak var topToolbar: UIView!
    @IBOutlet weak var bottomToolbar: UIView!

    @IBOutlet weak var topGradient: UIView!
    @IBOutlet weak var bottomGradient: UIView!
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var deleteView: UIView!
    @IBOutlet weak var colorsCollectionView: UICollectionView!
    @IBOutlet weak var colorPickerView: UIView!
    @IBOutlet weak var colorPickerViewBottomConstraint: NSLayoutConstraint!
    
    //Controls
    @IBOutlet weak var cropButton: UIButton!
    @IBOutlet weak var stickerButton: UIButton!
    @IBOutlet weak var drawButton: UIButton!
    @IBOutlet weak var textButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    
    public var originalImage = [UIImage]()
    var processedImage = [UIImage]()
    var canvasViews = [UIView]()
    var imageViews = [UIImageView]()
    var canvasImageViews = [UIImageView]()
    var canvasWidthConstraints = [NSLayoutConstraint]()
    var canvasHeightConstraints = [NSLayoutConstraint]()
    var activeIndex = 0
    /**
     Array of Stickers -UIImage- that the user will choose from
     */
    public var stickers : [UIImage] = []
    /**
     Array of Colors that will show while drawing or typing
     */
    public var colors  : [UIColor] = []
    
    public var photoEditorDelegate: PhotoEditorDelegate?
    var colorsCollectionViewDelegate: ColorsCollectionViewDelegate!
    
    // list of controls to be hidden
    public var hiddenControls : [control] = []
    
    var stickersVCIsVisible = false
    var drawColor: UIColor = UIColor.black
    var textColor: UIColor = UIColor.white
    var isDrawing: Bool = false
    var lastPoint: CGPoint!
    var swiped = false
    var lastPanPoint: CGPoint?
    var lastTextViewTransform: CGAffineTransform?
    var lastTextViewTransCenter: CGPoint?
    var lastTextViewFont:UIFont?
    var activeTextView: UITextView?
    var imageViewToPan: UIImageView?
    var isTyping: Bool = false
    
    
    var stickersViewController: StickersViewController!

    //Register Custom font before we load XIB
    public override func loadView() {
        registerFont()
        super.loadView()
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        guard !originalImage.isEmpty else { preconditionFailure("need to pass atleast 1 image") }
        let viewSize = getActualViewSize()
        processedImage = originalImage
        for image in processedImage {
            let canvasView = UIView()
            canvasView.translatesAutoresizingMaskIntoConstraints = false
            let imageView = UIImageView(image: image)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.contentMode = .scaleAspectFit
            imageViews.append(imageView)
            canvasView.addSubview(imageView)
            let canvasImageView = UIImageView()
            canvasImageView.contentMode = .scaleAspectFill
            canvasImageView.translatesAutoresizingMaskIntoConstraints = false
            canvasImageView.isUserInteractionEnabled = true
            canvasImageViews.append(canvasImageView)
            canvasView.addSubview(canvasImageView)
            canvasViews.append(canvasView)
            let containerView = UIView()
            containerView.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(canvasView)
            mainStackView.addArrangedSubview(containerView)
            let canvasSize = getCanvasSize(image: image, viewSize: viewSize)
            let canvasWidthConstraint = canvasView.widthAnchor.constraint(equalToConstant: canvasSize.width)
            let canvasHeightConstraint = canvasView.heightAnchor.constraint(equalToConstant: canvasSize.height)
            NSLayoutConstraint.activate([
                containerView.widthAnchor.constraint(equalToConstant: viewSize.width),
                containerView.heightAnchor.constraint(equalToConstant: viewSize.height),
                canvasView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                canvasView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
                canvasWidthConstraint,
                canvasHeightConstraint,
                imageView.leadingAnchor.constraint(equalTo: canvasView.leadingAnchor),
                imageView.trailingAnchor.constraint(equalTo: canvasView.trailingAnchor),
                imageView.topAnchor.constraint(equalTo: canvasView.topAnchor),
                imageView.bottomAnchor.constraint(equalTo: canvasView.bottomAnchor),
                canvasImageView.leadingAnchor.constraint(equalTo: canvasView.leadingAnchor),
                canvasImageView.trailingAnchor.constraint(equalTo: canvasView.trailingAnchor),
                canvasImageView.topAnchor.constraint(equalTo: canvasView.topAnchor),
                canvasImageView.bottomAnchor.constraint(equalTo: canvasView.bottomAnchor)
            ])
            canvasWidthConstraints.append(canvasWidthConstraint)
            canvasHeightConstraints.append(canvasHeightConstraint)
        }
//        self.setImageView(image: image!)
        
        deleteView.layer.cornerRadius = deleteView.bounds.height / 2
        deleteView.layer.borderWidth = 2.0
        deleteView.layer.borderColor = UIColor.white.cgColor
        deleteView.clipsToBounds = true
        
        let edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(screenEdgeSwiped))
        edgePan.edges = .bottom
        edgePan.delegate = self
        self.view.addGestureRecognizer(edgePan)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow),
                                               name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(keyboardWillChangeFrame(_:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        
        configureCollectionView()
        stickersViewController = StickersViewController(nibName: "StickersViewController", bundle: Bundle(for: StickersViewController.self))
        hideControls()
    }
    
    func getActualViewSize() -> CGSize {
        var width = UIScreen.main.bounds.width
        var height = UIScreen.main.bounds.height
        if #available(iOS 11.0, *), let safeAreaInsets = UIApplication.shared.keyWindow?.safeAreaInsets {
            width -= safeAreaInsets.left + safeAreaInsets.right
            height -= safeAreaInsets.top + safeAreaInsets.bottom
        }
        return CGSize(width: width, height: height)
    }
    
    func getCanvasSize(image: UIImage, viewSize: CGSize) -> CGSize {
        let ratio = image.size.width/image.size.height
        let canvasWidth: CGFloat
        let canvasHeight: CGFloat
        if viewSize.width/ratio <= viewSize.height {
            canvasWidth = viewSize.width
            canvasHeight = viewSize.width/ratio
        }else {
            canvasHeight = viewSize.height
            canvasWidth = viewSize.height*ratio
        }
        return CGSize(width: canvasWidth, height: canvasHeight)
    }
    
    func configureCollectionView() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 30, height: 30)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        colorsCollectionView.collectionViewLayout = layout
        colorsCollectionViewDelegate = ColorsCollectionViewDelegate()
        colorsCollectionViewDelegate.colorDelegate = self
        if !colors.isEmpty {
            colorsCollectionViewDelegate.colors = colors
        }
        colorsCollectionView.delegate = colorsCollectionViewDelegate
        colorsCollectionView.dataSource = colorsCollectionViewDelegate
        
        colorsCollectionView.register(
            UINib(nibName: "ColorCollectionViewCell", bundle: Bundle(for: ColorCollectionViewCell.self)),
            forCellWithReuseIdentifier: "ColorCollectionViewCell")
    }
    
    func setImageView(image: UIImage) {
        imageViews[activeIndex].image = image
        let canvasSize = getCanvasSize(image: image, viewSize: getActualViewSize())
        canvasWidthConstraints[activeIndex].constant = canvasSize.width
        canvasHeightConstraints[activeIndex].constant = canvasSize.height
    }
    
    func hideToolbar(hide: Bool) {
        topToolbar.isHidden = hide
        topGradient.isHidden = hide
        bottomToolbar.isHidden = hide
        bottomGradient.isHidden = hide
    }
}

extension PhotoEditorViewController: ColorDelegate {
    func didSelectColor(color: UIColor) {
        if isDrawing {
            self.drawColor = color
        } else if activeTextView != nil {
            activeTextView?.textColor = color
            textColor = color
        }
    }
}

extension PhotoEditorViewController: UIScrollViewDelegate {
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.size.width
        activeIndex = Int((scrollView.contentOffset.x + pageWidth / 2) / pageWidth)
    }
}
