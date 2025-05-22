//
//  FeatureRow.swift
//  SoundSleepStudio
//
//  Created by Kelvin on 21/05/25.
//

// Sources/Views/Onboarding/FeatureRow.swift

import SwiftUI

struct FeatureRow: View {
    let systemIconName: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: systemIconName)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(.brandPurple)
                .frame(width: 30, height: 30)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.textPrimary)

                Text(description)
                    .font(.system(size: 15))
                    .foregroundColor(.textSecondary)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
    }
}
