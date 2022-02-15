//
//  Document.swift
//  Test-TMPL-OPenGL
//
//  Created by MBookAdmin on 19/02/2017.
//  Copyright © 2017 MBookAdmin. All rights reserved
//

import Cocoa

class Document: NSDocument {

    // MARK: --- déclaration des propriétés de l'objet Document
    
    private var données = [Float]()
    var latticeparameter : Double = 0.0
    var step = [Int]()
    var atome = [String]()
    var nombre : Int = 0
    var tableau_xyz = [[[Double]]]()
    var Na : Int = 0 // création de 2 variables vides pour le dénombrement des atomes
    var Nb : Int = 0
    var s : Int = 0 //pour repérer les tableaux (3 en tout)
    
    override init() {
        super.init()
        Swift.print(#function, self.className)
        // MARK: --- initialisation des propriétés de l'objet
        
        données = [ 0.0, 1.1, 2.2, 3.3, 4.4, 5.5 ] // valeurs arbitraires

    }
    
    //
    // méthode appelée par l'option Open... du menu File de l'application exécutée
    //
    override func read(from monURL: URL, ofType nomType: String) throws {
        
        NSLog("%@ %@", self.className, #function)
        
        // affiche le nom de type du fichier sélectionné par l'utilisateur
        NSLog("%@", nomType)
        
        if nomType == "Fichier Output" { // extensions acceptées : .txt, xyz
            Swift.print("URL:",monURL)
            var uneURL = monURL // copie dans var pour pouvoir la modifier
            uneURL.deleteLastPathComponent()
            uneURL.appendPathComponent("TRAJEC_short.xyz")
            Swift.print(">>>",uneURL)
                        
            let str = try String(contentsOf: uneURL)
            var scanDataAtomes = Scanner(string:str)
            var monScanner = Scanner() // création d'un scanner vide
            do {
                let chaineFichier = try String(contentsOf: monURL)
                // à décommenter pour tester le contenu de la variable
                //Swift.print(chaineFichier)
                monScanner = Scanner(string: chaineFichier)
            } catch {
                NSLog("Erreur lecture fichier output ")
                throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
            }
        
            Swift.print("Nous sommes passés ici")
            // ******************************************
            // suite des opérations : parcours du scanner
            // ******************************************
            let cellule_str = monScanner.scanUpToString("CONSTANT(a.u.):") //permet d'acceder au lattice parameter
            let cellule1_str = monScanner.scanUpToCharacters(from: CharacterSet.whitespaces)!
            
            latticeparameter = monScanner.scanDouble()!
            let latticeparameter1 = latticeparameter*0.529177249 //conversion en angstrom
            
            while !scanDataAtomes.isAtEnd { //boucle qui lit et stocke toutes les données du fichier xyz
                let nombre = scanDataAtomes.scanInt()!
                let ligne2 = scanDataAtomes.scanUpToString("STEP:")
                let ligne_2 = scanDataAtomes.scanUpToCharacters(from: CharacterSet.whitespaces)!
                var sstep = scanDataAtomes.scanInt()!
                step.append(sstep)
                
                var conf = [[Double]]()
                for i in 1..<nombre+1 {
                    var aatome = scanDataAtomes.scanUpToCharacters(from: CharacterSet.whitespaces)!
                    if s == 0 {
                        atome.append(aatome)
                    }
                    var x = scanDataAtomes.scanDouble()!
                    var y = scanDataAtomes.scanDouble()!
                    var z = scanDataAtomes.scanDouble()!
                    var tablxyz = [Double]()
                    tablxyz.append(x)
                    tablxyz.append(y)
                    tablxyz.append(z)
                    // il faut replacer les atomes dans la cellule de base
                    for i in 0...2{
                        if tablxyz[i] > latticeparameter1 {
                            tablxyz[i] = tablxyz[i]-latticeparameter1
                        }
                        else if tablxyz[i] < 0{
                            tablxyz[i] += latticeparameter1
                        }
                    }
                    conf.append(tablxyz)
                    
                }
                //Swift.print(conf)
                Swift.print("Le nombre total d'atomes est : ",nombre)
                s = s+1
                tableau_xyz.append(conf)
                }
            //Swift.print(tableau_xyz)
            //calcul du Na et Nb

            for i in 0..<atome.count {
                if atome[i] == "Se" {
                        Nb+=1
                    } else {
                        Na+=1
                }
                }
            //Swift.print(">>>>>>>>atome=",atome)
            Swift.print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Na",Na,">>>>>>>>>>,Nb",Nb)
   
    // appel à la méthode calcul pour réaliser des opérations à partir des données lues (si nécessaire)
            }
            
            
            calcule()
    }
    
   func calcule() {
        Swift.print(">>>>>>>>>>>>>>>>>>s=",s)
        Swift.print("il y a ", tableau_xyz.count, "tableaux")
        let latticeparameter1 = latticeparameter*0.529177249 //conversion en angstrom
        Swift.print("Le paramètre de cellule est : ",latticeparameter1, "Angström")
        let volume = pow(latticeparameter1,3)
        Swift.print("Le volume de la cellule est : ",volume,"Angström^3")
        Swift.print("STEP : ",step)
        //Swift.print(atome)
        //Swift.print(nombre)
        //on génère une supercellule pour prendre en compte les atomes fantômes
        var supercellule = [[[[Double]]]]()
        for i in 0...26{
            supercellule.append(tableau_xyz)
        }
    
        var a = 1
        for i in -1...1{//supercellule avec les translations
            for j in -1...1{
                for k in -1...1{
                    if i==0 && j==0 && k==0 {//on exclut 0,0,0 car c'est la cellule de base
                    } else {
                        for l in 0...s-1 {
                            for m in 1..<nombre+1{
                        supercellule[a][l][m][0] = supercellule[a][l][m][0]+Double(i)*latticeparameter1
                        supercellule[a][l][m][1] = supercellule[a][l][m][1] + Double(j)*latticeparameter1
                        supercellule[a][l][m][2] = supercellule[a][l][m][2]+Double(k)*latticeparameter1
                }
            }
            a+=1
        }
    }
    }
    }
    //Swift.print(supercellule.count) nb d'elements ds la supercellule : 27
    Swift.print("Voici la supercellule",supercellule)
    //détermination des r
    var tabcase = [Int](repeating: 0, count:(Int((latticeparameter1*sqrt(3))/0.01)+1))//compteur qui rajoute 1 dans la case correspondante
    // Swift.print("TESTS",atome[0].count,tableau[0].count)
    
    Swift.print("Donner le nom de l'atome référence")
    var atomeRef = readLine()!
    Swift.print("Donner le nom de l'atome distant")
    var atomeDistant = readLine()!
    for l in 0...s-1{
        // interaction Ge-Se
        if atomeRef == "Ge" && atomeDistant == "Se" {
            for i in 0...atome.count-1{
                for j in 0...atome.count-1{
                    if j == i {continue}
                    if atome[i] == atomeRef && i != atome.count-1{
                        if atome[j] == atomeDistant{
                            var x1 = tableau_xyz[l][i][0]
                            var x2 = tableau_xyz[l][j][0]
                            var y1 = tableau_xyz[l][i][1]
                            var y2 = tableau_xyz[l][j][1]
                            var z1 = tableau_xyz[l][i][2]
                            var z2 = tableau_xyz[l][j][2]
                            var r = sqrt(pow(x1-x2,2) + pow(y1-y2,2) + pow(z1-z2,2))
                            //Swift.print(">>>>>>>>>>>>>r=",r)
                            if r < latticeparameter1{ //remplissage des cases
                                var k = Int(r/0.01)
                                let V_r = 4 * Double.pi * (r*r) * 0.01
                                //Swift.print("V_r =",V_r)
                                let rho_glob = Double(Nb)/volume
                                //Swift.print("rho_glob =", rho_glob)
                                tabcase[k] += 1
                        }
                    }
                }
            }
        }
        for k in 0...tabcase.count-1{
                tabcase[k] = (tabcase[k])/(3)
        }
        Swift.print("Pour un pas de 0.01 on obtient ce compteur",tabcase)
    }
    // interaction Se-Ge
    if atomeRef == "Se" && atomeDistant == "Ge" {
        Na = Nb
        Nb = Na
        for i in 0...atome.count-1{
            for j in 0...atome.count-1{
                if j == i {continue}
                if atome[i] == atomeRef && i != atome.count-1{
                    if atome[j] == atomeDistant{
                        var x1 = tableau_xyz[l][i][0]
                        var x2 = tableau_xyz[l][j][0]
                        var y1 = tableau_xyz[l][i][1]
                        var y2 = tableau_xyz[l][j][1]
                        var z1 = tableau_xyz[l][i][2]
                        var z2 = tableau_xyz[l][j][2]
                        var r = sqrt(pow(x1-x2,2) + pow(y1-y2,2) + pow(z1-z2,2))
                        //Swift.print(">>>>>>>>>>>>>r=",r)
                        if r < latticeparameter1{ //remplissage des cases
                            var k = Int(r/0.01)
                            let V_r = 4 * Double.pi * (r*r) * 0.01
                            //Swift.print("V_r =",V_r)
                            let rho_glob = Double(Nb)/volume
                            //Swift.print("rho_glob =", rho_glob)
                            tabcase[k] += 1
                    }
                }
            }
        }
    }
        for k in 0...tabcase.count-1{
            tabcase[k] = (tabcase[k])/(3)
        }
        Swift.print("Pour un pas de 0.01 on obtient ce compteur",tabcase)
}
    // interaction Se-Se
    if atomeRef == "Se" && atomeDistant == "Se" {
        Na = Nb
            for i in 0...atome.count-1{
                for j in 0...atome.count-1{
                    if j == i {continue}
                    if atome[i] == atomeRef && i != atome.count-1{
                        if atome[j] == atomeDistant{
                            var x1 = tableau_xyz[l][i][0]
                            var x2 = tableau_xyz[l][j][0]
                            var y1 = tableau_xyz[l][i][1]
                            var y2 = tableau_xyz[l][j][1]
                            var z1 = tableau_xyz[l][i][2]
                            var z2 = tableau_xyz[l][j][2]
                            var r = sqrt(pow(x1-x2,2) + pow(y1-y2,2) + pow(z1-z2,2))
                            //Swift.print(">>>>>>>>>>>>>r=",r)
                            if r < latticeparameter1{ //remplissage des cases
                                var k = Int(r/0.01)
                                let V_r = 4 * Double.pi * (r*r) * 0.01
                                //Swift.print("V_r =",V_r)
                                let rho_glob = Double(Nb)/volume
                                //Swift.print("rho_glob =", rho_glob)
                                tabcase[k] += 1
                        }
                    }
                }
            }
        }
        for k in 0...tabcase.count-1{
            tabcase[k] = (tabcase[k])/(3)
        }
        Swift.print("Pour un pas de 0.01 on obtient ce compteur",tabcase)
        
    // interaction Ge-Ge
    if atomeRef == "Ge" && atomeDistant == "Ge" {
        Nb = Na
            for i in 0...atome.count-1{
                for j in 0...atome.count-1{
                    if j == i {continue}
                    if atome[i] == atomeRef && i != atome.count-1{
                        if atome[j] == atomeDistant{
                            var x1 = tableau_xyz[l][i][0]
                            var x2 = tableau_xyz[l][j][0]
                            var y1 = tableau_xyz[l][i][1]
                            var y2 = tableau_xyz[l][j][1]
                            var z1 = tableau_xyz[l][i][2]
                            var z2 = tableau_xyz[l][j][2]
                            var r = sqrt(pow(x1-x2,2) + pow(y1-y2,2) + pow(z1-z2,2))
                            //Swift.print(">>>>>>>>>>>>>r=",r)
                            if r < latticeparameter1{ //remplissage des cases
                                var k = Int(r/0.01)
                                let V_r = 4 * Double.pi * (r*r) * 0.01
                                //Swift.print("V_r =",V_r)
                                let rho_global = Double(Nb)/volume
                                //Swift.print("rho_glob =", rho_glob)
                                tabcase[k] += 1
                        }
                    }
                }
            }
        }
        for k in 0...tabcase.count-1{
            tabcase[k] = (tabcase[k])/(3)
        }
        Swift.print("Pour un pas de 0.01 on obtient ce compteur",tabcase)
        
    }
}
var rho_r = Double()
var g_r = Double()
var n_r = Double()
let rho_global = Double(Nb)/volume
var r = Double()
var integrale : Double = 0.0
for i in 1...tabcase.count-1{
    r = Double(i)*0.01 + 0.01
    let V_r = 4 * Double.pi * (r*r) * 0.01
    rho_r = Double(1/V_r) * Double(1/Na) * Double(tabcase[i])
    g_r = 1/rho_global * rho_r
    for i in 0...Int(r)-1{
        integrale = integrale + pow(Double(i),2) * g_r * 0.01
    }
    n_r = 4 * Double.pi * rho_global * integrale
}
}
}
    override func data(ofType typeName: String) throws -> Data {
        // Insert code here to write your document to data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning nil.
        // You can also choose to override fileWrapperOfType:error:, writeToURL:ofType:error:, or writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    }

    override func windowControllerDidLoadNib(_ aController: NSWindowController) {
        NSLog("%@", #function)
        super.windowControllerDidLoadNib(aController)
    }
    
    override func awakeFromNib() { }
    
    override var windowNibName: NSNib.Name? {
        // Returns the nib file name of the document
        // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this property and override -makeWindowControllers instead.
        return NSNib.Name("Document")
    }

    // MARK: --- déclarations des méthodes additionnelles de l'objet Document

    // pour l'échange de données entre l'objet Document et l'openGLView
    func getUneDonnée(Numéro: Int) -> Float? {
        
        if Numéro >= 0 && Numéro < données.count {
            return données[Numéro]
        } else {
            return nil
        }
    }
}
