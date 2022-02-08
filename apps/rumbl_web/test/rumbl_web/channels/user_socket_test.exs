defmodule RumblWeb.Chanels.UserSocketTest do
  use RumblWeb.ChannelCase, async: true
  alias RumblWeb.UserSocket

  test "socket authenticatrion with valid token" do 
    token = Phoenix.Token.sign(@endpoint, "user socket", "123")

    assert {:ok, socket} = connect(UserSocket, %{"token" => token})
    assert socket.assigns.user_id == "123"
  end

  test "socket authenticatrion with invalid token" do
    assert :error = connect(UserSocket, %{"token" => "123"})
    assert :error = connect(UserSocket, %{})
  end
end
