defmodule TwitterPhx.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    GenServer.start_link(TwitterEngine.Server, :ok, name: :twitter_engine)
    GenServer.start_link(TwitterEngine.Storage, :ok, name: :storage)
    initialize_nodes(100,10)
    # List all child processes to be supervised
    children = [
      # Start the endpoint when the application starts
      TwitterPhxWeb.Endpoint,
      # TwitterEngine.NodeSupervisor,
      # Starts a worker by calling: TwitterPhx.Worker.start_link(arg)
      # {TwitterPhx.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TwitterPhx.Supervisor]
    Supervisor.start_link(children, opts)
   

  end

 

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    TwitterPhxWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp initialize_nodes(num_users, num_msg) do  #Enum.shuffle()
  Enum.map(1..num_users, fn i ->
      num_to_subscribe = get_nts(num_msg,num_users,i)
      IO.inspect(i)
      GenServer.start_link(TwitterEngine.Node, [i, num_msg,num_to_subscribe, true], name: String.to_atom("Account#{i}"))
   end)
  end

defp get_nts(num_msg,num_users,i) do  # i is user_id or ith user
  num_to_subscribe = round(Float.floor(num_users/(num_users-i+1))-1)  #for zipf CORRECT THIS FORMULA
  if(num_to_subscribe == 0) do
    num_to_subscribe + 1
  else
    num_to_subscribe
  end
end



end
