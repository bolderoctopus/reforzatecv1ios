//
//  ExpandibleHeaderRow.swift
//  ReforzaTecv1
//
//  Created by Delfin: Verano Científico on 26/07/17.
//  Copyright © 2017 TecUruapan. All rights reserved.
//

import UIKit

/**
 Permite que las unidades mostradas en ContenidoMateria se expandan o contraigan al tocarlas.
 */
protocol ExpandibleHeaderRowDelegate {
    func toggleSelection(header: ExpandibleHeaderView, section: Int)
}

class ExpandibleHeaderView: UITableViewHeaderFooterView {
    
    var delegate : ExpandibleHeaderRowDelegate?
    var section: Int!
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectHeaderAction)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func selectHeaderAction (gestureRecognizer : UITapGestureRecognizer) {
        let cell = gestureRecognizer.view as! ExpandibleHeaderView
        delegate?.toggleSelection(header: self, section: cell.section)
        
    }
    
    func customInit(title : String, section: Int, delegate: ExpandibleHeaderRowDelegate) {
        self.textLabel?.text = title
        self.section = section
        self.delegate = delegate
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.textLabel?.textColor = UIColor.white
        self.contentView.backgroundColor = UIColor.darkGray
    }

}
