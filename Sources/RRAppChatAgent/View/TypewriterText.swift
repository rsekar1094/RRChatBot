//
//  TypewriterText.swift
//  RRAppChatAgent
//
//  Created by Raj S on 04/01/25.
//

import Foundation
import SwiftUI
import Combine

struct TypewriterText: View {
    let fullText: String
    let characterDelay: Double
    
    @State private var oldText: String = ""
    @State private var displayedText: String = ""
    @State private var cancellable: AnyCancellable?
    
    var body: some View {
        Text(LocalizedStringKey(displayedText))
            .onAppear {
                startTyping()
            }
            .onDisappear {
                cancellable?.cancel()
            }
    }
    
    private func startTyping() {
        
        // If old text is empty then it is first time so no need to animate
        if oldText.isEmpty {
            displayedText = fullText
            oldText = fullText
            return
        }
        
        let characters = Array(fullText)
        var currentIndex = 0
        if fullText.contains(oldText) {
            if let range = fullText.range(of: oldText) {
                displayedText = String(fullText[fullText.startIndex..<range.upperBound])
                currentIndex = fullText.distance(from: fullText.startIndex, to: range.upperBound)
            }
        } else {
            displayedText = ""
        }
        
        cancellable = Timer.publish(every: characterDelay, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                if currentIndex < characters.count {
                    displayedText += String(characters[currentIndex])
                    currentIndex += 1
                    oldText = displayedText
                } else {
                    cancellable?.cancel()
                }
            }
    }
}
