////
////  OnboardView.swift
////  SoundSleepStudio
////
////  Created by Wentao Guo on 21/05/25.
////
//
//import SwiftUI
//
//struct OnboardView: View {
//    var body: some View {
//
//        VStack(spacing: 30) {
//            Spacer()
//            //MARK: IMAGE
//            Image("sleepCloud")
//                .resizable()
//                .scaledToFit()
//                .frame(width: 180, height: 180)
//
//            //MARK: TITLE
//            Text("Welcome to\nSound Sleep")
//                .font(.largeTitle)
//                .fontWeight(.bold)
//                .foregroundColor(.white)
//
//            //MARK: BODY
//            VStack(alignment: .leading, spacing: 25) {
//                HStack(alignment: .top) {
//
//                    Image(systemName: "music.note")
//                        .foregroundColor(.purple)
//                        .font(.title3)
//                    Text("Sync gentle music with your heartbeat")
//                        .foregroundColor(.white)
//
//                }
//
//                HStack(alignment: .top) {
//
//                    Image(systemName: "bed.double.fill")
//                        .foregroundColor(.purple)
//                        .font(.title3)
//                    Text(
//                        "Gradually slowing the tempo to lull you into sleep"
//                    )
//                    .foregroundColor(.white)
//
//                }
//            }
//            .frame(maxWidth: .infinity, alignment: .leading)
//            .padding(.horizontal, 40)
//
//            Spacer()
//
//            //MARK: BUTTON
//            Button(action: {
//
//            }) {
//                Text("Continue")
//                    .fontWeight(.semibold)
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .background(Color.purple)
//                    .foregroundColor(.white)
//                    .cornerRadius(12)
//                    .padding(.horizontal, 24)
//            }
//            .padding(.horizontal, 40)
//            .padding(.bottom, 40)
//        }.background(Color.black.edgesIgnoringSafeArea(.all))
//
//    }
//}
//
//#Preview {
//    OnboardView()
//}
