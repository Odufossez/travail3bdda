import mysql.connector
from mysql.connector import Error

try:
    # Connexion
    connexion = mysql.connector.connect(
        host="localhost",
        port=3306,
        user="alexandre",
        password="test",
        database="inventaire_a"
    )

    print("Connexion ouverte")

    curseur = connexion.cursor()

    curseur.execute(""" SELECT id_produit, nom, quantite FROM produit; """)

    print("\nListe des produits :")

    for ligne in curseur.fetchall():
        print(ligne)

except Error as erreur:
    print(f"Erreur MySQL : {erreur}")

finally:
    if 'curseur' in locals():
        curseur.close()

    if 'connexion' in locals() and connexion.is_connected():
        connexion.close()
        print("\nConnexion fermée")

