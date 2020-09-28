//
//  AboutPage.swift
//  Widget for Spotify
//
//  Created by Bram Koene on 28/09/2020.
//  Copyright © 2020 Sjoerd Bolten. All rights reserved.
//

import SwiftUI

struct AboutPage: View {
    var body: some View {
        VStack {
            Text("About")
            Text("Debug: ")
            Button(action: {
                UIPasteboard.general.string = SpotifyTokenHandler.accessToken() ?? ""
            }){
                Text("Copy accessToken to clipboard")
            }
        }
    }
}

struct AboutPage_Previews: PreviewProvider {
    static var previews: some View {
        AboutPage()
    }
}
