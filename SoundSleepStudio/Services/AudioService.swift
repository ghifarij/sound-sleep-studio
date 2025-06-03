//
//  AudioService.swift
//  SoundSleepStudio
//
//  Created by Wentao Guo on 27/05/25.
//

import AVFoundation

@Observable
class AudioService {
    private var audioPlayer: AVAudioPlayer?
    private var fadeOutTimer: Timer?
    private var stopTimer: Timer?
    
    var isPlaying = false
    var currentTrackName: String?
    var currentRate: Float = 1.0
    var volume: Float = 0.5
    var originalVolume: Float = 0.5

    init() {}

    //Load the audio file
    func load(trackName: String, fileExtension: String = "mp3") {
        guard
            let url = Bundle.main.url(
                forResource: trackName, withExtension: fileExtension)
        else {
            print("❌ Failed to find audio file: \(trackName).\(fileExtension)")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.volume = volume
            currentTrackName = trackName
        } catch {
            print("❌ Error loading audio: \(error)")
        }
    }
    
    // Play audio with timed stop and fade out
    func playWithTimedStop() {
        audioPlayer?.play()
        isPlaying = true

        scheduleStopWithFadeOut()
    }
    
    private func scheduleStopWithFadeOut() {
        fadeOutTimer?.invalidate()
        stopTimer?.invalidate()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 30.0) { [weak self] in
            self?.startFadeOut()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 60.0) { [weak self] in
            self?.stop()
        }
    }
    
    private func startFadeOut() {
        originalVolume = volume
        
        let fadeInterval = 0.5
        let numberOfSteps = 60
        let volumeDecrement = volume / Float(numberOfSteps)
        
        fadeOutTimer = Timer.scheduledTimer(withTimeInterval: fadeInterval, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            let newVolume = max(0, self.volume - volumeDecrement)
            self.setVolume(newVolume)
            
            if self.volume <= 0 {
                timer.invalidate()
            }
        }
    }
    
    //play audio
    func play() {
        audioPlayer?.play()
        isPlaying = true
    }
    
    //pause audio
    func pause() {
        audioPlayer?.pause()
        isPlaying = false
    }
    
    //stop audio
    func stop() {
        fadeOutTimer?.invalidate()
        stopTimer?.invalidate()
        audioPlayer?.stop()
        audioPlayer?.currentTime = 0
        isPlaying = false
        setVolume(originalVolume)
    }

    //volume control
    func setVolume(_ value: Float) {
        volume = value
        audioPlayer?.volume = value
    }
}
