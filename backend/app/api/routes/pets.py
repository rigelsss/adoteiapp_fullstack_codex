from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from app.core.security import get_current_user
from app.db.database import get_db
from app.db.models import Interesse, Pet, User
from app.schemas.pet import (
    InteresseResponse,
    InteressadoInfo,
    PetCreate,
    PetDetailResponse,
    PetResponse,
)

router = APIRouter(prefix="/pets", tags=["pets"])


@router.get("", response_model=list[PetResponse])
def listar_pets(
    q: str | None = Query(None, description="Busca por nome ou raça"),
    especie: str | None = Query(None, description="cão, gato, coelho, pássaro, outro"),
    porte: str | None = Query(None, description="pequeno, médio, grande"),
    cidade: str | None = Query(None),
    estado: str | None = Query(None),
    dono_id: int | None = Query(None, description="Filtra por dono (retorna todos os status)"),
    db: Session = Depends(get_db),
):
    query = db.query(Pet)

    if dono_id is not None:
        query = query.filter(Pet.dono_id == dono_id)
    else:
        query = query.filter(Pet.status == "disponível")

    if q:
        termo = f"%{q.lower()}%"
        query = query.filter(
            Pet.nome.ilike(termo) | Pet.raca.ilike(termo) | Pet.descricao.ilike(termo)
        )
    if especie:
        query = query.filter(Pet.especie.ilike(especie))
    if porte:
        query = query.filter(Pet.porte.ilike(porte))
    if cidade:
        query = query.filter(Pet.cidade.ilike(f"%{cidade}%"))
    if estado:
        query = query.filter(Pet.estado.ilike(estado))

    return query.order_by(Pet.criado_em.desc()).all()


@router.get("/{pet_id}", response_model=PetDetailResponse)
def detalhe_pet(pet_id: int, db: Session = Depends(get_db)):
    pet = db.query(Pet).filter(Pet.id == pet_id).first()
    if not pet:
        raise HTTPException(status_code=404, detail="Pet não encontrado")
    return pet


@router.post("", response_model=PetResponse, status_code=status.HTTP_201_CREATED)
def cadastrar_pet(
    data: PetCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    pet = Pet(**data.model_dump(), dono_id=current_user.id)
    db.add(pet)
    db.commit()
    db.refresh(pet)
    return pet


@router.delete("/{pet_id}", status_code=status.HTTP_204_NO_CONTENT)
def remover_pet(
    pet_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    pet = db.query(Pet).filter(Pet.id == pet_id).first()
    if not pet:
        raise HTTPException(status_code=404, detail="Pet não encontrado")
    if pet.dono_id != current_user.id:
        raise HTTPException(status_code=403, detail="Sem permissão para remover este pet")
    db.delete(pet)
    db.commit()


@router.post("/{pet_id}/interesse", response_model=InteresseResponse, status_code=status.HTTP_201_CREATED)
def registrar_interesse(
    pet_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    pet = db.query(Pet).filter(Pet.id == pet_id).first()
    if not pet:
        raise HTTPException(status_code=404, detail="Pet não encontrado")
    if pet.dono_id == current_user.id:
        raise HTTPException(status_code=400, detail="Você não pode demonstrar interesse no seu próprio pet")
    if pet.status != "disponível":
        raise HTTPException(status_code=400, detail="Este pet não está disponível para adoção")

    existente = db.query(Interesse).filter(
        Interesse.usuario_id == current_user.id,
        Interesse.pet_id == pet_id,
    ).first()
    if existente:
        raise HTTPException(status_code=400, detail="Você já demonstrou interesse neste pet")

    interesse = Interesse(usuario_id=current_user.id, pet_id=pet_id)
    db.add(interesse)
    db.commit()
    db.refresh(interesse)
    return interesse


@router.get("/{pet_id}/interessados", response_model=list[InteressadoInfo])
def listar_interessados(
    pet_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    pet = db.query(Pet).filter(Pet.id == pet_id).first()
    if not pet:
        raise HTTPException(status_code=404, detail="Pet não encontrado")
    if pet.dono_id != current_user.id:
        raise HTTPException(status_code=403, detail="Sem permissão para ver esta informação")

    interesses = db.query(Interesse).filter(Interesse.pet_id == pet_id).all()
    return [
        InteressadoInfo(
            usuario_id=i.usuario_id,
            nome=i.usuario.nome,
            sobrenome=i.usuario.sobrenome,
            email=i.usuario.email,
            criado_em=i.criado_em,
        )
        for i in interesses
    ]
