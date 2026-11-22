/*********************************************************************
    LABORATOIRE #3 : Application avec MYSQL

    ETAPE #1 - CREATION DES BASES DE DONNEES
    - inventaire_a
    - inventaire_b
    - tableau_bord
*********************************************************************/

drop database if exists tableau_bord;
drop database if exists inventaire_a;
drop database if exists inventaire_b;

create database inventaire_a;
create database inventaire_b;
create database tableau_bord;

/*********************************************************************
    INVENTAIRE_A
*********************************************************************/

use inventaire_a;

create table categorie
(
    id_categorie int auto_increment,

    nom varchar(50) not null,

    constraint pk_categorie
        primary key (id_categorie),

    constraint uq_categorie_nom
        unique (nom)
);

create table produit
(
    id_produit int auto_increment,

    nom varchar(100) not null,
    prix decimal(10,2) not null,
    quantite int not null default 0,

    id_categorie int not null,

    constraint pk_produit
        primary key (id_produit),

    constraint fk_produit_categorie
        foreign key (id_categorie)
        references categorie(id_categorie),

    constraint chk_produit_prix
        check (prix > 0),

    constraint chk_produit_quantite
        check (quantite >= 0)
);

create table mouvement_stock
(
    id_mouvement int auto_increment,

    id_produit int not null,

    ancienne_quantite int,
    nouvelle_quantite int,

    date_mouvement timestamp
        default current_timestamp,

    constraint pk_mouvement_stock
        primary key (id_mouvement),

    constraint fk_mouvement_stock_produit
        foreign key (id_produit)
        references produit(id_produit)
);

/*********************************************************************
    DONNEES INVENTAIRE_A
*********************************************************************/

insert into categorie (nom)
values
    ('Ordinateurs'),
    ('Peripheriques'),
    ('Reseau'),
    ('Impression'),
    ('Mobilier');

insert into produit
(
    nom,
    prix,
    quantite,
    id_categorie
)
values
    ('Portable Dell',1299.99,15,1),
    ('Portable Lenovo',1199.99,12,1),
    ('MacBook Air',1599.99,8,1),
    ('Clavier Mecanique',89.99,25,2),
    ('Souris Sans Fil',39.99,40,2),
    ('Ecran 27 pouces',299.99,18,2),
    ('Routeur TP-Link',129.99,10,3),
    ('Switch 24 Ports',249.99,6,3),
    ('Point Acces WiFi',179.99,9,3),
    ('Imprimante Laser',399.99,7,4),
    ('Imprimante Couleur',299.99,5,4),
    ('Bureau Assis-Debout',599.99,4,5),
    ('Chaise Ergonomique',449.99,6,5),
    ('Casque Audio',99.99,14,2),
    ('Webcam HD',69.99,21,2);

/*********************************************************************
    VUE INVENTAIRE_A
*********************************************************************/

create view vw_inventaire
as
select
    p.id_produit,
    p.nom as produit,
    c.nom as categorie,
    p.prix,
    p.quantite,
    p.prix * p.quantite as valeur_inventaire
from produit p
inner join categorie c
    on p.id_categorie = c.id_categorie;

/*********************************************************************
    FONCTION INVENTAIRE_A
*********************************************************************/

delimiter $$

create function fn_valeur_produit
(
    p_id_produit int
)
returns decimal(12,2)
reads sql data
begin

    declare v_valeur decimal(12,2);

    select prix * quantite
    into v_valeur
    from produit
    where id_produit = p_id_produit;

    return v_valeur;

end$$

delimiter ;

/*********************************************************************
    PROCEDURE INVENTAIRE_A
*********************************************************************/

delimiter $$

create procedure sp_ajuster_stock
(
    in p_id_produit int,
    in p_variation int
)
begin

    update produit
    set quantite = quantite + p_variation
    where id_produit = p_id_produit;

end$$

delimiter ;

/*********************************************************************
    TRIGGER INVENTAIRE_A
*********************************************************************/

delimiter $$

create trigger trg_mouvement_stock
after update
on produit
for each row
begin

    if old.quantite <> new.quantite then

        insert into mouvement_stock
        (
            id_produit,
            ancienne_quantite,
            nouvelle_quantite
        )
        values
        (
            new.id_produit,
            old.quantite,
            new.quantite
        );

    end if;

end$$

delimiter ;



/*********************************************************************
    INVENTAIRE_B
*********************************************************************/

use inventaire_b;

create table type_produit
(
    id_type int auto_increment,

    description_type varchar(50) not null,

    constraint pk_type_produit
        primary key (id_type),

    constraint uq_type_produit
        unique (description_type)
);

create table article
(
    id_article int auto_increment,

    description_article varchar(100) not null,

    cout_unitaire decimal(10,2) not null,

    id_type int not null,

    date_creation datetime
        default current_timestamp,

    date_modification datetime
        default current_timestamp,

    constraint pk_article
        primary key (id_article),

    constraint fk_article_type_produit
        foreign key (id_type)
        references type_produit(id_type),

    constraint chk_article_cout
        check(cout_unitaire > 0)
);

create table inventaire
(
    id_article int,

    quantite_disponible int not null default 0,

    constraint pk_inventaire
        primary key(id_article),

    constraint fk_inventaire_article
        foreign key(id_article)
        references article(id_article),

    constraint chk_inventaire_quantite
        check(quantite_disponible >= 0)
);

/*********************************************************************
    DONNEES INVENTAIRE_B
*********************************************************************/

insert into type_produit
(
    description_type
)
values
    ('Materiel'),
    ('Accessoire'),
    ('Infrastructure'),
    ('Impression'),
    ('Bureau');

insert into article
(
    description_article,
    cout_unitaire,
    id_type
)
values
    ('Station HP',1399.99,1),
    ('Portable Acer',999.99,1),
    ('Ecran Professionnel',349.99,2),
    ('Souris Bluetooth',44.99,2),
    ('Clavier Compact',59.99,2),
    ('Pare-feu Materiel',799.99,3),
    ('Switch Gigabit',289.99,3),
    ('Onduleur',249.99,3),
    ('Imprimante Multifonction',499.99,4),
    ('Scanner Bureau',199.99,4),
    ('Table Conference',899.99,5),
    ('Chaise Direction',599.99,5),
    ('Projecteur',749.99,1),
    ('Camera Conference',549.99,1),
    ('Casque USB',119.99,2);

insert into inventaire
(
    id_article,
    quantite_disponible
)
values
    (1,8),
    (2,12),
    (3,15),
    (4,25),
    (5,20),
    (6,4),
    (7,9),
    (8,6),
    (9,3),
    (10,11),
    (11,2),
    (12,5),
    (13,7),
    (14,4),
    (15,18);

/*********************************************************************
    VUE INVENTAIRE_B
*********************************************************************/

create view vw_stock_global
as
select
    a.id_article,
    a.description_article,
    tp.description_type,
    a.cout_unitaire,
    i.quantite_disponible,
    a.cout_unitaire * i.quantite_disponible as valeur_stock
from article a
inner join inventaire i
    on a.id_article = i.id_article
inner join type_produit tp
    on a.id_type = tp.id_type;

/*********************************************************************
    FONCTION INVENTAIRE_B
*********************************************************************/

delimiter $$

create function fn_qte_disponible
(
    p_id_article int
)
returns int
reads sql data
begin

    declare v_quantite int;

    select quantite_disponible
    into v_quantite
    from inventaire
    where id_article = p_id_article;

    return v_quantite;

end$$

delimiter ;

/*********************************************************************
    PROCEDURE INVENTAIRE_B
*********************************************************************/

delimiter $$

create procedure sp_reapprovisionner
(
    in p_id_article int,
    in p_quantite int
)
begin

    update inventaire
    set quantite_disponible =
        quantite_disponible + p_quantite
    where id_article = p_id_article;

end$$

delimiter ;

/*********************************************************************
    TRIGGER INVENTAIRE_B
*********************************************************************/

delimiter $$

create trigger trg_date_modification
before update
on article
for each row
begin

    set new.date_modification = current_timestamp;

end$$

delimiter ;

/*********************************************************************
    TABLEAU_BORD
*********************************************************************/

use tableau_bord;

/*
    Cette section sera utilisée lors des prochaines étapes.
*/




/*********************************************************************
    GESTION DES RÔLES, UTILISATEURS ET PERMISSION
*********************************************************************/

/* SUPPRESSION DE VOS RÔLE ET UTILISATEURS */
/* IMPORTANT : NE PAS SUPPRIMER VOTRE COMPTE DBA */
drop role if exists 'dev_a' ;
drop role if exists 'dev_b' ;
drop role if exists 'analyste';


/* CRÉATION DE VOS RÔLE ET UTILISATEURS */
create role 'dba'@'localhost';
GRANT ALL PRIVILEGES ON *.* TO 'dba'@'localhost' ;

create role 'dev_a'@'localhost' ;
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, ALTER, DROP, INDEX, REFERENCES, CREATE VIEW, SHOW VIEW,
    CREATE ROUTINE, ALTER ROUTINE, EXECUTE, EVENT, TRIGGER, LOCK TABLES
    ON inventaire_a.*
    TO 'dev_a'@'localhost';

create role 'dev_b'@'localhost' ;
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, ALTER, DROP, INDEX, REFERENCES, CREATE VIEW, SHOW VIEW,
    CREATE ROUTINE, ALTER ROUTINE, EXECUTE, EVENT, TRIGGER, LOCK TABLES
    ON inventaire_b.*
    TO 'dev_a'@'localhost';

create role 'analyste'@'localhost' ;
GRANT SELECT, SHOW VIEW ON inventaire_a.vw_inventaire to 'analyste'@'localhost' ;
GRANT SELECT, SHOW VIEW ON inventaire_b.vw_stock_global to 'analyste'@'localhost' ;

create user 'alexandre'@'localhost' identified by 'securite' ;
create user 'ariette'@'localhost' identified by 'securite' ;
create user 'brigitte'@'localhost' identified by 'securite' ;
create user 'bruno'@'localhost' identified by 'securite' ;
create user 'steve'@'localhost' identified by 'securite' ;
create user 'amir'@'localhost' identified by 'securite' ;

/* ASSOCIATION DES ROLES AUX UTILISATEURS */
grant 'dev_a'@'localhost' to 'alexandre'@'localhost', 'ariette'@'localhost', 'steve'@'localhost' ;
grant 'dev_b'@'localhost' to 'bruno'@'localhost','brigitte'@'localhost','steve'@'localhost';

/* DÉFINITION DES ROLES PAR DEFAUT */


/* VALIDATION AVANT DE CONTINUER */
-- show grants for 'alexandre'@'localhost';
-- show grants for 'bruno'@'localhost';
-- show grants for 'steve'@'localhost';
-- show grants for 'amir'@'localhost';
-- show grants for 'app_tableau_bord'@'localhost';


/* ASSIGNATION DES PERMISSIONS */
