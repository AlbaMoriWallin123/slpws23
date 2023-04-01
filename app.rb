require 'sinatra'
require 'slim'
require 'sinatra/reloader'
require 'sqlite3'
require 'bcrypt'
require_relative './model.rb'


enable :sessions

#before do
    #if session[:id] == nil && (request.path_info != '/')
     #   session[:error] = "Du måste vara inloggad för att se detta"
    #end
get('/user/new') do
    slim(:'/user/new')
end

get('/') do
    session[:id] = nil
    slim(:login)
end

get('/user/') do
    @parts = see_friends()
    slim(:index)
end


post('/user') do
    username = params[:username]
    password = params[:password]
    password2 = params[:password2]
    db = connect_to_db()
    username_db = db.execute("SELECT username FROM user")

    session[:error] = register_user(username, password, password2, username_db)
    redirect('/user')
end

post('/login') do
    username = params[:username]
    password = params[:password]

    db = connect_to_db()
    result = db.execute("SELECT * FROM user WHERE username = ?", username).first
    pwdigest = result["pwdigest"]
    id = result["id"]

    if BCrypt::Password.new(pwdigest) == password #hur redirect till oilika med model
        session[:id] = id
        redirect('/figure/:id')
    else
        session[:error] = "Fel lösenord eller användarnamn"
        redirect('/')
    end
end

get('/figure/:id') do 
    id = session[:id]
    @my_parts = join_parts_username(id)
    slim(:'/figure/show')
end

get('/figure/:id/edit') do
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
    slim(:'/figure/edit')
end

post('/figure/:id/update') do

    headgear = params[:select_headgear]
    head = params[:select_head]
    torso = params[:select_torso]
    legs = params[:select_legs]
    equipment = params[:select_equipment]

    db = SQLite3::Database.new('db/legofigure.db')
    db.execute("INSERT INTO partofig (headgear,pwdigest) VALUES (?,?)",username,password_digest)
end

get('/user/:id/edit') do
    slim(:'/user/edit')
end

post('/user/:id/delete') do
    password = params[:password]
    
    if BCrypt::Password.new(pwdigest) == password
        id = session[:id]
        session[:id] = nil
        db.execute("DELETE * FROM partofig INNER JOIN user 
        ON partofig.user_id = user.user_id WHERE user.user_id = ?", id) 
    end
    redirect('/')
end
