defmodule RumblWeb.UserController do
  use RumblWeb, :controller

  alias Rumbl.Accounts

  plug :authenticate_user when action in [:index, :show]

  def index(conn, _params) do
    render(conn, "index.html", users: Accounts.list_users())
  end

  def show(conn, %{"id" => id}) do
    render(conn, "show.html", user: Accounts.get_user(id))
  end

  def new(conn, _params) do 
    chengeset = Accounts.change_registration(%Accounts.User{}, %{})
    render(conn, "new.html", changeset: chengeset)
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        conn
        |> RumblWeb.Auth.login(user)
        |> put_flash(:info, "#{user.name} created!")
        |> redirect(to: Routes.user_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
          |> render("new.html", changeset: changeset)
    end
  end

end
