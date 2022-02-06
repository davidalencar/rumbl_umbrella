defmodule RumblWeb.VideosController do
  use RumblWeb, :controller

  alias Rumbl.Multimedia
  alias Rumbl.Multimedia.Videos

  plug :load_categories when action in [:new, :create, :edit, :update] 

  def action(conn, _) do
    args = [conn,conn.params,  conn.assigns.current_user]
    apply(__MODULE__, action_name(conn), args)
  end

  def index(conn, _params, current_user ) do
    videos = Multimedia.list_user_videos(current_user)
    render(conn, "index.html", videos: videos)
  end

  def new(conn, _params, _current_user) do
    changeset = Multimedia.change_videos(%Videos{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"videos" => videos_params}, current_user) do
    case Multimedia.create_videos(current_user, videos_params) do
      {:ok, videos} ->
        conn
        |> put_flash(:info, "Videos created successfully.")
        |> redirect(to: Routes.videos_path(conn, :show, videos))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}, current_user) do
    videos = Multimedia.get_user_video(current_user, id)
    render(conn, "show.html", videos: videos)
  end

  def edit(conn, %{"id" => id}, current_user) do
    videos = Multimedia.get_user_video(current_user, id)
    changeset = Multimedia.change_videos(videos)
    render(conn, "edit.html", videos: videos, changeset: changeset)
  end

  def update(conn, %{"id" => id, "videos" => videos_params}, current_user) do
    videos = Multimedia.get_user_video(current_user, id)

    case Multimedia.update_videos(videos, videos_params) do
      {:ok, videos} ->
        conn
        |> put_flash(:info, "Videos updated successfully.")
        |> redirect(to: Routes.videos_path(conn, :show, videos))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", videos: videos, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}, current_user) do
    videos = Multimedia.get_user_video(current_user, id)
    {:ok, _videos} = Multimedia.delete_videos(videos)

    conn
    |> put_flash(:info, "Videos deleted successfully.")
    |> redirect(to: Routes.videos_path(conn, :index))
  end

  defp load_categories(conn, _) do
    conn
    |> assign(:categories, Multimedia.list_alphabetical_categories())
  end
end
