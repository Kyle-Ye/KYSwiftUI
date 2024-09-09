//
//  View+KY.swift
//
//
//  Created by Kyle on 2024/4/23.
//

import KYFoundation
import protocol SwiftUI.View

public struct KY<Content> {
    public let content: Content
    
    @_transparent
    public init(_ content: Content) {
        self.content = content
    }
}

extension View {
    @_transparent
    public var ky: KY<Self> { KY(self) }
    
    @_transparent
    public static var ky: KY<Self>.Type { KY<Self>.self }
}
