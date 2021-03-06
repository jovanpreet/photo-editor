//
//  PhotoEditor+Drawing.swift
//  Photo Editor
//
//  Created by Mohamed Hamed on 6/16/17.
//
//
import UIKit

extension PhotoEditorViewController {
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isDrawing {
            swiped = false
            if let touch = touches.first { lastPoint = touch.location(in: self.canvasImageViews[activeIndex]) }
        }else if stickersVCIsVisible == true {
            if let touch = touches.first {
                let location = touch.location(in: self.view)
                if !stickersViewController.view.frame.contains(location) { removeStickersView() }
            }
        }
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?){
        if isDrawing {
            swiped = true
            if let touch = touches.first {
                let currentPoint = touch.location(in: canvasImageViews[activeIndex])
                drawLineFrom(lastPoint, toPoint: currentPoint)
                lastPoint = currentPoint
            }
        }
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?){
        if isDrawing {
            if !swiped { drawLineFrom(lastPoint, toPoint: lastPoint) }
        }
    }
    
    func drawLineFrom(_ fromPoint: CGPoint, toPoint: CGPoint) {
        let canvasImageView = canvasImageViews[activeIndex]
        let canvasSize = canvasImageView.frame.integral.size
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, 0)
        if let context = UIGraphicsGetCurrentContext() {
            canvasImageView.image?.draw(in: CGRect(x: 0, y: 0, width: canvasSize.width, height: canvasSize.height))
            context.move(to: CGPoint(x: fromPoint.x, y: fromPoint.y))
            context.addLine(to: CGPoint(x: toPoint.x, y: toPoint.y))
            context.setLineCap( CGLineCap.round)
            context.setLineWidth(5.0)
            context.setStrokeColor(drawColor.cgColor)
            context.setBlendMode( CGBlendMode.normal)
            context.strokePath()
            canvasImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        }
        UIGraphicsEndImageContext()
    }
    
}
