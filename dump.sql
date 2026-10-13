-- ============================================
-- SUPPRESSION DES TABLES
-- ============================================
DROP TABLE IF EXISTS PREND_EN_CHARGE CASCADE;
DROP TABLE IF EXISTS CONTIENT CASCADE;
DROP TABLE IF EXISTS COMMANDE CASCADE;
DROP TABLE IF EXISTS BOUQUET CASCADE;
DROP TABLE IF EXISTS CLIENT CASCADE;
DROP TABLE IF EXISTS DESTINATAIRE CASCADE;
DROP TABLE IF EXISTS LIVREUR CASCADE;
DROP TABLE IF EXISTS MAGASIN CASCADE;
DROP TABLE IF EXISTS CODE_POSTAUX CASCADE;

-- ============================================
-- CRÉATION DES TABLES
-- ============================================

-- Table MAGASIN (créée en premier)
CREATE TABLE MAGASIN (
    IdMagasin SERIAL PRIMARY KEY,
    Lieu VARCHAR(100) NOT NULL,
    Responsable VARCHAR(100) NOT NULL,
    CodePostal CHAR(5) NOT NULL UNIQUE
);

-- Table CODE_POSTAUX avec référence au magasin
CREATE TABLE CODE_POSTAUX (
    CodePostal CHAR(5) PRIMARY KEY,
    IdMagasin INT NOT NULL,
    FOREIGN KEY (IdMagasin) REFERENCES MAGASIN(IdMagasin) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Table LIVREUR
CREATE TABLE LIVREUR (
    IdLivreur SERIAL PRIMARY KEY,
    NomLiv VARCHAR(50) NOT NULL,
    NumTelLiv VARCHAR(15) NOT NULL,
    CodePostal CHAR(5) NOT NULL,
    FOREIGN KEY (CodePostal) REFERENCES CODE_POSTAUX(CodePostal) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Table DESTINATAIRE
CREATE TABLE DESTINATAIRE (
    NumDestinataire SERIAL PRIMARY KEY,
    Nom VARCHAR(50) NOT NULL,
    Prenom VARCHAR(50) NOT NULL,
    Rue VARCHAR(100) NOT NULL,
    CodePostal CHAR(5) NOT NULL,
    FOREIGN KEY (CodePostal) REFERENCES CODE_POSTAUX(CodePostal) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Table CLIENT
CREATE TABLE CLIENT (
    NumClient SERIAL PRIMARY KEY,
    Nom VARCHAR(50) NOT NULL,
    Prenom VARCHAR(50) NOT NULL,
    MDP VARCHAR(100) ,
    Adherent BOOLEAN DEFAULT FALSE,
    Mail VARCHAR(100) UNIQUE, 
    Adresse_Rue VARCHAR(100) , -- N° et Rue
    Adresse_CP CHAR(5),       -- Code Postal
    Adresse_Ville VARCHAR(50),-- Ville
    NumTelCl VARCHAR(15) NOT NULL
);
-- Table COMMANDE
CREATE TABLE COMMANDE (
    NumCommande SERIAL PRIMARY KEY,
    DateCommande DATE,
    DateExpedition DATE,
    PrixTotal DECIMAL(10, 2),
    Message TEXT,
    CodeConfidentiel VARCHAR(20),
    PhotoCommande VARCHAR(255),
    NumClient INT,
    NumDestinataire INT,
    EtatCommande VARCHAR(50) CHECK (EtatCommande IN ('Annulé', 'En cours de préparation', 'En cours de livraison', 'Arrivé')),
    FOREIGN KEY (NumClient) REFERENCES CLIENT(NumClient) ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (NumDestinataire) REFERENCES DESTINATAIRE(NumDestinataire) ON DELETE SET NULL ON UPDATE CASCADE
);

-- Table BOUQUET
CREATE TABLE BOUQUET (
    IdBouquet SERIAL PRIMARY KEY,
    Modele VARCHAR(50),
    Taille VARCHAR(20) CHECK (Taille IN ('Petit', 'Moyen', 'Grand')),
    PrixUnitaire DECIMAL(10, 2),
    Saison VARCHAR(20) CHECK (Saison IN ('Ete', 'Printemps', 'Automne', 'Hiver')),
    Description TEXT,
    PhotoBouquet VARCHAR(255)
);

-- Table CONTIENT
CREATE TABLE CONTIENT (
    NumCommande INT,
    IdBouquet INT,
    Quantite INT DEFAULT 1,
    PRIMARY KEY (NumCommande, IdBouquet),
    FOREIGN KEY (NumCommande) REFERENCES COMMANDE(NumCommande) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (IdBouquet) REFERENCES BOUQUET(IdBouquet) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Table PREND_EN_CHARGE
CREATE TABLE PREND_EN_CHARGE (
    IdLivreur INT,
    NumCommande INT,
    PRIMARY KEY (IdLivreur, NumCommande),
    FOREIGN KEY (NumCommande) REFERENCES COMMANDE(NumCommande) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (IdLivreur) REFERENCES LIVREUR(IdLivreur) ON DELETE CASCADE ON UPDATE CASCADE
);

-- ============================================
-- CRÉATION DES VUES
-- ============================================

CREATE VIEW vue_livreurs_zones AS
SELECT 
    NomLiv as nomLivreur,
    NumTelLiv as numerotelephone,
    CodePostal,
    Lieu AS Magasin
FROM LIVREUR 
NATURAL JOIN CODE_POSTAUX 
NATURAL JOIN MAGASIN 
ORDER BY Lieu, NomLiv;


CREATE VIEW vue_top_bouquets AS
SELECT 
    b.IdBouquet,
    b.Modele,
    b.Taille,
    b.PrixUnitaire,
    b.PhotoBouquet,
    COUNT(co.NumCommande) AS NombreCommandes,
    SUM(co.Quantite) AS QuantiteTotale,
    SUM(b.PrixUnitaire * co.Quantite) AS ChiffreAffaireTotal
FROM BOUQUET b
JOIN CONTIENT co ON b.IdBouquet = co.IdBouquet
GROUP BY b.IdBouquet, b.Modele, b.Taille, b.PrixUnitaire, b.PhotoBouquet
ORDER BY QuantiteTotale DESC, ChiffreAffaireTotal DESC;



CREATE VIEW vue_classement_magasins AS
SELECT 
    m.IdMagasin,
    m.Lieu AS NomMagasin,
    m.Responsable,
    COUNT(c.NumCommande) AS NombreVentes,
    SUM(c.PrixTotal) AS ChiffreAffaireTotal
FROM MAGASIN m
LEFT JOIN CODE_POSTAUX cp ON m.IdMagasin = cp.IdMagasin
LEFT JOIN DESTINATAIRE d ON cp.CodePostal = d.CodePostal
LEFT JOIN COMMANDE c ON d.NumDestinataire = c.NumDestinataire
GROUP BY m.IdMagasin, m.Lieu, m.Responsable
ORDER BY SUM(c.PrixTotal) DESC NULLS LAST;

-- ============================================
-- INSERTIONS
-- ============================================

-- MAGASIN (d'abord les magasins)
INSERT INTO MAGASIN (Lieu, Responsable, CodePostal) VALUES 
('Paris Centre', 'Fatima Benali', '75001'),
('Lyon Presqu''île', 'Chen Li', '69001'),
('Marseille Vieux-Port', 'Youssef Alaoui', '13001'),
('Toulouse Centre', 'Priya Kapoor', '31000'),
('Nice Promenade', 'Ahmed Hassan', '06000'),
('Nantes Centre', 'Amara Diop', '44000'),
('Strasbourg Centre', 'Sofia Popescu', '67000'),
('Montpellier Antigone', 'Carlos Silva', '34000'),
('Bordeaux Chartrons', 'Leila Aziz', '33000'),
('Lille Centre', 'Kwame Mensah', '59000'),
('Rennes République', 'Aisha Patel', '35000'),
('Reims Centre', 'Giovanni Rossi', '51100'),
('Saint-Étienne Centre', 'Nadia El Amrani', '42000'),
('Toulon Port', 'Raj Sharma', '83000'),
('Le Havre Centre', 'Aminata Keita', '76600'),
('Grenoble Centre', 'Dmitri Volkov', '38000'),
('Dijon Centre', 'Mariam Toure', '21000'),
('Angers Centre', 'Luis Fernandez', '49000'),
('Nîmes Arènes', 'Safiya Traore', '30000'),
('Villeurbanne Gratte-Ciel', 'Kenji Tanaka', '69100'),
('Clermont-Ferrand Jaude', 'Elena Martinez', '63000'),
('Aix-en-Provence Cours', 'Omar Jaber', '13100'),
('Brest Centre', 'Mei Lin', '29200'),
('Tours Centre', 'Ibrahim Nour', '37000'),
('Amiens Centre', 'Isabela Costa', '80000'),
('Limoges Centre', 'Leila Mansour', '87000'),
('Annecy Lac', 'Takumi Sato', '74000'),
('Perpignan Centre', 'Zahra Hosseini', '66000'),
('Besançon Centre', 'Anton Sokolov', '25000'),
('Metz Centre', 'Anika Das', '57000');

-- CODE_POSTAUX avec attribution aux magasins
-- Paris (Magasin 1) - Tous les arrondissements de Paris
INSERT INTO CODE_POSTAUX (CodePostal, IdMagasin) VALUES 
('75001', 1), ('75002', 1), ('75003', 1), ('75004', 1), ('75005', 1), 
('75006', 1), ('75007', 1), ('75008', 1), ('75009', 1), ('75010', 1),
('75011', 1), ('75012', 1), ('75013', 1), ('75014', 1), ('75015', 1), 
('75016', 1), ('75017', 1), ('75018', 1), ('75019', 1), ('75020', 1);

-- Lyon (Magasin 2) - Départements 69
INSERT INTO CODE_POSTAUX (CodePostal, IdMagasin) VALUES 
('69001', 2), ('69002', 2), ('69003', 2), ('69004', 2), ('69005', 2), 
('69006', 2), ('69007', 2), ('69008', 2), ('69009', 2), ('69100', 20);

-- Marseille (Magasin 3) - Départements 13
INSERT INTO CODE_POSTAUX (CodePostal, IdMagasin) VALUES 
('13001', 3), ('13002', 3), ('13003', 3), ('13004', 3), ('13005', 3),
('13006', 3), ('13007', 3), ('13008', 3), ('13009', 3), ('13010', 3),
('13100', 22), ('13110', 3), ('13120', 3), ('13130', 3), ('13140', 3),
('13150', 3), ('13160', 3), ('13170', 3), ('13190', 3), ('13200', 3);

-- Toulouse (Magasin 4) - Départements 31
INSERT INTO CODE_POSTAUX (CodePostal, IdMagasin) VALUES 
('31000', 4), ('31100', 4), ('31110', 4), ('31120', 4), ('31130', 4),
('31140', 4), ('31150', 4), ('31170', 4), ('31200', 4), ('31220', 4);

-- Nice (Magasin 5) - Départements 06
INSERT INTO CODE_POSTAUX (CodePostal, IdMagasin) VALUES 
('06000', 5), ('06100', 5), ('06110', 5), ('06120', 5), ('06130', 5),
('06140', 5), ('06150', 5), ('06160', 5), ('06200', 5), ('06220', 5);

-- Nantes (Magasin 6) - Départements 44
INSERT INTO CODE_POSTAUX (CodePostal, IdMagasin) VALUES 
('44000', 6), ('44100', 6), ('44110', 6), ('44115', 6), ('44116', 6),
('44117', 6), ('44118', 6), ('44119', 6), ('44120', 6), ('44130', 6);

-- Strasbourg (Magasin 7) - Départements 67
INSERT INTO CODE_POSTAUX (CodePostal, IdMagasin) VALUES 
('67000', 7), ('67100', 7), ('67110', 7), ('67120', 7), ('67130', 7),
('67140', 7), ('67150', 7), ('67160', 7), ('67170', 7), ('67180', 7);

-- Montpellier (Magasin 8) - Départements 34
INSERT INTO CODE_POSTAUX (CodePostal, IdMagasin) VALUES 
('34000', 8), ('34070', 8), ('34080', 8), ('34090', 8), ('34100', 8),
('34110', 8), ('34120', 8), ('34130', 8), ('34140', 8), ('34150', 8);

-- Bordeaux (Magasin 9) - Départements 33
INSERT INTO CODE_POSTAUX (CodePostal, IdMagasin) VALUES 
('33000', 9), ('33100', 9), ('33110', 9), ('33120', 9), ('33130', 9),
('33140', 9), ('33150', 9), ('33160', 9), ('33170', 9), ('33200', 9);

-- Lille (Magasin 10) - Départements 59
INSERT INTO CODE_POSTAUX (CodePostal, IdMagasin) VALUES 
('59000', 10), ('59100', 10), ('59110', 10), ('59120', 10), ('59130', 10),
('59140', 10), ('59150', 10), ('59160', 10), ('59170', 10), ('59190', 10),
('59800', 10);

-- Rennes (Magasin 11) - Départements 35
INSERT INTO CODE_POSTAUX (CodePostal, IdMagasin) VALUES 
('35000', 11), ('35131', 11), ('35132', 11), ('35133', 11), ('35135', 11),
('35136', 11), ('35137', 11), ('35138', 11), ('35200', 11), ('35220', 11);

-- Reims (Magasin 12) - Départements 51
INSERT INTO CODE_POSTAUX (CodePostal, IdMagasin) VALUES 
('51000', 12), ('51100', 12), ('51110', 12), ('51120', 12), ('51130', 12),
('51140', 12), ('51150', 12), ('51160', 12), ('51170', 12), ('51200', 12);

-- Saint-Étienne (Magasin 13) - Départements 42
INSERT INTO CODE_POSTAUX (CodePostal, IdMagasin) VALUES 
('42000', 13), ('42100', 13), ('42110', 13), ('42120', 13), ('42130', 13),
('42140', 13), ('42150', 13), ('42160', 13), ('42170', 13), ('42190', 13);

-- Toulon (Magasin 14) - Départements 83
INSERT INTO CODE_POSTAUX (CodePostal, IdMagasin) VALUES 
('83000', 14), ('83100', 14), ('83110', 14), ('83120', 14), ('83130', 14),
('83140', 14), ('83150', 14), ('83160', 14), ('83170', 14), ('83200', 14);

-- Le Havre (Magasin 15) - Départements 76
INSERT INTO CODE_POSTAUX (CodePostal, IdMagasin) VALUES 
('76000', 15), ('76100', 15), ('76110', 15), ('76120', 15), ('76130', 15),
('76140', 15), ('76150', 15), ('76160', 15), ('76170', 15), ('76190', 15),
('76600', 15);

-- Grenoble (Magasin 16) - Départements 38
INSERT INTO CODE_POSTAUX (CodePostal, IdMagasin) VALUES 
('38000', 16), ('38100', 16), ('38110', 16), ('38120', 16), ('38130', 16),
('38140', 16), ('38150', 16), ('38160', 16), ('38170', 16), ('38180', 16);

-- Dijon (Magasin 17) - Départements 21
INSERT INTO CODE_POSTAUX (CodePostal, IdMagasin) VALUES 
('21000', 17), ('21110', 17), ('21120', 17), ('21130', 17), ('21140', 17),
('21150', 17), ('21160', 17), ('21170', 17), ('21190', 17), ('21200', 17);

-- Angers (Magasin 18) - Départements 49
INSERT INTO CODE_POSTAUX (CodePostal, IdMagasin) VALUES 
('49000', 18), ('49100', 18), ('49110', 18), ('49120', 18), ('49130', 18),
('49140', 18), ('49150', 18), ('49160', 18), ('49170', 18), ('49180', 18);

-- Nîmes (Magasin 19) - Départements 30
INSERT INTO CODE_POSTAUX (CodePostal, IdMagasin) VALUES 
('30000', 19), ('30100', 19), ('30110', 19), ('30120', 19), ('30130', 19),
('30140', 19), ('30150', 19), ('30160', 19), ('30190', 19), ('30200', 19);

-- Clermont-Ferrand (Magasin 21) - Départements 63
INSERT INTO CODE_POSTAUX (CodePostal, IdMagasin) VALUES 
('63000', 21), ('63100', 21), ('63110', 21), ('63120', 21), ('63130', 21),
('63140', 21), ('63150', 21), ('63160', 21), ('63170', 21), ('63200', 21);

-- Brest (Magasin 23) - Départements 29
INSERT INTO CODE_POSTAUX (CodePostal, IdMagasin) VALUES 
('29200', 23), ('29000', 23), ('29100', 23), ('29120', 23), ('29140', 23);

-- Tours (Magasin 24) - Départements 37
INSERT INTO CODE_POSTAUX (CodePostal, IdMagasin) VALUES 
('37000', 24), ('37100', 24), ('37110', 24), ('37120', 24), ('37130', 24);

-- Amiens (Magasin 25) - Départements 80
INSERT INTO CODE_POSTAUX (CodePostal, IdMagasin) VALUES 
('80000', 25), ('80080', 25), ('80090', 25), ('80100', 25), ('80110', 25);

-- Limoges (Magasin 26) - Départements 87
INSERT INTO CODE_POSTAUX (CodePostal, IdMagasin) VALUES 
('87000', 26), ('87100', 26), ('87110', 26), ('87120', 26), ('87130', 26);

-- Annecy (Magasin 27) - Départements 74
INSERT INTO CODE_POSTAUX (CodePostal, IdMagasin) VALUES 
('74000', 27);

-- Perpignan (Magasin 28) - Départements 66
INSERT INTO CODE_POSTAUX (CodePostal, IdMagasin) VALUES 
('66000', 28);

-- Besançon (Magasin 29) - Départements 25
INSERT INTO CODE_POSTAUX (CodePostal, IdMagasin) VALUES 
('25000', 29);

-- Metz (Magasin 30) - Départements 57
INSERT INTO CODE_POSTAUX (CodePostal, IdMagasin) VALUES 
('57000', 30);

-- Codes postaux supplémentaires pour zones diverses
INSERT INTO CODE_POSTAUX (CodePostal, IdMagasin) VALUES 
('91000', 1), ('91100', 1), ('91300', 1), ('91330', 1), ('93140', 1),
('92000', 1), ('92100', 1), 
('93000', 1), ('93400', 1),
('94000', 1), ('94100', 1), ('94300', 1),
('95000', 1), ('95300', 1),
('77000', 1), ('77100', 1),
('78000', 1), ('78100', 1), ('78120', 1),
('62000', 10), ('64000', 9), ('68000', 7),
('84000', 5), ('17000', 9), ('24100', 9),
('54000', 30), ('97200', 3);

-- LIVREUR (avec CodePostal valide)
INSERT INTO LIVREUR (NomLiv, NumTelLiv, CodePostal) VALUES
('Kylian Mbappé', '0601023456', '93140'),
('Youssef Alaoui', '0601000001', '75001'),
('Chen Wei', '0601000002', '69001'),
('Aminata Diallo', '0601000003', '13001'),
('Dmitri Volkov', '0601000004', '31000'),
('Aisha Patel', '0601000005', '06000'),
('Carlos Silva', '0601000006', '44000'),
('Fatima Benzema', '0601000007', '67000'),
('Kenji Tanaka', '0601000008', '34000'),
('Amara Diaye', '0601000009', '33000'),
('Ibrahim Hassan', '0601000010', '59000'),
('Sofia Rodriguez', '0601000011', '35000'),
('Mohammed Khadra', '0601000012', '51100'),
('Mei Lin', '0601000013', '42000'),
('Kwame Mensah', '0601000014', '83000'),
('Leila Aziz', '0601000015', '76600'),
('Giovanni Rossi', '0601000016', '38000'),
('Priya Kumar', '0601000017', '21000'),
('Ahmed Farouk', '0601000018', '49000'),
('Yuki Nakamura', '0601000019', '30000');

-- CLIENT
INSERT INTO CLIENT (Nom, Prenom, MDP, Adherent, Mail, Adresse_Rue, Adresse_CP, Adresse_Ville, NumTelCl) VALUES 
('Alaoui', 'Fatima', 'hash001', TRUE, 'fatima.alaoui@email.com', '12 rue de Rivoli', '75001', 'Paris', '0612000001'),
('Chen', 'Wei', 'hash002', FALSE, 'wei.chen@email.com', '45 avenue Victor Hugo', '75116', 'Paris', '0612000002'),
('Diallo', 'Aminata', 'hash003', TRUE, 'aminata.diallo@email.com', '8 boulevard Voltaire', '75011', 'Paris', '0612000003'),
('Volkov', 'Dmitri', 'hash004', TRUE, 'dmitri.volkov@email.com', '23 rue des Champs', '38000', 'Grenoble', '0612000004'),
('Patel', 'Aisha', 'hash005', FALSE, 'aisha.patel@email.com', '67 avenue de la République', '35000', 'Rennes', '0612000005'),
('Silva', 'Carlos', 'hash006', TRUE, 'carlos.silva@email.com', '34 rue de la Paix', '34000', 'Montpellier', '0612000006'),
('Benzema', 'Leila', 'hash007', FALSE, 'leila.benzema@email.com', '91 boulevard Haussmann', '75008', 'Paris', '0612000007'),
('Tanaka', 'Kenji', 'hash008', TRUE, 'kenji.tanaka@email.com', '15 avenue Montaigne', '75008', 'Paris', '0612000008'),
('Diaye', 'Amara', 'hash009', FALSE, 'amara.ndiaye@email.com', '78 rue du Faubourg', '33000', 'Bordeaux', '0612000009'),
('Hassan', 'Ibrahim', 'hash010', TRUE, 'ibrahim.hassan@email.com', '52 avenue des Ternes', '75017', 'Paris', '0612000010'),
('Rodriguez', 'Sofia', 'hash011', TRUE, 'sofia.rodriguez@email.com', '29 rue de la Pompe', '75116', 'Paris', '0612000011'),
('Khadra', 'Mohammed', 'hash012', FALSE, 'mohammed.khadra@email.com', '43 boulevard Saint-Germain', '75005', 'Paris', '0612000012');

-- BOUQUET
INSERT INTO BOUQUET (Modele, Taille, PrixUnitaire, Saison, Description, PhotoBouquet) VALUES 

-- 1. ROSES ROUGES (Petit, Moyen, Grand)
('Rose Rouge Passion', 'Petit', 29.99, 'Hiver', 
'Cultivées avec soin par nos producteurs partenaires en Équateur, réputés pour offrir les roses les plus robustes au monde, ces fleurs incarnent l''amour absolu. Leurs pétales veloutés d''un rouge profond sont parfaits pour déclarer votre flamme. Idéal pour la Saint-Valentin ou un anniversaire de mariage, ce petit format permet une attention délicate et passionnée qui saura toucher le cœur de votre destinataire sans encombrer son espace.', 
'roses_rouges.jpg'),

('Rose Rouge Passion', 'Moyen', 49.99, 'Hiver', 
'Cultivées avec soin par nos producteurs partenaires en Équateur, réputés pour offrir les roses les plus robustes au monde, ces fleurs incarnent l''amour absolu. Leurs pétales veloutés d''un rouge profond sont parfaits pour déclarer votre flamme. Idéal pour la Saint-Valentin ou un anniversaire de mariage, ce format moyen est l''équilibre parfait entre élégance et générosité, garantissant un effet "wouah" dès la réception du bouquet.', 
'roses_rouges.jpg'),

('Rose Rouge Passion', 'Grand', 79.99, 'Hiver', 
'Cultivées avec soin par nos producteurs partenaires en Équateur, réputés pour offrir les roses les plus robustes au monde, ces fleurs incarnent l''amour absolu. Leurs pétales veloutés d''un rouge profond sont parfaits pour déclarer votre flamme. Idéal pour la Saint-Valentin ou une grande demande en mariage, ce format spectaculaire est conçu pour impressionner et marquer les esprits avec un volume floral exceptionnel et luxueux.', 
'roses_rouges.jpg'),

-- 2. ROSES BLANCHES (Petit, Moyen, Grand)
('Rose Blanche Élégance', 'Petit', 27.99, 'Printemps', 
'Symbole de pureté et d''innocence, ces roses blanches proviennent directement des serres horticoles de la région lyonnaise, garantissant une fraîcheur locale incomparable. Ce bouquet est le choix privilégié pour exprimer le respect, féliciter de jeunes mariés ou apporter du réconfort lors de moments solennels. En petit format, il se pose discrètement sur une table de chevet ou un bureau, apportant une touche de lumière sereine et raffinée à tout intérieur.', 
'roses_blanches.jpg'),

('Rose Blanche Élégance', 'Moyen', 45.99, 'Printemps', 
'Symbole de pureté et d''innocence, ces roses blanches proviennent directement des serres horticoles de la région lyonnaise, garantissant une fraîcheur locale incomparable. Ce bouquet est le choix privilégié pour exprimer le respect, féliciter de jeunes mariés ou apporter du réconfort lors de moments solennels. Ce format moyen offre un volume généreux qui habillera magnifiquement un centre de table lors d''un dîner chic ou d''une réception familiale.', 
'roses_blanches.jpg'),

('Rose Blanche Élégance', 'Grand', 75.99, 'Printemps', 
'Symbole de pureté et d''innocence, ces roses blanches proviennent directement des serres horticoles de la région lyonnaise, garantissant une fraîcheur locale incomparable. Ce bouquet est le choix privilégié pour exprimer le respect, féliciter de jeunes mariés ou apporter du réconfort lors de moments solennels. En grand format, c''est une véritable cascade de blancheur immaculée, un cadeau prestigieux pour les grandes occasions qui exigent une élégance sans faille.', 
'roses_blanches.jpg'),

-- 3. ROSES ROSES (Petit, Moyen, Grand)
('Rose Rose Tendre', 'Petit', 28.99, 'Printemps', 
'Ces roses aux nuances pastel sont récoltées à la main dans le sud de la France, baignées par le soleil méditerranéen qui leur confère un parfum subtil. Elles expriment la tendresse, la gratitude et la douceur. C''est le cadeau incontournable pour la Fête des Mères, pour célébrer une naissance ou simplement pour dire "merci" à un ami proche. Ce petit bouquet est une pensée affectueuse, facile à offrir et à entretenir.', 
'roses_roses.jpg'),

('Rose Rose Tendre', 'Moyen', 47.99, 'Printemps', 
'Ces roses aux nuances pastel sont récoltées à la main dans le sud de la France, baignées par le soleil méditerranéen qui leur confère un parfum subtil. Elles expriment la tendresse, la gratitude et la douceur. C''est le cadeau incontournable pour la Fête des Mères, pour célébrer une naissance ou simplement pour dire "merci". Ce format moyen est idéal pour exprimer une affection grandissante avec un volume de fleurs qui ravira les amateurs de douceur.', 
'roses_roses.jpg'),

('Rose Rose Tendre', 'Grand', 77.99, 'Printemps', 
'Ces roses aux nuances pastel sont récoltées à la main dans le sud de la France, baignées par le soleil méditerranéen qui leur confère un parfum subtil. Elles expriment la tendresse, la gratitude et la douceur. C''est le cadeau incontournable pour la Fête des Mères, pour célébrer une naissance ou simplement pour dire "merci" avec emphase. Ce grand bouquet est une déclaration d''affection puissante, transformant n''importe quelle pièce en un jardin enchanté.', 
'roses_roses.jpg'),

-- 4. AUTRES FLEURS (Variés)
('Rose Jaune Soleil', 'Petit', 26.99, 'Ete', 
'Éclatantes de vitalité, ces roses jaunes nous arrivent de partenaires sélectionnés aux Pays-Bas. Couleur de l''amitié et de la joie, le jaune est parfait pour redonner le sourire, fêter une réussite professionnelle ou un bon rétablissement. Attention toutefois à la symbolique amoureuse parfois ambiguë ! Ce bouquet compact est un véritable rayon de soleil concentré, capable d''illuminer instantanément une pièce sombre ou une journée un peu grise.', 
'roses_jaunes.jpg'),

('Tulipe Printanière', 'Petit', 24.99, 'Printemps', 
'Emblèmes du retour des beaux jours, ces tulipes fraîches sont importées directement des célèbres marchés aux fleurs de Hollande. Elles symbolisent le renouveau et la vitalité de la nature qui s''éveille. Parfaites pour Pâques ou pour égayer un déjeuner dominical, elles apportent une touche de couleur vive et croquante. En petit format, elles forment une botte charmante et sans prétention, idéale pour une attention spontanée et joyeuse.', 
'tulipes_printemps.jpg'),

('Tulipe Printanière', 'Moyen', 39.99, 'Printemps', 
'Emblèmes du retour des beaux jours, ces tulipes fraîches sont importées directement des célèbres marchés aux fleurs de Hollande. Elles symbolisent le renouveau et la vitalité de la nature qui s''éveille. Parfaites pour Pâques ou pour égayer un déjeuner dominical, elles apportent une touche de couleur vive. Ce format moyen offre une belle densité de fleurs, créant une explosion de couleurs printanières qui dynamisera votre décoration intérieure.', 
'tulipes_printemps.jpg'),

('Pivoine Rose Romantique', 'Petit', 35.99, 'Printemps', 
'Fleur éphémère et précieuse, la pivoine est la reine de la fin du printemps, cultivée avec patience dans nos régions tempérées. Ses grosses têtes froufroutantes inspirent le romantisme et la prospérité. Offrez-les pour un anniversaire en mai ou juin, ou pour témoigner d''un amour sincère et protecteur. Ce petit bouquet concentre tout le charme et le parfum enivrant de la pivoine en quelques tiges d''exception.', 
'pivoines_rose.jpg'),

('Pivoine Rose Romantique', 'Moyen', 59.99, 'Printemps', 
'Fleur éphémère et précieuse, la pivoine est la reine de la fin du printemps, cultivée avec patience dans nos régions tempérées. Ses grosses têtes froufroutantes inspirent le romantisme et la prospérité. Offrez-les pour un anniversaire en mai ou juin, ou pour témoigner d''un amour sincère. Ce bouquet de taille moyenne est généreux et rond, mettant en valeur la texture incroyable des pétales de pivoine pour un effet visuel époustouflant.', 
'pivoines_rose.jpg'),

('Lys Blanc Majestueux', 'Petit', 31.99, 'Ete', 
'Symbole royal par excellence, ce lys blanc provient de cultures raisonnées en France. Son parfum puissant et ses lignes architecturales en font une fleur noble, souvent associée à la pureté de l''âme. Idéal pour un mariage, une cérémonie officielle ou pour exprimer des condoléances avec dignité. Même en petite taille, la prestance naturelle du Lys impose le respect et l''élégance, faisant de ce bouquet une pièce maîtresse de votre décoration.', 
'lys_blanc.jpg'),

('Orchidée Phalaenopsis Blanc', 'Moyen', 69.99, 'Hiver', 
'Cette plante exotique d''une grande longévité est cultivée en serre pour garantir une floraison parfaite. Symbole de fécondité et de perfection, l''orchidée est le cadeau idéal pour une crémaillère ou pour décorer un bureau moderne, car elle demande peu d''entretien tout en fleurissant longtemps. Présentée ici en taille moyenne, elle offre généralement deux belles hampes florales qui apporteront une touche zen et sophistiquée à n''importe quel environnement.', 
'orchidee_blanc.jpg'),

('Tournesol Joyeux', 'Grand', 59.99, 'Ete', 
'Cultivés en plein champ sous le soleil ardent du sud-ouest, ces tournesols géants capturent l''essence même de l''été. Ils symbolisent l''admiration, la fierté et la positivité inébranlable. C''est le bouquet parfait pour un anniversaire estival, un barbecue entre amis ou pour féliciter un diplômé. En grand format, ces fleurs imposantes créent une atmosphère rustique et chaleureuse impossible à ignorer, rayonnant de bonne humeur dans toute la maison.', 
'tournesol_grand.jpg'),

('Bouquet Champêtre', 'Moyen', 52.99, 'Printemps', 
'Ce ravissant assemblage tire son inspiration des prairies fleuries de nos horticulteurs partenaires situés en région Nouvelle-Aquitaine, garantissant une fraîcheur locale et authentique. Composé d''un mélange harmonieux de fleurs sauvages, il capture l''essence même de la nature qui s''éveille. C''est le choix idéal pour célébrer une fête des mères ou un anniversaire décontracté. Son allure bohème et naturelle apportera instantanément une touche de gaieté, de lumière et de sérénité.', 
'bouquet_champetre.jpg'),

('Bouquet Romantique', 'Grand', 94.99, 'Automne', 
'Composé par nos meilleurs artisans fleuristes parisiens, ce bouquet mélange des roses anciennes et des feuillages de saison aux teintes chaudes et cuivrées. Il évoque la nostalgie heureuse et l''amour durable qui traverse les saisons. Parfait pour un anniversaire de rencontre ou pour réchauffer le cœur d''un proche lorsque les jours raccourcissent. Ce format grandiose est une véritable œuvre d''art florale, riche en textures et en émotions.', 
'bouquet_romantique.jpg'),

('Bouquet Saint-Valentin', 'Moyen', 64.99, 'Hiver', 
'Création exclusive pour la fête des amoureux, ce bouquet associe des roses rouges intenses à des touches de gypsophile léger comme un nuage. Provenant d''une sélection rigoureuse pour garantir une tenue longue durée, il est l''ambassadeur de votre passion. À offrir impérativement le 14 février ! Sa taille moyenne est parfaitement étudiée pour être offerte au restaurant ou lors d''un rendez-vous, facile à transporter tout en restant spectaculaire.', 
'bouquet_saint_valentin.jpg');

-- DESTINATAIRE (avec codes postaux valides)
INSERT INTO DESTINATAIRE(Nom, Prenom, Rue, CodePostal) VALUES
('Messi', 'Lionel', '5 rue Victor Hugo', '75016'),
('Nguyen', 'Thi Hoa', '12 avenue du Soleil', '75013'),
('Diallo', 'Mamadou', '8 rue des Lilas', '75018'),
('Santos', 'Maria', '24 rue de Lisbonne', '69003'),
('Kovacs', 'Mate', '15 rue Centrale', '67000'),
('Hernandez', 'Carlos', '3 rue du Marché', '31000'),
('Zhang', 'Wei', '42 boulevard du Rhône', '13008'),
('Kim', 'Min-Ji', '19 rue de la République', '75011'),
('O''Connor', 'Sean', '7 rue des Jardins', '35000'),
('Rossi', 'Giulia', '11 voie Roma', '44000'),
('Petrov', 'Anastasia', '17 rue Voltaire', '59800'),
('Singh', 'Arjun', '22 rue Victor Hugo', '54000'),
('Haddad', 'Leila', '9 rue des Cedres', '34000'),
('Garcia', 'Javier', '6 rue Nationale', '33000'),
('Yamamoto', 'Haruto', '13 allée des Cerisiers', '78000');

-- COMMANDE
INSERT INTO COMMANDE (DateCommande, DateExpedition, PrixTotal, Message, CodeConfidentiel, PhotoCommande, NumClient, NumDestinataire, EtatCommande) VALUES
('2025-01-03','2025-01-05',39.99,'Bon anniversaire !','A1X9Z2','photo1.jpg',1,1, 'Arrivé'),
('2025-01-04','2025-01-06',59.50,'Avec toute mon affection','B8K2M1','photo2.jpg',2,2, 'Arrivé'),
('2025-01-06','2025-01-08',22.00,'Prompt rétablissement','C3L4P8','photo3.jpg',3,3, 'Arrivé'),
('2025-01-07','2025-01-09',48.20,'Félicitations !','D2Q1R5','photo4.jpg',4,4, 'En cours de livraison'),
('2025-01-08','2025-01-10',75.99,'Bonne fête','E9S3T7','photo5.jpg',5,5, 'En cours de livraison'),
('2025-01-09','2025-01-11',18.50,'Juste pour toi','F6V1W2','photo6.jpg',6,6, 'En cours de préparation'),
('2025-01-10','2025-01-12',62.30,'Avec mes meilleurs vœux','G5B6C1','photo7.jpg',7,7, 'En cours de préparation'),
('2025-01-11','2025-01-13',29.80,'Bon courage','H3D7E4','photo8.jpg',8,8, 'Annulé'),
('2025-01-12','2025-01-14',45.00,'Je pense à toi','I8F2G9','photo9.jpg',9,9, 'En cours de préparation'),
('2025-01-13','2025-01-15',99.90,'Joyeux anniversaire','J1H4I3','photo10.jpg',10,10, 'En cours de livraison');

-- CONTIENT
INSERT INTO CONTIENT(NumCommande, IdBouquet, Quantite) VALUES
(1, 1, 2),
(1, 3, 1),
(2, 2, 3),
(2, 7, 1),
(3, 4, 2),
(4, 5, 1),
(5, 6, 4),
(6, 11, 2),
(7, 18, 1),
(8, 13, 3),
(9, 15, 2),
(10, 20, 1);

-- PREND_EN_CHARGE
INSERT INTO PREND_EN_CHARGE (NumCommande, IdLivreur) VALUES
(1, 2),  -- Paris
(2, 2),  -- Paris
(3, 2),  -- Paris
(4, 3),  -- Lyon
(5, 7),  -- Strasbourg
(6, 5),  -- Toulouse
(7, 4),  -- Marseille
(8, 2),  -- Paris
(9, 12), -- Rennes
(10, 7); -- Nantes

