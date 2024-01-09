//
//  CALayerDSL.swift
//  Pods
//
//  Created by 朱继超 on 2020/12/31.
//

import Foundation
import QuartzCore

/**
     A DSL for setting common properties of a CALayer instance.
     
     - Returns: The modified CALayer instance.
     */
public extension CALayer {
    
    @discardableResult
    func bounds(_ rect: CGRect) -> Self {
        let layer = self
        layer.bounds = rect
        return self
    }
    
    @discardableResult
    func position(_ point: CGPoint) -> Self {
        let layer = self
        layer.position = point
        return self
    }
    
    @discardableResult
    func zPosition(_ position: CGFloat) -> Self {
        let layer = self
        layer.zPosition = position
        return self
    }
    
    @discardableResult
    func anchorPoint(_ point: CGPoint) -> Self {
        let layer = self
        layer.anchorPoint = point
        return self
    }
    
    @discardableResult
    func anchorPointZ(_ position: CGFloat) -> Self {
        let layer = self
        layer.anchorPointZ = position
        return self
    }
    
    @discardableResult
    func transform(_ form: CATransform3D) -> Self {
        let layer = self
        layer.transform = form
        return self
    }
    
    @discardableResult
    func frame(_ rect: CGRect) -> Self {
        let layer = self
        layer.frame = rect
        return self
    }
    
    @discardableResult
    func hidden(_ hidden: Bool) -> Self {
        let layer = self
        layer.isHidden = hidden
        return self
    }
    
    @discardableResult
    func doubleSided(_ doubleSided: Bool) -> Self {
        let layer = self
        layer.isDoubleSided = doubleSided
        return self
    }
    
    @discardableResult
    func geometryFlipped(_ geometryFlipped: Bool) -> Self {
        let layer = self
        layer.isGeometryFlipped = geometryFlipped
        return self
    }
    
    @discardableResult
    func sublayers(_ layers: [CALayer]) -> Self {
        let layer = self
        layer.sublayers = layers
        return self
    }
    
    @discardableResult
    func addSublayers(_ layers: [CALayer]) -> Self {
        let layer = self
        layer.sublayers = layers
        return self
    }
    
    @discardableResult
    func mask(_ maskLayer: CALayer) -> Self {
        let layer = self
        layer.mask = maskLayer
        return self
    }
    
    @discardableResult
    func masksToBounds(_ mask: Bool) -> Self {
        let layer = self
        layer.masksToBounds = mask
        return self
    }
    
    @discardableResult
    func contents(_ content: Any?) -> Self {
        let layer = self
        layer.contents = content
        return self
    }
    
    @discardableResult
    func contentsRect(_ rect: CGRect) -> Self {
        let layer = self
        layer.contentsRect = rect
        return self
    }
    
    @discardableResult
    func contentsGravity(_ gravity: CALayerContentsGravity) -> Self {
        let layer = self
        layer.contentsGravity = gravity
        return self
    }
    
    @discardableResult
    func contentsScale(_ scale: CGFloat) -> Self {
        let layer = self
        layer.contentsScale = scale
        return self
    }
    
    @discardableResult
    func contentsCenter(_ rect: CGRect) -> Self {
        let layer = self
        layer.contentsCenter = rect
        return self
    }
    
    @discardableResult
    func contentsFormat(_ format: CALayerContentsFormat) -> Self {
        let layer = self
        if #available(iOS 10.0, *) {
            layer.contentsFormat = format
        }
        return self
    }
    
    @discardableResult
    func minificationFilter(_ filter: CALayerContentsFilter) -> Self {
        let layer = self
        layer.minificationFilter = filter
        return self
    }
    
    @discardableResult
    func magnificationFilter(_ filter: CALayerContentsFilter) -> Self {
        let layer = self
        layer.magnificationFilter = filter
        return self
    }
    
    @discardableResult
    func minificationFilterBias(_ filterBias: Float) -> Self {
        let layer = self
        layer.minificationFilterBias = filterBias
        return self
    }
    
    @discardableResult
    func isOpaque(_ opaque: Bool) -> Self {
        let layer = self
        layer.isOpaque = opaque
        return self
    }
    
    @discardableResult
    func needsDisplayOnBoundsChange(_ change: Bool) -> Self {
        let layer = self
        layer.needsDisplayOnBoundsChange = change
        return self
    }
    
    @discardableResult
    func drawsAsynchronously(_ isAsync: Bool) -> Self {
        let layer = self
        layer.drawsAsynchronously = isAsync
        return self
    }
    
    @discardableResult
    func edgeAntialiasingMask(_ mask: CAEdgeAntialiasingMask) -> Self {
        let layer = self
        layer.edgeAntialiasingMask = mask
        return self
    }
    
    @discardableResult
    func allowsEdgeAntialiasing(_ allow: Bool) -> Self {
        let layer = self
        layer.allowsEdgeAntialiasing = allow
        return self
    }
    
    @discardableResult
    func backgroundColor(_ color: CGColor?) -> Self {
        let layer = self
        layer.backgroundColor = color
        return self
    }
    
    @discardableResult
    func cornerRadius(_ radius: CGFloat) -> Self {
        let layer = self
        layer.cornerRadius = radius
        return self
    }
    
    @available(iOS 11.0,*)
    @discardableResult
    func maskedCorners(_ corners: CACornerMask) -> Self {
        let layer = self
        layer.maskedCorners = corners
        return self
    }
    
    @available(iOS 13.0,*)
    @discardableResult
    func cornerCurve(_ curve: CALayerCornerCurve) -> Self {
        let layer = self
        layer.cornerCurve = curve
        return self
    }
    
    @discardableResult
    func borderWidth(_ width: CGFloat) -> Self {
        let layer = self
        layer.borderWidth = width
        return self
    }
    
    @discardableResult
    func borderColor(_ color: CGColor?) -> Self {
        let layer = self
        layer.borderColor = color
        return self
    }
    
    @discardableResult
    func opacity(_ alpha: Float) -> Self {
        let layer = self
        layer.opacity = alpha
        return self
    }
    
    @discardableResult
    func allowsGroupOpacity(_ allow: Bool) -> Self {
        let layer = self
        layer.allowsGroupOpacity = allow
        return self
    }
    
    @discardableResult
    func compositingFilter(_ filter: Any?) -> Self {
        let layer = self
        layer.compositingFilter = filter
        return self
    }
    
    @discardableResult
    func filters(_ array: [Any]?) -> Self {
        let layer = self
        layer.filters = array
        return self
    }
    
    @discardableResult
    func backgroundFilters(_ array: [Any]?) -> Self {
        let layer = self
        layer.backgroundFilters = array
        return self
    }
    
    @discardableResult
    func shouldRasterize(_ should: Bool) -> Self {
        let layer = self
        layer.shouldRasterize = should
        return self
    }
    
    @discardableResult
    func rasterizationScale(_ scale: CGFloat) -> Self {
        let layer = self
        layer.rasterizationScale = scale
        return self
    }
    
    @discardableResult
    func shadowColor(_ color: CGColor?) -> Self {
        let layer = self
        layer.shadowColor = color
        return self
    }
    
    @discardableResult
    func shadowOpacity(_ opacity: Float) -> Self {
        let layer = self
        layer.shadowOpacity = opacity
        return self
    }
    
    @discardableResult
    func shadowOffset(_ offset: CGSize) -> Self {
        let layer = self
        layer.shadowOffset = offset
        return self
    }
    
    @discardableResult
    func shadowPath(_ path: CGPath?) -> Self {
        let layer = self
        layer.shadowPath = path
        return self
    }
    
    @discardableResult
    func name(_ text: String?) -> Self {
        let layer = self
        layer.name = text
        return self
    }
    
    @discardableResult
    func delegate(_ del: CALayerDelegate?) -> Self {
        let layer = self
        layer.delegate = del
        return self
    }
    
    @discardableResult
    func style(_ dic: [AnyHashable : Any]?) -> Self {
        let layer = self
        layer.style = dic
        return self
    }
}


public extension CAShapeLayer {
    
    @discardableResult
    func path(_ p: CGPath?) -> Self {
        let layer = self
        layer.path = p
        return layer
    }
    
    @discardableResult
    func fillColor(_ color: CGColor?) -> Self {
        let layer = self
        layer.fillColor = color
        return layer
    }
    
    @discardableResult
    func fillRule(_ rule: CAShapeLayerFillRule) -> Self {
        let layer = self
        layer.fillRule = rule
        return layer
    }
    
    @discardableResult
    func strokeColor(_ color: CGColor?) -> Self {
        let layer = self
        layer.strokeColor = color
        return layer
    }
    
    @discardableResult
    func strokeStart(_ point: CGFloat) -> Self {
        let layer = self
        layer.strokeStart = point
        return layer
    }
    
    @discardableResult
    func strokeEnd(_ point: CGFloat) -> Self {
        let layer = self
        layer.strokeEnd = point
        return layer
    }
    
    @discardableResult
    func lineWidth(_ width: CGFloat) -> Self {
        let layer = self
        layer.lineWidth = width
        return layer
    }
    
    @discardableResult
    func miterLimit(_ limit: CGFloat) -> Self {
        let layer = self
        layer.miterLimit = limit
        return layer
    }
    
    @discardableResult
    func lineCap(_ cap: CAShapeLayerLineCap) -> Self {
        let layer = self
        layer.lineCap = cap
        return layer
    }
    
    @discardableResult
    func lineJoin(_ join: CAShapeLayerLineJoin) -> Self {
        let layer = self
        layer.lineJoin = join
        return layer
    }
    
    @discardableResult
    func lineDashPhase(_ phase: CGFloat) -> Self {
        let layer = self
        layer.lineDashPhase = phase
        return layer
    }
    
    @discardableResult
    func lineDashPattern(_ patterns: [NSNumber]?) -> Self {
        let layer = self
        layer.lineDashPattern = patterns
        return layer
    }
}

public extension CAGradientLayer {
    @discardableResult
    func colors(_ colors: [Any]?) -> Self {
        let layer = self
        layer.colors = colors
        return layer
    }
    
    @discardableResult
    func locations(_ locations: [NSNumber]?) -> Self {
        let layer = self
        layer.locations = locations
        return layer
    }
    
    @discardableResult
    func startPoint(_ point: CGPoint) -> Self {
        let layer = self
        layer.startPoint = point
        return layer
    }
    
    @discardableResult
    func endPoint(_ point: CGPoint) -> Self {
        let layer = self
        layer.endPoint = point
        return layer
    }
    
    @discardableResult
    func type(_ type: CAGradientLayerType) -> Self {
        let layer = self
        layer.type = type
        return layer
    }
}
