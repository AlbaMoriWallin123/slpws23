require 'sinatra'
require 'slim'
require 'sinatra/reloader'
require 'sqlite3'
require 'bcrypt'
require_relative './model.rb'





enable :sessions


get('/register') do
    slim(:register)
end


get('/') do
    slim(:login)
end

get('/friends') do
    db = SQLite3::Database.new('db/legofigure.db')
    db.results_as_hash = true
    @name = db.execute("SELECT username FROM user")
    p @name
    @parts = db.execute("SELECT * FROM partofig")  
    slim(:index)
end


post('/new_user') do
    username = params[:username]
    password = params[:password]
    password2 = params[:password2]
    

    if (password == password2)
        db = SQLite3::Database.new('db/legofigure.db')
        db.results_as_hash = true
        username_db = db.execute("SELECT username FROM user") 
        
        username_db.each do |username_db|
            if username == username_db['username']
                session[:error] = "Användarnamnet är upptaget, välj ett annat"
                redirect('/register')
            end
        end

        password_digest = BCrypt::Password.create(password)
        db = SQLite3::Database.new('db/legofigure.db')
        db.execute("INSERT INTO user (username,pwdigest) VALUES (?,?)",username,password_digest)
        session[:error] = "Logga in med ditt nya konto"
        redirect('/')
    
    else
        session[:error] = "Lösenorden matchar inte"
        redirect('/register')
    end
end

post('/login') do
    username = params[:username]
    password = params[:password]

    db = SQLite3::Database.new('db/legofigure.db')
    db.results_as_hash = true
    result = db.execute("SELECT * FROM user WHERE username = ?", username).first
    pwdigest = result["pwdigest"]
    id = result["id"]

    if BCrypt::Password.new(pwdigest) == password
        session[:id] = id
        redirect('/figure')

    else
        session[:error] = "Fel lösenord eller användar namn"
        redirect('/')
    end
end



get('/figure') do #ser id:t
    id = session[:id].to_i
    db = SQLite3::Database.new('db/legofigure.db')
    db.results_as_hash = true
    @result = db.execute("SELECT * FROM partofig WHERE user_id = ?", id)
    p "herghgrjhgrhioefjiiho#{@result}"
    slim(:show)
end

get('/edit_figure') do
    db = SQLite3::Database.new('db/legofigure.db')
    db.results_as_hash = true
    @parts_all = db.execute("SELECT * FROM parts")
    slim(:edit)
end

post('/edit') do

    headgear = params[:select_headgear]
    head = params[:select_head]
    torso = params[:select_torso]
    legs = params[:select_legs]
    equipment = params[:select_equipment]

    #db = SQLite3::Database.new('db/legofigure.db')
    #db.execute("INSERT INTO partofig (headgear,pwdigest) VALUES (?,?)",username,password_digest)
end
