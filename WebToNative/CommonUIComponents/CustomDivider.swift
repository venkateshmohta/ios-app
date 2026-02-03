//
//  CustomDivider.swift
//  WebToNative
//
//  Created by Akash Kamati on 28/05/24.
//  Copyright © 2024 WebToNative. All rights reserved.
//

import SwiftUI

/**
 SwiftUI view representing a custom divider line.

 This view uses a horizontal rectangle to create a divider line with specific styling.

 - Note: The rectangle is styled with a height of 0.4 points, gray color, and 50% opacity.

 - Important: SwiftUI views automatically infer types for parameters based on their assigned values, allowing for concise initialization without explicit type annotations.
 */
struct CustomDivider: View {
    var body: some View {
        Rectangle()
            .frame(height: 0.4)
            .foregroundColor(.gray).opacity(0.5)
            .padding(.all,0)
    }
}

