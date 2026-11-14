from sqlalchemy import DECIMAL, Integer, String, DateTime, ForeignKey, func
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, relationship

class Base(DeclarativeBase):
    pass

class TypeProduit(Base):
    __tablename__ = "type_produit"

    id_type: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    description_type: Mapped[str] = mapped_column(String(50), unique=True, nullable=False)

    articles = relationship("Article", back_populates="type_produit")

class Article(Base):
    __tablename__ = "article"

    id_article: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    description_article: Mapped[str] = mapped_column(String(100), nullable=False)
    cout_unitaire: Mapped[float] = mapped_column(DECIMAL(10, 2), nullable=False)
    id_type: Mapped[int] = mapped_column(ForeignKey("type_produit.id_type"), nullable=False)
    date_creation: Mapped[str] = mapped_column(DateTime, server_default=func.current_timestamp())
    date_modification: Mapped[str] = mapped_column(DateTime, server_default=func.current_timestamp())

    type_produit = relationship("TypeProduit", back_populates="articles")
    inventaire = relationship("Inventaire", back_populates="article", uselist=False)

class Inventaire(Base):
    __tablename__ = "inventaire"

    id_article: Mapped[int] = mapped_column(ForeignKey("article.id_article"), primary_key=True)
    quantite_disponible: Mapped[int] = mapped_column(Integer, nullable=False, default=0)

    article = relationship("Article", back_populates="inventaire")
