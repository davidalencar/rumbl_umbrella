defmodule VideosControllerTest do
  use RumblWeb.ConnCase, async: true



  test "require user authentication on all actions", %{conn: conn} do
    [get(conn, Routes.videos_path(conn, :new)),
      get(conn, Routes.videos_path(conn, :index)),
      get(conn, Routes.videos_path(conn, :show, "123")),
      get(conn, Routes.videos_path(conn, :edit, "123")),
      put(conn, Routes.videos_path(conn, :update, "123", %{})),
      post(conn, Routes.videos_path(conn, :create, %{})),
      delete(conn, Routes.videos_path(conn, :delete, "123"))]
      |> Enum.each(fn conn ->
        assert html_response(conn, 302)
        assert conn.halted
      end)
  end
  

  describe "with logged-in user" do

    setup %{conn: conn, login_as: username} do
      user = user_fixture(usernme: username)
      conn = assign(conn, :current_user, user)

      {:ok, conn: conn, user: user}
    end

    @tag login_as: "max"
    test "list all user's videos on index", %{conn: conn, user: user} do
      user_video = videos_fixture(user, %{title: "funny cats"})
      other_video = videos_fixture(user_fixture(username: "other"), title: "another video")

      conn = get(conn, Routes.videos_path(conn, :index))
      assert html_response(conn, 200) =~ ~r/Listing Videos/
      assert String.contains?(conn.resp_body, user_video.title)
      refute  String.contains?(conn.resp_body, other_video.title)
    end
  end
end
