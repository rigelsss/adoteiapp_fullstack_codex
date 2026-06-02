from sqlalchemy import Column, Integer, String
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
