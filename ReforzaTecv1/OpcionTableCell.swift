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
    @IBOutlet weak var etiqueta: UILabel!
    
    static let reuseId : String = "celdaOpcion"
    var color : UIColor!
    var estadoActual : posiblesEstados!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        etiqueta.layer.borderWidth = 1.5
        etiqueta.layer.cornerRadius = 6
        etiqueta.tag = 1
        self.selectionStyle = UITableViewCellSelectionStyle.none
        
    }
    
    func inicializar(titulo: String, color: UIColor) {
        etiqueta.text = titulo
        self.color = color
       //etiqueta.textColor = color
        etiqueta.layer.borderColor = color.cgColor
        
        estadoActual = posiblesEstados.blanco
    }
    
    func marcar(bien : Bool) {
       // UIView.animate(withDuration: 0.2, delay: 0, options: [], animations: {
            let colorNuevo = (bien) ?  #colorLiteral(red: 0.1906670928, green: 0.9801233411, blue: 0.474581778, alpha: 1) : #colorLiteral(red: 1, green: 0.3005838394, blue: 0.2565174997, alpha: 1)
            self.etiqueta.layer.borderColor = colorNuevo.cgColor
            self.etiqueta.layer.backgroundColor = colorNuevo.cgColor
            self.etiqueta.textColor = UIColor.white
      // }, completion: nil)
       
    }
    

    func  agitar(){
        marcar(bien: false)
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 1.5
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - 10, y: self.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + 10, y: self.center.y))
        self.layer.add(animation, forKey: "position")
    }
    
    // no usar, el bloque de completion se llama antes de tiempo cuando la intento sincronizar con la animacion de la otra clase
    func  saltar(retraso: Double, fin : ()){
        UIView.animateKeyframes(withDuration: 0.3, delay: retraso, options: [], animations: {            
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 2/3, animations: {
                self.etiqueta.transform = CGAffineTransform.init(scaleX: 1.1, y: 0.98)
                self.marcar(bien: true)
            })
            UIView.addKeyframe(withRelativeStartTime: 2/3, relativeDuration: 1/3, animations: {
                self.etiqueta.transform = CGAffineTransform.init(scaleX: 1, y: 1)
                
            })
        }, completion: {(finalizo: Bool) in
                fin
        })
    }
    
}
