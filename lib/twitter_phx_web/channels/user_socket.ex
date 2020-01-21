defmodule TwitterPhxWeb.UserSocket do
  use Phoenix.Socket
  # import {Socket} from "pheonix"
  ## Channels
  # channel "room:*", TwitterWeb.RoomChannel
  channel "twitter_engine:*", TwitterPhxWeb.TwitterEngineChannel

  # transport :websocket, Pheonix.Transports.Websocket
  # let socket = new Socket("/socket", {params: {token: window.userToken}})
  # socket.connect()
  # channel = socket.channel("twitter_engine:lobby", {})

  # channel.join()
  # .receive("ok", resp => { console.log("Joined successfully", resp) })
  # .receive("error", resp => { console.log("Unable to join", resp) })



  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  
  # To deny connection, return `:error`.
  
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.
  def connect(_params, socket, _connect_info) do
    {:ok, socket}
  end



  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "user_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     TwitterWeb.Endpoint.broadcast("user_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  def id(_socket), do: nil
end
