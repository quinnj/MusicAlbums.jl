module Mapper

using ..Model
using SQLite, DBInterface, Strapping

const DB = Ref{SQLite.DB}()
getdb() = DB[]

function __init__()
    DB[] = SQLite.DB()
    DBInterface.execute(getdb(), """
        CREATE TABLE album (
            id INTEGER PRIMARY KEY,
            name TEXT,
            artist TEXT,
            year INTEGER,
            timespicked INTEGER DEFAULT 0
        )
    """)
    DBInterface.execute(getdb(), """
        CREATE TABLE songs (
            album_id INTEGER,
            name TEXT
        )
    """)
    DBInterface.execute(getdb(), """
        CREATE INDEX idx_album_id ON songs (album_id)
    """)
    return
end

function create!(album::Album)
    stmt = DBInterface.@prepare(getdb, """
        INSERT INTO album (name, artist, year) VALUES(?, ?, ?)
    """)
    cursor = DBInterface.execute(stmt, (album.name, album.artist, album.year))
    id = DBInterface.lastrowid(cursor)
    album.id = id
    DBInterface.executemany(DBInterface.@prepare(getdb, """
        INSERT INTO songs (album_id, name) VALUES (?, ?)
    """), ([id for _ = 1:length(album.songs)], album.songs))
    return
end

function update(album)
    DBInterface.execute(DBInterface.@prepare(getdb, """
        UPDATE album
        SET name = ?,
            artist = ?,
            year = ?,
            timespicked = ?
        WHERE id = ?
    """), (album.name, album.artist, album.year, album.timespicked, album.id))
    DBInterface.execute(DBInterface.@prepare(getdb, """
        DELETE FROM songs WHERE album_id = ?
    """), (album.id,))
    DBInterface.executemany(DBInterface.@prepare(getdb, """
        INSERT INTO songs (album_id, name) VALUES (?, ?)
    """), ([album.id for _ = 1:length(album.songs)], album.songs))
    return
end

function get(id)
    Strapping.construct(Album, DBInterface.execute(DBInterface.@prepare(getdb, """
        SELECT A.id, A.name, A.artist, A.year, A.timespicked, B.name as songs FROM album A
        LEFT JOIN songs B ON A.id = B.album_id
        WHERE id = ?
    """), (id,)))
end

function delete(id)
    DBInterface.execute(DBInterface.@prepare(getdb, """
        DELETE FROM album WHERE id = ?
    """), (id,))
    DBInterface.execute(DBInterface.@prepare(getdb, """
        DELETE FROM songs WHERE album_id = ?
    """), (id,))
    return
end

function getAllAlbums()
    Strapping.construct(Vector{Album}, DBInterface.execute(DBInterface.@prepare(getdb, """
        SELECT A.id, A.name, A.artist, A.year, A.timespicked, B.name as songs FROM album A
        LEFT JOIN songs B ON A.id = B.album_id
    """)))
end

end # module