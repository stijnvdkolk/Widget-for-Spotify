//
//  StatusService.swift
//  Widget for Spotify WidgetExtension
//
//  Created by Bram Koene on 27/09/2020.
//  Copyright © 2020 Sjoerd Bolten. All rights reserved.
//

import Foundation

public struct StatusService {
    public static var currentPlayingContextRequest: URLRequest {
        let url = "https://api.spotify.com/v1/me/player"
        
        var request = URLRequest(url: URL(string: url)!)
        request.setValue("Bearer " + (UserDefaults(suiteName: "group.dev.netlob.widget-for-spotify")?.string(forKey: "accessToken") ?? ""), forHTTPHeaderField: "Authorization")
        
        return request
    }
    
    static func getStatus(client: NetworkClient, completion: ((CurrentlyPlayingContext) -> Void)? = nil) {
        runStatusRequest(currentPlayingContextRequest, on: client, completion: completion)
    }

    private static func runStatusRequest(_ request: URLRequest,
                                         on client: NetworkClient,
                                         completion: ((CurrentlyPlayingContext) -> Void)? = nil) {
        client.executeRequest(request: request) { result in
            switch result {
            case .success(let data):
                let decoder = JSONDecoder()
                do {
                    let lineStatus = try decoder.decode(CurrentlyPlayingContext.self, from: data)
                    completion?(lineStatus)
                } catch {
                    print(error.localizedDescription)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}