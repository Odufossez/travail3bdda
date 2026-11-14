import mysql.connector
from mysql.connector import Error


# --------------------------------------------------
# CONNEXION
# --------------------------------------------------

def obtenir_connexion():

    return mysql.connector.connect(
        host="localhost",
        port=3306,
        user="alexandre",
        password="test",
        database="inventaire_a"
    )

# --------------------------------------------------
# TEST CONNEXION
# --------------------------------------------------

def tester_connexion():

    print("\n=== TEST CONNEXION ===")

    con = obtenir_connexion()

    if con.is_connected():
        print("Connexion réussie")

    con.close()


# --------------------------------------------------
# SELECT
# --------------------------------------------------

def tester_select():

    print("\n=== TEST SELECT ===")

    con = obtenir_connexion()
    cur = con.cursor()

    cur.execute("""
        select id_produit, nom, prix, quantite 
        from produit
        order by nom
    """)

    for ligne in cur.fetchall():
        print(ligne)

    cur.close()
    con.close()


# --------------------------------------------------
# INSERT
# --------------------------------------------------

def tester_insert():

    print("\n=== TEST INSERT ===")

    con = obtenir_connexion()
    cur = con.cursor()

    sql = """
        insert into produit (nom, prix, quantite, id_categorie)
        values (%s, %s, %s, %s)
    """
    valeurs = ("Produit Python", 99.99, 25, 2)

    cur.execute(sql, valeurs)
    con.commit()

    print("Produit ajouté")
    print("ID :", cur.lastrowid)

    cur.close()
    con.close()


# --------------------------------------------------
# UPDATE
# --------------------------------------------------

def tester_update():

    print("\n=== TEST UPDATE ===")

    con = obtenir_connexion()
    cur = con.cursor()

    sql = """
        update produit
        set prix = %s
        where id_produit = %s
    """

    cur.execute(sql, (149.99, 1 ))
    con.commit()

    print(cur.rowcount, "ligne modifiée")

    cur.close()
    con.close()


# --------------------------------------------------
# DELETE
# --------------------------------------------------

def tester_delete():

    print("\n=== TEST DELETE ===")

    con = obtenir_connexion()
    cur = con.cursor()

    sql = """
        delete
        from produit
        where nom = %s
    """

    cur.execute(sql, ("Produit Python",))
    con.commit()

    print(cur.rowcount, "ligne supprimée")

    cur.close()
    con.close()


# --------------------------------------------------
# VUE
# --------------------------------------------------

def tester_vue():

    print("\n=== TEST VUE ===")

    con = obtenir_connexion()
    cur = con.cursor()

    cur.execute("""
        select *
        from vw_inventaire
        limit 5
    """)

    for ligne in cur.fetchall():
        print(ligne)

    cur.close()
    con.close()


# --------------------------------------------------
# FONCTION
# --------------------------------------------------

def tester_fonction():

    print("\n=== TEST FONCTION ===")

    con = obtenir_connexion()
    cur = con.cursor()

    cur.execute("select fn_valeur_produit(%s)", (1,))

    resultat = cur.fetchone()

    print("Valeur du produit :", resultat[0])

    cur.close()
    con.close()


# --------------------------------------------------
# PROCEDURE IN
# --------------------------------------------------

def tester_procedure_in():

    print("\n=== TEST PROCEDURE IN ===")

    con = obtenir_connexion()
    cur = con.cursor()

    cur.callproc("sp_ajuster_stock", [1, 5])
    con.commit()

    print("Stock ajusté")

    cur.close()
    con.close()


# --------------------------------------------------
# PROCEDURE OUT
# --------------------------------------------------

def tester_procedure_out():

    print("\n=== TEST PROCEDURE OUT ===")

    con = obtenir_connexion()
    cur = con.cursor()

    resultat = cur.callproc("sp_nb_produits", [0])

    print("Nombre de produits :", resultat[0])

    cur.close()
    con.close()


# --------------------------------------------------
# PROCEDURE INOUT
# --------------------------------------------------

def tester_procedure_inout():

    print("\n=== TEST PROCEDURE INOUT ===")

    con = obtenir_connexion()
    cur = con.cursor()

    resultat = cur.callproc("sp_doubler", [10])

    print("Valeur après traitement :", resultat[0])

    cur.close()
    con.close()


# --------------------------------------------------
# PREPARED STATEMENT
# --------------------------------------------------

def tester_prepared_statement():

    print("\n=== TEST PREPARED STATEMENT ===")

    con = obtenir_connexion()
    cur = con.cursor()

    nom_produit = "Portable Dell"

    sql = """
        select id_produit, nom, prix, quantite 
        from produit
        where nom = %s
    """

    cur.execute(sql, (nom_produit,))

    for ligne in cur.fetchall():
        print(ligne)

    cur.close()
    con.close()


# --------------------------------------------------
# TRIGGER
# --------------------------------------------------

def tester_trigger():

    print("\n=== TEST TRIGGER ===")

    con = obtenir_connexion()
    cur = con.cursor()

    cur.callproc("sp_ajuster_stock", [1, 2])
    con.commit()

    cur.execute("""
        select id_mouvement, id_produit, ancienne_quantite, nouvelle_quantite 
        from mouvement_stock
        order by id_mouvement desc
        limit 5
    """)

    for ligne in cur.fetchall():
        print(ligne)

    cur.close()
    con.close()


# --------------------------------------------------
# TRANSACTION
# --------------------------------------------------

def tester_transaction():

    print("\n=== TEST TRANSACTION ===")

    con = obtenir_connexion()
    cur = con.cursor()

    try:

        cur.execute("""
            update produit
            set quantite = quantite + 5
            where id_produit = 1
        """)

        cur.execute("""
            update produit
            set quantite = quantite - 5
            where id_produit = 2
        """)

        con.commit()

        print("COMMIT effectué")

    except Exception as erreur:

        con.rollback()

        print("ROLLBACK")
        print(erreur)

    finally:

        cur.close()
        con.close()


# --------------------------------------------------
# MAIN
# --------------------------------------------------

def main():

    try:
        tester_connexion()
        tester_select()
        tester_insert()
        tester_update()
        tester_vue()
        tester_fonction()
        tester_procedure_in()
        tester_procedure_out()
        tester_procedure_inout()
        tester_prepared_statement()
        tester_trigger()
        tester_transaction()
        tester_delete()
    except Error as erreur:
        print("Erreur MySQL :", erreur)


if __name__ == "__main__":
    main()