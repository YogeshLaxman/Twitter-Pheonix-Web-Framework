
defmodule TwitterEngine.NodeSupervisor do
  use DynamicSupervisor

  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, :no_args, name: __MODULE__)
    initialize_nodes(10, 10)
  end

  def init(:no_args) do
    DynamicSupervisor.init(strategy: :one_for_one)
    
  end
  
  defp initialize_nodes(num_users, num_msg) do  #Enum.shuffle()
  Enum.map(1..num_users, fn i ->
      num_to_subscribe = get_nts(num_msg,num_users,i)
      start_worker(i, num_msg, num_to_subscribe, true)
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

  def start_worker(i, num_msg, num_to_subscribe, is_new_user) do
    spec = {TwitterEngine.Node, [i, num_msg,num_to_subscribe, is_new_user]}
    {:ok, pid} =   DynamicSupervisor.start_child(__MODULE__, spec)
    # pid
  end
end 
