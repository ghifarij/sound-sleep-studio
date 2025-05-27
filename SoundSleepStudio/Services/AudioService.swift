//
//  AudioService.swift
//  SoundSleepStudio
//
//  Created by Wentao Guo on 27/05/25.
//

import AVFoundation

@Observable
class AudioService {
    static let audioManager = AudioService()

    private var audioPlayer: AVAudioPlayer?
    var isPlaying = false
    var currentTrackName: String?
    var currentRate: Float = 1.0

    private init() {}

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
            currentTrackName = trackName
        } catch {
            print("❌ Error loading audio: \(error)")
        }
    }
    
    func play() {
        audioPlayer?.play()
        isPlaying = true
    }
    
    func pause() {
        audioPlayer?.pause()
        isPlaying = false
    }
    
    func stop() {
        audioPlayer?.stop()
        audioPlayer?.currentTime = 0
        isPlaying = false
    }

}
