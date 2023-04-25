
module Model

def connect_to_db()

    db = SQLite3::Database.new('db/legofigure.db')
    db.results_as_hash = true
    return db
end

def see_friends(id) #användarnamn och delar till index

    db = connect_to_db()
    return db.execute("SELECT username, part1, part2, part3, part4, part5 FROM part_user_relation INNER JOIN user ON part_user_relation.user_id = user.user_id WHERE NOT user.user_id = ?", id) 

end

def register_user(username, password, password2, username_db) #användarregistering
    
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
        db.execute("INSERT INTO user (username,pwdigest,admin) VALUES (?,?,'no')",username,password_digest)
        id = db.execute("SELECT user_id FROM user WHERE username = ?",username)
        db.execute("INSERT INTO part_user_relation VALUES (?,24,21,22,23,24)",id)
        
        return "Du har nu ett konto och kan logga in"
    else
        return "Lösenorden matchar inte"
    end
end

def join_parts_username(id) #anändarnamn och delar för show, en själv
    db = SQLite3::Database.new('db/legofigure.db')
    return db.execute("SELECT username, part1, part2, part3, part4, part5 FROM part_user_relation INNER JOIN user 
    ON part_user_relation.user_id = user.user_id WHERE user.user_id = ?", id).first
end

def part_loop(id) #alla delar till edit figure

    i = 0
    parts = []

    db = connect_to_db()
    while i <= 4
        parts << db.execute("SELECT part_id FROM parts WHERE type = ?", @type[i])
        i += 1
    end

    return parts
end

def update_parts(headgear, head, torso, legs, equipment, id) #post rout för att uppdaetra delar på gubbe

    if headgear == nil || head == nil || torso == nil || legs == nil || equipment == nil  
        return "Du måste välja en av varje del"
    else
        db = SQLite3::Database.new('db/legofigure.db')
        db.execute("UPDATE part_user_relation SET part1 = ?, part2 = ?, part3 = ?, part4 = ?, part5 = ? WHERE user_id = ?",headgear,head,torso,equipment,legs,id)
        return "" 
    end
end

def admin_check(id, db)
    return db.execute("SELECT admin FROM user WHERE user_id = ?",id)
end

def admin_loop(db)
    return db.execute("SELECT username, user_id, admin FROM user ORDER BY user_id")
end

def admin_updates() #admin post route

    db = SQLite3::Database.new('db/legofigure.db')
    users = db.execute("SELECT user_id FROM user ORDER BY user_id")

    i = 0
    while i < users.length
        id = users[i][0]
        update = params[:"update#{id}"]

        if update == "delete"
            db.execute("DELETE FROM part_user_relation WHERE user_id = ?",id)
            db.execute("DELETE FROM user WHERE user_id = ?",id)
        elsif update == "promote"
            db.execute("UPDATE user SET admin = 'yes' WHERE user_id = ?",id)
        end

        i += 1
    end
end

def user_delete(password, id) #ta bort sitt eget konto

    db = SQLite3::Database.new('db/legofigure.db')
    pwdigest = db.execute("SELECT pwdigest FROM user WHERE user_id = ?", id)
        
    if BCrypt::Password.new(pwdigest[0][0]) == password
        db.execute("DELETE FROM part_user_relation WHERE user_id = ?", id)
        db.execute("DELETE FROM user WHERE user_id = ?", id)
        return true
    else
        return "Fel lösenord"
    end
end

def login(username, password)

    #time << Time.now.to_i
    db = connect_to_db()
    result = db.execute("SELECT * FROM user WHERE username = ?", username).first

    #if validate(time) == true
    
    if result == nil
        return "Fel lösenord eller användarnamn"
    end

    pwdigest = result['pwdigest']
    id = result['user_id']

    if BCrypt::Password.new(pwdigest) == password 
        return id
    else
        return "Fel lösenord eller användarnamn"
    end
end

def validate(time)

end

end