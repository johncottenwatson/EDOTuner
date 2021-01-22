//
//  Tuner.swift
//  Tuner
//
//  Created by John Watson on 11/13/20.
//

import AudioKit

// Model for tuner containing AudioKit infrastructure
public class Tuner: ObservableObject {
    @Published var frequency: Float = 262.0
    @Published var dampedFrequency: Float = 262.0
    var frequencyBuffer = [Float](repeating: 262.0, count: 8)
    // How far can two frequencies be from each other and still be considered near?
    let differenceMetricCutoff: Float = log2(1.05)
    // What fraction of recently polled values must near to a newly polled far value
    // to jump to the new value?
    let recentShareCutoff: Float = 0.6
    
    let pollingInterval = 0.05
    var pollingTimer: Timer?

    var mic: AKMicrophone!
    var tracker: AKFrequencyTracker!
    var silence: AKBooster!

    // Setup AudioKit microphone
    func create() {
        AKSettings.audioInputEnabled = true
        let recordingFormat = AKManager.engine.inputNode.inputFormat(forBus: 0);
        AKSettings.sampleRate = recordingFormat.sampleRate;
        mic = AKMicrophone(with: recordingFormat)!
        tracker = AKFrequencyTracker(mic)
        silence = AKBooster(tracker, gain: 0)
        
        AKManager.output = silence
    }

    // Start audio manager and polling process
    func start() {
        do {
            try AKManager.start()
        } catch {
            print("Trouble starting AKManager")
        }
        
        pollingTimer = Timer.scheduledTimer(withTimeInterval: pollingInterval, repeats: true, block: {_ in self.pollingTick()})
    }
    
    // Start audio manager and polling process
    func stop() {
        do {
            try AKManager.stop()
        } catch  {
            print("Trouble stopping AKManager")
        }
        
        if let t = pollingTimer {
            t.invalidate()
        }
    }
    
    // Code run every tick to poll the input audio status
    private func pollingTick() {
        frequency = Float(tracker.frequency)
        updateFrequencyBuffer()
        
        // Compare newest value in frequency to dampedFrequency
        if frequenciesNear(frequency, dampedFrequency) {
            // If near, just lerp towards the new frequency
            dampedFrequency = dampedFrequency * 0.9 + frequency * 0.1
        } else {
            // If far, check whether most recently polled values are near to
            let count: Int = frequencyBuffer.reduce(0) { $0 + (frequenciesNear($1, frequency) ? 1 : 0) }
            
            let share: Float = Float(count) / Float(frequencyBuffer.count)
            if share > recentShareCutoff {
                dampedFrequency = frequency
            }
        }
    }
    
    private func frequenciesNear(_ f1: Float, _ f2: Float) -> Bool {
        let differenceMetric = abs(log2(f1 / f2))
        return differenceMetric < differenceMetricCutoff
    }
    
    private func updateFrequencyBuffer() {
        for i in (1..<frequencyBuffer.count).reversed() {
            frequencyBuffer[i] = frequencyBuffer[i - 1]
        }
        frequencyBuffer[0] = frequency
    }
}
