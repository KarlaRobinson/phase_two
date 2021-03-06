get '/' do
  erb :index
end

post '/tweet' do
  ### twitter request!!! ####
  if params[:time] == ""
    job_id = current_user.tweet_later(params[:text])
  else
    job_id = current_user.tweet_later(params[:text], params[:time])
  end
  job_id
end

post '/status/:job_id' do
  # regresa el status de un job a una petición AJAX
  job_is_complete(params[:job_id]).to_s
end

get '/refresh' do
  #### twitter request!!! ####
  current_user.twitter_user.user_timeline(current_user.name).each do |tweet|
    t = Tweet.new(text: tweet.text, post_date: tweet.created_at)
    if t.save
      current_user.tweets << t
    end
  end
  @user = current_user
  erb :profile
end


get '/fetch/:username' do
  @user = TwitterUser.find_by_name(params[:username])
  if @user == nil
    @user = TwitterUser.new(name: params[:username])
    if !@user.save
      @user = TwitterUser.find_by_name("@karlasophiarob")
    end
end

  # checks if user has 0 tweets or if last db entry was more than an hour ago
  if @user.tweets.length > 1
    last_db_entry = Time.now.utc - @user.tweets.order(:created_at).last.created_at
  end

  if @user.tweets.length == 0 || last_db_entry > 3600
    #### twitter request!!! ####
    current_user.twitter_user.user_timeline(@user.name).each do |tweet|
      t = Tweet.new(text: tweet.text, post_date: tweet.created_at)
      if t.save
        @user.tweets << t
      end
    end
  end
  erb :profile
end

# get '/profile' do
#   erb :profile
# end

get '/sign_in' do
  # El método `request_token` es uno de los helpers
  # Esto lleva al usuario a una página de twitter donde sera atentificado con sus credenciales
  redirect request_token.authorize_url(:oauth_callback => "http://#{host_and_port}/auth")
  # Cuando el usuario otorga sus credenciales es redirigido a la callback_url 
  # Dentro de params twitter regresa un 'request_token' llamado 'oauth_verifier'
end

get '/auth' do
  p "/auth"
  # Volvemos a mandar a twitter el 'request_token' a cambio de un 'acces_token' 
  # Este 'acces_token' lo utilizaremos para futuras comunicaciones. 
  @access_token = request_token.get_access_token(:oauth_verifier => params[:oauth_verifier])
  # Despues de utilizar el 'request token' ya podemos borrarlo, porque no vuelve a servir. 
  session.delete(:request_token)

  # Aquí es donde deberás crear la cuenta del usuario y guardar usando el 'access_token' lo siguiente:
  p name = @access_token.params[:screen_name]
  p token = @access_token.token
  p secret = @access_token.secret
  p user = TwitterUser.find_by_name("@#{name}")
  if user == nil
    user = TwitterUser.new(name: "@#{name}", access_token: token, access_token_secret: secret)
    if user.save
      session[:user_id] = user.id
      erb :profile
    else
      p "fail: User info not valid"
    end
  elsif user.access_token == nil
    user.access_token = token
    user.access_token_secret = secret
    user.save
    session[:user_id] = user.id
    erb :profile
  else
    session[:user_id] = user.id
    erb :profile
  end
end

get '/logout' do
  session.clear
  erb :index
end








