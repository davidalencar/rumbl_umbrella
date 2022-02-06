defmodule RumblWeb.AnnotationView do
  use RumblWeb, :view

  def render("annotation.json", %{annotation: ant}) do
    %{
      id: ant.id,
      body: ant.body,
      at: ant.at,
      user: render_one(ant.user, RumblWeb.UserView, "user.json")
    }
  end
  
end
