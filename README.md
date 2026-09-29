# Coucou Android V2 — Termux Edition

Versão Android inspirada na ideia geral do Coucou, refeita em Flutter para funcionar como companheiro flutuante no Android.

## O que foi acrescentado

- Mascote em overlay por cima dos outros apps
- Estados: idle, thinking, working, success, error e sleeping
- Ponte HTTP **somente em localhost**: `127.0.0.1:8765`
- Controle direto pelo Termux
- Script `coucou`
- Wrapper `coucou-run` que detecta sucesso/erro do comando
- Histórico dos eventos recentes
- Painel de status da ponte Termux
- Visual dark/neon adaptado para celular

## 1. Criar a estrutura Flutter

Em um PC com Flutter:

```bash
flutter create --org com.meraky --project-name coucou_android .
flutter pub get
flutter run
```

O ZIP contém os arquivos que devem ser preservados:
- `lib/main.dart`
- `pubspec.yaml`
- `android/app/src/main/AndroidManifest.xml`
- `android/app/src/main/kotlin/com/meraky/coucou_android/MainActivity.kt`

## 2. No Android

Abra o app e:
1. Toque em **Abrir permissão de sobreposição**.
2. Autorize o Coucou.
3. Volte ao app.
4. Toque em **Mostrar mascote flutuante**.
5. Mantenha o app aberto ou em segundo plano para a ponte Termux continuar ativa.

## 3. Instalar integração no Termux

Copie a pasta `termux` do projeto para o Termux e execute:

```bash
cd termux
chmod +x install-termux.sh coucou coucou-run
./install-termux.sh
source ~/.zshrc
```

Teste:

```bash
coucou ping
```

Depois:

```bash
coucou working
coucou thinking
coucou success
coucou error
coucou sleeping
coucou idle
```

## 4. Rodar comandos com estado automático

Exemplo:

```bash
coucou-run ls
```

ou:

```bash
coucou-run npm run build
```

Enquanto o processo roda:
- mascote = Trabalhando

Se terminar com código 0:
- mascote = Concluído

Se terminar com erro:
- mascote = Erro

## 5. Teste manual sem instalar script

```bash
curl "http://127.0.0.1:8765/ping"
curl "http://127.0.0.1:8765/state?value=working"
curl "http://127.0.0.1:8765/state?value=success"
```

## Redmi 15C / HyperOS 2

O HyperOS pode encerrar apps em segundo plano para economizar bateria. Se a ponte parar quando você sair do app, abra as configurações do Coucou e procure opções equivalentes a:

- Economia de bateria / Bateria do app -> **Sem restrições**
- Inicialização automática -> **Ativar**, se essa opção estiver disponível
- Exibir sobre outros apps -> **Permitir**

Os nomes exatos podem mudar conforme a versão/região do HyperOS.

## Segurança da ponte

O servidor é vinculado apenas a:

```text
127.0.0.1:8765
```

Ele não é exposto diretamente para outros aparelhos na mesma rede Wi‑Fi.

## Limitação atual

A ponte HTTP é executada pelo processo principal do app Flutter. Se o HyperOS encerrar completamente o Coucou, o Termux não conseguirá enviar estados até o app ser aberto novamente.

Uma V3 pode mover a ponte para um serviço Android em primeiro plano dedicado, deixando-a mais resistente ao gerenciamento agressivo de bateria.
