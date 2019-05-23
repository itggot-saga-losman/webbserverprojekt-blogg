require 'sinatra'
require 'sinatra/flash'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require 'byebug'
require 'json'
require_relative 'model.rb'
include MyModule
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
    result = login(params)

    response = createUser(params)
    
    if result == []
         
        flash[:loginError] = "Wrong username or password"
        redirect('/login')
    end

    if params["Username"] == result[0]["Username"] && BCrypt::Password.new(result[0]["Password"]) == params['Password']
        id = result[0]
        session[:userId] = id[2]
        redirect("/loggedin/profile/#{:userId}")
        
    else
        session[:error] = "ERROR: Wrong username or password"
        redirect('/login')
    end
    
end

get('/loggedin/profile/:userId') do
    if session[:userId]
        session[:username] = params["username"]
        session[:password] = params["password"]
        name = params["username"]
        posts = posts(session[:userId])

        slim(:profile, locals:{posts:posts})
    else
        redirect("/")
    end
end

post('/logout') do

    session.clear
    redirect('/')
end

get('/createUser') do

    slim(:createUser)
end

post('/created') do
    response = createUser(params)
    if response[:error]
        flash[:error] = response[:message] 
        redirect back
    else
       
        redirect('/')
    end

end

post('/newPost') do
    userId = session[:userId]
    newPost(userId, params)
    redirect('/loggedin/profile/:userId')
end

post('/deletePost/:postId') do
    
    deletePost(params)
    redirect('/loggedin/profile/:userId')
end

post('/editPostForm/:postId') do
    session["edit"] = params["postId"]
    redirect('/loggedin/profile/:userId')
end

post('/editPost/:postId') do
    userId = session[:userId]
    editPost(userId, params)
    session["edit"] = nil 
    redirect('/loggedin/profile/:userId')
end

post('/searchUsername') do

    if searchUser(params)
        result = searchUser(params)
        session[:username] = params['Username'].to_s
        session[:user] = result[0]["UserId"]

        redirect("/loggedin/user/#{:user}")
    else
        redirect('/loggedin/profile/:userId')
    end

end

get('/loggedin/user/:user') do
    user = session[:user]
    posts = getPosts(user)
    slim(:user, locals:{posts:posts})
end


