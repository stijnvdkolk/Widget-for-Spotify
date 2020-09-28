//
//  MainView.swift
//  Widget for Spotify
//
//  Created by Bram Koene on 26/09/2020.
//  Copyright © 2020 Sjoerd Bolten. All rights reserved.
//

import SwiftUI
import WidgetKit

struct MainView: View {
    @ObservedObject var spotifyData = SpotifyData.shared
    
    var body: some View {
        TabView{
            NavigationView{
                ScrollView(.vertical){
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Welcome " + (spotifyData.personInfo?.display_name ?? "{{ user }}"))
                            Button(action: {
                                WidgetCenter.shared.reloadAllTimelines()
                            }){
                                Text("Restart widget")
                            }
                            Spacer()
                            Button(action: {
                                UIPasteboard.general.string = SpotifyTokenHandler.accessToken() ?? ""
                            }){
                                Text("Copy accessToken to clipboard")
                            }
                        }
                        .navigationBarTitle("Home")
                        Spacer()
                    }
                    .padding(.horizontal, 15)
                }
            }
            .tabItem {
                Image(systemName: "music.note.list")
                Text("Home")
            }
            
//            NavigationView{
//                ScrollView(.vertical){
//                    HStack {
//                        VStack(alignment: .leading) {
////                            Text("Welcome " + (spotifyData.personInfo?.display_name ?? "{{ user }}"))
//                            CardView(card: Card(prompt: "Change background of the widget"))
//                            CardView(card: Card(prompt: "Change background of the widget"))
//                            CardView(card: Card(prompt: "Change background of the widget"))
//                            CardView(card: Card(prompt: "Change background of the widget"))
//                            CardView(card: Card(prompt: "Change background of the widget"))
//                            Spacer()
//                        }
//                        .navigationBarTitle("Tutorials")
//                        Spacer()
//                    }
//                    .padding(.horizontal, 15)
//                }
//            }
//            .tabItem {
//                Image(systemName: "text.book.closed")
//                Text("Tutorials")
//            }
//
            NavigationView{
                SettingsPage()
                    .navigationBarTitle("Settings Page")
            }
            .tabItem {
                Image(systemName: "gear")
                Text("Settings")
            }
        }
        .onAppear {
            SpotifyData.shared.getPersonInfo()
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MainView()
            MainView()
        }
    }
}


struct CardView: View {
    let card: Card

    var body: some View {
        ZStack {
            Image("TestImage")
                .resizable()
                .scaledToFill()
                .frame(width: .infinity, height: 200, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)

            VStack(alignment: .leading) {
                Spacer()
                ZStack {
                    BlurView(style: .light).frame(width: .infinity, height: 60)
                    Text(card.prompt)
                        .font(.system(size: 20, weight: .bold, design: .default))
                        .foregroundColor(.black)
//                        .padding(20)
                }
                .multilineTextAlignment(.center)
            }
        }
        .cornerRadius(15)
        .frame(width: .infinity, height: 200)
    }
}


struct Card {
    let prompt: String
}

struct BlurView: UIViewRepresentable {

    let style: UIBlurEffect.Style

    func makeUIView(context: UIViewRepresentableContext<BlurView>) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        let blurEffect = UIBlurEffect(style: style)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(blurView, at: 0)
        NSLayoutConstraint.activate([
            blurView.heightAnchor.constraint(equalTo: view.heightAnchor),
            blurView.widthAnchor.constraint(equalTo: view.widthAnchor),
        ])
        return view
    }

    func updateUIView(_ uiView: UIView,
                      context: UIViewRepresentableContext<BlurView>) {

    }

}
