defmodule RumblWeb.VideosChannelTest do
  use RumblWeb.ChannelCase

  setup do
    {:ok, _, socket} =
      RumblWeb.UserSocket
      |> socket("user_id", %{some: :assign})
      |> subscribe_and_join(RumblWeb.VideosChannel, "videos:lobby")

    %{socket: socket}
  end

end
