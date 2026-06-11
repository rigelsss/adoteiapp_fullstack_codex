# Adotei App

App mobile para divulgação e adoção de pets. Projeto full stack: API REST em FastAPI + app Flutter (Android).

## Stack

- **Backend**: Python 3.11+ · FastAPI · SQLAlchemy · SQLite · JWT (python-jose)
- **Frontend**: Flutter (Android) · Provider · go_router

## Funcionalidades

- Cadastro e login com JWT, com recuperação de senha por pergunta de segurança
- Listagem de pets disponíveis com busca e filtros (espécie, porte, cidade, estado)
- Detalhe do pet, incluindo informações do dono
- Cadastro e remoção de anúncios de pets (requer login)
- Demonstração de interesse em adotar e listagem de interessados (para o dono do pet)
- Perfil do usuário com seus pets cadastrados

## Estrutura do repositório

```
adoteiapp_fullstack_codex/
├── backend/      ← API Python (FastAPI)
├── frontend/     ← Projeto Flutter (adotei_app)
└── render.yaml   ← Configuração de deploy (Render)
```

---

## Rodando o Backend

```bash
cd backend

# Criar e ativar ambiente virtual
python -m venv venv
venv\Scripts\activate

# Instalar dependências
pip install -r requirements.txt

# Configurar variáveis de ambiente
copy .env.example .env

# (Opcional) popular o banco com dados de teste
python seed.py

# Iniciar servidor
uvicorn app.main:app --reload
```

A API sobe em **http://localhost:8000**

Documentação interativa: **http://localhost:8000/docs**

### Variáveis de ambiente (`backend/.env`)

| Variável | Descrição | Padrão |
|----------|-----------|--------|
| `SECRET_KEY` | Chave usada para assinar os tokens JWT | - |
| `ALGORITHM` | Algoritmo de assinatura do JWT | `HS256` |
| `ACCESS_TOKEN_EXPIRE_MINUTES` | Tempo de expiração do token (minutos) | `30` |
| `DATABASE_URL` | URL de conexão do banco | `sqlite:///./adotei.db` |

### Usuários de teste (após `python seed.py`)

| Email | Senha | Cidade/UF |
|-------|-------|-----------|
| seed_ana@adotei.com | 123456 | João Pessoa/PB |
| seed_carlos@adotei.com | 123456 | Recife/PE |
| seed_beatriz@adotei.com | 123456 | Campina Grande/PB |

---

## Rodando o Frontend

```bash
cd frontend/adotei_app
flutter pub get
flutter run
```

### Conectando ao backend

A URL da API é definida em `lib/core/constants.dart` (`kApiBase`):

- **Emulador Android** apontando para o backend local: `http://10.0.2.2:8000`
- **Produção**: URL do backend publicado no Render

---

## Deploy

O backend está configurado para deploy no [Render](https://render.com) via `render.yaml`: ao subir, o serviço executa `seed.py` (popular dados de exemplo) e em seguida inicia o servidor com `start.sh`.

> **Atenção**: no plano gratuito do Render, a instância "dorme" após período de inatividade. A primeira requisição à API pode levar até **60 segundos** enquanto o servidor é reativado.
