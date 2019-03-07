require 'sinatra'
require 'slim'
require 'sqlite3'
enable :sessions

get('/') do

    slim(:index)
end

get('/login') do


    slim(:login)
end

# FIXA SÅ ATT MAN INTE KAN GÖRA NÅGOT DÅ ANVÄNDARNAMNET INTE FINNS
post('/logged') do 
    db = SQLite3::Database.new("db/Users.db")
    db.results_as_hash = true

    result = db.execute("SELECT * FROM users WHERE Username = (?)", params['Username'])

    id = result[0]
    session[:userId] = id[2]

    if result == nil 
        redirect('/logged')
    end

    if params["Username"] == result[0]["Username"] && params["Password"] == result[0]["Password"]
        redirect("/loggedin/profile/#{:userId}")
        
    else
        redirect('/logged')
    end
    
end

get('/loggedin/profile/:userId') do

    session[:username] = params["username"]
    session[:password] = params["password"]
    name = params["username"]

    db = SQLite3::Database.new("db/Users.db")
    db.results_as_hash = true

    posts_classic = db.execute("SELECT * FROM posts WHERE UserId = (?)", session[:userId])
    posts = posts_classic.reverse

    slim(:profile, locals:{posts:posts})
end

post('/logout') do
    session.destroy
    redirect('/')
end

get('/createUser') do

    slim(:createUser)
end

post('/created') do
    db = SQLite3::Database.new("db/Users.db")
    db.results_as_hash = true

    Users = db.execute("SELECT * FROM users WHERE Username = ?", params['Username'])

    if params['Username'] && params['Password'] 
        if Users == []
            newUser = db.execute("INSERT INTO users (Username,Password) VALUES ((?), (?))", params['Username'], params['Password'])
            redirect('/')
        else
            redirect('/createUser')
        end
    end
end

post('/newPost') do
    db = SQLite3::Database.new("db/Users.db")
    db.results_as_hash = true

    db.execute("INSERT INTO posts (Title, Text, Img, UserId ) VALUES ((?), (?), (?), (?))", params['Title'], params['Text'], params['Img'], session[:userId])
    redirect('/loggedin/profile/:userId')
end



