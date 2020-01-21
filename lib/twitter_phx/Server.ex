defmodule TwitterEngine.Server do
    use GenServer
    require Logger
    
 ################################---------------------------------API--------------------------------####################################

    def start_link(_) do
        GenServer.start_link(__MODULE__, :ok, name: :twitter_engine)
    end

   

    def register_new_user(user_id, is_new_user, user_pid) do
       # IO.inspect(user_pid, label: "This is user_pid for user_id: #{user_id}.")
        GenServer.call __MODULE__, {:register_new_user,user_id, is_new_user, user_pid}
    end
    
  ###############################------------------------------SERVER-----------------------------#####################################
   ## Register User 
  def handle_call({:register_new_user,user_id,is_new_user, user_pid},_from,current_state) do
     #IO.inspect(user_pid, label: "This is user_pid for user_id: #{user_id}.")
    register_user(user_id, is_new_user, user_pid)
    # {:reply,"abc",current_state}
    
  end
   ## Subscribe
  def handle_call({:add_user_to_following_list, user_id, subscriber},_from,current_state) do
    #Update following list of user_id
    [tuple] = :ets.lookup(:followers_list, user_id)
        list_followers = elem(tuple,1)
        updated_list = [subscriber|list_followers]
        # IO.inspect(updated_list, label: "Update Following")
        {user_id,updated_list} |> TwitterEngine.Storage.insert_followinglist
   
        #Add followers of user_id
    if :ets.lookup(:followers_list, user_id) == [], do: :ets.insert(:followers_list, {user_id, []})
        [tup] = :ets.lookup(:followers_list, user_id)
        list = elem(tup, 1)
        list= [subscriber | list]
        # IO.inspect(list, label: "This is list  for followers.")
        {user_id,list} |> TwitterEngine.Storage.insert_followers_list
        {:reply,{:added_followers,self()},self()}
  end

  def handle_call({:add_user_to_following_list_two, user_id, subscriber},_from,current_state) do
    #Update following list of user_id
        IO.puts "Inside server+++++++++++++++++++"
        [tuple] = :ets.lookup(:followers_list, user_id)
        list_followers = elem(tuple,1)
        updated_list = [subscriber|list_followers]
        # IO.inspect(updated_list, label: "Update Following")
        {user_id,updated_list} |> TwitterEngine.Storage.insert_followinglist
   
        #Add followers of user_id
    if :ets.lookup(:followers_list, user_id) == [], do: :ets.insert(:followers_list, {user_id, []})
        [tup] = :ets.lookup(:followers_list, user_id)
        list = elem(tup, 1)
        list= [subscriber | list]
        # IO.inspect(list, label: "This is list  for followers.")
        {user_id,list} |> TwitterEngine.Storage.insert_followers_list
        {:reply,{:added_followers,self()},self()}
  end
  
  ##Tweet #HASHTAG
  def handle_call({:tweet_hashtag, tweet , user_id, pid},_from,current_state) do
    #IO.inspect(user_pid, label: "This is user_pid for user_id: #{user_id}.")
    update_tweets(tweet, user_id)
  end 

  #tweet @Mention
  def handle_call({:tweet_mention, tweet , user_id, pid},_from,current_state) do
    #IO.inspect(user_pid, label: "This is user_pid for user_id: #{user_id}.")
    update_tweets(tweet, user_id)
  end 

  #Handles Tweet Requests from Client
  def handle_call({:tweet, tweet , user_id, pid},_from,current_state) do
   
    update_tweets(tweet, user_id)
  end 

  #Handling retweet request
  def handle_call({:retweet, user_id, pid }, _from, current_state) do
    list_tweets = get_tweets_following(user_id)
    {:reply,{:returning_alltweets_following,list_tweets, pid},self()}
    end

    #Query by Tweets subscribed to
    def handle_call({:queryby_following, user_id, pid}, _from, current_state) do
        list_tweets = get_tweets_following(user_id)
        [tuple] = :ets.lookup(:user_list,user_id)
        currently_online = elem(tuple,1)
        if (currently_online == true) do
            {:reply,{:reply_queryby_following,list_tweets, pid},self()}
        

    else 
        {:reply,{:reply_queryby_following,["User #{user_id} is offline"], pid},self()}
    end    
    end

    #Query by Hashtags
    def handle_call({:queryby_hashtag, tag, user_id, pid}, _from, current_state) do
       
        # IO.puts("In the server sode of query by hashtag")
        list_hashtags = queryby_hashtag(tag,user_id)
        [tuple] = :ets.lookup(:user_list,user_id)
        currently_online = elem(tuple,1)
        if (currently_online == true) do
            {:reply,{:reply_queryby_hashtag,list_hashtags, pid},self()}
        else 
        {:reply,{:reply_queryby_hashtag,["User #{user_id} is offline"], pid},self()}
    end    
        
        # {:reply,{:reply_queryby_hashtag,list_hashtags, pid},self()}
        # {:noreply, :ok}
    end

    def handle_call({:simulate_logout,user_id,pid}, _from, current_state) do
        if :ets.lookup(:user_list, user_id) != [], do: :ets.insert(:user_list,{user_id, false, pid})  

        [tup] = :ets.lookup(:followers_list, user_id)
        IO.inspect(tup, label: "In ETS tup Followers Lookup")

        {:reply,{:user_loggedout}, self()}
    end

    def queryby_hashtag(tag,user_id) do
        
        [tup] = if :ets.lookup(:hashtags, tag) != [] do
            :ets.lookup(:hashtags, tag)
        else
            [{"#",[]}]
        end
        list = elem(tup, 1)
        # IO.inspect(list, label: "LIST OF HASHTAGS")
    end

     #Query by mention
     def handle_call({:queryby_mention, user_id, pid}, _from, current_state) do
        # IO.puts("--------------------------------------------------------------------------")
        list_mention = queryby_mention(user_id)
        [tuple] = :ets.lookup(:user_list,user_id)
        currently_online = elem(tuple,1)
        if (currently_online == true) do
            {:reply,{:reply_queryby_mention,list_mention, pid},self()}
        else 
            {:reply,{:reply_queryby_mention,["User #{user_id} is offline"], pid},self()}
    end    
        
        # {:reply,{:reply_queryby_mention,list_mention, pid},self()}
        # {:noreply, :ok}
    end

    def queryby_mention(user_id) do
        user_string= Integer.to_string(user_id)
        string_check= "@" <> user_string
       
        [tup] = if :ets.lookup(:hashtags, string_check) != [] do
            :ets.lookup(:hashtags, string_check)
        else
            [{"@",[]}]
        end
        list = elem(tup, 1)
      
    end


  def handle_call(:return_engine_pid,_from,current_state) do
   
    {:reply,self(),current_state}
   
  end

   def init(:ok) do
        IO.puts("Server Started") 
        #receive do: (_ -> :ok)
        {:ok, self()} 
    end



    def register_user(user_id,is_new_user,pid) do
       
        {user_id,is_new_user,pid} |> TwitterEngine.Storage.insert_new_user
        {user_id,[]} |> TwitterEngine.Storage.insert_tweetlist
        {user_id,[]} |> TwitterEngine.Storage.insert_followinglist
        if :ets.lookup(:followers_list,user_id) == [], do: :ets.insert(:followers_list,{user_id,[]})


        [tup] = :ets.lookup(:following_list, user_id)
        IO.inspect(tup, label: "In ETS tup Followers Lookup")
        # list = elem(tup,0)
        # IO.inspect(list, label: "In ETS Lookup")
        IO.puts("IN HERE - AFFTER REGISTERING")
        {:reply,{:user_registered,self()},self()}
    end 
    
    def update_following(user_id, subscriber) do
        # IO.puts("In server update following func")
        [tuple] = :ets.lookup(:followers_list, user_id)
        list_followers = elem(tuple,1)
        updated_list = [subscriber|list_followers]
        # IO.inspect(updated_list, label: "Update Following")
        {user_id,updated_list} |> TwitterEngine.Storage.insert_followinglist
    end

    def add_followers(follower,user_id) do
        if :ets.lookup(:followers_list, user_id) == [], do: :ets.insert(:followers_list, {user_id, []})
        [tup] = :ets.lookup(:followers_list, user_id)
      
        list = elem(tup, 1)
        list= [follower | list]
        
        {user_id,list} |> TwitterEngine.Storage.insert_followers_list
    end

    def update_tweets(tweet, user_id) do
        
         [tuple] = TwitterEngine.Storage.lookup_tweet_list(user_id)
        
        #[tuple] = :ets.lookup(:tweet_list,user_id)
        # IO.inspect(tuple, label: "This is tuple for update tweets.")
        list_tweets = elem(tuple,1)
        # IO.inspect(list_tweets, label: "Before adding new")
        list_tweets = [tweet|list_tweets]
        #  IO.inspect(list_tweets, label: "After adding new")
        :ets.insert(:tweet_list,  {user_id,list_tweets})
        #  {user_id,list_tweets} |> TwitterEngine.Storage.insert_tweetlist

        # [tuple]
        
        hashlist = Regex.scan(~r/\B#[a-zA-Z0-9_]+/,tweet) |> Enum.concat
        
        Enum.each hashlist, fn hashtag ->
            insert_into_ets(hashtag,tweet)
        # tup 
        end
       
        mentions = Regex.scan(~r/\B@[a-zA-Z0-9_]+/, tweet) |> Enum.concat
        # IO.inspect(mentions, label: "Mentions")
        Enum.each mentions, fn mention -> 
	        insert_into_ets(mention,tweet)
            username = String.slice(mention,1, String.length(mention)-1)
            # if getpid(username) != nil, do: GenServer.call(String.to_atom("Account#{username}"),:liveview, tweet)
            # lookup(user_id)
        end

        {:reply,{:Tweeted_Successfully,self()},self()}
    end

    def insert_into_ets(tag, tweet) do
        # IO.puts("In insert func")
        [tuple] = if :ets.lookup(:hashtags, tag ) !=[] do
            :ets.lookup(:hashtags,tag)
      
        else
            [nil]
        end

        if tuple ==nil do
            :ets.insert(:hashtags,{tag,[tweet]})
            
        else
            list = elem(tuple,1)
            list = [tweet|list]
            :ets.insert(:hashtags,{tag,list})
        end
    end

    def getpid(user_id) do
        if :ets.lookup(:user_list, user_id) == [] do
            nil
        else
            [tuple] = :ets.lookup(:user_list, user_id)
            elem(tuple, 1)
            
        end
    end

    
   
        #Functions to handle retweets
    def get_tweets_following(user_id) do  #called in handle_call -> retweet
    list_following = get_subscribed_to(user_id)
    # IO.puts("TILL HERE")
    list_alltweets = get_alltweets_byuser(list_following,[])
        if list_alltweets != [] do
            list_alltweets
        end
    
    end 

    def get_subscribed_to(user_id) do
        [tup] = :ets.lookup(:following_list, user_id)
        # IO.inspect([tup], label: "This is [tup] for get_subscribed_to tweets.")
        elem(tup, 1)
    end
    
   

    def get_alltweets_byuser( [head|tail], list_tweets) do
        # IO.puts("FBVRNTVFWEVBGNGBFVSDFDBGFNH")
        list_tweets = get_tweetlist(head) ++ list_tweets
        # IO.inspect(list_tweets, label: "RBTGF")
        get_alltweets_byuser(tail,list_tweets)
    end

    def get_alltweets_byuser( [], list_tweets), do: list_tweets

    def get_tweetlist(user_id) do
        # IO.puts("get tweetlisst")
         tuple = :ets.lookup(:tweet_list,String.to_integer(user_id))
        if :ets.lookup(:tweet_list, String.to_integer(user_id)) == [] do
            # IO.puts("igdsfv")
            []
        else
            [tup] = :ets.lookup(:tweet_list,String.to_integer(user_id))
            elem(tup, 1)
        end
        
    end

    

end
