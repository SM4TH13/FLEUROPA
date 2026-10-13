import random
from flask import Flask, render_template, request, redirect, url_for, session
import db



app = Flask(__name__)
app.secret_key = '6Y5T4R3E2Z1A'

@app.route("/")
@app.route("/accueil")
def welcome():
    nomClient = session.get('Nomcomplet')
    bouquets = db.recuperer_best_sellers()
    return render_template("accueil.html", liste_bouquet = bouquets, client  = nomClient)


########### CONNEXION ################

@app.route("/connecter", methods=['GET', 'POST']) 
def connecter():
    if request.method == 'POST': 
        commande = request.form.get('commande')
        code = request.form.get('code')
        resultat = db.recuperID(commande, code)
        
        if resultat:
            session['commande'] = commande
            session['code'] = code
            session['Numclient'] = resultat.numclient
            session['Nomcomplet'] = db.recupernomclient(resultat.numcommande)            
            return redirect(url_for('welcome'))
        else:
            return render_template("connecter.html", error="Identifiants incorrects.")
    
    return render_template("connecter.html")


@app.route("/inscription", methods=['GET', 'POST']) 
def inscription():
    if request.method == 'POST': 
        nom = request.form.get('nom')
        prenom = request.form.get('prenom')
        telephone = request.form.get('numero') 
        mail = request.form.get('mail')        
        mdp = request.form.get('mdp')
        confirm_mdp = request.form.get('confirm_mdp')
        
        if mdp != confirm_mdp:
            return render_template("inscription.html", error="Les mots de passe ne correspondent pas.")
            
        succes = db.inscrire_client(nom, prenom, telephone, mail, mdp)
        if succes:
            session['Nomcomplet'] = f"{nom} {prenom}"
            session['Numclient'] = db.recuper_numclient(mail)
            return redirect(url_for('connecter'))
        else:
            return render_template("inscription.html", error="Erreur lors de l'inscription.")

    return render_template("inscription.html")


########### BOUTIQUES ################

@app.route("/boutiques")
def boutiques():
    page = request.args.get('page', 1, type=int)
    noms_magasin, total_magasins = db.recuperer_lieu_magasins(page=page, limit=9)
    total_pages = (total_magasins / 9) if ((total_magasins / 9) - (total_magasins // 9)) == 0 else (total_magasins // 9)+1
    return render_template(
        "boutiques.html", liste_boutiques = noms_magasin, page_actuelle = page, total_pages = total_pages)

@app.route("/boutiques/<idmagasin>") 
def fiche_magasin(idmagasin):
    magasin_details = db.recuperer_magasin(idmagasin)
    print(magasin_details)
    if magasin_details is not None:
        return render_template("fiche_magasin.html", magasin=magasin_details)
    return redirect(url_for('boutiques'))


########### BOUQUETS ################


@app.route("/bouquets")
def bouquets():
    page = request.args.get('page', 1, type=int)
    nom_bouquets, total_bouquets = db.recuperer_modele_bouquet(page=page, limit=9)
    total_pages = (total_bouquets / 9) if ((total_bouquets / 9) - (total_bouquets // 9)) == 0 else (total_bouquets // 9)+1
    return render_template("bouquets.html", liste_bouquets = nom_bouquets, page_actuelle = page, total_pages = total_pages)

@app.route("/bouquets/<int:idbouquet>") 
def fiche_bouquet(idbouquet):
    bouquet_details = db.recuperer_bouquet(idbouquet)
    if bouquet_details is not None:
        return render_template("fiche_bouquet.html", bouquet=bouquet_details) 
    return redirect(url_for('bouquets'))


########### PANIER ################

@app.route("/ajout_bouquet/<idbouquet>", methods=['POST'])
def ajouter_panier(idbouquet):
    panier = session.get('Panier', {})
    quantite = int(request.form.get('quantite', 1))
    if idbouquet in panier:
        panier[idbouquet] += quantite    
    else: 
        panier[idbouquet] = quantite
    session['Panier'] = panier
    session.modified = True 
    return redirect("/panier")

@app.route("/supprimer_bouquet/<idbouquet>", methods=['GET'])
def supprimer_bouquet(idbouquet):
    panier = session.get('Panier', {})
    if idbouquet in panier:
        del panier[idbouquet]    
    session['Panier'] = panier
    session.modified = True 
    return redirect("/panier")


@app.route("/panier", methods = ['GET'])
def affiche_panier():
    panier = session.get('Panier', {})
    infos, total = None, None
    if panier :
        infos, total = db.recuperer_panier_detaille(panier)
        session['Total'] = total
    return render_template("panier.html", panier = panier, infos = infos, total = total)

@app.route("/confirmer_commande", methods = ['GET'])
def valider_infos_panier():
    num_client = session.get('Numclient')
    total = float(session.get('Total', 0))
    client = None
    ancien = None
    if num_client:
        client = db.recuperinfoclient(num_client)
        ancien = db.recup_destinataire(num_client)
        total = round(total*0.9 if client.adherent == True else total, 2)
        session['Total'] = total

    return render_template("confirmation_commande.html", client = client , ancien = ancien, total = total)

@app.route("/valider_commande", methods = ['POST'])
def valider_commande():
    panier = session.get('Panier')
    total = session.get('Total')
    num_client = session.get('Numclient', None)
    #ajouter un nouveau client
    if not num_client:
        nom = request.form.get("new_nom")
        prenom = request.form.get("nex_prenom")
        mail = request.form.get("new_mail_cl")
        telephone = request.form.get("new_num_cl")
        rue = request.form.get("adresse_rue")
        cp = request.form.get("adresse_cp")
        ville = request.form.get("adresse_ville")
        adherent = request.form.get('adherent') == True
        success = db.inscrire_client(nom, prenom, telephone, mail, adherent, rue, cp, ville)
        if success:
             num_client = db.recuper_numclient(mail).numclient
             session['Numclient'] = num_client 
    #ajouter destinataire
    nom_d = request.form.get("new_nom_d")
    prenom_d = request.form.get("new_prenom_d")
    rue_d = request.form.get("new_rue_d")
    cp_d = request.form.get("new_cp_d")
    if db.inscrire_destinataire(nom_d, prenom_d, rue_d, cp_d):
        num_destinataire = db.recup_IDdestinataire(nom_d, rue_d, cp_d)


    #ajouter la commande
    return render_template("valide_commande.html")


if __name__ == '__main__':
    app.run(debug= True)
