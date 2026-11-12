# Imagem Docker TilBuci

Este modelo descreve a imagem Docker do projeto TilBuci, uma ferramenta livre para a criação de conteúdo digital interativo que funcipona a partir de navegadores.

## Idioma

Memso que os textos deste modelo estejam todos em português, todos os textos usados para a imegem e referêncvias devem estar em inglês.

## Sobre o TilBuci

O TilBuci é uma ferramenta web, que funciona a partir de um navegador. A ferramenta carrega a página em formato rtadicional (HTML/CSS/JS). O usuário acessa a url da instalação, faz um login (caso ela esteja instalada em modo multi usuário) ou simplesmente acessa o prograna (caso ela esteja instalada no modo de usuário único). Para funcionar, o TilBuci é testado no seguinte ambiente:

- sistema Linux (Ubuntu)
- servidor Apache
- PHP (versão 8 ou superior)
- MariaDB

### Instalação do TilBuci

O TilBuci conta com um pacote instalador, que traz um script "setup.php" e alguns outros arquivos. A instalação manual começa com o acesso a esse script por meio de um navegador onde o usuário informa as seguintes configurações:

- dados de acesso ao banco MariaDB
- e-mail do usuário
- modo de instalação: "multi" ou "single"

Ao enviar essas informações o script inicia a instalação, que copia os arquivos necessários e cria a estrutra de base de dados usada.

O mesmo script de instalação pode ser executado em uma pasta do servidor em que já exista uma instalação válida do TilBuci para atualizar a versão existente. Nesse caso nenhuma informação é pedida ao usuáiro, ele apenas confirma a instenção de atualizar.

### Estrutura de pastas e persistência de dados

No servidor web, após instalado, a estrutura de pastas criada na instalação do TilBuci é essa:

app
database
events
export
|- desktop
|- ifrane
|- mobile
|- publish
|- pwa
|- runtimes
|- site
language
public_html (pasta pública, visível a partir do navegador)
|- app
|- download
|- editor
|- font
|- movie
|- ws
|- sites (opcional, criada por demanda)
|- pwa (opcional, criada por demanda)

Para a persistência das informações no uso do TilBuci, além de toda a base de dados gerada, os seguintes arquivos também são necessários:

- arquivo "Config.php" na pasta "app"
- arquivo "player.json" na pasta "public_html/app"
- arquivo "editor.json" na pasta "public_html/app"
- toda a pasta "public_html/movie"
- toda a pasta "public_html/font"
- toda a pasta "public_html/sites" caso ela exista
- toda a pasta "public_html/pwa" caso ela exista

Além de aplicar ajustes na estrutura e mudar algumas informações na base de dados, a atualização do TilBuci sobrescreve todos os arquivos no servidor web.