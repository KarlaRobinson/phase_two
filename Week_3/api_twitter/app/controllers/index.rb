get '/' do
  erb :index
end

post '/tweet' do
  CLIENT.update(params[:text])
  # redirect '/'
end

post '/fetch' do
  # finds user if they exist and if not a new user is created
  user = User.find_by_username(params[:username])
  if user == nil
    user = User.create(username: params[:username])
  end

  # checks if user has 0 tweets or if last db entry was more than an hour ago
  last_db_entry = Time.now.utc - user.tweets.order(:created_at).last.created_at
  if user.tweets.length == 0 || last_db_entry > 3600
    return "twitter" #go to twitter to update db
  else
    return "db" #don't update db
  end
end

get '/db/:username' do
  @user = User.find_by_username(params[:username])
  erb :tweets
end

get '/twitter/:username' do
  @user = User.find_by_username(params[:username])
  # add new tweets into the db
  CLIENT.user_timeline(@user.username).each do |tweet|
        t = Tweet.new(text: tweet.text, post_date: tweet.created_at)
        if t.save
          @user.tweets << t
        end
    end
  return "true"
end





