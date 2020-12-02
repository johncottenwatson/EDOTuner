//
//  IntroPageView.swift
//  Tuner
//
//  Created by John Watson on 11/15/20.
//

import SwiftUI

struct IntroPageView: View {
    
    @State var tapTextOpacity: Double = 0.0
    
    @Binding var showTapMessage: Bool
   
    let flavorText = ["""
                        In the tuner bar, the big number \
                        is the note number, the small \
                        number is the octave.
                        """,
                      """
                        Tap the numbers to the left and \
                        right of the sliders to fine \
                        tune!
                        """,
                      """
                        1 tone equal temperament is just \
                        octaves!
                        """]
    let flavorTextIndex = Int.random(in: 0..<3)
    
    let tapText = ["Press anywhere to continue", " "]
    
    var body: some View {
        ZStack() {
            // Background
            ColorPalette.lightGray
                .ignoresSafeArea()
            // Content
            VStack() {
                Spacer()
                Text("edo")
                    .foregroundColor(ColorPalette.blue)
                    .font(.largeTitle)
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    .scaleEffect(2)
                VStack(alignment: .leading) {
                    Text("Tip")
                        .font(.title2)
                        .foregroundColor(ColorPalette.darkGray)
                    Text(flavorText[flavorTextIndex])
                        .font(.body)
                        .foregroundColor(ColorPalette.darkGray)
                        
                }.padding(40)
                Text(tapText[showTapMessage ? 0 : 1])
                    .font(.body)
                    .foregroundColor(ColorPalette.blue)
                    .opacity(1.0 - pow(tapTextOpacity, 0.01))
                    .onAppear {
                        let baseAnimation = Animation.easeInOut(duration: 1)
                        let repeated = baseAnimation.repeatForever(autoreverses: true)

                        return withAnimation(repeated) {
                            self.tapTextOpacity = 2.0
                        }
                    }
                    .padding(40)
                Spacer()
                Spacer()
            }
        }
    }
}

struct IntroPageView_Previews: PreviewProvider {
    static var previews: some View {
        IntroPageView(showTapMessage: .constant(false))
    }
}
