from datetime import datetime

from pydantic import BaseModel


class DonoInfo(BaseModel):
    id: int
    nome: str
    sobrenome: str
    email: str
    cidade: str | None
    estado: str | None

    model_config = {"from_attributes": True}


class PetCreate(BaseModel):
    nome: str
    especie: str        # cão, gato, coelho, pássaro, outro
    raca: str | None = None
    idade: int | None = None   # em meses
    porte: str | None = None   # pequeno, médio, grande
    descricao: str | None = None
    foto_url: str | None = None
    cidade: str | None = None
    estado: str | None = None


class PetResponse(BaseModel):
    id: int
    nome: str
    especie: str
    raca: str | None
    idade: int | None
    porte: str | None
    descricao: str | None
    foto_url: str | None
    cidade: str | None
    estado: str | None
    status: str
    dono_id: int
    criado_em: datetime

    model_config = {"from_attributes": True}


class PetDetailResponse(PetResponse):
    dono: DonoInfo


class InteresseResponse(BaseModel):
    id: int
    usuario_id: int
    pet_id: int
    criado_em: datetime

    model_config = {"from_attributes": True}


class InteressadoInfo(BaseModel):
    usuario_id: int
    nome: str
    sobrenome: str
    email: str
    criado_em: datetime

    model_config = {"from_attributes": True}
