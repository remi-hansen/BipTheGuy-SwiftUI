//
//  ContentView.swift
//  BipTheGuy-SwiftUI
//
//  Created by Remi Pacifico Hansen on 9/30/22.
//

import SwiftUI
import AVFAudio
import PhotosUI

struct ContentView: View {
    @State private var audioPlayer: AVAudioPlayer!
    @State private var animateImage = true
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var bipImage = Image("clown")
    
    var body: some View {
        VStack {
            Spacer()
            bipImage
                .resizable()
                .scaledToFit()
                .scaleEffect(animateImage ? 1.0 : 0.9)
                .onTapGesture {
                    playsound(soundName: "punchSound")
                    animateImage = false // will imediately shrink down in size
                    withAnimation (.spring(response: 0.3, dampingFraction: 0.3)){
                        animateImage = true // will go from 90 to 100% using spring animation
                    }
                }
            Spacer()
            
            PhotosPicker(selection: $selectedPhoto, matching: .images, preferredItemEncoding: .automatic) {
                Label("Photo Library", systemImage: "photo.fill.on.rectangle.fill")
            }
            .onChange(of: selectedPhoto) { newValue in
                Task {
                    do {
                        if let data = try await
                            newValue?.loadTransferable(type: Data.self){
                            if let uiImage = UIImage(data: data) {
                                bipImage = Image(uiImage: uiImage)
                            }
                        }
                    }catch {
                        print("😡 ERROR: Loading failed \(error.localizedDescription)")
                    }
                }
            }
        }
        .padding()
    }
    func playsound(soundName: String){
        guard let soundFile = NSDataAsset(name: soundName) else{
            print("😡 Could not read filename \(soundName)")
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(data: soundFile.data)
            audioPlayer.play()
        }catch{
            print("😡 Error: \(error.localizedDescription) creating audio player")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
