defmodule TwitterPhxWeb.TwitterEngineChannel do
  use TwitterPhxWeb, :channel

  def join("twitter_engine:lobby", _payload, socket) do
    
      {:ok, socket}
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
 

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (twitter_engine:lobby).
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end
  
  
  
  
  def handle_in("register", payload, socket) do
   
    user_string = payload["name"]
    IO.inspect(user_string)
    user_id = :binary.decode_unsigned(user_string)
    IO.inspect(user_id, label: "ETGRCAVE")
    if :ets.lookup(:name_list, user_id) == [], do: :ets.insert(:name_list, {user_id, user_string})
    # GenServer.start_link(TwitterEngine.Node, [user_id, 5,5, true], name: String.to_atom(user_string))
    case GenServer.call(:twitter_engine,{:register_new_user,user_string, true ,self()}) do
        
      {:user_registered,server_pid} ->
        IO.puts(" ")
        IO.puts(" ")
        if :ets.lookup(:name_list, user_id) == [] do
          IO.puts(" User #{user_id} has been successfully registered")
        else
          [tuple] = :ets.lookup(:name_list, user_id)
          user_string = elem(tuple, 1)
          # IO.inspect(user_string, label: "This is the user that has been registered")
          # IO.puts(" User #{user_string} has been successfully registered")
        end
        
        # IO.puts("Time taken to register:  #{System.system_time(:microsecond) - start_time} micro-seconds")
  
    end
    
    {:noreply, socket}
  end

  def handle_in("subscribe", payload, socket) do
    IO.puts "Inside subscribe function+++++++++++++++++++++++++"
    user_string = payload["name"]
    user_tosubscribe = payload["follow"]
    
      case GenServer.call(:twitter_engine,{:add_user_to_following_list_two,user_string,user_tosubscribe}) do
      {:added_followers,server_pid} -> :ok
      # IO.puts(" User #{user_id}'s following list has been updated")
      end
      [tuple] = :ets.lookup(:followers_list, user_string)
      temp = elem(tuple, 1)
      IO.inspect(temp, label: "This is the user that has been following-------------------------")
      # IO.puts(" User #{user_string} has been successfully registered")
      #Display live view of Subs

      ##########################
      [tuple] = TwitterEngine.Storage.lookup_tweet_list(user_tosubscribe)
      temp = elem(tuple, 1)
      IO.inspect(temp, label: "**************** Tweet List of #{user_tosubscribe}**********************")
      {:reply, {:ok, %{tweets: temp}}, socket}
      ###############################
      #{:noreply, socket}
  end

  def handle_in("tweet", payload, socket) do
   
    user_string = payload["name"]
    tweet_value = payload["tweet"]
   
    case GenServer.call(:twitter_engine,{:tweet, tweet_value , user_string,self()}) do
        {:Tweeted_Successfully,server_pid} ->
        IO.puts(" User #{user_string} has tweeted successfully.")
    end
    [tuple] = TwitterEngine.Storage.lookup_tweet_list(user_string)
    temp = elem(tuple, 1)
    IO.inspect(temp, label: "****************Tweet List***********************")
    # {:noreply, socket}
    {:reply, {:ok, %{tweets: temp}}, socket}
  end

  def handle_in("query_hashtag", payload, socket) do
   
    user_string = payload["name"]
    hash_value = payload["hash"]
   
    case GenServer.call(:twitter_engine, {:queryby_hashtag, hash_value, user_string, self()}) do
        
      {:reply_queryby_hashtag,list_hashtags, pid} ->
        
        if list_hashtags !=[], do: IO.inspect(list_hashtags, label: "---------------------------------------All Tweets by Hashtags( #GoGators!)---------------------------------------- \n")
        IO.puts(" ")
        {:reply, {:ok, %{hashtags: list_hashtags}}, socket}
    end

    # {:noreply, socket}
    # {:reply, {:ok, %{hashtags: list_hashtags}}, socket}
  end

  def handle_in("query_mentions", payload, socket) do
   
    user_string = payload["name"]
    mention_value = payload["mention"]
   
    case GenServer.call(:twitter_engine, {:queryby_hashtag, mention_value, user_string, self()}) do
        
      {:reply_queryby_hashtag,list_hashtags, pid} -> if list_hashtags !=[], do: IO.inspect(list_hashtags, label: "---------------------------------------All Tweets by Hashtags( #GoGators!)---------------------------------------- \n")
      IO.puts(" ")
      # {:reply, {:ok, %{hashtags: list_hashtags}}, socket}
        
        {:reply, {:ok, %{mentions: list_hashtags}}, socket}
    end

    # {:noreply, socket}
    # {:reply, {:ok, %{hashtags: list_hashtags}}, socket}
  end
  
  
end
