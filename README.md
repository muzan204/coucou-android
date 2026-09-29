# Coucou Projects Hub V3

Hub Android para organizar projetos GitHub, Termux, sites e APKs.

## Recursos
- sincroniza repositórios públicos do usuário `muzan204`
- suporta privados com Fine-grained GitHub PAT salvo em `flutter_secure_storage`
- cards com imagem social do GitHub
- abre GitHub e homepage/site
- detecta APKs em GitHub Releases
- baixa/atualiza projetos no Termux via agente localhost `127.0.0.1:8766`
- preserva a ponte de estados do mascote em `127.0.0.1:8765`
- overlay flutuante com mascote e identidade visual própria
- paleta 60-30-10: `#0F172A`, `#1E293B/#111827`, destaques cyan/violeta/verde

## Termux
Entre na pasta `termux` e rode:

```bash
chmod +x install-agent.sh coucou-agent
bash install-agent.sh
source ~/.zshrc
coucou-agent
```

O agente só escuta em `127.0.0.1` e aceita ações específicas de projeto: status, clone e pull. O pull é bloqueado quando existem alterações locais.

## Projetos privados
No app: Ajustes > Projetos privados > Configurar.
Use um Fine-grained PAT com acesso somente aos repositórios necessários. Nunca coloque o token no GitHub ou no código.

## APKs
Publique APKs em GitHub Releases nos repositórios dos aplicativos. O Coucou mostra automaticamente o APK da release mais recente.
