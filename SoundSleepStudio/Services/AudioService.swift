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
    var isPlaying = false
    var currentTrackName: String?
    var currentRate: Float = 1.0

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
            currentTrackName = trackName
        } catch {
            print("❌ Error loading audio: \(error)")
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
        audioPlayer?.stop()
        audioPlayer?.currentTime = 0
        isPlaying = false
    }

}
