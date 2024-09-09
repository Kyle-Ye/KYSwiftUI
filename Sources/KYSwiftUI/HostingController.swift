//
//  HostingController.swift
//
//
//  Created by Kyle on 2024/7/15.
//

import SwiftUI

open class HostingController<Content: View>: UIHostingController<Content> {
    override public init(rootView: Content) {
        super.init(rootView: rootView)
        view.backgroundColor = .clear
    }
    
    @available(*, unavailable)
    public dynamic required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
