require 'sinatra'
require 'slim'
require 'sqlite3'


get('/') do

    slim(:index)
end


get('/login') do

    slim(:login)
end

post('/logged') do 
    db = SQLite3::Database.new("db/Users.db")
    db.results_as_hash = true


    #DETTA FUNKAR ITNE
    result = db.execute("SELECT * FROM users WHERE Username = (?)", params['Username'])

    id = result[0]
    userId = id[2]

    if result == [] 
        redirect('/logged')
    end

    if params["Username"] == result[0]["Username"] && params["Password"] == result[0]["Password"]
        redirect("/loggedin/#{userId}/profile")
        
    else
        redirect('/logged')
    end
    

end

get('/loggedin/:userId/profile') do

    session[:username] = params["username"]
    session[:password] = params["password"]

    slim(:profile)
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




