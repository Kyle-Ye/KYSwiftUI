//
//  UnevenRoundedRectangle.swift
//
//
//  Created by Kyle on 2024/7/24.
//

import SwiftUI

@frozen
public struct RectangleCornerRadii: Equatable, Animatable {
    /// The radius of the top-leading corner.
    public var topLeading: CGFloat

    /// The radius of the bottom-leading corner.
    public var bottomLeading: CGFloat

    /// The radius of the bottom-trailing corner.
    public var bottomTrailing: CGFloat

    /// The radius of the top-trailing corner.
    public var topTrailing: CGFloat

    /// Creates a new set of corner radii for a rounded rectangle with
    /// uneven corners.
    ///
    /// - Parameters:
    ///   - topLeading: the radius of the top-leading corner.
    ///   - bottomLeading: the radius of the bottom-leading corner.
    ///   - bottomTrailing: the radius of the bottom-trailing corner.
    ///   - topTrailing: the radius of the top-trailing corner.
    public init(topLeading: CGFloat = 0, bottomLeading: CGFloat = 0, bottomTrailing: CGFloat = 0, topTrailing: CGFloat = 0) {
        self.topLeading = topLeading
        self.bottomLeading = bottomLeading
        self.bottomTrailing = bottomTrailing
        self.topTrailing = topTrailing
    }

    public typealias AnimatableData = AnimatablePair<AnimatablePair<CGFloat, CGFloat>, AnimatablePair<CGFloat, CGFloat>>

    /// The data to animate.
    public var animatableData: RectangleCornerRadii.AnimatableData {
        get {
            AnimatablePair(AnimatablePair(topLeading, bottomLeading), AnimatablePair(bottomTrailing, topTrailing))
        }
        set {
            topLeading = newValue.first.first
            bottomLeading = newValue.first.second
            bottomTrailing = newValue.second.first
            topTrailing = newValue.second.second
        }
    }
    
    mutating func inset(amount: Double) {
        topLeading = max(0, topLeading - CGFloat(amount))
        bottomLeading = max(0, bottomLeading - CGFloat(amount))
        bottomTrailing = max(0, bottomTrailing - CGFloat(amount))
        topTrailing = max(0, topTrailing - CGFloat(amount))
    }
}

public struct UnevenRoundedRectangle: Shape {
    /// The radii of each corner of the rounded rectangle.
    public var cornerRadii: RectangleCornerRadii

    /// The style of corners drawn by the rounded rectangle.
    public var style: RoundedCornerStyle

    /// Creates a new rounded rectangle shape with uneven corners.
    ///
    /// - Parameters:
    ///   - cornerRadii: the radii of each corner.
    ///   - style: the style of corners drawn by the shape.
    @inlinable
    public init(cornerRadii: RectangleCornerRadii, style: RoundedCornerStyle = .continuous) {
        self.cornerRadii = cornerRadii
        self.style = style
    }

    /// Creates a new rounded rectangle shape with uneven corners.
    public init(topLeadingRadius: CGFloat = 0, bottomLeadingRadius: CGFloat = 0, bottomTrailingRadius: CGFloat = 0, topTrailingRadius: CGFloat = 0, style: RoundedCornerStyle = .continuous) {
        self.init(
            cornerRadii: .init(
                topLeading: topLeadingRadius,
                bottomLeading: bottomLeadingRadius,
                bottomTrailing: bottomTrailingRadius,
                topTrailing: topTrailingRadius
            ),
            style: style
        )
    }

    /// Describes this shape as a path within a rectangular frame of reference.
    ///
    /// - Parameter rect: The frame of reference for describing this shape.
    ///
    /// - Returns: A path that describes this shape.
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let tl = cornerRadii.topLeading
        let tr = cornerRadii.topTrailing
        let bl = cornerRadii.bottomLeading
        let br = cornerRadii.bottomTrailing
        path.move(to: CGPoint(x: rect.origin.x + tl, y: rect.origin.y))
        path.addLine(to: CGPoint(x: rect.origin.x + width - tr, y: rect.origin.y))
        path.addArc(center: CGPoint(x: rect.origin.x + width - tr, y: rect.origin.y + tr), radius: tr, startAngle: Angle(degrees: 270), endAngle: Angle(degrees: 360), clockwise: false)
        path.addLine(to: CGPoint(x: rect.origin.x + width, y: rect.origin.y + height - br))
        path.addArc(center: CGPoint(x: rect.origin.x + width - br, y: rect.origin.y + height - br), radius: br, startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)
        path.addLine(to: CGPoint(x: rect.origin.x + bl, y: rect.origin.y + height))
        path.addArc(center: CGPoint(x: rect.origin.x + bl, y: rect.origin.y + height - bl), radius: bl, startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)
        path.addLine(to: CGPoint(x: rect.origin.x, y: rect.origin.y + tl))
        path.addArc(center: CGPoint(x: rect.origin.x + tl, y: rect.origin.y + tl), radius: tl, startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)
        path.closeSubpath()
        return path
    }
        
    public var animatableData: RectangleCornerRadii.AnimatableData {
        get { cornerRadii.animatableData }
        set { cornerRadii.animatableData = newValue }
    }
}

extension UnevenRoundedRectangle: InsettableShape {
    public func inset(by amount: CGFloat) -> some InsettableShape {
        return _Inset(base: self, amount: amount)
    }
    
    struct _Inset: InsettableShape {
        var base: UnevenRoundedRectangle
    
        var amount: CGFloat
        
        init(base: UnevenRoundedRectangle, amount: CGFloat) {
            (self.base, self.amount) = (base, amount)
        }

        func path(in rect: CGRect) -> Path {
            var cornerRadii = base.cornerRadii
            cornerRadii.inset(amount: amount)
            return UnevenRoundedRectangle(cornerRadii: cornerRadii, style: base.style).path(in: rect.inset(by: EdgeInsets(top: amount, leading: amount, bottom: amount, trailing: amount)))
        }
        
        var animatableData: AnimatablePair<UnevenRoundedRectangle.AnimatableData, CGFloat> {
            get { AnimatablePair(base.animatableData, amount) }
            set {
                base.animatableData = newValue.first
                amount = newValue.second
            }
        }

        func inset(by amount: CoreFoundation.CGFloat) -> UnevenRoundedRectangle._Inset {
            var copy = self
            copy.amount += amount
            return copy
        }
    }
}

extension CGRect {
    func inset(by insets: EdgeInsets) -> CGRect {
        guard !isNull else {
            return self
        }
        let result = standardized
        let width = result.width - insets.leading - insets.trailing
        guard width >= 0 else {
            return .null
        }
        let height = result.height - insets.top - insets.bottom
        guard height >= 0 else {
            return .null
        }
        return CGRect(
            x: result.minX + insets.leading,
            y: result.minY + insets.top,
            width: width,
            height: height
        )
    }
}

#Preview {
    ZStack {
        UnevenRoundedRectangle(topLeadingRadius: 2, bottomLeadingRadius: 4, bottomTrailingRadius: 2, topTrailingRadius: 4)
            .fill(.red)

        UnevenRoundedRectangle(topLeadingRadius: 2, bottomLeadingRadius: 4, bottomTrailingRadius: 2, topTrailingRadius: 4)
            .strokeBorder(Color.gray.opacity(0.5), lineWidth: 2)
    }
    .frame(width: 21, height: 12)
    .scaleEffect(10)
}
