defmodule Rumbl.TestHelpers do
  alias Rumbl.{
    Accounts,
    Multimedia
  }

  def user_fixture(attrs \\ %{}) do
    {:ok, user} = 
      attrs =  Enum.into(attrs, %{
        name: "some name",
        username: "user#{System.unique_integer([:positive])}",
        password: attrs[:password] || "supersecret" })
        |> Accounts.register_user()

    user
  end

  def videos_fixture(%Accounts.User{} = user, attrs \\ %{}) do
      attrs = Enum.into(attrs, %{
        description: "some description",
        title: "some title",
        url: "some url"
      })

    {:ok, videos} =Rumbl.Multimedia.create_videos(user, attrs)

    videos
  end

end
