from sqlalchemy import create_engine

utilisateur = "alexandre"
mot_passe = "test"
base_donnees = "inventaire_a"

con_string = "mysql+mysqlconnector://" + utilisateur + ":" + mot_passe + "@localhost:3306/" + base_donnees
engine = create_engine(con_string)

with engine.connect() as connexion:
    print("Connexion réussie")
