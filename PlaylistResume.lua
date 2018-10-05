-- Documentação massa, é um txt gigante dizendo o que as funções fazem, pra saber como o script inicializa(que função ele chama, ou o que precisa pra iniciar),
-- precisa ver outros plugins, das plataformas que já programei essa aqui com certeza é a mais merda e frustrante de programar
-- Só to fazendo isso por que não to conseguindo lembrar onde parei de ver naruto
-- Saca essa bosta de documentação https://www.videolan.org/developers/vlc/share/lua/README.txt GRRRRRRR


function descriptor()
    return { title = "PlayelistSavePosition" ;
             version = "1.0" ;
             author = "Feldmann" ;
             url = 'http://github.com/FeldmannJR/';
             shortdesc = "Playlist Resume",
             description = "Save the current position in playlist, this is usefull for long shows when you can't remember where you stopped" ;
             capabilities = {"input-listener","meta-listener"}
		    }
end


saveFolder = nil
sep = nil
JSON = nil
nameW = nil
savingFile = nil

function loadConfig()

end
function meta_changed()  
    local inpt = vlc.object.input()
    if inpt == nil then return end   -- just in case
    local stst = vlc.var.get(inpt, "state") -- 1=start 4=stop
    if savingFile~=nil and stst == 4 then
        saveTableToFile(currentPlaylistToTable(), savingFile)
    end
end


function addCurrentPlaylist()
    local table = currentPlaylistToTable()
    local saving = nameW:get_text()
    savingFile = saving
    saveTableToFile(table,saving)
    nameW:set_text("")
end


function currentPlaylistToTable()
    local entries = vlc.playlist.get("playlist").children
    local info = {files = {}}
    local currentId = vlc.playlist.current()
    for i, item in pairs(entries) do
        if currentId==item.id then
           table.insert(info.files,{id=item.id,path=item.path,current=true})
        else
            table.insert(info.files,{id=item.id,path=item.path})
        end
    end
    info.lastTime=getTimePassed()
    vlc.msg.info(tostring(info.lastTime))
    return info
end

function getTimePassed()
    return math.floor(vlc.var.get(vlc.object.input(), "time")/1000000)
end

function loadPlaylist()
    local name = nameW:get_text()
    local f = assert(io.open(saveFolder..sep..name..".json"))
    local cont = f:read("*all")
    f:close()
    local info = JSON:decode(cont)
    vlc.playlist.clear()
    local lastPlayed = nil
    
    for k,v in pairs(info.files) do
        vlc.playlist.enqueue({{path=v.path}})
        if v.current and v.current == true then
            vlc.msg.info(info.lastTime)
            vlc.playlist.add({{path=v.path,options={"start-time="..info.lastTime}}})
        else
            vlc.playlist.enqueue({{path=v.path}})
        end
    end  
    savingFile = name
end


function saveTableToFile(table,file)
    local f = assert(io.open(saveFolder..sep..file..".json","w"))
    f:write(JSON:encode_pretty(table))
    f:flush()
    f:close()
end


function loadGUI()
    local d = vlc.dialog("Load show")
    nameW = d:add_text_input("")
    d:add_button("Adicionar Playlist",addCurrentPlaylist)
    d:add_button("Load Playlist",loadPlaylist)
    d:show()
end

function debug(value)
    vlc.msg.info(JSON:encode(value))
end

function mkdir_p(path)
    os.execute("mkdir -p '" .. path.."'")
end

function activate()
    sep = package.config:sub(1,1);    
    local jsonLoc = vlc.config.userdatadir()..sep.."lua"..sep.."extensions"..sep.."JSON.lua"
    JSON = assert(loadfile(jsonLoc))()
    saveFolder = vlc.config.userdatadir()..sep.."PlayListResume"
    mkdir_p(saveFolder)
    loadGUI()
end

function desactivate()
    if savingFile ~= nil then
        saveTableToFile(currentPlaylistToTable(),savingFile)
        savingFile = nil
    end
end