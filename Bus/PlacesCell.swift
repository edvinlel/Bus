//
//  PlacesCell.swift
//  Bus
//
//  Created by Edvin Lellhame on 12/17/18.
//  Copyright © 2018 Edvin Lellhame. All rights reserved.
//

import UIKit

class PlacesCell: UITableViewCell {
    
    let placeLabel: UILabel = {
        let label = UILabel()
        //        rgb(116, 125, 140)
        label.textColor = UIColor(red: 116/255.0, green: 125/255.0, blue: 140/255.0, alpha: 1)
        label.font = UIFont(name: "Avenir", size: 14)
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(placeLabel)
        placeLabel.translatesAutoresizingMaskIntoConstraints = false
        placeLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 35).isActive = true
        placeLabel.topAnchor.constraint(equalTo: topAnchor, constant: 15).isActive =  true
        placeLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
