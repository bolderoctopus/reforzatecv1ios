//
//  CustomTableViewCell.swift
//  ReforzaTecv1
//
//  Created by Omar Rico on 7/17/17.
//  Copyright © 2017 TecUruapan. All rights reserved.
//

import UIKit

/**
 Permite que al presionar el botón de borrar en una materia esta se borre en MisMateriasViewController
 */
protocol BtnBorrarMateriaDelegate : class {
    func eliminarMateria (_ materia: MateriaCell)
}

class MateriaCell: UITableViewCell {
    
    @IBOutlet weak var TituloView: UIView!
    @IBOutlet weak var DetallesView: UIView! {
        didSet {
            DetallesView?.isHidden = true
            DetallesView?.alpha = 0
        }
    }
    @IBOutlet weak var NombreLabel: UILabel!
    @IBOutlet weak var AbrirButton: UIButton!
    @IBOutlet weak var VersionLabel: UILabel!
    @IBOutlet weak var DescripcionTextView: UITextView!
    @IBOutlet weak var RemoverButton: UIButton!
    @IBOutlet weak var AlturaConstraint: NSLayoutConstraint!
    
    var ReferenciaCD : Materia?
    weak var delegate:BtnBorrarMateriaDelegate?
    var cellExists : Bool = false
    var indicadorDeDescarga: UIActivityIndicatorView!
    var estaDescargando: Bool? {
        didSet{
            indicarDescarga(estaDescargando)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
       self.selectionStyle = UITableViewCellSelectionStyle.none
        
    }
    
    func animate(duration : Double, c: @escaping () -> Void) {        
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: .calculationModePaced, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: duration, animations: {
                self.DetallesView.isHidden = !self.DetallesView.isHidden
                if self.DetallesView.alpha == 1 {
                    self.NombreLabel.numberOfLines = 1
                    self.DetallesView.alpha = 0.5
                    self.AlturaConstraint.constant = 80
                }else {
                    self.NombreLabel.numberOfLines = 0
                    self.NombreLabel.sizeToFit()
                    let constante = self.NombreLabel.frame.size.height
                    self.AlturaConstraint.constant = constante
                    self.DetallesView.alpha = 1
                }
            })
            
        }, completion: { (finished : Bool) in
            c()
            
        })
    }
    
    func indicarDescarga(_ estamosDescargando: Bool?) {
        if let cierto = estaDescargando{
            if cierto{
                indicadorDeDescarga = UIActivityIndicatorView.init(frame: AbrirButton.frame)
                indicadorDeDescarga.alpha  = 0
                indicadorDeDescarga.color = UIColor.black
                indicadorDeDescarga.startAnimating()
                TituloView.addSubview(indicadorDeDescarga)
                UIView.animate(withDuration: 0.4, animations: {
                    self.AbrirButton.alpha = 0
                    self.indicadorDeDescarga.alpha = 1
                })
            }else{
                UIView.animate(withDuration: 0.4, animations: {
                    self.AbrirButton.alpha = 1
                    self.indicadorDeDescarga.alpha = 0
                })
                TituloView.willRemoveSubview(indicadorDeDescarga)
            }
        }
    }
    
    @IBAction func removeMateria(_ sender: Any) {
        delegate?.eliminarMateria(self)
        
    }    
}


