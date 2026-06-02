A ideia aqui é desenvolver um app mobile em flutter + backend para a disciplina de programação mobile. Já existe um design gráfico "pré" estabelecido e os prints dessas telas encontram-se em /prints. Eu ainda vou iniciar o projeto flutter e o repositorio, antes resolvi jogar as ideias aqui para que você me oriente quanto a organização de pastas e outras pontos que você achar relevante ou tiver dúvidas.

A ideia do app é ser um app para divulgação e adoção de pets. Gostaria que tivesse um backend com uma API em python e tivesse um banco de dados para registrar usuarios, registrar pets, guardar informações em geral e etc. A API seria para intermediar essa troca de informações e outras funções a mais que você possa me sugerir. 


Ideias que escrevi:
    Backend:
        - API em python - Nada muito complicado, usado apenas para funcionalidades como criar conta, login, cadastrar pet, excluir pet, ver pets cadastrados, adotar pet e etc...
        - Banco de dados para consultas via API - Um banco relacional qualquer é o suficiente desde que a implementação do mesmo seja simples
        - Login com checagem em banco dos dados das informações e retorno via API com token JWT 
        - Transações via a API apenas se o usuário tiver um token JWT

    Frontend:
        - Desenvolver em flutter (eu vou iniciar o projeto flutter em um momento adiante mais adequado utilizando o android studio)
        - Telas: Cadastro, login, tela inicial, pets para adoçao, detalhes de um pet, adotar um pet, pesquisar por pets, cadastrar um pet e outras telas que você pode me sugerir. 
        - Existe o design de algumas telas pronto como consta em /prints. O design de algumas telas precisa ser feito mas deve seguir o padrão gráfico de cores e estilo dos prints

Preciso que você me ajude a implementar esse projeto. Quaisquer dúvidas que você tenha crie /docs/perguntas.md para que eu possa responder e você ter uma visão melhor do que precisa ser feito e desenvolvido. Um roadmap, que você pode criar em /docs/roadmap.md, pode ser útil para separar a implementação em etapas e eu acompanhar o desenvolvimento. Me oriente também quanto como deve ser a organização das pastas, já que nesse mesmo repositorio eu gostaria de ter o backend e o frontend do projeto. Me oriente. 