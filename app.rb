require 'sinatra'
require 'slim'
require 'sinatra/reloader'
require 'sqlite3'
require 'bcrypt'
require_relative './model.rb'


enable :sessions

before do
    if session[:id] == nil && request.path_info != '/' && request.path_info != '/error' && request.path_info != '/login' && request.path_info != '/user/new' && request.path_info != '/user'
        redirect('/error')
    end
end

get('/error') do
    slim(:error)
end


get('/') do
    session[:id] = nil
    slim(:login)
end

get('/user/new') do
    slim(:'/user/new')
end

get('/user/') do
    id = session[:id]
    @parts = see_friends(id)
    slim(:'/figure/index')
end


post('/user') do
    username = params[:username]
    password = params[:password]
    password2 = params[:password2]
    db = connect_to_db()
    username_db = db.execute("SELECT username FROM user")

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
        redirect("/figure/#{id}")
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
    @parts = part_loop(id)
    @my_parts = join_parts_username(id)
    slim(:'/figure/edit')
end

post('/figure/:id/update') do

    headgear = params[:select_headgear]
    head = params[:select_head]
    torso = params[:select_torso]
    legs = params[:select_legs]
    equipment = params[:select_equipment]
    id = session[:id]

    session[:error] = update_parts(headgear, head, torso, legs, equipment, id)
    redirect("/figure/#{id}/edit")
end

get('/user/:id/edit') do

    id = session[:id]

    db = connect_to_db()
    @check = admin_check(id, db)
    @username_id = admin_loop(db)

    slim(:'/user/edit')
end

post('/user/:id/update') do
    id = session[:id]
    admin_updates()
    redirect("/user/#{id}/edit")
end

post('/user/:id/delete') do

    password = params[:password]
    id = session[:id]

    if user_delete(password, id) == true
        redirect('/')
    else
        redirect("/user/#{id}/edit")
    end
end
