require 'sinatra'
require 'slim'
require 'sinatra/reloader'
require 'sqlite3'
require 'bcrypt'
require_relative './model.rb'

include Model


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
    time =[]

    if login(username, password).class == Integer
        session[:id] = login(username, password)
        redirect("/figure/#{session[:id]}")
    else
        login(username, password).class == String
        session[:error] = login(username, password)
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
        session[:error] = user_delete(password, id)
        redirect("/user/#{id}/edit") 
    end
end
