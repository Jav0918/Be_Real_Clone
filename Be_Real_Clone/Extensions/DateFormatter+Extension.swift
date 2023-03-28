//
//  DateFormatter+Extension.swift
//  Be_Real_Clone
//
//  Created by Jonathan Velez on 3/27/23.
//

import Foundation


extension DateFormatter {
    static var postFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter
    }()
}
