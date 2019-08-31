//
//  Bundle+HE.swift
//  HEPhotoPicker
//
//  Created by heyode on 8/31/19.
//

import Foundation

extension Bundle{
    public static var heBundle :Bundle?{
        get{
            guard let url = Bundle(for: HETool.self).url(forResource: "HEPhotoPicker", withExtension: "bundle")else {
                return nil
            }
            return  Bundle.init(url:url)
        }
    }
}
