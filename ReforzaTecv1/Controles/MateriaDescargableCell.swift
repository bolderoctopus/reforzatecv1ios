//
//  MateriaDescargableCell.swift
//  ReforzaTecv1
//
//  Created by Delfin: Verano Científico on 21/07/17.
//  Copyright © 2017 TecUruapan. All rights reserved.
//

import UIKit


/**
 Para que al presionar el botón de la vista de esta clase, se llame la función de descargar en
 MateriasDsponiblesViewController y se inicie la descarga
 */
protocol BtnMateriaDelegate : class {
    func btnDescargarDelegate (_ row : MateriaDescargableCell)
}

class MateriaDescargableCell: UITableViewCell {
   
    
    @IBOutlet weak var TituloView: UIView!
    @IBOutlet weak var DetallesView: UIView! {
        didSet {
            DetallesView?.isHidden = true
            DetallesView?.alpha = 0
        }
    }
    @IBOutlet weak var DescripcionTextView: UITextView!
    @IBOutlet weak var DescargarButton: UIButton!
    @IBOutlet weak var AlturaConstraint: NSLayoutConstraint!
    @IBOutlet weak var NombreLabel: UILabel!
    @IBOutlet weak var VersionLabel: UILabel!
    
    
    var objMateria : MateriaStruct?
    var cellExists : Bool = false
    var indicadorDeDescarga: UIActivityIndicatorView!
    var estamosDescargando: Bool!{
        didSet{
            indicarDescarga(estamosDescargando)
        }
    }
    weak var delegate :BtnMateriaDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = UITableViewCellSelectionStyle.none        
    }
 
    @IBAction func descargar(_ sender: Any) {
        delegate?.btnDescargarDelegate(self)
    }
    
    private func indicarDescarga(_ estamosDescargando: Bool) {
        if estamosDescargando == false{
            TituloView.willRemoveSubview(indicadorDeDescarga)
            
            UIView.animate(withDuration: 0.4, animations: {
                self.DescargarButton.alpha = 1
                self.indicadorDeDescarga.alpha = 0
            })
            return
        }
        
        if(indicadorDeDescarga == nil){
            indicadorDeDescarga = UIActivityIndicatorView.init(frame: DescargarButton.frame)
            indicadorDeDescarga.alpha  = 0
            indicadorDeDescarga.color = UIColor.black
            indicadorDeDescarga.startAnimating()
            TituloView.addSubview(indicadorDeDescarga)
            
            UIView.animate(withDuration: 0.4, animations: {
                self.DescargarButton.alpha = 0
                self.indicadorDeDescarga.alpha = 1
            })
        }

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
    
}
