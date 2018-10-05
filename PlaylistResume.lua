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
GUI ={
    main = {
        window = nil,        
        fname = nil,
        select = nil,
        error = nil
    }
}
Config = {
    back = 5
}


jsonFiles = {}
saveFolder = nil
sep = nil
savingFile = nil

function loadConfig()

end
function meta_changed()  
    local inpt = vlc.object.input()
    if inpt == nil then return end   -- just in case
    local stst = vlc.var.get(inpt, "state") -- 1=start 4=stop
    if savingFile~=nil then
        saveTableToFile(currentPlaylistToTable(), savingFile)
    end
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
    local value = GUI.main.select:get_value()
    local name = jsonFiles[value]
    vlc.playlist.clear()
    if name == nil then
        error("File not found!")        
        return
    end
    local f = assert(io.open(saveFolder..sep..name..".json"))
    local cont = f:read("*all")
    f:close()
    local info = JSON:decode(cont)
    local lastPlayed = nil
    local started = false
    for k,v in pairs(info.files) do
        if v.current and v.current == true then
            vlc.playlist.add({{path=v.path,options={"start-time="..math.max(0,info.lastTime-Config.back)}}})
            started = true
        else
            vlc.playlist.enqueue({{path=v.path}})
        end
    end  
    if not started then vlc.playlist.play() end
    savingFile = name
    GUI.main.window:hide()
end

function msg(msg)
    GUI.main.error:set_text(msg);
end

function saveCurrentPlaylist()
    local table = currentPlaylistToTable()
    local saving = GUI.main.fname:get_text()
    savingFile = saving
    saveTableToFile(table,saving)
    GUI.main.fname:set_text("")
    msg("Playlist salva!")
    reloadPlaylists()

end

function saveTableToFile(table,file)
    local f = assert(io.open(saveFolder..sep..file..".json","w"))
    f:write(JSON:encode_pretty(table))
    f:flush()
    f:close()
end

function loadJsonFiles()
    jsonFiles = {}
    for k,v in pairs(scandir(saveFolder..sep)) do
        if ends_with(v,".json") then
            jsonFiles[k] = v:sub(0,-6)
        end
    end
end

function reloadPlaylists()
    loadJsonFiles()
    GUI.main.select:clear()
    for k,v in pairs(jsonFiles) do
        GUI.main.select:add_value(v,k)
    end
end

function loadGUI()
    local d = vlc.dialog("Load show")
    -- LOAD
    d:add_button("Load Playlist",loadPlaylist,3,1,1)
    GUI.main.select = d:add_dropdown(1,1,2)
    reloadPlaylists()
    -- SAVE
    d:add_button("Save",saveCurrentPlaylist,3,2,1)
    GUI.main.fname = d:add_text_input("",1,2,2)
    GUI.main.error = d:add_label("",1,3,3)
    d:show()
    GUI.main.window = d;

end

function debug(value)
    vlc.msg.info(JSON:encode(value))
end

function activate()
    sep = package.config:sub(1,1);    
    local jsonLoc = vlc.config.userdatadir()..sep.."lua"..sep.."extensions"..sep.."JSON.lua"
    JSON = assert(loadfile(jsonLoc))()
    saveFolder = vlc.config.userdatadir()..sep.."PlayListResume"
    mkdir_p(saveFolder)
    loadJsonFiles()
    debug(jsonFiles)
    loadGUI()
    vlc.msg.info(debug(vlc.misc))
end

function desactivate()
    if savingFile ~= nil then
        saveTableToFile(currentPlaylistToTable(),savingFile)
        savingFile = nil
    end
end


-- Utils Functions

function ends_with(str, ending)
    return ending == "" or str:sub(-#ending) == ending
 end
 
-- FILE FUNCTIONS - Need MS Windows functions, this only works in Linux
function mkdir_p(path)
    os.execute("mkdir -p '" .. path.."'")
end

function scandir(dirname)
    callit = os.tmpname()
    os.execute("ls -1 "..dirname .. " >"..callit)
    f = io.open(callit,"r")
    rv = f:read("*all")
    f:close()
    os.remove(callit)

    tabby = {}
    local from = 1
    local delim_from, delim_to = string.find( rv, "\n", from )
    while delim_from do
            table.insert( tabby, string.sub( rv, from , delim_from-1 ) )
            from = delim_to + 1
            delim_from, delim_to = string.find( rv, "\n", from )
    end
    -- table.insert( tabby, string.sub( rv, from  ) )
    -- Comment out eliminates blank line on end!
    return tabby
end