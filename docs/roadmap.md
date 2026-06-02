# Roadmap — Adotei App

Desenvolvimento dividido em etapas sequenciais. Cada etapa tem entregável testável antes de avançar.

---

## Etapa 0 — Estrutura do Repositório ✅
> Concluída.

- [x] Criar estrutura de pastas (`backend/`, `frontend/`)
- [x] Criar `backend/requirements.txt`, `.env` e `.env.example`
- [x] Criar `app/main.py` com endpoint `/health` funcionando
- [x] Criar `app/core/config.py` e `app/db/database.py`
- [x] Criar `README.md` na raiz com instruções de setup
- [ ] **[usuário]** Criar ambiente virtual: `cd backend && python -m venv venv`
- [ ] **[usuário]** Instalar dependências: `pip install -r requirements.txt`
- [ ] **[usuário]** Inicializar projeto Flutter: `flutter create adotei_app` dentro de `frontend/`

---

## Etapa 1 — Backend: Auth ✅
> Concluída e testada via Swagger.

- [x] Setup do FastAPI + SQLite (via SQLAlchemy)
- [x] Modelo `User` no banco (id, nome, sobrenome, email, senha hash, pergunta_seguranca, resposta_seguranca, cidade, estado)
- [x] Endpoint `POST /auth/register` — criar conta
- [x] Endpoint `POST /auth/login` — retorna JWT
- [x] Endpoint `GET /auth/me` — dados do usuário logado (requer JWT)
- [x] Endpoints `POST /auth/recuperar-senha/pergunta` e `/redefinir`
- [x] Middleware HTTPBearer valida JWT em rotas protegidas

---

## Etapa 2 — Backend: Pets ✅
> Concluída e testada via Swagger.

- [x] Modelos `Pet` e `Interesse` no banco
- [x] Endpoint `GET /pets` — lista disponíveis, com filtros: `q`, `especie`, `porte`, `cidade`, `estado`
- [x] Endpoint `GET /pets/{id}` — detalhe com info do dono (público)
- [x] Endpoint `POST /pets` — cadastrar pet (requer JWT)
- [x] Endpoint `DELETE /pets/{id}` — remover pet (requer JWT, apenas dono)
- [x] Endpoint `POST /pets/{id}/interesse` — registrar interesse (requer JWT)
- [x] Endpoint `GET /pets/{id}/interessados` — listar interessados (requer JWT, apenas dono)
- [x] `seed.py` — 2 usuários + 15 pets de teste (SP e PE)

---

## Etapa 3 — Flutter: Setup + Telas de Auth ✅
> Concluída.

- [x] Setup do projeto Flutter (pacotes: `http`, `shared_preferences`, `go_router`)
- [x] Tela Splash / Boas-vindas (print 2) — "Já tenho conta" e "Continuar como visitante"
- [x] Tela Login (print 1) — conectada ao `POST /auth/login`, salva JWT localmente
- [x] Tela Cadastro (prints 3 e 4) — fluxo em 2 passos, conectado ao `POST /auth/register`
- [x] Gerenciamento de estado de autenticação (Provider)
- [x] Redirecionamento automático: logado → Home, visitante → Home (modo leitura)

---

## Etapa 4 — Flutter: Home + Listagem de Pets ✅
> Concluída.

- [x] Tela Home (print 5) — barra de busca + filtros + lista de cards de pets
- [x] Card de pet com foto, nome e espécie
- [x] Filtros por espécie/categoria (chips circulares horizontais)
- [x] Barra de busca conectada ao `GET /pets?q=...` com debounce de 500ms
- [x] Seção "Próximos de mim" — filtra por cidade/estado do perfil do usuário

---

## Etapa 5 — Flutter: Detalhes do Pet + Cadastrar Anúncio ✅
> Concluída.

- [x] Tela Página de Anúncio — foto hero, nome, descrição, botão "Quero adotar"
- [x] Tela Criar Anúncio — formulário conectado ao `POST /pets` (FAB na Home)
- [x] Ação "Quero adotar" — registra interesse; visitante é redirecionado ao login
- [x] Opção B: dono vê botão "Ver interessados" com lista em bottom sheet

---

## Etapa 6 — Flutter: Perfil do Usuário
> Objetivo: usuário visualiza e gerencia seus anúncios.

- [ ] Tela Perfil — nome, e-mail, lista de pets cadastrados pelo usuário
- [ ] Opção de excluir pet cadastrado
- [ ] Logout (limpa JWT salvo localmente)

---

## ~~Etapa 7 — Chat~~ (removido do escopo)
> Descartado — sem chat no projeto.

---

## Telas Planejadas (resumo)

| Tela                   | Design pronto     | Etapa |
|------------------------|:-----------------:|-------|
| Splash / Boas-vindas   | Sim (print 2)     | 3     |
| Login                  | Sim (print 1)     | 3     |
| Cadastro (2 passos)    | Sim (prints 3, 4) | 3     |
| Home / Listagem        | Parcial (print 5) | 4     |
| Detalhe do pet         | Não               | 5     |
| Criar anúncio          | Não               | 5     |
| Perfil do usuário      | Não               | 6     |

---

## Stack Recomendada

| Camada    | Tecnologia              | Justificativa                          |
|-----------|-------------------------|----------------------------------------|
| API       | FastAPI (Python)        | Simples, rápido, docs automáticas      |
| Banco     | SQLite + SQLAlchemy     | Zero configuração de servidor          |
| Auth      | JWT (python-jose)       | Stateless, compatível com mobile       |
| Frontend  | Flutter                 | Multiplataforma, definido pelo projeto |
| Estado    | Provider ou Riverpod    | Leves e bem documentados para Flutter  |
