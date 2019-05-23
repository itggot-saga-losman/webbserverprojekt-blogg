module MyModule
    

    def login(params)
        db = settings.db
        db.results_as_hash = true
        return db.execute("SELECT * FROM users WHERE Username = (?)", params['Username'])
    end

    def posts(userId)
        db = settings.db
        db.results_as_hash = true
        posts_unsorted = db.execute("SELECT * FROM posts WHERE UserId = (?)", userId)
        return posts_unsorted.reverse
    end

    
    def createUser(params)
        if params['Password'] == params['Password2']
            if getUser(params) == []
                db = settings.db
                db.results_as_hash = true
                password = BCrypt::Password.create(params['Password']) 
                
                newUser = db.execute("INSERT INTO users (Username, Password) VALUES ((?), (?))", params['Username'], password)
                return {
                    error: false
                }
            else
                return {
                    error: true,
                    message: "Username already occupied"
                }
            end
        else
            return {
                error: true,
                message: "Passwords don't match"
            } 
        end
    end

    def getUser(params)
            db = settings.db
            db.results_as_hash = true

            return db.execute("SELECT * FROM users WHERE Username = (?)", params['Username'])
        end


    def newPost(userId, params)
        db = settings.db
        db.results_as_hash = true

        return db.execute("INSERT INTO posts (Title, Text, UserId ) VALUES ((?), (?), (?))", params['Title'], params['Text'], userId)
    end

    def deletePost(params)
        db = settings.db
        db.results_as_hash = true

        db.execute("DELETE FROM posts WHERE Id = (?)", params["postId"])
    end

    def editPost(userId,params)
        db = settings.db
        db.results_as_hash = true

        db.execute("UPDATE Posts set Title = (?), Text = (?), UserId = (?) where ID = (?)", params['Title'], params['Text'], userId, session["edit"])
        
    end

    def searchUser(params)
        db = settings.db
        db.results_as_hash = true

        result = db.execute("SELECT UserId FROM Users WHERE Username = (?)", params['Username'])

        if result != []
             return result
        else
             false
        end

    end

    def getPosts(user)
        db = settings.db
        db.results_as_hash = true
        posts_classic = db.execute("SELECT * FROM posts WHERE UserId = (?)", user)
        return posts_classic.reverse
    end
    
end
