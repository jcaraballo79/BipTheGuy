//
//  ContentView.swift
//  BipTheGuy
//
//  Created by Jorge Caraballo on 2/10/26.
//

import SwiftUI
import AVFAudio
import PhotosUI
import UIKit

struct ContentView: View {
    @State private var audioPlayer: AVAudioPlayer!
    @State private var isFullSize = true
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var bipImage = Image("clown")
    @AppStorage("savedImageData") private var savedImageData: Data = Data()
    
    var body: some View {
        VStack {
            
            Spacer()
            
            bipImage
                .resizable()
                .scaledToFit()
                .scaleEffect(isFullSize ? 1.0 : 0.9)
                .onTapGesture {
                    playSound(soundName: "punchSound")
                    isFullSize = false // will immediately shrink using .scalEffect down to 90% of size
                    withAnimation (.spring(response: 0.3, dampingFraction: 0.3)) {
                        isFullSize = true // will go from 90% to 100% size but using the .spring animation
                    }
                }
            
            
            Spacer()
            
            PhotosPicker(
                selection: $selectedPhoto,
                matching: .images,
                preferredItemEncoding: .automatic
            ) {
                Label("Photo Library", systemImage: "photo.fill.on.rectangle.fill")
                    .font(.title2)
            }
            .buttonStyle(.glassProminent)
            .tint(.green.opacity(0.7))
            .controlSize(.large)
            .onChange(of: selectedPhoto) {
                Task {
                    guard let data = try? await selectedPhoto?.loadTransferable(type: Data.self),
                          let uiImage = UIImage(data: data) else {
                        print("😡 ERROR: Could not get image data from loadTransferable.")
                        return
                    }
                    savedImageData = data
                    bipImage = Image(uiImage: uiImage)
                }
            }
        }
        
        .padding()
        .task {
            if let uiImage = UIImage(data: savedImageData), !savedImageData.isEmpty {
                bipImage = Image(uiImage: uiImage)
            }
        }
    }
    
    func playSound(soundName: String) {
        if audioPlayer != nil && audioPlayer.isPlaying {
            audioPlayer.stop()
        }
        guard let soundFile = NSDataAsset(name: soundName) else {
            print("😡 Could not read file named \(soundName)")
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(data: soundFile.data)
            audioPlayer.play()
        } catch {
            print("😡 ERROR: \(error.localizedDescription) creating audioPlayer")
        }
    }
    
}

#Preview {
    ContentView()
}
