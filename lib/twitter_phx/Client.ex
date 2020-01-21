defmodule TwitterEngine.Node do
  use GenServer, restart: :transient

 ####################### API ##############################

 def start_link(args) do
  #[user_id, num_tweets,num_to_subscribe, is_new_user] = args
  #  GenServer.start_link(__MODULE__, args,name: "Account#{user_id}")
  [user_id, num_tweets,num_to_subscribe, is_new_user] = args
  IO.inspect([user_id, num_tweets])
  GenServer.start_link(__MODULE__, args, name: String.to_atom("Account#{user_id}"))
  end

  
  ####################### SERVER ##############################

 
  
  def init([user_id, num_tweets,num_to_subscribe, is_new_user]) do
    # {:ok, iflist} = :inet.getif()

    :global.sync()
 

    ########### Register (Sign-up) User #############
     
      #Register
      start_time = System.system_time(:microsecond)
      IO.inspect(start_time)
      case GenServer.call(:twitter_engine,{:register_new_user,user_id, is_new_user ,self()}) do
        
        {:user_registered,server_pid} ->
          IO.puts(" ")
          IO.puts(" ")
          if :ets.lookup(:name_list, user_id) == [] do
            IO.puts(" User #{user_id} has been successfully registered")
          else
            [tuple] = :ets.lookup(:name_list, user_id)
            user_string = elem(tuple, 1)
            # IO.inspect(user_string, label: "This is the user that has been registered")
            IO.puts(" User #{user_string} has been successfully registered")
          end
          
          IO.puts("Time taken to register:  #{System.system_time(:microsecond) - start_time} micro-seconds")
    
      end
     
      simulate_user_functions(user_id, num_tweets, num_to_subscribe)
      
      #Tweet with Hashtag
      s = System.system_time(:microsecond)
      case GenServer.call(:twitter_engine, {:tweet_hashtag, "#{random_func(4)} #GoGators!" , user_id,self()}) do
        {:Tweeted_Successfully,server_pid} ->
          if :ets.lookup(:name_list, user_id) == [] do
            IO.puts(" User #{user_id} has tweeted with hashtag")
          else
            [tuple] = :ets.lookup(:name_list, user_id)
            user_string = elem(tuple, 1)
            # IO.inspect(user_string, label: "This is the user that has been registered")
            IO.puts(" User #{user_string} has tweeted with hashtag")
          end
          
          
      end
      # IO.puts(" Time taken to tweet with #GoGators:  #{System.system_time(:microsecond) - s} microsecond")

      #Tweet with Mention
      s1 = System.system_time(:microsecond)
      case GenServer.call(:twitter_engine, {:tweet_mention, "This tweet is mentioning @#{(user_id)}" , user_id,self()}) do
        {:Tweeted_Successfully,server_pid} ->
          # IO.puts(" User #{user_id} has tweeted with mention.")
      end
      # IO.puts("Time taken to tweet with a mention:  #{System.system_time(:microsecond) - s1} microsecond")
      
      #Tweet 
      s2 = System.system_time(:microsecond)
      for _ <- 1..num_tweets do
        case GenServer.call(:twitter_engine, {:tweet, " This is a sample tweet by #{user_id}!!! with random text #{random_func(7)}" , user_id,self()}) do
          {:Tweeted_Successfully,server_pid} ->
            # IO.puts(" User #{user_id} has tweeted successfully.")
        end
      end
        #  time_tweet = System.system_time(:microsecond) - s2
          # IO.puts("Time taken to tweet:  #{System.system_time(:microsecond) - s2} microsecond")

      #Retweet 
      s3 = System.system_time(:microsecond)
      case GenServer.call(:twitter_engine, {:retweet, user_id, self() }) do
        {:returning_alltweets_following,list_tweets, pid} ->
                if list_tweets != [] do
                  # msg_retweet = hd(list_tweets)
                  msg_retweet = Enum.random(list_tweets)
                  
                  case GenServer.call(:twitter_engine, {:tweet, msg_retweet <> " *Re-tweet* " , user_id,self()}) do
                    {:Tweeted_Successfully,server_pid} ->
                      IO.puts(" User #{user_id} has re-tweeted successfully.")
                  end
                  
                end 
         #change this to returned list of tweets which is tweeted by following people.
      end 
      # IO.puts("Time required to successfully re-tweet a tweet:  #{System.system_time(:microsecond) - s3} microsenconds")

      #Simulate Log Out
      if( rem(user_id, 10) == 0) do
        case GenServer.call(:twitter_engine,{:simulate_logout,user_id,self()}) do
          
          {:user_loggedout} ->
            # IO.puts("User #{user_id} has been logged out")

        end
      end


      #Query to get all tweets subscribed to 
      t1 = System.system_time(:microsecond)
      case GenServer.call(:twitter_engine, {:queryby_following, user_id, self() }) do
        {:reply_queryby_following,list_tweets_subscribed_to, pid} -> 
                IO.puts(" ")
                if list_tweets_subscribed_to !=[], do: IO.inspect list_tweets_subscribed_to, label: " ---------------------------------User #{user_id} :-> Wall of all Tweets (Live View) ----------------------------------- \n"
      end 
      # IO.puts("Time required to query all tweets subscribed to: #{System.system_time(:microsecond) - t1} microsecond")

      #Query to search by Hashtag
      t2 = System.system_time(:microsecond)
      case GenServer.call(:twitter_engine, {:queryby_hashtag, "#GoGators", user_id, self()}) do
        
        {:reply_queryby_hashtag,list_hashtags, pid} ->
          
          if list_hashtags !=[], do: IO.inspect(list_hashtags, label: "---------------------------------------All Tweets by Hashtags( #GoGators!)---------------------------------------- \n")
          IO.puts(" ")
      end
      # IO.puts("Time required to query with hashtags(#GoGators):  #{System.system_time(:microsecond) - t2} microsecond")
 
      #Query to search by Mention

      t3= System.system_time(:microsecond)
      case GenServer.call(:twitter_engine, {:queryby_mention, user_id, self()}) do
        
        {:reply_queryby_mention,list_mention, pid} ->
          
          if list_mention !=[], do: IO.inspect(list_mention, label: "-------------------------------------------All Tweets by Mention of User ID:  @#{user_id}--------------------------------------------- \n")
          IO.puts(" ")
      end
      # IO.puts("Time required to query with mentions:  #{System.system_time(:microsecond) - t3} microsecond")
      server_pid = GenServer.call(:twitter_engine,:return_engine_pid)
      # IO.inspect server_pid
      

      ### Add condn for login for returning user
      # client_functions(user_id, num_tweets, num_to_subscribe)
      
      {:ok, {user_id,num_tweets,num_to_subscribe, is_new_user,server_pid}}

      # receive do: (_ -> :ok)
  end

#############---------simulate_user_functions----------###########3

    def simulate_user_functions(user_id, num_tweets, num_to_subscribe) do
      #Follow/Subscribe to users     
      subscribe_to_uf(user_id,num_to_subscribe)
      # handle_retweet(userId)
    end



   
    #When a user is mentioned, a live view pops up (LATER PART)
    # def handle_call({:liveview, user_id, tweet},_from,current_state) do
    #   # IO.inspect(tweet, label: "User #{user_id}:--------------------------- Wall of Tweets, Re-Tweets and more!!----------------------------- ")
    #   {:reply, :ok, current_state}

    # end 

     def subscribe_to_uf(user_id,num_to_subscribe) do
      if(num_to_subscribe>0) do
        following_list = Enum.to_list(1..num_to_subscribe)
        #IO.inspect(following_list, label: "following_list for user_id #{user_id}")
        Enum.each(following_list,fn following_list_item ->
           case GenServer.call(:twitter_engine,{:add_user_to_following_list,user_id,Integer.to_string(following_list_item)}) do
            {:added_followers,server_pid} -> :ok
            # IO.puts(" User #{user_id}'s following list has been updated")
            end
        end)
      end
    end
    # IO.puts(" User #{user_id}'s following list has been updated")
    
    def random_func(length) do
      random_text = :crypto.strong_rand_bytes(length) |> Base.encode16 |> binary_part(0, length) 
      random_text
    end
  

    
end 