module Mapper

using ..Model
using SQLite, DBInterface, Strapping, Tables

const DB = Ref{SQLite.DB}()
getdb() = DB[]
const COUNTER = Ref{Int64}(0)

function init(dbfile)
    if isfile(dbfile)
        DB[] = SQLite.DB(dbfile)
    else
        DB[] = SQLite.DB(dbfile)
        DBInterface.execute(getdb(), """
            CREATE TABLE album (
                id INTEGER,
                name TEXT,
                artist TEXT,
                year INTEGER,
                timespicked INTEGER DEFAULT 0,
                songs TEXT
            )
        """)
        DBInterface.execute(getdb(), """
            CREATE INDEX idx_album_id ON album (id)
        """)
    end
    return
end

function insert(album)
    DBInterface.executemany(DBInterface.@prepare(getdb, """
        INSERT INTO album (id, name, artist, year, timespicked, songs) VALUES(?, ?, ?, ?, ?, ?)
    """), columntable(Strapping.deconstruct(album)))
    return
end

function create!(album::Album)
    album.id = COUNTER[] += 1
    insert(album)
    return
end

function update(album)
    delete(album.id)
    insert(album)
    return
end

get(id) = Strapping.construct(Album, DBInterface.execute(DBInterface.@prepare(getdb, "SELECT * FROM album WHERE id = ?"), (id,)))

delete(id) = DBInterface.execute(DBInterface.@prepare(getdb, "DELETE FROM album WHERE id = ?"), (id,))

getAllAlbums() = Strapping.construct(Vector{Album}, DBInterface.execute(DBInterface.@prepare(getdb, "SELECT * FROM album")))

end # module