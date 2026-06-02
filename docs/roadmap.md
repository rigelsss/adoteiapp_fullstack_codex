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

## Etapa 1 — Backend: Auth
> Objetivo: usuário consegue criar conta e fazer login via API.

- [ ] Setup do FastAPI + SQLite (via SQLAlchemy)
- [ ] Modelo `User` no banco (id, nome, sobrenome, email, senha hash, pergunta_seguranca, resposta_seguranca, cidade, estado)
- [ ] Endpoint `POST /auth/register` — criar conta
- [ ] Endpoint `POST /auth/login` — retorna JWT
- [ ] Middleware que valida JWT em rotas protegidas
- [ ] Testar com Postman ou curl

---

## Etapa 2 — Backend: Pets
> Objetivo: CRUD de pets funcionando via API.

- [ ] Modelo `Pet` no banco (id, nome, espécie, raça, idade, porte, descrição, foto_url, cidade, estado, status, dono_id)
- [ ] Endpoint `GET /pets` — listar todos os pets disponíveis (público)
- [ ] Endpoint `GET /pets/{id}` — detalhe de um pet (público)
- [ ] Endpoint `POST /pets` — cadastrar pet (requer JWT)
- [ ] Endpoint `DELETE /pets/{id}` — remover pet (requer JWT, apenas dono)
- [ ] Endpoint `GET /pets/search?q=...` — buscar pets por nome/espécie
- [ ] Endpoint `POST /pets/{id}/interesse` — registrar interesse em adotar (requer JWT)
- [ ] Endpoint `GET /pets/{id}/interessados` — listar interessados (requer JWT, apenas dono)

---

## Etapa 3 — Flutter: Setup + Telas de Auth
> Objetivo: splash, login e cadastro funcionando e conectados ao backend.

- [ ] Setup do projeto Flutter (pacotes: `http`, `shared_preferences`, `go_router`)
- [ ] Tela Splash / Boas-vindas (print 2) — "Já tenho conta" e "Continuar como visitante"
- [ ] Tela Login (print 1) — conectada ao `POST /auth/login`, salva JWT localmente
- [ ] Tela Cadastro (prints 3 e 4) — fluxo em 2 passos, conectado ao `POST /auth/register`
- [ ] Gerenciamento de estado de autenticação (ex.: Provider ou Riverpod)
- [ ] Redirecionamento automático: logado → Home, visitante → Home (modo leitura)

---

## Etapa 4 — Flutter: Home + Listagem de Pets
> Objetivo: tela principal com listagem e busca funcionando.

- [ ] Tela Home (print 5) — barra de busca + filtros + lista de cards de pets
- [ ] Card de pet com foto, nome e espécie
- [ ] Filtros por espécie/categoria (chips horizontais)
- [ ] Barra de busca conectada ao `GET /pets/search`
- [ ] Seção "Próximos de mim" — filtra por cidade/estado do perfil do usuário

---

## Etapa 5 — Flutter: Detalhes do Pet + Cadastrar Anúncio
> Objetivo: fluxo completo de anúncio — ver e criar.

- [ ] Tela Página de Anúncio — fotos, nome, descrição, botão "Quero adotar"
- [ ] Tela Criar Anúncio — formulário conectado ao `POST /pets`
- [ ] Ação "Quero adotar" — registra interesse do usuário (Opção B: dono visualiza interessados)

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
