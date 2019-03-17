require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
enable :sessions

configure do 

    set :db, SQLite3::Database.new("db/Users.db")
end

get('/') do
    slim(:index)
end

get('/login') do

    slim(:login)
end

post('/logged') do 

    db = settings.db
    db.results_as_hash = true

    result = db.execute("SELECT * FROM users WHERE Username = (?)", params['Username'])
 

    if result == []
        redirect('/login')
    end

    if params["Username"] == result[0]["Username"] && BCrypt::Password.new(result[0]["Password"]) == params['Password']
        id = result[0]
        session[:userId] = id[2]
        redirect("/loggedin/profile/#{:userId}")
        
    else
        redirect('/login')
    end
    
end

get('/loggedin/profile/:userId') do

    session[:username] = params["username"]
    session[:password] = params["password"]
    name = params["username"]

    db = settings.db
    db.results_as_hash = true

    posts_unsorted = db.execute("SELECT * FROM posts WHERE UserId = (?)", session[:userId])
    posts = posts_unsorted.reverse

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
    db = settings.db
    db.results_as_hash = true

    Users = db.execute("SELECT * FROM users WHERE Username = (?) OR Email = (?)", params['Username'], params['Email'])

    if params['Username'] && params['Password'] && params['Email']
        if Users == []
            password = BCrypt::Password.create(params['Password']) 
            
            newUser = db.execute("INSERT INTO users (Username, Password, Email) VALUES ((?), (?), (?))", params['Username'], password, params['Email'])
            redirect('/')
        else
            redirect('/createUser')
        end
    end
end

post('/newPost') do
    db = settings.db
    db.results_as_hash = true

    db.execute("INSERT INTO posts (Title, Text, Img, UserId ) VALUES ((?), (?), (?), (?))", params['Title'], params['Text'], params['Img'], session[:userId])
    redirect('/loggedin/profile/:userId')
end

post('/deletePost/:postId') do
    db = settings.db
    db.results_as_hash = true

    db.execute("DELETE FROM posts WHERE Id = (?)", params["postId"])

    redirect('/loggedin/profile/:userId')
end

post('/editPostForm/:postId') do
    session["edit"] = params["postId"]
    redirect('/loggedin/profile/:userId')
end

post('/editPost/:postId') do
    db = settings.db
    db.results_as_hash = true

    db.execute("UPDATE Posts set Title = (?), Text = (?), Img =(?), UserId = (?) where ID = (?)", params['Title'], params['Text'], params['Img'], session[:userId], session["edit"])
    session["edit"] = nil 
    redirect('/loggedin/profile/:userId')
end

post('/searchUsername') do
    db = settings.db
    db.results_as_hash = true

    result = db.execute("SELECT UserId FROM Users WHERE Username = (?)", params['Username'])

    if result != []
        session[:username] = params['Username'].to_s
        session[:user] = result[0]["UserId"]

        redirect("/loggedin/user/#{:user}")
    else
        redirect('/loggedin/profile/:userId')
    end
end

get('/loggedin/user/:user') do
    db = settings.db
    db.results_as_hash = true

    posts_classic = db.execute("SELECT * FROM posts WHERE UserId = (?)", session[:user])
    posts = posts_classic.reverse

    slim(:user, locals:{posts:posts})
end
