//
//  Widget_for_Spotify_Widget.swift
//  Widget for Spotify Widget
//
//  Created by Bram Koene on 26/09/2020.
//  Copyright © 2020 Sjoerd Bolten. All rights reserved.
//

import WidgetKit
import SwiftUI
import Intents
import Kingfisher
import struct KingfisherSwiftUI.KFImage
import Combine

// Creating model for JSON data...

struct Model : TimelineEntry {
    var date: Date
    var widgetData: CurrentlyPlayingContext
    let configuration: ConfigurationIntent
    let albumImage: Kingfisher.KFCrossPlatformImage?
    let playlistName: String?
    let artistName: String?
}

struct Provider: IntentTimelineProvider {
    public typealias Entry = Model
    
    public typealias Intent = ConfigurationIntent
    
    public func placeholder(in context: Context) -> Model {
        return Model(date: Date(), widgetData: CurrentlyPlayingContext(device: Device(is_active: true, is_private_session: false, is_restricted: false, name: "My iPhone", type: "Widget"), repeat_state: "IDK", shuffle_state: false, timestamp: 324, is_playing: true,item: FullTrack(album: SimplifiedAlbum(album_type: "single", artists: [], available_markets: [], external_urls: ["": ""], href: "", id: "", images: [], name: "", release_date: "", release_date_precision: "", restrictions: nil, type: "", uri: ""), artists: [SimplifiedArtist(external_urls: ["":""], href: "", id: "", name: "Billie Eilish", type: "artist", uri: "")], available_markets: [], disc_number: 1, duration_ms: 23423, explicit: true, external_ids: ["": ""], external_urls: ["":""], href: "", id: "", is_playable: true, linked_from: "", restrictions: "", name: "my future", popularity: 23, preview_url: "", track_number: 1, type: "single", uri: "", is_local: false), currently_playing_type: "Song", actions: nil), configuration: ConfigurationIntent(), albumImage: nil, playlistName: nil, artistName: nil)
    }
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Model) -> Void) {
        let loadingData = Model(date: Date(), widgetData: CurrentlyPlayingContext(device: Device(is_active: true, is_private_session: false, is_restricted: false, name: "My iPhone", type: "Widget"), repeat_state: "IDK", shuffle_state: false, timestamp: 324, is_playing: true,item: FullTrack(album: SimplifiedAlbum(album_type: "single", artists: [], available_markets: [], external_urls: ["": ""], href: "", id: "", images: [], name: "", release_date: "", release_date_precision: "", restrictions: nil, type: "", uri: ""), artists: [SimplifiedArtist(external_urls: ["":""], href: "", id: "", name: "Billie Eilish", type: "artist", uri: "")], available_markets: [], disc_number: 1, duration_ms: 23423, explicit: true, external_ids: ["": ""], external_urls: ["":""], href: "", id: "", is_playable: true, linked_from: "", restrictions: "", name: "my future", popularity: 23, preview_url: "", track_number: 1, type: "single", uri: "", is_local: false), currently_playing_type: "Song", actions: nil), configuration: ConfigurationIntent(), albumImage: nil, playlistName: "Billie Eilish", artistName: "Billie Eilish")
        completion(loadingData)
    }
    
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Model>) -> Void) {
        // Parsing json data and displaying...
        print("Updating Timeline")
        if(UserDefaults(suiteName: "group.dev.netlob.widget-for-spotify")?.string(forKey: "accessToken") == nil){
            let nextUpdate = Calendar.current.date(byAdding: .second, value: Int(truncating: (configuration.refreshTime ?? 30)), to: Date())

            let data = Model(date: nextUpdate!, widgetData: CurrentlyPlayingContext(device: Device(is_active: true, is_private_session: false, is_restricted: false, name: "Example Device", type: "NOLOGIN"), repeat_state: "IDK", shuffle_state: false, timestamp: 324, is_playing: true, currently_playing_type: "Song", actions: nil), configuration: configuration, albumImage: nil, playlistName: nil, artistName: nil)

            let timeline = Timeline(entries: [data], policy: .after(nextUpdate!))

            completion(timeline)
        } else {
            StatusService.getStatus(client: NetworkClient()){ updates in
                var playlistName: String? = nil
                var artistName: String? = nil
                if(updates?.item?.album.album_type != "single"){
                    playlistName = updates?.item?.album.name
                }
                
                updates?.item?.artists.forEach{ artist in
                    if(artistName == nil){
                        artistName = ""
                        artistName?.append(artist.name)
                    } else {
                        artistName?.append(", ")
                        artistName?.append(artist.name)
                    }
                }

                if((updates?.item?.album.images[1]) != nil){
                    KingfisherManager.shared.retrieveImage(with: URL(string: (updates?.item?.album.images[1].url)!)!){ result in
                        switch result{
                        case .success(let value):
                            
                            let nextUpdate = Calendar.current.date(byAdding: .second, value: Int(truncating: configuration.refreshTime ?? 30), to: Date())

                            let data = Model(date: nextUpdate!, widgetData: updates!, configuration: configuration, albumImage: value.image, playlistName: playlistName, artistName: artistName)

                            let tomorrow = Calendar.current.date(byAdding: .second, value: 20, to: Date())!
                            let timeline = Timeline(entries: [data], policy: .after(tomorrow))

                            completion(timeline)
                        case .failure(let error):
                            print(error)
                        }
                        
                        
                    }
                } else {
                    
                    let nextUpdate = Calendar.current.date(byAdding: .second, value: Int(truncating: (configuration.refreshTime ?? 30)), to: Date())

                    let data = Model(date: nextUpdate!, widgetData: updates!, configuration: configuration, albumImage: nil, playlistName: playlistName, artistName: nil)

                    let timeline = Timeline(entries: [data], policy: .after(nextUpdate!))

                    completion(timeline)
                }
                
            }
        }
        
    }
}

struct CurrentPlayingWidgetEntryView : SwiftUI.View {
    @Environment(\.widgetFamily) var family

    var data: Model
    
    var backgroundColor: SwiftUI.Color?
    var textColor: SwiftUI.Color?
    var useCustomBackground: Bool = false
    
    init(data: Model){
        self.data = data
        if(data.albumImage != nil && data.configuration.dynamicBackground?.boolValue == true){
            let colors = data.albumImage?.imageWithoutBaseline().getColors(quality: .lowest)
            self.backgroundColor = Color((colors?.background)!)
            self.textColor = Color((colors?.primary)!)
            self.useCustomBackground = true
        }else{
            self.backgroundColor = Color("WidgetBackgroundColor")
            self.textColor = Color("WidgetTextColor")
        }
    }
    
    var body: some SwiftUI.View{
        if(data.widgetData.device.type == "NOLOGIN"){
            VStack{
                Text("It seems like you are not logged in.")
                    .font(.headline)
                Text("To login open the app by pressing this widget, Or the app icon on your homescreen")
                if(family == .systemMedium || family == .systemLarge){
                    SpotifySignIn()
                }
            }
            .padding(10)
        } else {
            HStack {
                switch family{
                case .systemSmall:
                    SmallCurrentWidget(data: data, useCustomBackground: useCustomBackground)
                case .systemMedium:
                    MediumCurrentWidget(data: data, useCustomBackground: useCustomBackground)
                case .systemLarge:
                    HStack{
                        
                    }
                @unknown default:
                    Text("An unknown error occured")
                }
            }
            .background(backgroundColor)
            .foregroundColor(textColor)
        }
    }
}

struct CurrentPlayingWidget: Widget {
    let kind: String = "Widget_for_Spotify_Widget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            CurrentPlayingWidgetEntryView(data: entry)
        }
        .configurationDisplayName("Spotify Widget")
        .description("Widget to show spotify Data")
        .supportedFamilies([.systemSmall, .systemMedium])
        .onBackgroundURLSessionEvents(matching: "CurrentlyPlaying"){ (string, session) in
            debugPrint(string)
            debugPrint(session)
        }
    }
}

@propertyWrapper
struct StoredOnHeap<T> {
    private var value: [T]

    init(wrappedValue: T) {
        self.value = [wrappedValue]
    }

    var wrappedValue: T {
        get {
            return self.value[0]
        }

        set {
            self.value[0] = newValue
        }
    }
}

