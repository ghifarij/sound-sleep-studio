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
    var onPlaybackComplete: (() -> Void)?

    init() {
        setupAudioSession()
    }
    
    deinit {
            cleanup()
        }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("❌ Failed to setup audio session: \(error)")
        }
    }
    
    private func cleanup() {
        fadeOutTimer?.invalidate()
        stopTimer?.invalidate()
        audioPlayer?.stop()
        audioPlayer = nil
    }

    //Load the audio file
    func load(trackName: String, fileExtension: String = "mp3") {
        if currentTrackName == trackName && audioPlayer != nil {
            return
        }
        
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
            audioPlayer?.numberOfLoops = -1
            currentTrackName = trackName
        } catch {
            print("❌ Error loading audio: \(error)")
        }
    }
    
    // Play audio with timed stop and fade out
    func playWithTimedStop() {
        guard let player = audioPlayer else { return }
        
        player.play()
        isPlaying = true
        scheduleStopWithFadeOut()
    }
    
    private func scheduleStopWithFadeOut() {
        // Cancel existing timers
        fadeOutTimer?.invalidate()
        stopTimer?.invalidate()
        
        // Schedule fade out after 30 seconds
        fadeOutTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: false) { [weak self] _ in
            self?.startFadeOut()
        }
        
        // Schedule stop after 60 seconds total
        stopTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: false) { [weak self] _ in
            self?.stop()
        }
    }
    
    private func startFadeOut() {
        originalVolume = volume
        
        let fadeDuration: Double = 30.0
        let fadeInterval = 0.1
        let numberOfSteps = Int(fadeDuration / fadeInterval)
        let volumeDecrement = volume / Float(numberOfSteps)
        
        fadeOutTimer = Timer.scheduledTimer(withTimeInterval: fadeInterval, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            let newVolume = max(0, self.volume - volumeDecrement)
            self.setVolume(newVolume)
            
            if newVolume <= 0 {
                timer.invalidate()
            }
        }
    }
    
    //play audio
    func play() {
        guard let player = audioPlayer else { return }
        player.play()
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
        onPlaybackComplete?()
        
        DispatchQueue.main.async { [weak self] in
            self?.onPlaybackComplete?()
        }
    }

    //volume control
    func setVolume(_ value: Float) {
        volume = value
        audioPlayer?.volume = value
    }
}
