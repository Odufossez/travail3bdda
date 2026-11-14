from sqlalchemy import DECIMAL, Integer, String, ForeignKey, TIMESTAMP, func
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, relationship

class Base(DeclarativeBase):
    pass

class Categorie(Base):
    __tablename__ = "categorie"

    id_categorie: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    nom: Mapped[str] = mapped_column(String(50), unique=True, nullable=False)

    produits = relationship("Produit", back_populates="categorie")

class Produit(Base):
    __tablename__ = "produit"

    id_produit: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    nom: Mapped[str] = mapped_column(String(100), nullable=False)
    prix: Mapped[float] = mapped_column(DECIMAL(10, 2), nullable=False)
    quantite: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    id_categorie: Mapped[int] = mapped_column(ForeignKey("categorie.id_categorie"), nullable=False)

    categorie = relationship("Categorie", back_populates="produits")
    mouvements = relationship("MouvementStock", back_populates="produit")

class MouvementStock(Base):
    __tablename__ = "mouvement_stock"

    id_mouvement: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    id_produit: Mapped[int] = mapped_column(ForeignKey("produit.id_produit"), nullable=False)
    ancienne_quantite: Mapped[int | None] = mapped_column(Integer)
    nouvelle_quantite: Mapped[int | None] = mapped_column(Integer)
    date_mouvement: Mapped[str] = mapped_column(TIMESTAMP, server_default=func.current_timestamp())

    produit = relationship("Produit", back_populates="mouvements")
