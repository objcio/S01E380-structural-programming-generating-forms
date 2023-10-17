//

import Foundation
import SwiftUI

public protocol ToView {
    associatedtype V: View
    @ViewBuilder var view: V { get }
}

extension Empty: ToView {
    public var view: some View {
        EmptyView()
    }
}

extension Property: ToView where Value: ToView {
    public var view: some View {
        LabeledContent(name) {
            value.view
        }
    }
}

extension List: ToView where Head: ToView, Tail: ToView {
    public var view: some View {
        head.view
        tail.view
    }
}

extension Struct: ToView where Properties: ToView {
    public var view: some View {
        VStack {
            Text(name).bold()
            properties.view
        }
    }
}

// primitive types

extension String: ToView {
    public var view: some View {
        Text(self)
    }
}

extension Date: ToView {
    public var view: some View {
        Text(self, format: .dateTime)
    }
}

extension Bool: ToView {
    public var view: some View {
        Text(self ? "yes" : "no")
    }
}

extension Structural where Structure: ToView {
    public var view: some View {
        to.view
    }
}
