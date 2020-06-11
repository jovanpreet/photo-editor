//
//  PhotoEditor+UITextView.swift
//  Pods
//
//  Created by Mohamed Hamed on 6/16/17.
//
//

import Foundation
import UIKit

extension PhotoEditorViewController: UITextViewDelegate {
    
    public func textViewDidChange(_ textView: UITextView) {
        let rotation = atan2(textView.transform.b, textView.transform.a)
        if rotation == 0 {
            let oldFrame = textView.frame
            let sizeToFit = textView.sizeThatFits(CGSize(width: oldFrame.width, height:CGFloat.greatestFiniteMagnitude))
            textView.frame.size = CGSize(width: oldFrame.width, height: sizeToFit.height)
        }
    }
    
    public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        updateGeatureState(textView: textView, state: false)
        lastTextViewTransform =  textView.transform
        lastTextViewTransCenter = textView.center
        lastTextViewFont = textView.font
        activeTextView = textView
        mainScrollView.isUserInteractionEnabled = false
        if let window = UIApplication.shared.keyWindow {
            textView.frame.origin = textView.convert(.zero, to: self.view)
            textView.removeFromSuperview()
            window.addSubview(textView)
        }
        return true
    }
    
    
    public func textViewDidBeginEditing(_ textView: UITextView) {
        isTyping = true
        textView.font = .systemFont(ofSize: 30)
        textView.bounds.size = CGSize(width: canvasWidthConstraints[activeIndex].constant, height: textView.sizeThatFits(CGSize(width: canvasWidthConstraints[activeIndex].constant, height: .greatestFiniteMagnitude)).height)
        UIView.animate(withDuration: 0.3, animations: {
            textView.transform = CGAffineTransform.identity
            textView.center = CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/5)
            self.mainScrollView.alpha = 0.5
        }, completion: nil)
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        guard textView == activeTextView else { return }
        textView.frame.origin = textView.convert(.zero, to: canvasImageViews[activeIndex])
        textView.removeFromSuperview()
        canvasImageViews[activeIndex].addSubview(textView)
        updateGeatureState(textView: textView, state: true)
        textView.font = self.lastTextViewFont
        textView.bounds.size = textView.sizeThatFits(CGSize(width: self.canvasWidthConstraints[self.activeIndex].constant, height: .greatestFiniteMagnitude))
        UIView.animate(withDuration: 0.3, animations: {
            if let lastTextViewTransform = self.lastTextViewTransform, let lastTextViewTransCenter = self.lastTextViewTransCenter {
                textView.transform = lastTextViewTransform
                textView.center = lastTextViewTransCenter
            }
            self.mainScrollView.alpha = 1
        }, completion: { _ in
            self.activeTextView = nil
            self.lastTextViewFont = nil
            self.lastTextViewTransform = nil
            self.lastTextViewTransCenter = nil
        })
    }
    
    func updateGeatureState(textView: UITextView, state: Bool) {
        if let gestureRecognizers = textView.gestureRecognizers {
            for gesture in gestureRecognizers {
                if gesture is UIPanGestureRecognizer || gesture is  UIPinchGestureRecognizer {
                    gesture.isEnabled = state
                }
            }
        }
    }
}
