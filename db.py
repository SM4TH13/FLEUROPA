import psycopg2
import psycopg2.extras as PE

def connect():
  conn = psycopg2.connect(
    host='localhost',
    user='mathusan',
    dbname = 'fleuropa',
    cursor_factory = psycopg2.extras.NamedTupleCursor
  )
  conn.autocommit = True
  return conn


############# MAGASIN  ##############

def recuperer_magasin(idmagasin):
    conn = connect()
    if conn is None:
        return []
    cur = conn.cursor()
    cur.execute("SELECT * FROM magasin WHERE idmagasin = %s", (idmagasin,))
    resultat = cur.fetchone()
    cur.close()
    conn.close()
    return resultat

def recuperer_lieu_magasins(page=1, limit=10):
    conn = connect()
    if conn is None:
        return [], 0
    cur = conn.cursor()
    cur.execute("SELECT COUNT(*) FROM magasin")
    total_magasins = cur.fetchone()[0]
    offset = (page - 1) * limit
    cur.execute(f"SELECT IdMagasin, Lieu FROM magasin ORDER BY Lieu LIMIT {limit} OFFSET {offset}")
    resultat = cur.fetchall()
    cur.close()
    conn.close()
    return resultat, total_magasins
    

############# BOUQUET  ##############

def recuperer_best_sellers():
    conn = connect()
    if conn is None:
        return []
    cur = conn.cursor()
    cur.execute("SELECT idbouquet, modele, taille, prixunitaire, photobouquet FROM vue_top_bouquets LIMIT 5")
    resultat = cur.fetchall()
    cur.close()
    conn.close()
    return resultat

def recuperer_bouquet(idbouquet):
    conn = connect()
    if conn is None:
        return []
    cur = conn.cursor()
    cur.execute("SELECT * FROM bouquet WHERE idbouquet = %s", (idbouquet,))
    resultat = cur.fetchone()
    cur.close()
    conn.close()
    return resultat    

def check_bouquet(idbouquet):
    conn = connect()
    if conn is None:
        return[]
    cur = conn.cursor()
    cur.execute("SELECT idbouquet FROM bouquet")
    bouquets = cur.fetchall()
    cur.close()
    conn.close()
    for bouquet in bouquets:
        if idbouquet == bouquet:
            return True
    return False

def recuperer_modele_bouquet(page=1, limit=10):
    conn = connect()
    if conn is None:
        return [], 0
    cur = conn.cursor()
    cur.execute("SELECT COUNT(*) FROM bouquet")
    total_magasins = cur.fetchone()[0]
    offset = (page - 1) * limit
    cur.execute(f"SELECT idbouquet, modele, taille, photobouquet FROM bouquet ORDER BY modele LIMIT {limit} OFFSET {offset}")
    resultat = cur.fetchall()
    cur.close()
    conn.close()
    return resultat, total_magasins



############# CLIENT  ##############

def recupernomclient(Numcommande):
    conn = connect()
    if conn is None:
        return []
    cur = conn.cursor()
    cur.execute(f"SELECT nom ||' '|| prenom as NomComplet FROM CLIENT Natural join commande Where NumCommande = {Numcommande}")
    resultat = cur.fetchone()
    cur.close()
    conn.close()
    return resultat.nomcomplet

def recuperinfoclient():
    conn = connect()
    if conn is None:
        return []
    cur = conn.cursor()
    cur.execute("SELECT * FROM CLIENT")
    resultat = cur.fetchall()
    cur.close()
    conn.close()
    return resultat

def recuperinfoclient(numclient):
    conn = connect()
    if conn is None:
        return []
    cur = conn.cursor()
    cur.execute("SELECT * FROM CLIENT where numclient = %s", (numclient,))
    resultat = cur.fetchone()
    cur.close()
    conn.close()
    return resultat

def inscrire_client(nom, prenom, telephone, email, mdp):
    conn = connect()
    if conn is None:
        return False
    cur = conn.cursor()
    try:
        cur.execute(
            """
            INSERT INTO CLIENT (Nom, Prenom, NumTelCl, Mail, MDP, Adresse_Rue, Adresse_CP, Adresse_Ville, Adherent) 
            VALUES (%s, %s, %s, %s, %s, 'Non renseigné', '00000', 'Inconnu', FALSE)
            """,
            (nom, prenom, telephone, email, mdp)
        )
        conn.commit()
        succes = True
    except Exception as e:
        print(f"Erreur SQL lors de l'inscription : {e}")
        succes = False
    finally:
        cur.close()
        conn.close()
    return succes

def recuper_numclient(mail):
    conn = connect()
    if conn is None:
        return []
    cur = conn.cursor()
    cur.execute(
        "SELECT Numclient FROM client WHERE mail = %s ",
        (mail)
    )
    resultat = cur.fetchone()
    cur.close()
    conn.close()
    return resultat


def recuperID(id, mdp):
    conn = connect()
    if conn is None:
        return []
    cur = conn.cursor()
    cur.execute(
        "SELECT NumCommande, CodeConfidentiel , Numclient FROM COMMANDE WHERE NumCommande = %s AND CodeConfidentiel = %s",
        (id, mdp)
    )
    resultat = cur.fetchone()
    cur.close()
    conn.close()
    return resultat


############# PANIER  ##############

def recuperer_panier_detaille(panier):
    conn = connect()
    if conn is None:
        return []
    cur = conn.cursor()
    if not panier:
        return [], 0.0
    infos = {}
    total = 0
    for bouquet, quantite in panier.items():
        cur.execute("SELECT modele, prixunitaire, taille from bouquet where idbouquet = %s",(bouquet,))
        infos[bouquet] = cur.fetchone()
        total += quantite * infos[bouquet].prixunitaire
    return infos, total
        
def recup_destinataire(numclient):
    conn = connect()
    if conn is None:
        return []
    cur = conn.cursor()
    cur.execute(
        "SELECT d.NumDestinataire,d.Nom , d.Prenom, d.Rue, d.CodePostal FROM DESTINATAIRE d NATURAL JOIN COMMANDE co LEFT JOIN CLIENT cl ON cl.Numclient = co.Numclient where Numcommande = %s ",
        (numclient,)
    )
    resultat = cur.fetchall()
    cur.close()
    conn.close()
    return resultat 

# Ajoutez l'argument "est_adherent" à la fin
def inscrire_client(nom, prenom, telephone, mail, adherent, rue, cp, ville):
    conn = connect()
    if conn is None: return False
    cur = conn.cursor()
    try:
        cur.execute(
            """
            INSERT INTO CLIENT (Nom, Prenom, NumTelCl, Mail, MDP, Adherent, Adresse_Rue, Adresse_CP, Adresse_Ville) 
            VALUES (%s, %s, %s, 'hash', %s, %s, %s, %s, %s)
            """, (nom, prenom, telephone, mail, adherent, rue, cp, ville,)
        )
        conn.commit()
        return True
    except Exception as e:
        print(f"Erreur inscription : {e}")
        return False
    finally:
        conn.close()


def inscrire_destinataire(nom, prenom, rue, cp):
    conn = connect()
    if conn is None: return False
    cur = conn.cursor()
    try:
        cur.execute(
            """
            INSERT INTO DESTINATAIRE (Nom, Prenom, Rue, CodePostal) 
            VALUES (%s, %s, %s, %s)
            """, (nom, prenom, rue, cp,)
        )
        nouveau_id = cur.fetchone().numclient
        conn.commit()
        return nouveau_id
    except Exception as e:
        print(f"Erreur inscription : {e}")
        return None
    finally:
        conn.close()

def recup_IDdestinataire(nom, rue, cp):
    conn = connect()
    if conn is None:
        return []
    cur = conn.cursor()
    cur.execute(
        "SELECT NumDestinataire FROM DESTINATAIRE WHERE Nom = %s AND Rue = %s AND CodePostal = %s ",
        (nom, rue, cp)
    )
    resultat = cur.fetchone()
    cur.close()
    conn.close()
    return resultat 

def enregistrer_commande(numclient, numdestinataire, total):
    pass



