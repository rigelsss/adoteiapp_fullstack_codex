# Adotei App

App mobile para divulgação e adoção de pets.

## Stack

- **Backend**: Python 3.11+ · FastAPI · SQLite · JWT
- **Frontend**: Flutter (Android)

## Estrutura do repositório

```
adoteiapp_fullstack_codex/
├── backend/      ← API Python
├── frontend/     ← Projeto Flutter
├── docs/         ← Documentação e roadmap
└── prints/       ← Design das telas
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

# Iniciar servidor
uvicorn app.main:app --reload
```

A API sobe em **http://localhost:8000**

Documentação interativa: **http://localhost:8000/docs**

---

## Rodando o Frontend

> Inicialize o projeto Flutter no Android Studio antes de rodar:
> `flutter create adotei_app` dentro da pasta `frontend/`

```bash
cd frontend/adotei_app
flutter pub get
flutter run
```
