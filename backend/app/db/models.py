from datetime import datetime, timezone

from sqlalchemy import Column, DateTime, ForeignKey, Integer, String, UniqueConstraint
from sqlalchemy.orm import relationship

from app.db.database import Base


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    nome = Column(String, nullable=False)
    sobrenome = Column(String, nullable=False)
    email = Column(String, unique=True, index=True, nullable=False)
    senha_hash = Column(String, nullable=False)
    pergunta_seguranca = Column(String, nullable=False)
    resposta_seguranca_hash = Column(String, nullable=False)
    cidade = Column(String, nullable=True)
    estado = Column(String, nullable=True)

    pets = relationship("Pet", back_populates="dono", foreign_keys="Pet.dono_id")
    interesses = relationship("Interesse", back_populates="usuario", foreign_keys="Interesse.usuario_id")


class Pet(Base):
    __tablename__ = "pets"

    id = Column(Integer, primary_key=True, index=True)
    nome = Column(String, nullable=False)
    especie = Column(String, nullable=False)   # cão, gato, coelho, pássaro, outro
    raca = Column(String, nullable=True)
    idade = Column(Integer, nullable=True)     # em meses
    porte = Column(String, nullable=True)      # pequeno, médio, grande
    descricao = Column(String, nullable=True)
    foto_url = Column(String, nullable=True)
    cidade = Column(String, nullable=True)
    estado = Column(String, nullable=True)
    status = Column(String, default="disponível")  # disponível, adotado
    dono_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    criado_em = Column(DateTime, default=lambda: datetime.now(timezone.utc))

    dono = relationship("User", back_populates="pets", foreign_keys=[dono_id])
    interesses = relationship("Interesse", back_populates="pet", cascade="all, delete-orphan")


class Interesse(Base):
    __tablename__ = "interesses"
    __table_args__ = (UniqueConstraint("usuario_id", "pet_id", name="uq_interesse"),)

    id = Column(Integer, primary_key=True, index=True)
    usuario_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    pet_id = Column(Integer, ForeignKey("pets.id"), nullable=False)
    criado_em = Column(DateTime, default=lambda: datetime.now(timezone.utc))

    usuario = relationship("User", back_populates="interesses", foreign_keys=[usuario_id])
    pet = relationship("Pet", back_populates="interesses")
