# Publicação no Docker Hub — guia de manutenção

Este guia descreve como **gerar o pacote de distribuição** (`docker/distro`),
**copiá-lo para o repositório principal** e **publicar/atualizar a imagem no
Docker Hub**.

> Observação de idioma: este é um guia de manutenção (não vai para dentro da
> imagem). Os artefatos gerados para a imagem continuam em inglês.

---

## 0. Instalação a partir do Docker Hub (usuário final)

Imagem publicada: **`tilbuci/tilbuci`** (tags `26.0.0` e `latest`).

### 0.1 Baixar a imagem

```bash
docker pull tilbuci/tilbuci:latest
# ou fixando a versão:
docker pull tilbuci/tilbuci:26.0.0
```

O Docker escolhe automaticamente a variante da arquitetura (amd64 ou arm64).

### 0.2 Primeira execução (configuração no navegador)

O contêiner sobe normalmente, **sem prompt e sem parâmetros de configuração**. A
primeira visita ao endereço do aplicativo carrega o instalador automaticamente
(`setup.php?docker=true`), onde você informa apenas **e-mail**, **senha inicial**
e **modo**. O banco já vem configurado (usuário `tilbuci`, base `tilbuci`).

```bash
docker run -d --name tilbuci \
  -p 8080:80 \
  -v tilbuci-data:/data \
  -e TILBUCI_URL=http://localhost:8080/ \
  tilbuci/tilbuci:latest
```

Abra `http://localhost:8080/` → o instalador é carregado → informe e-mail, senha
inicial e modo (`multi` ou `single`) → conclua. Ao terminar, o instalador se
remove sozinho e o contêiner segue normalmente.

Depois acesse `http://localhost:8080/editor/` com o e-mail e a senha definidos.

> Use `multi` para servidor/rede (login e papéis) e `single` para uso
> pessoal/local sem login.

### 0.4 Configuração essencial

- **Porta e URL precisam bater.** O contêiner escuta na porta 80 internamente e
  não descobre a porta publicada no host:
  - `-p 8080:80` → defina `TILBUCI_URL=http://localhost:8080/`;
  - para manter `http://localhost/` (padrão), publique na 80: `-p 80:80`.
- **Volume obrigatório.** Use um volume nomeado (`-v tilbuci-data:/data`). Sem
  ele, remover o contêiner apaga banco, mídias e configuração (`/data`).
- **Banco de dados interno:** usuário `tilbuci`, base `tilbuci`, servidor
  `localhost` (socket interno, sem TCP). A senha padrão é `S3nh4Dogg0` e pode ser
  trocada com `-e TILBUCI_DB_PASSWORD=...`. O banco não é exposto fora do
  contêiner.
- **Acesso remoto/produção:** use o endereço real, por exemplo
  `-e TILBUCI_URL=https://tilbuci.seudominio.com/`, de preferência atrás de um
  proxy com HTTPS.

### 0.5 Verificações rápidas

```bash
docker logs -f tilbuci
curl -s -o /dev/null -w '%{http_code}\n' http://localhost:8080/editor/   # esperado: 302
docker exec tilbuci mysql tilbuci -e 'SHOW TABLES;'
```

### 0.6 Atualizar (mesmo volume)

```bash
docker pull tilbuci/tilbuci:latest
docker rm -f tilbuci
docker run -it --name tilbuci -p 8080:80 -v tilbuci-data:/data \
  -e TILBUCI_URL=http://localhost:8080/ tilbuci/tilbuci:latest
```

Se o banco estiver em versão anterior, o contêiner faz backup em `/data/backups`
e aplica a atualização automaticamente (`TILBUCI_AUTO_UPDATE`, padrão `true`).

### 0.7 Docker Compose (recomendado)

O pacote inclui um `compose.yaml` que já usa a imagem publicada, publica a porta
e monta o volume — basta um comando (sem prompt no start):

```bash
docker compose up -d
```

Equivalente ao arquivo distribuído:

```yaml
services:
  tilbuci:
    image: tilbuci/tilbuci:latest
    container_name: tilbuci
    restart: unless-stopped
    ports:
      - "${TILBUCI_PORT:-8080}:80"
    environment:
      TILBUCI_URL: "${TILBUCI_URL:-http://localhost:${TILBUCI_PORT:-8080}/}"
    volumes:
      - tilbuci-data:/data
volumes:
  tilbuci-data:
```

Para mudar a porta: `TILBUCI_PORT=9090 docker compose up -d`. Para acesso
remoto: `TILBUCI_URL=https://tilbuci.seudominio.com/ docker compose up -d`.

### 0.8 Problemas comuns na instalação

| Sintoma | Solução |
| --- | --- |
| A instalação não abre / contêiner reinicia | Inspecione `docker logs -f tilbuci`; o instalador aparece no navegador na primeira visita ao endereço (`setup.php?docker=true`). |
| Página aponta para a porta errada | Ajuste `TILBUCI_URL` ou rode `docker exec -it tilbuci tilbuci-set-url http://SEU_ENDERECO:PORTA/`. |
| `container name is already in use` | Já existe um `tilbuci`: `docker start -a tilbuci` ou `docker rm -f tilbuci`. |
| Recomeçar do zero | `docker rm -f tilbuci && docker volume rm tilbuci-data` (apaga tudo). |

---

## 1. Estrutura e papéis

| Local | Papel |
| --- | --- |
| `docker/` (este repositório) | Ambiente de desenvolvimento: `Dockerfile`, entrypoint, configs e helpers |
| `docker/setup/` | Instalador do TilBuci (**fonte da verdade**, substituído a cada versão) |
| `docker/distro/` | **Pacote de distribuição gerado**, autocontido, pronto para copiar |
| Repositório principal → `docker/` | Destino: o conteúdo de `docker/distro` é copiado para cá |

Regra: o `distro` é **gerado a partir** dos arquivos de `docker/` + o instalador.
Os arquivos exclusivos do pacote (`README.md`, `build.sh`, `compose.yaml`,
`VERSION`, `.dockerignore`) são mantidos manualmente e **não** são sobrescritos
pela sincronização.

Arquivos sincronizados a partir de `docker/`:
`Dockerfile`, `docker-entrypoint.sh`, `supervisord.conf`, `apache/`, `php/`,
`bin/` e `setup/` (do `docker/setup`).

Arquivos exclusivos do pacote (mantidos): `README.md`, `build.sh`,
`compose.yaml`, `VERSION`, `.dockerignore`.

---

## 2. Pré-requisitos

- Docker Engine 20.10+ com `buildx` (`docker buildx version`).
- Conta no Docker Hub (ex.: `tilbuci`) e um **Access Token**
  (Docker Hub → Account Settings → Security → New Access Token).
- (Opcional) Para gerar a variante `linux/arm64` em host `amd64`:
  ```bash
  docker run --privileged --rm tonistiigi/binfmt --install all
  ```

---

## 3. Passo 1 — Atualizar o instalador

Substitua o conteúdo de `docker/setup/` pela versão nova do instalador,
mantendo a estrutura:

```
docker/setup/
├── setup.php
├── README.txt
└── setup/
    ├── part1.zip
    ├── part2.zip
    ├── part3.zip
    └── database/*.sql
```

**Não altere o `setup.php`.** A integração (instalação headless, detecção de
versão e atualização automática) é feita ao redor dele.

---

## 4. Passo 2 — Sincronizar o pacote `docker/distro`

A partir da raiz **deste** repositório:

```bash
cp -a docker/Dockerfile docker/docker-entrypoint.sh docker/supervisord.conf \
      docker/apache docker/php docker/bin \
      docker/distro/

rm -rf docker/distro/setup
cp -a docker/setup docker/distro/setup
```

> Não copie `docker/.dockerignore` para o distro — o pacote tem o seu próprio
> (que ignora `README.md`, `build.sh`, `compose.yaml`, `VERSION`).
> Os arquivos exclusivos do pacote permanecem intactos.

Atualize a versão do pacote (usada pelo `build.sh` como tag padrão):

```bash
echo "26.0.0" > docker/distro/VERSION     # ajuste ao lançar, ex.: 26.0.1
```

Conteúdo esperado de `docker/distro/`:

```
Dockerfile
docker-entrypoint.sh
supervisord.conf
apache/tilbuci.conf
php/php.ini
bin/install.php  bin/tilbuci-common.sh  bin/tilbuci-update
bin/tilbuci-set-url  bin/tilbuci-set-url.php
setup/            (instalador autocontido)
build.sh
compose.yaml
VERSION
.dockerignore
README.md
```

---

## 5. Passo 3 — Validar localmente

```bash
cd docker/distro
docker compose -f compose.yaml config >/dev/null && echo "compose OK"
docker build -t tilbuci:26.0.0 .
docker run -d --name tilbuci-test -p 8082:80 -v tilbuci-test-data:/data \
  -e TILBUCI_URL=http://localhost:8082/ tilbuci:26.0.0
sleep 50
curl -s -o /dev/null -w 'editor: %{http_code}\n' http://localhost:8082/editor/   # esperado: 302
docker rm -f tilbuci-test && docker volume rm tilbuci-test-data
```

> Um build **multi-plataforma** não pode ser carregado na engine local; para
> testar localmente, construa uma única plataforma (`PLATFORMS=linux/amd64 ./build.sh`).

---

## 6. Passo 4 — Copiar para o repositório principal

No repositório principal do TilBuci, substitua o conteúdo de `docker/` pelo do
pacote (ou mescle os arquivos):

```bash
rm -rf docker && cp -a /caminho/tbmodels/docker/distro docker
```

Garanta que o `.gitignore` do repositório principal mantenha o pacote rastreado.
O modelo `gitignore-tilbuci` inclui, ao final:

```gitignore
!docker/
!docker/**
```

Isso preserva as regras existentes (por exemplo, `setup/*.zip` da raiz continua
ignorado) e libera todo o conteúdo de `docker/`, inclusive o instalador
embutido (`docker/setup/setup/part*.zip`).

Commit e push:

```bash
git add docker
git commit -m "Add multi-arch Docker package for TilBuci 26 (package 26.0.0)"
git push
```

---

## 7. Passo 5 — Publicar no Docker Hub

Execute da **raiz do repositório principal** (onde existe a pasta `docker/`).
Confirme o contexto antes:

```bash
ls -d ./docker ./docker/Dockerfile
```

Login (usuário + **Access Token**):

```bash
docker login          # Username: tilbuci   Password: <access token>
```

Build multi-arquitetura + push:

```bash
DOCKERHUB_USER=tilbuci

docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --build-arg TILBUCI_VERSION=26 \
  --build-arg DOCKER_VERSION=26.0.0 \
  -t "${DOCKERHUB_USER}/tilbuci:26.0.0" \
  -t "${DOCKERHUB_USER}/tilbuci:latest" \
  --push ./docker
```

Ou, usando o script do pacote (no repositório principal ele fica em
`docker/build.sh`):

```bash
IMAGE=tilbuci/tilbuci TAG=26.0.0 PUSH=true ./docker/build.sh
```

Se aparecer `unable to prepare context: path "./docker" not found`, você não
está na raiz do repositório — ajuste o diretório (`cd /caminho/do/repo`) ou o
contexto (use `.` se estiver dentro de `docker/`).

### Verificar o que foi publicado

```bash
docker buildx imagetools inspect tilbuci/tilbuci:26.0.0
docker buildx imagetools inspect tilbuci/tilbuci:latest
```

Devem aparecer as duas plataformas (`linux/amd64` e `linux/arm64`).

### Testar o pull

```bash
docker pull tilbuci/tilbuci:26.0.0
docker run -it --name tilbuci -p 8080:80 -v tilbuci-data:/data \
  -e TILBUCI_URL=http://localhost:8080/ \
  tilbuci/tilbuci:26.0.0
# acesse http://localhost:8080/editor/  (senha inicial: password)
```

---

## 8. Passo 6 — Atualizações de versão (fluxo resumido)

1. Substituir `docker/setup/` (instalador novo).
2. Sincronizar `docker/distro` (Passo 4) e atualizar `docker/distro/VERSION`.
3. Commit/push no repositório principal.
4. Publicar novas tags (versão + `latest`):

   ```bash
   docker buildx build \
     --platform linux/amd64,linux/arm64 \
     --build-arg TILBUCI_VERSION=26 \
     --build-arg DOCKER_VERSION=26.0.0 \
     -t tilbuci/tilbuci:26.0.0 \
     -t tilbuci/tilbuci:latest \
     --push ./docker
   ```

No primeiro start após a atualização, o contêiner compara o `dbVersion` do banco
com a versão do instalador embarcado e, se o banco for anterior, faz **backup em
`/data/backups`** e aplica a atualização automaticamente (`TILBUCI_AUTO_UPDATE`,
padrão `true`).

---

## 9. Automação (opcional)

### GitHub Actions → Docker Hub

Crie os secrets `DOCKERHUB_USERNAME` e `DOCKERHUB_TOKEN` no repositório e troque
o login no workflow por:

```yaml
- uses: docker/login-action@v3
  with:
    username: ${{ secrets.DOCKERHUB_USERNAME }}
    password: ${{ secrets.DOCKERHUB_TOKEN }}
```

Mantenha no `docker/build-push-action`:

```yaml
context: ./docker
platforms: linux/amd64,linux/arm64
```

### Docker Hub “Automated Builds”

Vincule o repositório GitHub e configure:

- **Dockerfile location:** `docker/Dockerfile`
- **Build context:** `/docker`

(Geralmente o GitHub Actions é mais flexível, especialmente para
multi-arquitetura.)

---

## 10. Boas práticas

- **Nome minúsculo:** usuário/repositório do Docker Hub devem ser minúsculos
  (`tilbuci/tilbuci`).
- **Sempre publique versão + `latest`**, permitindo pinagem e atualização.
- **Use Access Token** (não a senha), principalmente com 2FA.
- **Rate limits:** o Docker Hub limita pulls anônimos; imagens completas
  (Ubuntu + MariaDB) contam. Consumidores autenticados têm limites maiores.
- **Metadados do repositório:** preencha descrição/README na página do Hub e
  vincule ao repositório Git (os rótulos OCI da imagem já trazem
  `org.opencontainers.image.source`).
- **Espelho opcional:** o mesmo `build.sh` publica no GHCR trocando `IMAGE`.

---

## 11. Problemas comuns

| Sintoma | Causa / solução |
| --- | --- |
| `bash: <nome>: No such file or directory` | Placeholders com `<>`; substitua o valor **sem** os `<>`. |
| `unable to prepare context: path "./docker" not found` | Comando fora da raiz do repositório; use `./docker` da raiz (ou `.` dentro de `docker/`). |
| `denied: requested access to the resource is denied` | Falta `docker login` ou namespace errado; use `tilbuci/tilbuci`. |
| Falha ao gerar `linux/arm64` | Instale binfmt (QEMU) e use o builder do `buildx`. |
| `Conflict. The container name ... is already in use` | Já existe um contêiner com esse nome: `docker start -a tilbuci` ou `docker rm -f tilbuci`. |

---

## 12. Checklist rápido

- [ ] `docker/setup/` atualizado (instalador novo)
- [ ] `docker/distro` sincronizado e `VERSION` atualizado
- [ ] build local validado (compose OK; `editor: 302`)
- [ ] repositório principal com `!docker/**` no `.gitignore` e push feito
- [ ] `docker login` com access token
- [ ] `buildx --push` (amd64 + arm64) com tags `<versão>` e `latest`
- [ ] `imagetools inspect` confirmando as duas plataformas
