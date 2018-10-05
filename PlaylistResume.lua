-- Documentação massa, é um txt gigante dizendo o que as funções fazem, pra saber como o script inicializa(que função ele chama, ou o que precisa pra iniciar),
-- precisa ver outros plugins, das plataformas que já programei essa aqui com certeza é a mais merda e frustrante de programar
-- Só to fazendo isso por que não to conseguindo lembrar onde parei de ver naruto
-- Saca essa bosta de documentação https://www.videolan.org/developers/vlc/share/lua/README.txt GRRRRRRR

function descriptor()
    return { title = "PlayelistSavePosition" ;
             version = "1.0" ;
             author = "Feldmann" ;
             url = 'http://github.com/FeldmannJR/';
             shortdesc = "Save playlist location",
             description = "Save the current position in playlist, this is usefull for long shows when you can't remember where you stopped" ;
             capabilities = {"input-listener","meta-listener"}
		    }
end


saveFolder = nil
sep = nil
JSON = nil

function loadConfig()


end


function addCurrentPlaylist()
    local entries = vlc.playlist.get("playlist").children
    vlc.msg.info(tostring(#entries))
    local info = {files = {}}
    for i, item in pairs(entries) do
        table.insert(info.files,{id=item.id,path=item.path})
    end
    table.insert(info, (lastPlayed))
    vlc.msg.info(vlc.playlist.current()..JSON:encode_pretty(info))
    
end


function loadGUI()
    local d = vlc.dialog("Load show")
    d:add_button("Adicionar Playlist",addCurrentPlaylist)
    d:show()
end

function debug(value)
    vlc.msg.info(JSON:encode(value))
end

function activate()
    --Loading json api to save table in files
    JSON = assert(loadfile "JSON.lua")()
    sep = package.config:sub(1,1);    
    saveFolder = vlc.config.userdatadir()
    loadGUI()
end
