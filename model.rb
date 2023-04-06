


def connect_to_db()

    db = SQLite3::Database.new('db/legofigure.db')
    db.results_as_hash = true
    return db
end

def see_friends()

    db = connect_to_db()
    return db.execute("SELECT username, part1, part2, part3, part4, part5 FROM partofig INNER JOIN user ON partofig.user_id = user.user_id")
end

def register_user(username, password, password2, username_db)
    
    db = connect_to_db()

    if username == "" || password == "" || password2 == ""
        return "Fyll i alla rutor!!!"

    elsif (password == password2)

        username_db.each do |username_db|
            if username == username_db['username'] 
                return "Användarnamnet är upptaget, välj ett annat" 
            end
        end

        password_digest = BCrypt::Password.create(password)
        db = SQLite3::Database.new('db/legofigure.db')
        db.execute("INSERT INTO user (username,pwdigest) VALUES (?,?)",username,password_digest)
        id = db.execute("SELECT user_id FROM user WHERE username = ?",username)
        db.execute("INSERT INTO partofig VALUES (?,24,21,22,23,24)",id)
        
        return "Du har nu ett konto och kan logga in"
    else
        return "Lösenorden matchar inte"
    end
end

def join_parts_username(id)
    db = SQLite3::Database.new('db/legofigure.db')
    return db.execute("SELECT username, part1, part2, part3, part4, part5 FROM partofig INNER JOIN user 
    ON partofig.user_id = user.user_id WHERE user.user_id = ?", id).first
end

#admin, yes or no admin
# ta bort och läägga till användare

#säkra up routes

#restfull
