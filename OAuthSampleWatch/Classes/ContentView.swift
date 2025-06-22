//
//  ContentView.swift
//  OAuthSampleWatch
//
//  Created by Kevin McKee
//

import OAuthKit
import SwiftUI

struct ContentView: View {

    @Environment(\.oauth)
    var oauth: OAuth

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
            debugPrint("✅", state)
        }
        .padding()
    }

    /// Displays a list of oauth providers.
    var providerList: some View {
        List(oauth.providers) { provider in
            Button(provider.id) {
                // Start authorization (See companion iOS app for details)
            }
        }
    }
}

#Preview {
    ContentView()
}
