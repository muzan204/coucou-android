# Coucou Projects Hub V4

Hub Android para organizar projetos GitHub, Termux, sites e APKs em uma interface dark premium.

## V4

- nova paleta global dark premium
- identidade visual própria por projeto
- capas temáticas por projeto
- cores, brilho, ícones e categorias individuais
- cards redesenhados
- favoritos persistentes
- filtros: Todos, Favoritos, Sites, Públicos e Privados
- busca por nome, descrição e linguagem
- grid responsivo para celular, tablet e telas maiores
- detalhes do projeto usando a paleta do próprio projeto
- atualização do app via GitHub Releases
- fallback/cache para evitar tela vazia quando a API pública do GitHub atinge limite
- projetos privados via Fine-grained PAT salvo em flutter_secure_storage
- integração segura com Termux em localhost
- mascote flutuante com estados

## GitHub

Sem token, o Coucou carrega projetos públicos.

Para privados:

Ajustes > Projetos privados > Configurar

Use um Fine-grained PAT apenas com acesso aos repositórios necessários. Nunca coloque tokens no código ou no repositório.

## Termux

Instale o agente:

```bash
cd termux
chmod +x install-agent.sh coucou-agent
bash install-agent.sh
source ~/.zshrc
coucou-agent
```

O agente escuta somente em:

```text
127.0.0.1:8766
```

Ele aceita apenas operações específicas de projeto: status, clone e pull. O pull é bloqueado quando existem alterações locais.

A ponte de estado do mascote usa:

```text
127.0.0.1:8765
```

Exemplos:

```bash
coucou ping
coucou thinking
coucou working
coucou success
coucou error
```

## Atualizações

Cada push na branch main gera um APK release.

O canal automático publica:

- coucou-latest.apk
- version.json
- Release Coucou Projects Hub 4.0.x

O app compara a versão instalada com a versão publicada e oferece atualização dentro do Coucou.

## Estrutura principal

```text
lib/
├── core/
├── data/
│   └── project_themes.dart
├── models/
├── screens/
├── services/
└── widgets/
```

## Identidade visual

Base global:
- fundo: #07101D
- superfícies: #0F1B2D / #142238 / #1A2B44
- texto: #F8FAFC
- cyan: #16E7FF
- azul: #5B7CFA
- violeta: #9B6CFF
- rosa: #FF5FD2
- verde: #3BD88F
- âmbar: #F7C451
- vermelho: #FF627D

Cada projeto pode sobrescrever essas cores através de lib/data/project_themes.dart.
