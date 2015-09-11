Ectophile
========

Ectophile is an extension for Ecto models to instantly support file uploads.

## Usage

`Ectophile` provides an `attachment_fields/2` macro for your model which is used like:

```elixir
defmodule MyApp.User do
  use Ectophile  #=> Note that this needs to be used before MyApp.Web so that the callbacks will work
  use MyApp.Web, :model

  schema "users" do
    field :email, :string

    attachment_fields :avatar
    timestamps
  end

  ...
end
```

`attachment_fields/2` in the above example, defines three different fields which are:

  - `field :avatar, :string`
  - `field :avatar_filename, :string`
  - `field :avatar_upload, :any, virtual: true`

The `:avatar` field is where the path to the file in your filesystem is saved and `:avatar_upload` is the field we'll use for file uploads.

Keep in mind that you will need to create the necessary `migration` to add the `Ectophile` fields to your model.

In your application's top-level supervisor's `start/2` function, add the following to setup the directories where your files will be uploaded:

```elixir
import Ectophile.Helpers

def start(_type, _args) do
  ensure_upload_paths_exist([MyApp.User]) #=> This creates all the required directories for your uploaded files
  ...
end
```

After doing the migrations and defining your model's `attachment_fields`, you can then add file upload field to your model's form like:

```html
...

<div class="form-group">
  <%= label f, :avatar_upload, "Avatar" %>
  <%= file_input f, :avatar_upload, class: "form-control" %>
</div>

...
```

That's it!!! Now every time a user uploads a file and submits a form, that file is stored in a configurable location in your `priv/static` directory and a reference to that file is stored in your database.

In your template, you can then do:

```html
<img alt="<%= @user.avatar %>" src="<%= static_path(@conn, Ectophile.Helpers.static_path(avatar)) %>">
```

## Important links

  * Documentation - to be published
  * [License](https://github.com/gjaldon/ectophile/blob/master/LICENSE)
