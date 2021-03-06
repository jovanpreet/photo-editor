//
//  PhotoEditor+Controls.swift
//  Pods
//
//  Created by Mohamed Hamed on 6/16/17.
//
//

import Foundation
import UIKit
import CropViewController

// MARK: - Control
public enum control {
    case crop
    case sticker
    case draw
    case text
    case clear
}

extension PhotoEditorViewController {

     //MARK: Top Toolbar
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        photoEditorDelegate?.canceledEditing()
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func cropButtonTapped(_ sender: UIButton) {
        let image = originalImage[activeIndex]// else { return }
        let controller = CropViewController(image: image)
        controller.aspectRatioLockDimensionSwapEnabled = true
        controller.delegate = self
        present(controller, animated: true, completion: nil)
    }

    @IBAction func stickersButtonTapped(_ sender: Any) {
        addStickersViewController()
    }

    @IBAction func drawButtonTapped(_ sender: Any) {
        isDrawing = true
        mainScrollView.isUserInteractionEnabled = false
        doneButton.isHidden = false
        colorPickerView.isHidden = false
        hideToolbar(hide: true)
    }

    @IBAction func textButtonTapped(_ sender: Any) {
        isTyping = true
        let textView = UITextView(frame: CGRect(x: 0, y: canvasImageViews[activeIndex].center.y-25, width: canvasWidthConstraints[activeIndex].constant, height: 50))
        textView.textAlignment = .center
        textView.font = .systemFont(ofSize: 30)
        textView.textColor = textColor
        textView.layer.shadowColor = UIColor.black.cgColor
        textView.layer.shadowOffset = CGSize(width: 1, height: 0)
        textView.layer.shadowOpacity = 0.2
        textView.layer.shadowRadius = 1.0
        textView.layer.backgroundColor = UIColor.clear.cgColor
        textView.isScrollEnabled = false
        textView.delegate = self
        self.canvasImageViews[activeIndex].addSubview(textView)
        addGestures(view: textView)
        textView.becomeFirstResponder()
    }    
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        if let textView = activeTextView { textView.resignFirstResponder() }
        mainScrollView.isUserInteractionEnabled = true
        doneButton.isHidden = true
        colorPickerView.isHidden = true
        hideToolbar(hide: false)
        isDrawing = false
    }
    
    //MARK: Bottom Toolbar
    
    @IBAction func clearButtonTapped(_ sender: AnyObject) {
        let canvasImageView = canvasImageViews[activeIndex]
        canvasImageView.image = nil
        for subview in canvasImageView.subviews { subview.removeFromSuperview() }
    }
    
    @IBAction func continueButtonPressed(_ sender: Any) {
        var images = [UIImage]()
        for canvasView in canvasViews { images.append(canvasView.toImage()) }
        photoEditorDelegate?.doneEditing(images: images)
        self.dismiss(animated: true, completion: nil)
    }

    //MAKR: helper methods
    
    @objc func image(_ image: UIImage, withPotentialError error: NSErrorPointer, contextInfo: UnsafeRawPointer) {
        let alert = UIAlertController(title: "Image Saved", message: "Image successfully saved to Photos library", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func hideControls() {
        for control in hiddenControls {
            switch control {
                
            case .clear:
                clearButton.isHidden = true
            case .crop:
                cropButton.isHidden = true
            case .draw:
                drawButton.isHidden = true
            case .sticker:
                stickerButton.isHidden = true
            case .text:
                stickerButton.isHidden = true
            }
        }
    }
    
}
