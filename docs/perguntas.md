# Perguntas — Adotei App

Perguntas para alinhar o escopo antes de iniciar a implementação.

---

## Acesso e Autenticação

**1. "Continuar como visitante" (print 2)**
O visitante consegue apenas visualizar a listagem de pets sem poder adotar ou cadastrar um pet? Ou há outras restrições/permissões específicas para visitantes?
O visitante pode apenas visualizar a listagem de pets e detalhes de pets sem poder adotar ou cadastrar 

**2. "Esqueci minha senha" (print 1)**
Essa funcionalidade precisa ser implementada? Se sim, como deve funcionar — envio de e-mail de recuperação ou apenas uma pergunta de segurança?
Uma pergunta de segurança (nada de envio de email)
---

## Funcionalidades de Pet

**3. Upload de fotos dos pets**
O usuário vai enviar a foto diretamente pelo app (upload de arquivo) ou apenas informar uma URL de imagem? Upload direto é mais complexo de implementar no backend (armazenamento de arquivos).
URL de imagem

**4. Fluxo de adoção**
Quando o usuário clica em "adotar", qual é o fluxo esperado?
- Opção A: O app abre um chat com o dono do pet para combinar a adoção.
- Opção B: O usuário apenas demonstra interesse e o dono entra em contato.
- Opção C: A adoção é confirmada diretamente no app (muda o status do pet para "adotado").
Opcao B)

**5. Filtros e categorias (print 5)**
O que as categorias circulares no topo da homescreen representam? Espécie (cão, gato, coelho...)? Tamanho? Idade? Quais filtros são necessários?
Decida você entre o que for mais interessante
**6. "Próximos de mim" (print 5)**
Essa seção usa geolocalização do dispositivo, ou o usuário informa manualmente a cidade/estado no perfil?
Informa manualmente a cidade/estado no perfil
---

## Chat

**7. Chat entre usuários (print 6)**
O chat é uma funcionalidade confirmada para o escopo da disciplina? Se sim:
- Pode ser simples (mensagens assíncronas consultadas por polling) ou precisa ser em tempo real (WebSocket)?
- A conversa é iniciada a partir da página de um pet ("quero adotar") ou os usuários podem se contatar livremente?
Não, não haverá chat.
---

## Backend e Infraestrutura

**8. Banco de dados**
Tem preferência ou restrição?
- SQLite: mais simples, sem servidor, arquivo local — ideal para desenvolvimento da disciplina.
- PostgreSQL: mais robusto, requer servidor — útil se houver deploy.
SQLite

**9. Deploy da API**
A API vai rodar apenas localmente (na mesma rede/máquina para testes com o emulador Android) ou precisa estar acessível publicamente (Railway, Render, etc.) durante a disciplina?
Apenas localmente
---

## Prazo e Escopo

**10. Prazo da disciplina**
Qual é a data de entrega do projeto? Isso ajuda a priorizar o que entra no MVP e o que fica como bônus (ex.: chat pode ser deixado para o final).
10/06
**11. Avaliação**
Há critérios específicos de avaliação — ex.: quantidade mínima de telas, documentação de API, testes unitários, apresentação?
Não