# VlcPlaylistResume

Extensão do VLC feita em lua, salva a playlist atual em um .json, após salvar a primeira vez ou carregar um .json, ele salva automaticamente em que arquivo e tempo você parou. Ao abrir o vlc novamente e clicar na aba da extensão e abrir o .json ele adiciona todos os episodios na fila e volta onde você estava.

Existem uns 3 plugins que fazer a mesma coisa, só que de uma forma mais complexa e dificil de usar, esse é mais facil de usar, ainda falta fazer algumas coisinhas.

## Atualmente só funciona no Linux
Como acabei rushando em uma madrugada, não me preocupei com outros sistemas(2 dos plugins não funcionavam no linux), mas a adaptação é facil.

## Como instalar
Só executa o ./copy.sh, ele simplesmente copia os arquivos .lua pra pasta certa onde o vlc pesquisa os arquivos ``~/.local/share/vlc/lua/extensions``

## Como Usar
Clicar no menu View, e em Playlist Resume.  

Na primeira vez que for usar é necessário adicionar os arquivos que quer que salve na sua playlist atual ordenados, ao fazer isso abra a janela do plugin e digite um nome, e save playlist, apartir dai ele já começa a salvar automaticamente o tempo que está e em qual episódio.

Para carregar o seu progresso, ao abri ro vlc clique vá no menu do plugin e digite o nome que digitou para salvar e clique para dar load, ele vai dar play onde você estava.

### Vai ter um dropdown menu pra selecionar os que tão salvos rlx