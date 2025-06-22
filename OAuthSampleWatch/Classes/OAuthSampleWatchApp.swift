//
//  OAuthSampleWatchApp.swift
//  OAuthSampleWatch
//
//  Created by Kevin McKee
//

import OAuthKit
import SwiftUI

@main
struct OAuthSampleWatchApp: App {

    @Environment(\.oauth)
    var oauth: OAuth

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
