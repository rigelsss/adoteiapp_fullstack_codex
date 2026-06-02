from pydantic import BaseModel, EmailStr


class UserRegister(BaseModel):
    nome: str
    sobrenome: str
    email: EmailStr
    senha: str
    pergunta_seguranca: str
    resposta_seguranca: str
    cidade: str | None = None
    estado: str | None = None


class UserLogin(BaseModel):
    email: EmailStr
    senha: str


class RecuperarSenhaStep1(BaseModel):
    email: EmailStr


class RecuperarSenhaStep2(BaseModel):
    email: EmailStr
    resposta: str
    nova_senha: str


class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"


class UserResponse(BaseModel):
    id: int
    nome: str
    sobrenome: str
    email: str
    cidade: str | None
    estado: str | None

    model_config = {"from_attributes": True}
