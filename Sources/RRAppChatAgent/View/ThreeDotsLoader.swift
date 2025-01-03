//
//  ThreeDotsLoader.swift
//  RRAppChatAgent
//
//  Created by Raj S on 04/01/25.
//

import Foundation
import SwiftUI

struct ThreeDotsLoader: View {
    @State private var bounceOffsets: [CGFloat] = [0, 0, 0]
    
    var body: some View {
        ForEach(0..<3) { index in
            Circle()
                .frame(width: 3, height: 3)
                .offset(y: bounceOffsets[index])
                .padding(.trailing, 1)
                .animation(
                    Animation.easeInOut(duration: 0.5)
                        .repeatForever()
                        .delay(Double(index) * 0.2),
                    value: bounceOffsets[index]
                )
        }
        .onAppear {
            for i in 0..<3 {
                DispatchQueue.main.asyncAfter(deadline: .now() + (Double(i) * 0.2)) {
                    withAnimation {
                        bounceOffsets[i] = -3 // Move up
                    }
                    withAnimation(Animation.easeInOut(duration: 0.5).repeatForever().delay(Double(i) * 0.2)) {
                        bounceOffsets[i] = 3 // Move down
                    }
                }
            }
        }
    }
    
}
