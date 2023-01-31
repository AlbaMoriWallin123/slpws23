require 'sinatra'
require 'slim'
require 'sinatra/reloader'
require 'sqlite3'
require 'bcrypt'


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
    p @parts 
    slim(:index)
end



=begin
post('/new_user') do
    username = params[:username]
    password = params[:password]
    password2 = params[:password2]
    

    if (password == password2)
        #if anvämdar namn inte är unikt
        password_digest = BCrypt::Password.create(password)
        db = SQLite3::Database.new('db/legofigure.db')
        db.execute("INSERT INTO user (username,pwdigest) VALUES (?,?)",username,password_digest)
        redirect('/register')
    else
        "Lösenorden matchar inte"
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
        "fel"
    end
end

get('/figure') do #ser id:t
    id = session[:id].to_i
    db = SQLite3::Database.new('db/legofigure.db')
    db.results_as_hash = true
    result = db.execute("SELECT * FROM partofig WHERE user_id = ?", id)
    p "herghgrjhgrhioefjiiho#{result}"
    slim(:"show", locals:{figure:result})
end
=end