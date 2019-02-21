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

    result = db.execute("SELECT * FROM users WHERE Username = (?)", params['Username'])

    if result == [] 
        redirect('/logged')
    end

    if params["Username"] == result[0]["Username"] && params["Password"] == result[0]["Password"]
        redirect('/loggedin/profile')
        
    else
        redirect('/logged')
    end
    

end

get('/createUser') do

    slim(:createUser)
end


get('/loggedin/profile') do

    slim(:profile)
end
