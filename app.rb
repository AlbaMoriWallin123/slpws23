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
    db = connect_to_db()
    @parts = ("SELECT username, part1, part2, part3, part4, part5 
    FROM partofig INNER JOIN user 
    ON partofig.user_id = user.user_id")
    slim(:index)
end


post('/new_user') do
    username = params[:username]
    password = params[:password]
    password2 = params[:password2]
    
    session[:error] = register_user(username, password, password2)

    redirect('/register')
end

post('/login') do
    username = params[:username]
    password = params[:password]

    db = connect_to_db()
    result = db.execute("SELECT * FROM user WHERE username = ?", username).first
    pwdigest = result["pwdigest"]
    id = result["id"]

    if BCrypt::Password.new(pwdigest) == password
        session[:id] = id
        redirect('/figure')

    else
        session[:error] = "Fel lösenord eller användarnamn"
        redirect('/')
    end
end

get('/figure') do #ser id:t
    id = 18#session[:id].to_i
    db = connect_to_db()
    @my_parts = db.execute("SELECT * FROM partofig WHERE user_id = ?", id) 
    @my_name = db.execute("SELECT username FROM user WHERE user_id = ?", id)
    slim(:show)
end

get('/edit_figure') do
    db = connect_to_db()
    headgear = db.execute("SELECT part_id FROM parts WHERE type='headgear'")
    head = db.execute("SELECT part_id FROM parts WHERE type='head'")
    torso = db.execute("SELECT part_id FROM parts WHERE type='torso'")
    legs = db.execute("SELECT part_id FROM parts WHERE type='legs'")
    equipment = db.execute("SELECT part_id FROM parts WHERE type='equipment'")

    @parts = []
    @parts << headgear
    @parts << head
    @parts << torso
    @parts << legs
    @parts << equipment
    #p @parts #fixa bättre
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

get('/logout') do
    session[:id] = nil
    flash[:notice] = "Nu är du utloggade"
    redirect('/')
end
 
post('/delet_account') do
    db.execute("DELETE  FROM partofig INNER JOIN user 
    ON partofig.user_id = user.user_id") inner join
end
