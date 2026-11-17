//
//  GridLine.swift
//  iphoneapp
//
//  Created by mac on 10/23/24.
//

import Foundation
import SwiftUI

struct DashedLine: View {
    var thickness: CGFloat = 2        // 선 두께
    var color: Color = .black         // 선 색상
    var direction: Axis = .horizontal // 방향: 가로(.horizontal) 또는 세로(.vertical)
    var dash: [CGFloat] = [5, 5]      // 점선 패턴 (선 길이, 간격)
    var offset: CGFloat = 0           // 위치 조정 (기본값: 0)

    var body: some View {
        GeometryReader { geometry in
            Path { path in
                if direction == .horizontal {
                    path.move(to: CGPoint(x: 0, y: geometry.size.height / 2 + offset))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height / 2 + offset))
                } else {
                    path.move(to: CGPoint(x: geometry.size.width / 2 + offset, y: 0))
                    path.addLine(to: CGPoint(x: geometry.size.width / 2 + offset, y: geometry.size.height))
                }
            }
            .stroke(color, style: StrokeStyle(lineWidth: thickness, dash: dash))
        }
    }
}
