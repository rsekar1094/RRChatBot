//
//  ContentView.swift
//  RRChatAppDemo
//
//  Created by Raj S on 28/12/24.
//

import SwiftUI
import RRAppChatAgent

struct ContentView: View {
    @State var isLoaded = false
    
    var body: some View {
        if isLoaded {
            HomeView()
        } else {
            Color.white
                .onAppear {
                    RRAppChatAgent.load()
                    isLoaded = true
                }
        }
    }
}

#Preview {
    ContentView()
}



