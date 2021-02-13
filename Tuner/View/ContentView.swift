//
//  ContentView.swift
//  Tuner
//
//  Created by John Watson on 11/13/20.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var userData: UserData
    @ObservedObject var tuner = Tuner()
    
    @State var ableToSwitch = false
    @State var showTapMessage = false
    @State var onIntro = true
    
    var body: some View {
        if onIntro {
            IntroPageView(showTapMessage: $showTapMessage)
                .onAppear() {
                    delayTapMessage()
                    loadTuner()
                }
                .onTapGesture(count: 1) {
                        if (ableToSwitch) {
                            withAnimation {
                                onIntro = false
                            }
                        }
                    }
        } else {
            TunerView(tuner: tuner)
                .transition(.opacity)
                .onAppear() {
                    if userData.sessionNumber == 5 {
                        StoreReviewManager.requestReview()
                    }
                }
        }
    }
    
    private func delayTapMessage() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showTapMessage = true
        }
    }
    
    private func loadTuner() {
        DispatchQueue.main.async {
            tuner.create()
            ableToSwitch = true
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
