


def connect_to_db()

    db = SQLite3::Database.new('db/legofigure.db')
    db.results_as_hash = true
end

def see_friends()

    #inner join  

end

def register_user(username, password, password2)
   
    if username == "" || password == "" || password2 == ""
        return "Fyll i alla rutor!!!"

    elsif
        db = connect_to_db()
        username_db = db.execute("SELECT username FROM user")

        username_db.each do |username_db|
            if username == username_db['username'] 
                retrun "Användarnamnet är upptaget, välj ett annat"
            end
        end

    elsif (password == password2)
        password_digest = BCrypt::Password.create(password)
        db = SQLite3::Database.new('db/legofigure.db')
        db.execute("INSERT INTO user (username,pwdigest) VALUES (?,?)",username,password_digest)
        id = db.execute("SELECT user_id FROM user WHERE username = ?", username)
        db.execute("INSERT INTO partofig (user_id) VALUES (?)",id)
        
        return "Du har nu ett konto och kan logga in"

    else
        return "Lösenorden matchar inte"
    end
end

def join_parts_username(id)
    return ("SELECT username, part1, part2, part3, part4, part5 
    FROM partofig INNER JOIN user 
    ON partofig.user_id = user.user_id")
end
