defmodule RumblWeb.VideosChannelTest do
  use RumblWeb.ChannelCase
  import RumblWeb.TestHelpers

  setup do
    user = insert_user(name: "Gary")
    video = insert_video(user, title: "Testing")
    token = Phoenix.Token.sign(@endpoint, "user socket", user.id)

    {:ok, socket} = connect(RumblWeb.UserSocket, %{"token" => token})

    {:ok, socket: socket, user: user, video: video}
  end

  test "join replies with video annotations", %{socket: socket, user: user, video: video} do
    for body <- ~w(one two) do
      Rumbl.Multimedia.annotate_video(user, video.id, %{body: body, at: 0})
    end

    {:ok, reply, socket} = subscribe_and_join(socket, "videos:#{video.id}", %{})

    assert socket.assigns.video_id == video.id
    assert %{annotations: [%{body: "one"}, %{body: "two"}]} = reply
  end

  test "insertig new annnotatios", %{socket: socket, video: video} do
    {:ok,_, socket} = subscribe_and_join(socket, "videos:#{video.id}", %{})

    ref = push(socket,"new_annotation", %{body: "the body", at: 0})
    assert_reply(ref, :ok, %{})
    assert_broadcast("new_annotation", %{})
  end
end
