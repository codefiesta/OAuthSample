//
//  OAuthSampleApp.swift
//  OAuthSample
//
//  Created by Kevin McKee on 5/16/24.
//

import OAuthKit
import SwiftUI

@main
struct OAuthSampleApp: App {

    @Environment(\.oauth)
    var oauth: OAuth

    var body: some Scene {

        WindowGroup {
            ContentView()
        }

        #if canImport(WebKit)
        WindowGroup(id: .oauth) {
            OAWebView(oauth: oauth)
        }
        #endif
    }
}
