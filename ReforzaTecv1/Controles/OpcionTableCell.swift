//
//  OpcionTableCell.swift
//  ReforzaTecv1
//
//  Created by Omar Rico on 8/1/17.
//  Copyright © 2017 TecUruapan. All rights reserved.
//

import UIKit

enum posiblesEstados {
    case equivocado
    case acertado
    case blanco
}

class OpcionTableCell: UITableViewCell {
    static let REUSE_ID : String = "celdaOpcion"
    
    @IBOutlet weak var TextoLabel: UILabel!
    var color : UIColor!
    var estadoActual : posiblesEstados!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        TextoLabel.layer.borderWidth = 1.5
        TextoLabel.layer.cornerRadius = 6
        TextoLabel.tag = 1
        self.selectionStyle = UITableViewCellSelectionStyle.none
    }
    
    func inicializar(titulo: String, color: UIColor) {
        TextoLabel.text = titulo
        self.color = color
        TextoLabel.layer.borderColor = color.cgColor
        estadoActual = posiblesEstados.blanco
    }
    
    func marcar(bien : Bool) {
            let colorNuevo = (bien) ?  #colorLiteral(red: 0.1906670928, green: 0.9801233411, blue: 0.474581778, alpha: 1) : #colorLiteral(red: 1, green: 0.3005838394, blue: 0.2565174997, alpha: 1)
            self.TextoLabel.layer.borderColor = colorNuevo.cgColor
            self.TextoLabel.layer.backgroundColor = colorNuevo.cgColor
            self.TextoLabel.textColor = UIColor.white       
    }

    func agitar(){
        marcar(bien: false)
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 1.5
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - 10, y: self.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + 10, y: self.center.y))
        self.layer.add(animation, forKey: "position")
    }    
    
    func  saltar(retraso: Double, fin : ()){
        UIView.animateKeyframes(withDuration: 0.3, delay: retraso, options: [], animations: {            
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 2/3, animations: {
                self.TextoLabel.transform = CGAffineTransform.init(scaleX: 1.1, y: 0.98)
                self.marcar(bien: true)
            })
            UIView.addKeyframe(withRelativeStartTime: 2/3, relativeDuration: 1/3, animations: {
                self.TextoLabel.transform = CGAffineTransform.init(scaleX: 1, y: 1)
                
            })
        }, completion: {(finalizo: Bool) in
                fin
        })
    }
    
}
