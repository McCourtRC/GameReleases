//
//  Utilities.swift
//  GameReleases
//
//  Created by Corey McCourt on 4/19/17.
//  Copyright © 2017 Corey McCourt. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    public func imageFromServerURL(urlString: String) {
        let task = URLSession.shared.dataTask(with: URL(string: urlString)!) { (data, response, error) in
            guard error == nil else {
                print(error!)
                return
            }
            
            DispatchQueue.main.async {
                let image = UIImage(data: data!)
                self.image = image
            }
        }
        task.resume()
    }
}
