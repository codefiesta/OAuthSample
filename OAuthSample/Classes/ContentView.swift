//
//  ContentView.swift
//  OAuthSample
//
//  Created by Kevin McKee on 5/16/24.
//

import OAuthKit
import SwiftUI

struct ContentView: View {

    @Environment(\.oauth)
    var oauth: OAuth

    #if canImport(WebKit)
    @Environment(\.openWindow)
    var openWindow

    @Environment(\.dismissWindow)
    private var dismissWindow
    #endif

    var body: some View {
        VStack(spacing: 8) {
            switch oauth.state {
            case .empty:
                providerList
            case .authorizing(let provider, let grantType):
                Text("Authorizing [\(provider.id)] with [\(grantType.rawValue)]")
            case .requestingAccessToken(let provider):
                Text("Requesting Access Token [\(provider.id)]")
            case .requestingDeviceCode(let provider):
                Text("Requesting Device Code [\(provider.id)]")
            case .authorized(let provider, _):
                HStack {
                    Button("Authorized [\(provider.id)]") {
                        oauth.clear()
                    }
                    Button {
                        oauth.authorize(provider: provider, grantType: .refreshToken)
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }

                }
            case .receivedDeviceCode(_, let deviceCode):
                Text("To login, visit")
                Text(.init("[\(deviceCode.verificationUri)](\(deviceCode.verificationUri))"))
                    .foregroundStyle(.blue)
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
                authorize(provider: provider)
            }
        }
    }

    /// Starts the authorization process for the specified provider.
    /// - Parameter provider: the provider to begin authorization for
    private func authorize(provider: OAuth.Provider) {
        #if canImport(WebKit)
        // Use the PKCE grantType for iOS, macOS, visionOS
        let grantType: OAuth.GrantType = .pkce(.init())
        #else
        // Use the Device Code grantType for tvOS, watchOS
        let grantType: OAuth.GrantType = .deviceCode
        #endif
        // Start the authorization flow
        oauth.authorize(provider: provider, grantType: grantType)
    }

    /// Reacts to oauth state changes by opening or closing authorization windows.
    /// - Parameter state: the published state change
    private func handle(state: OAuth.State) {
        switch state {
        case .empty, .requestingAccessToken, .requestingDeviceCode:
            break
        case .authorizing(_, let grantType):
            switch grantType {
            case .authorizationCode, .pkce, .deviceCode:
                openWebView()
            case .clientCredentials, .refreshToken:
                break
            }
        case .receivedDeviceCode:
            openWebView()
        case .authorized(_, let authorization):
            dismissWebView()
            makeAuthenticatedRequest(authorization)
        }
    }

    private func openWebView() {
        #if canImport(WebKit)
        openWindow(id: .oauth)
        #endif
    }

    private func dismissWebView() {
        #if canImport(WebKit)
        dismissWindow(id: .oauth)
        #endif
    }

    /// Sample of making an authenticated request against Github.
    /// - Parameter authorization: the authorization to use
    private func makeAuthenticatedRequest(_ authorization: OAuth.Authorization) {
        Task {
            let urlSession: URLSession = .init(configuration: .ephemeral)
            let url: URL = .init(string: "https://api.github.com/users/codefiesta/repos")!
            var request = URLRequest(url: url)
            request.addAuthorization(auth: authorization)
            let (data, _) = try await urlSession.data(for: request)
            guard let string = String(data: data, encoding: .utf8) else { return }
            debugPrint(string)
        }
    }
}

#Preview {
    ContentView()
}
