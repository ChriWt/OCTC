
Db = { metadata = {}, data = {} }
Db.__index = Db

-- una risorsa altro non e' che un file txt che contiene un dizionario

function Db:__new()
    -- qui deve creare una nuova risorsa
end

function Db:load()
    -- qui deve loaddare da un file
end

function Db:get()
    -- qui deve ritornare un valore da data 
end

function Db:getMetadata()
    -- qui ritorna una qualche informazione dei metadati
end

return Db
