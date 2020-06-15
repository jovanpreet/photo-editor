//
//  PhotoEditor+Font.swift
//
//
//  Created by Mohamed Hamed on 6/16/17.
//
//

import Foundation
import UIKit

extension PhotoEditorViewController {
    
    func registerFont() {
        guard let bundleURL = Bundle(for: PhotoEditorViewController.self).resourceURL?.appendingPathComponent("iOSPhotoEditor.bundle"), let bundle = Bundle(url: bundleURL), let url =  bundle.url(forResource: "icomoon", withExtension: "ttf"), let fontDataProvider = CGDataProvider(url: url as CFURL) else { return }
            guard let font = CGFont(fontDataProvider) else {return}
            var error: Unmanaged<CFError>?
            guard CTFontManagerRegisterGraphicsFont(font, &error) else { return }
    }
}
