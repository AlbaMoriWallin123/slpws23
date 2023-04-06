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

get('/') do
    slim(:login)
end

get('/user/new') do
    slim(:'/user/new')
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
    p username_db 

    session[:error] = register_user(username, password, password2, username_db)
    redirect('/user/new')
end

post('/login') do
    username = params[:username]
    password = params[:password]

    db = connect_to_db()
    result = db.execute("SELECT * FROM user WHERE username = ?", username).first

    if result == nil
        session[:error] = "Fel lösenord eller användarnamn"
        redirect('/')
    end

    pwdigest = result['pwdigest']
    id = result['user_id']

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

    id = session[:id]
    @type = ["headgear", "head", "torso", "legs", "equipment"]
    i = 0
    @parts = []

    db = connect_to_db()
    while i <= 4
        @parts << db.execute("SELECT part_id FROM parts WHERE type = ?", @type[i])
        i += 1
    end

    @my_parts = join_parts_username(id)
    slim(:'/figure/edit')
end

post('/figure/:id/update') do

    headgear = params[:select_headgear]
    head = params[:select_head]
    torso = params[:select_torso]
    legs = params[:select_legs]
    equipment = params[:select_equipment]

    db = SQLite3::Database.new('db/legofigure.db')
    db.execute("INSERT INTO partofig (part1, part2, part3, part4, part5) VALUES (?, ?, ?, ?, ?)",headgear,head,torso,legs,equipment)
    redirect('/figure/:id/edit')
end

get('/user/:id/edit') do
    slim(:'/user/edit')
end

#get('/logout') do
    #session[:id] = nil
    #flash[:notice] = "Nu är du utloggad"
    #redirect('/')
#end

post('/user/:id/delete') do

    id = session[:id]
    db = SQLite3::Database.new('db/legofigure.db')
    pwdigest = db.execute("SELECT pwdigest FROM user WHERE user_id = ?", id)
    password = params[:password]

    p password
    p pwdigest[0][0]

    if BCrypt::Password.new(pwdigest[0][0]) == password
        db.execute("DELETE FROM partofig WHERE user_id = ?", id)
        db.execute("DELETE FROM user WEHERE user_id = ?", id)
        #db.execute("DELETE FROM user INNER JOIN partofig 
        #ON partofig.user_id = user.user_id WHERE user.user_id = ?", id) inner jin funkar inte av någon annledning
        redirect('/')
    else
        session[:error] = "Fel lösenord"
        redirect('/user/:id/edit')
    end
end
