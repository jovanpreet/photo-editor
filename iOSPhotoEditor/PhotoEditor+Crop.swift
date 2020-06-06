//
//  PhotoEditor+Crop.swift
//  CropViewController
//
//  Created by Jovanpreet Randhawa on 28/05/20.
//

import UIKit
import CropViewController

extension PhotoEditorViewController: CropViewControllerDelegate {
    
    public func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        self.setImageView(image: image)
        cropViewController.dismiss(animated: true, completion: nil)
    }
    
    public func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        dismiss(animated: true, completion: nil)
    }
}
