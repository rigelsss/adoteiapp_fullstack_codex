from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.security import create_access_token, get_current_user, hash_text, verify_text
from app.db.database import get_db
from app.db.models import User
from app.schemas.user import (
    RecuperarSenhaStep1,
    RecuperarSenhaStep2,
    Token,
    UserLogin,
    UserRegister,
    UserResponse,
)

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post("/register", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
def register(data: UserRegister, db: Session = Depends(get_db)):
    if db.query(User).filter(User.email == data.email).first():
        raise HTTPException(status_code=400, detail="Email já cadastrado")

    user = User(
        nome=data.nome,
        sobrenome=data.sobrenome,
        email=data.email,
        senha_hash=hash_text(data.senha),
        pergunta_seguranca=data.pergunta_seguranca,
        resposta_seguranca_hash=hash_text(data.resposta_seguranca.strip().lower()),
        cidade=data.cidade,
        estado=data.estado,
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return user


@router.post("/login", response_model=Token)
def login(data: UserLogin, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == data.email).first()
    if not user or not verify_text(data.senha, user.senha_hash):
        raise HTTPException(status_code=401, detail="Email ou senha incorretos")

    return {"access_token": create_access_token(user.id)}


@router.post("/recuperar-senha/pergunta")
def obter_pergunta(data: RecuperarSenhaStep1, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == data.email).first()
    if not user:
        raise HTTPException(status_code=404, detail="Usuário não encontrado")
    return {"pergunta": user.pergunta_seguranca}


@router.post("/recuperar-senha/redefinir")
def redefinir_senha(data: RecuperarSenhaStep2, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == data.email).first()
    if not user:
        raise HTTPException(status_code=404, detail="Usuário não encontrado")
    if not verify_text(data.resposta.strip().lower(), user.resposta_seguranca_hash):
        raise HTTPException(status_code=400, detail="Resposta de segurança incorreta")

    user.senha_hash = hash_text(data.nova_senha)
    db.commit()
    return {"message": "Senha redefinida com sucesso"}


@router.get("/me", response_model=UserResponse)
def me(current_user: User = Depends(get_current_user)):
    return current_user
