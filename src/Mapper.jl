module Mapper

using ..Model, ..Contexts, ..ConnectionPools
using SQLite, DBInterface, Strapping, Tables

const DB_POOL = Ref{ConnectionPools.Pod{ConnectionPools.Connection{SQLite.DB}}}()
const COUNTER = Ref{Int64}(0)

function init(dbfile)
    new = () -> SQLite.DB(dbfile)
    DB_POOL[] = ConnectionPools.Pod(SQLite.DB, Threads.nthreads(), 60, 1000, new)
    if !isfile(dbfile)
        db = SQLite.DB(dbfile)
        DBInterface.execute(db, """
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
        DBInterface.execute(db, """
            CREATE INDEX idx_album_id ON album (id)
        """)
        DBInterface.execute(db, """
            CREATE INDEX idx_album_userid ON album (userid)
        """)
        DBInterface.execute(db, """
            CREATE INDEX idx_album_id_userid ON album (id, userid)
        """)
        DBInterface.execute(db, """
            CREATE TABLE user (
                id INTEGER PRIMARY KEY,
                username TEXT,
                password TEXT
            )
        """)
    end
    return
end

function execute(sql, params; executemany::Bool=false)
    withconnection(DB_POOL[]) do db
        stmt = DBInterface.prepare(db, sql)
        if executemany
            DBInterface.executemany(stmt, params)
        else
            DBInterface.execute(stmt, params)
        end
    end
end

function insert(album)
    user = Contexts.getuser()
    album.userid = user.id
    execute("""
        INSERT INTO album (id, userid, name, artist, year, timespicked, songs) VALUES(?, ?, ?, ?, ?, ?, ?)
    """, columntable(Strapping.deconstruct(album)); executemany=true)
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
    cursor = execute("SELECT * FROM album WHERE id = ? AND userid = ?", (id, user.id))
    return Strapping.construct(Album, cursor)
end

function delete(id)
    user = Contexts.getuser()
    execute("DELETE FROM album WHERE id = ? AND userid = ?", (id, user.id))
    return
end

function getAllAlbums()
    user = Contexts.getuser()
    cursor = execute("SELECT * FROM album WHERE userid = ?", (user.id,))
    return Strapping.construct(Vector{Album}, cursor)
end

function create!(user::User)
    x = execute("""
        INSERT INTO user (username, password) VALUES (?, ?)
    """, (user.username, user.password))
    user.id = DBInterface.lastrowid(x)
    return
end

function get(user::User)
    cursor = execute("SELECT * FROM user WHERE username = ?", (user.username,))
    return Strapping.construct(User, cursor)
end

end # module