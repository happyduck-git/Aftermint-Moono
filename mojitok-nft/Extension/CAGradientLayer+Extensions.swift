//
//  CAGradientLayer+Extensions.swift
//  Aftermint
//
//  Created by Platfarm on 2023/03/28.
//

import UIKit

extension CAGradientLayer {
    
    /// Make gradient layer with colors given with colors argument.
    /// Default direction of gradient is diagonal, from top-left to bottom-right.
    func makeGradient(with colors: [CGColor],
                      startPoint: CGPoint = CGPoint(x: 0, y: 0),
                      endPoint: CGPoint = CGPoint(x: 1, y: 1))
    {
        self.colors = colors
        self.startPoint = startPoint
        self.endPoint = endPoint
    }
    
}
