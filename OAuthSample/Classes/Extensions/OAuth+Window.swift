//
//  OAuth+Window.swift
//  OAuthSample
//
//  Created by Kevin McKee
//

import OAuthKit
import SwiftUI

#if canImport(WebKit)

extension OAuth {

    /// Provides a convenience enum that identifies application scene windows that can be opened or dismissed.
    public enum Window: String {
        /// Identifies the OAWebView window wrapper that coordinates oauth authorization flows inside a WKWebView.
        case oauth
    }
}

public extension WindowGroup {

    /// Convenience initializer that accepts a `OAuth.Window`  as the identifier.
    /// - Parameters:
    ///   - id: the oauth window group
    ///   - makeContent: the make content closure
    nonisolated init(id: OAuth.Window, @ViewBuilder makeContent: @escaping () -> Content) {
        self.init(id: id.rawValue, makeContent: makeContent)
    }
}

public extension OpenWindowAction {

    /// Convenience function that allows the application to open a window with an `OAuth.Window`
    /// - Parameters:
    ///   - id: the oauth window group
    @MainActor @preconcurrency func callAsFunction(id: OAuth.Window) {
        callAsFunction(id: id.rawValue)
    }
}

public extension DismissWindowAction {

    /// Convenience function that allows the application to dismiss a window with an `OAuth.Window`
    /// - Parameters:
    ///   - id: the oauth window group
    @MainActor @preconcurrency func callAsFunction(id: OAuth.Window) {
        callAsFunction(id: id.rawValue)
    }
}

#endif
