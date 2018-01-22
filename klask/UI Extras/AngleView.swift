//
//  AngleView.swift
//  klask
//
//  Created by Joel Whitney on 1/13/18.
//  Copyright © 2018 JoelWhitney. All rights reserved.
//

import UIKit

@IBDesignable
class AngleView: UIView {
    
    @IBInspectable var fillColor: UIColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) {
        didSet {
            layoutIfNeeded()
        }
    }
    
    var linePoints = [
        CGPoint(x: 1, y: 0),
        CGPoint(x: 1, y: 0),
        CGPoint(x: 1, y: 0.40),
        CGPoint(x: 0, y: 0.60),
        CGPoint(x: 0, y: 0.598),
        CGPoint(x: 1, y: 0.398),
        ] { didSet { setNeedsLayout() } }
    
    var points = [
        CGPoint.zero,
        CGPoint(x: 1, y: 0),
        CGPoint(x: 1, y: 0.40),
        CGPoint(x: 0, y: 0.60)
        ] { didSet { setNeedsLayout() } }
    
    lazy var shapeLayer: CAShapeLayer = {
        let _shapeLayer = CAShapeLayer()
        self.layer.insertSublayer(_shapeLayer, at: 0)
        return _shapeLayer
    }()
    
    lazy var lineLayer: CAShapeLayer = {
        let _lineLayer = CAShapeLayer()
        self.layer.insertSublayer(_lineLayer, at: 0)
        return _lineLayer
    }()
    
    func setColor(color: UIColor, onComplete: () -> Void) {
        self.layoutSubviews()
        onComplete()
    }
    
    override func layoutSubviews() {
        lineLayer.fillColor = #colorLiteral(red: 0.1484079361, green: 0.108229287, blue: 0.1866647303, alpha: 1)
        shapeLayer.fillColor = fillColor.cgColor
        guard points.count > 2 else {
            shapeLayer.path = nil
            return
        }
        
        let path = UIBezierPath()
        
        path.move(to: convert(relativePoint: points[0]))
        for point in points.dropFirst() {
            path.addLine(to: convert(relativePoint: point))
        }
        path.close()
        
        shapeLayer.path = path.cgPath
        
        let linePath = UIBezierPath()
        
        linePath.move(to: convert(relativePoint: linePoints[0]))
        for point in linePoints.dropFirst() {
            linePath.addLine(to: convert(relativePoint: point))
        }
        linePath.close()
        
        lineLayer.path = linePath.cgPath
    }
    
    private func convert(relativePoint point: CGPoint) -> CGPoint {
        return CGPoint(x: point.x * bounds.width + bounds.origin.x, y: point.y * bounds.height + bounds.origin.y)
    }
}
