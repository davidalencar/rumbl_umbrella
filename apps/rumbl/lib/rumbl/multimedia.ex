defmodule Rumbl.Multimedia do
  @moduledoc """
  The Multimedia context.
  """

  import Ecto.Query, warn: false
  alias Rumbl.Repo

  alias Rumbl.Multimedia.Videos
  alias Rumbl.Multimedia.Category
  alias Rumbl.Multimedia.Annotation
  alias Rumbl.Accounts.User

  @doc """
  Returns the list of videos.

  ## Examples

      iex> list_videos()
      [%Videos{}, ...]

  """
  def list_videos do
    Repo.all(Videos)
  end

  @doc """
  Gets a single videos.

  Raises `Ecto.NoResultsError` if the Videos does not exist.

  ## Examples

      iex> get_videos!(123)
      %Videos{}

      iex> get_videos!(456)
      ** (Ecto.NoResultsError)

  """
  def get_videos!(id), do: Repo.get!(Videos, id)

  @doc """
  Creates a videos.

  ## Examples

      iex> create_videos(%{field: value})
      {:ok, %Videos{}}

      iex> create_videos(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_videos(%Rumbl.Accounts.User{} = user, attrs \\ %{}) do
    %Videos{}
    |> Videos.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:user, user)
    |> Repo.insert()
  end

  @doc """
  Updates a videos.

  ## Examples

      iex> update_videos(videos, %{field: new_value})
      {:ok, %Videos{}}

      iex> update_videos(videos, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_videos(%Videos{} = videos, attrs) do
    videos
    |> Videos.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a videos.

  ## Examples

      iex> delete_videos(videos)
      {:ok, %Videos{}}

      iex> delete_videos(videos)
      {:error, %Ecto.Changeset{}}

  """
  def delete_videos(%Videos{} = videos) do
    Repo.delete(videos)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking videos changes.

  ## Examples

      iex> change_videos(videos)
      %Ecto.Changeset{data: %Videos{}}

  """
  def change_videos(%Videos{} = videos, attrs \\ %{}) do
    Videos.changeset(videos, attrs)
  end


  
  def list_user_videos(%Rumbl.Accounts.User{} = user) do
    Videos
    |> user_videos_query(user)
    |> Repo.all()
  end

  def get_user_video(%Rumbl.Accounts.User{} = user, id) do
    Videos
    |> user_videos_query(user)
    |> Repo.get!(id)
  end


  def user_videos_query(query, %Rumbl.Accounts.User{id: user_id}) do
    from(v in query, where: v.user_id == ^user_id)
  end

  def create_category!(name) do
    Repo.insert!(%Category{name: name}, on_conflict: :nothing)
  end

  def list_alphabetical_categories() do
    Category
    |> Category.alphabetical()
    |> Repo.all()
  end


  def annotate_video(%User{id: user_id}, video_id, attrs) do
    %Annotation{videos_id: video_id, user_id: user_id}
    |> Annotation.changeset(attrs)
    |> Repo.insert()
  end


  def list_annotations(%Videos{} = video, since_id \\ 0) do
    Repo.all(
      from a in Ecto.assoc(video, :annotations), 
      where: a.id > ^since_id,
      order_by: [asc: a.at, asc: a.id],
      limit: 500,
      preload: [:user]
    )
  end
end
