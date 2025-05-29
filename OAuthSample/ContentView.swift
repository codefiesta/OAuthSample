//
//  ContentView.swift
//  OAuthSample
//
//  Created by Kevin McKee on 5/16/24.
//

import OAuthKit
import SwiftUI

struct ContentView: View {
    
    #if !os(tvOS)
    @Environment(\.openWindow)
    var openWindow
    
    @Environment(\.dismissWindow)
    private var dismissWindow
    #endif
    
    @Environment(\.oauth)
    var oauth: OAuth

    var body: some View {
        VStack(spacing: 8) {
            switch oauth.state {
            case .empty:
                providerList
            case .authorizing(let provider, _):
                Text("Authorizing [\(provider.id)]")
            case .requestingAccessToken(let provider):
                Text("Requesting Access Token [\(provider.id)]")
            case .requestingDeviceCode(let provider):
                Text("Requesting Device Code [\(provider.id)]")
            case .authorized(let auth):
                Button("Authorized [\(auth.issuer)]") {
                    oauth.clear()
                }
            case .receivedDeviceCode(_, let deviceCode):
                Text("To login, visit")
                Text(deviceCode.verificationUri).foregroundStyle(.blue)
                Text("and enter the following code:")
                Text(deviceCode.userCode)
                    .padding()
                    .border(Color.primary)
                    .font(.title)
            }
        }
        .onChange(of: oauth.state) { _, state in
            handle(state: state)
        }
    }
    
    /// Displays a list of oauth providers.
    var providerList: some View {
        List(oauth.providers) { provider in
            Button(provider.id) {
                // Start the authorization flow (use .deviceCode for tvOS)
                oauth.authorize(provider: provider, grantType: .authorizationCode)
            }
        }
    }
    
    /// Reacts to oauth state changes by opening or closing authorization windows.
    /// - Parameter state: the published state change
    private func handle(state: OAuth.State) {
        switch state {
        case .empty, .requestingAccessToken, .requestingDeviceCode:
            break
        case .authorizing, .receivedDeviceCode:
            #if !os(tvOS)
            openWindow(id: "oauth")
            #endif
            break
        case .authorized(_):
            #if !os(tvOS)
            dismissWindow(id: "oauth")
        #endif
            break
        }
    }
}

#Preview {
    ContentView()
}
