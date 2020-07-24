module Mapper

using ..Model, ..Contexts
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
                userid INTEGER,
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
        DBInterface.execute(getdb(), """
            CREATE INDEX idx_album_userid ON album (userid)
        """)
        DBInterface.execute(getdb(), """
            CREATE INDEX idx_album_id_userid ON album (id, userid)
        """)
        DBInterface.execute(getdb(), """
            CREATE TABLE user (
                id INTEGER PRIMARY KEY,
                username TEXT,
                password TEXT
            )
        """)
    end
    return
end

function insert(album)
    user = Contexts.getuser()
    album.userid = user.id
    DBInterface.executemany(DBInterface.@prepare(getdb, """
        INSERT INTO album (id, userid, name, artist, year, timespicked, songs) VALUES(?, ?, ?, ?, ?, ?, ?)
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

function get(id)
    user = Contexts.getuser()
    cursor = DBInterface.execute(DBInterface.@prepare(getdb, "SELECT * FROM album WHERE id = ? AND userid = ?"), (id, user.id))
    return Strapping.construct(Album, cursor)
end

function delete(id)
    user = Contexts.getuser()
    DBInterface.execute(DBInterface.@prepare(getdb, "DELETE FROM album WHERE id = ? AND userid = ?"), (id, user.id))
    return
end

function getAllAlbums()
    user = Contexts.getuser()
    cursor = DBInterface.execute(DBInterface.@prepare(getdb, "SELECT * FROM album WHERE userid = ?"), (user.id,))
    return Strapping.construct(Vector{Album}, cursor)
end

function create!(user::User)
    x = DBInterface.execute(DBInterface.@prepare(getdb, """
        INSERT INTO user (username, password) VALUES (?, ?)
    """), (user.username, user.password))
    user.id = DBInterface.lastrowid(x)
    return
end

function get(user::User)
    Strapping.construct(User, DBInterface.execute(DBInterface.@prepare(getdb, """
        SELECT * FROM user WHERE username = ?
    """), (user.username,)))
end

end # module