#  defmodule TwitterEngine do
#   use GenServer
# #  def run(argv) do
# #       argv
# #       |> extract_numnodes_requests
# #       |> start_main
# #     end
    
# #     def extract_numnodes_requests(args) do
# #       num_request = OptionParser.parse(args,aliases: [g: :guide] ,switches: [guide: :boolean])
# #       case num_request do
# #         {[guide: true],_,_} -> :guide
# #         {_, [num_nodes,req],_} -> {num_nodes,req}
# #         _ -> :guide
# #       end
# #     end
    
# #     def start_main(:guide) do
# #       IO.puts("""
# #                Syntax Error. Please run the program using 
# #                mix run project3.exs <Number of nodes> <Number of requpests>
# #                """)
# #     System.halt(0)
# #     end

   
#     def start_main() do #{num_users,num_msgs}
#       # GenServer.start_link(_MODULE_)
#       num_users = 100 #String.to_integer(num_users)
#       num_msg = 10 # String.to_integer(num_msgs)
#       # num_to_subscribe = round(Float.floor(num_msg/(num_users-i+1)))
#       nodes = initialize_nodes(num_users,num_msg)

#       # Task.start fn-> TwitterEngine.Server.start_link() end
#       end

     

#     # def performance_metrics(user_id,)
# end


# #####
