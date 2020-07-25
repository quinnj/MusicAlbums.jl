using Test, MusicAlbums

const DBFILE = joinpath(dirname(pathof(MusicAlbums)), "../test/albums2.sqlite")
const AUTHFILE = "file://" * joinpath(dirname(pathof(MusicAlbums)), "../resources/authkeys.json")

server = @async MusicAlbums.run(DBFILE, AUTHFILE)

Client.createUser("quinnj", "julia4evah!")
user = Client.loginUser("quinnj", "julia4evah!")

using HTTP; HTTP.CookieRequest.default_cookiejar[1]

alb1 = Client.createAlbum("Free Yourself Up", "Lake Street Dive", 2018, ["Baby Don't Leave Me Alone With My Thoughts", "Good Kisser"])
@test Client.pickAlbumToListen() == alb1
@test Client.pickAlbumToListen() == alb1

@test Client.getAlbum(alb1.id) == alb1

push!(alb1.songs, "Shame, Shame, Shame")
alb2 = Client.updateAlbum(alb1)
@test length(alb2.songs) == 3
@test length(Client.getAlbum(alb1.id).songs) == 3

Client.deleteAlbum(alb1.id)
# Client.pickAlbumToListen()

# alb2 = Client.createAlbum("Haunted Heart", "Charlie Haden Quartet West", 1991, ["Introduction", "Hello My Lovely"])
# @test Client.pickAlbumToListen() == alb2

# Client.createAlbum("Hazards Of Love", "The Decemberists", 2009, ["Prelude", "The Hazards Of Love 1"])
# Client.createAlbum("Tapestry", "Carole King", 1971, ["I Feel The Earth Move", "So Far Away"])
