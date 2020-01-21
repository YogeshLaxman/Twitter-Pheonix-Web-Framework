defmodule TwitterEngine.Storage do
    use GenServer, restart: :transient 

    @server_name :storage
    @user_list :user_list # ets table name    
    @tweet_list :tweet_list
    @hashtags :hashtags
    @following_list :following_list
    @followers_list :followers_list
    @name_list :name_list
    #####################Interface functions############################

    def start_link(_) do
        GenServer.start_link __MODULE__, nil, name: @server_name
    end

    
    def insert_new_user(data) do
        # IO.puts "USER_LIST"
        # data |> IO.inspect
        GenServer.call @server_name, {:insert_new_user,data}
    end

 
    
    def insert_tweetlist(data) do
        # IO.puts "TWEETLIST"
        # data |> IO.inspect
        GenServer.call @server_name, {:insert_tweetlist,data}
    end

    def insert_followinglist(data) do
        # IO.puts "FOLLOWING LIST"
        # data |> IO.inspect
        GenServer.call @server_name, {:insert_followinglist,data}
    end

    def insert_followers_list(data) do
        # IO.puts "FOLLOWERS LIST"
        # data |> IO.inspect
        GenServer.call @server_name, {:insert_followers_list,data}
    end

   

    def insert_hashtags(data) do
        IO.puts "HASHTAGS store**************************************************************"
         IO.inspect(data, label: "data in insert hastag storage")

        GenServer.call @server_name, {:insert_hashtags,data}
    end

    def store(data) do
        IO.puts "storing data..."
        # data |> IO.inspect
        GenServer.call @server_name, {:store,data}
    end

    def fetch_all do
        GenServer.call @server_name, :fetch_all #after all registered TwitterEngine.Sorage.fetch_all
    end

      ####################Callback functions#############################
    def init(_) do
        #create a new ets table
        #:ets.new @ets_name, [:ordered_set, :private, :named_table, {:keypos,1}] #cannot have duplicate key values
        # IO.puts("Creating ETS Tables")
        :ets.new @user_list, [:set, :public, :named_table, {:keypos,1}]
        :ets.new @tweet_list, [:set, :public, :named_table, {:keypos,1}]
        :ets.new @hashtags, [:ordered_set, :public, :named_table]
        :ets.new @following_list, [:set, :public, :named_table, {:keypos,1}]
        :ets.new @followers_list, [:set, :public, :named_table, {:keypos,1}]
        :ets.new @name_list, [:set, :public, :named_table, {:keypos,1}]
        {:ok,nil}

    end

    def handle_call({:insert_new_user,data},_,_current_state) do
        :ets.insert @user_list, data # data={user_id,user_pid} data|> TwitterEngine.Storage.store
        {:reply,data,data} #send reply data and set data as current state
    end

    def handle_call({:insert_tweetlist,data},_,_current_state) do
        :ets.insert @tweet_list, data # data={user_id,user_pid} data|> TwitterEngine.Storage.store
        {:reply,data,data} #send reply data and set data as current state
    end

    def handle_call({:insert_followinglist,data},_,_current_state) do
        :ets.insert @following_list, data # data={user_id,user_pid} data|> TwitterEngine.Storage.store
        {:reply,data,data} #send reply data and set data as current state
    end

    def handle_call({:insert_followers_list,data},_,_current_state) do
        # IO.puts("sffef")
        :ets.insert @followers_list, data # data={user_id,user_pid} data|> TwitterEngine.Storage.store
        {:reply,data,data} #send reply data and set data as current state
    end

    def handle_call({:insert_hashtags,data},_,_current_state) do
        :ets.insert @hashtags, data # data={user_id,user_pid} data|> TwitterEngine.Storage.store
        {:reply,data,data} #send reply data and set data as current state
    end

   

    #fetch single last entry
    def handle_call(:fetch,_,current_state) do
        
        {:reply,current_state,current_state} #send reply data and set data as current state
    end

  

    ############################## Lookup Functions ###################
    def lookup_user_list(user_id) do #Lookup fn of user list
    GenServer.call @server_name, {:lookup_user_list,user_id}
    end
    
    def lookup_tweet_list(user_id) do #Lookup fn of tweet list
    GenServer.call @server_name, {:lookup_tweet_list,user_id}
    end
    
     
    def lookup_following_list(user_id) do #Lookup fn of followers list
    GenServer.call @server_name, {:lookup_following_list,user_id}
    end
    
    def lookup_followers_list(user_id) do #Lookup fn of followers list
    GenServer.call @server_name, {:lookup_followers_list,user_id}
    end

    def lookup_hashtags(user_id) do #Lookup fn of followers list
    GenServer.call @server_name, {:lookup_hashtags,user_id}
    end


    def handle_call({:lookup_user_list,user_id},_,_state) do #Handle for USER LIST
        tuple = :ets.lookup(:user_list,user_id)
        {:reply,tuple, tuple}
    end

    
    def handle_call({:lookup_tweet_list,user_id},_,_state) do #Handle for TWEET LIST
        
        tuple = :ets.lookup(:tweet_list,user_id)
        # # list =elem(tuple,1)
        # IO.inspect(tuple, label: "///////////////////////////////////////////////")
        {:reply,tuple, tuple}
    end
    
    def handle_call({:lookup_hashtags,user_id},_,_state) do #Handle for HASHTAGS LIST
    tuple = :ets.lookup(:hashtags,user_id)
    {:reply,tuple, tuple}
    end

    def handle_call({:lookup_following_list,user_id},_,_state) do  #Handle for FOLLOWING LIST
        # IO.puts("jyvnjgnrt")
        tuple = :ets.lookup(:following_list,user_id)
        {:reply,tuple, tuple}
    end

    def handle_call({:lookup_followers_list,user_id},_,_state) do  #Handle for FOLLOWERS LIST
        # IO.puts("Hoorah")
        tuple = :ets.lookup(:followers_list,user_id)
        {:reply,tuple, tuple}
    end
end