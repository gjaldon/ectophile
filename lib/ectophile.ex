defmodule Ectophile do

  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__), only: [attachment_fields: 1]
      @before_compile Ectophile

      Module.register_attribute(__MODULE__, :ectophile_fields, accumulate: true)
    end
  end

  defmacro attachment_fields(name, opts \\ []) do
    filename_field = :"#{name}_filename"
    upload_field   = :"#{name}_upload"
    upload_path    = opts[:upload_path] || "#{name}/uploads"
    ectophile_fields = %{
      filepath: name,
      filename: filename_field,
      upload: upload_field,
      upload_path: upload_path
    }
    ectophile_fields = Macro.escape(ectophile_fields)

    quote bind_quoted: binding do
      Ecto.Schema.field(name)
      Ecto.Schema.field(filename_field)
      Ecto.Schema.field(upload_field, :any, virtual: true)

      @ectophile_fields ectophile_fields
    end
  end

  def static_path(filepath) do
    "/" <> Path.relative_to(filepath, "/priv/static")
  end


  import Ecto.Changeset

  def put_file(changeset, file_fields) do
    %{upload_path: upload_path} = file_fields

    if upload = get_change(changeset, file_fields.upload) do
      %{path: tmp_path, filename: filename} = upload
      file_id  = generate_file_id()
      filepath = priv_path(upload_path, file_id, filename)
      File.cp!(tmp_path, filepath)
      File.cp!(tmp_path, build_priv_path(upload_path, file_id, filename))

      changeset
      |> put_change(file_fields.filename, filename)
      |> put_change(file_fields.filepath, "/" <> filepath)
    else
      changeset
    end
  end

  # TODO: Fix rm_file!

  def rm_file(%{model: model} = changeset, file_fields) do
    new_filepath = get_change(changeset, file_fields.filepath)
    old_filepath = Map.get(model, file_fields.filepath)

    if new_filepath && old_filepath do
      File.rm!(old_filepath)
      File.rm!(build_priv_path(old_filepath))
    end
    changeset
  end

  defp generate_file_id() do
    :crypto.strong_rand_bytes(30) |> Base.encode16(case: :lower) |> binary_part(0,30)
  end

  def priv_path(upload_path) do
    Path.join(["priv/static", upload_path])
  end

  defp priv_path(upload_path, file_id, filename) do
    file_id = file_id <> Path.extname(filename)
    Path.join(["priv/static", upload_path, file_id])
  end

  def build_priv_path(filepath) do
    Application.app_dir(otp_app(), filepath)
  end

  def build_priv_path(upload_path, file_id, filename) do
    file_id = file_id <> Path.extname(filename)
    Application.app_dir(otp_app(), Path.join(["priv/static", upload_path, file_id]))
  end

  defp otp_app do
    Application.get_env(:ectophile, :otp_app) || raise ":otp_app key required for :ectophile env"
  end

  defmacro __before_compile__(env) do
    ectophile_fields = Module.get_attribute(env.module, :ectophile_fields)

    callbacks =
      for file_fields <- ectophile_fields do
        file_fields = Macro.escape(file_fields)

        quote do
          before_insert Ectophile, :put_file, [unquote(file_fields)]
          before_insert Ectophile, :rm_file,  [unquote(file_fields)]
        end
      end

    quote do
      unquote(callbacks)
      Module.eval_quoted __ENV__, [Ectophile.helpers(unquote(Macro.escape(ectophile_fields)))]
    end
  end

  def helpers(ectophile_fields) do
    quote do
      def ensure_upload_paths_exist do
        Ectophile.ensure_upload_paths_exist(unquote(Macro.escape(ectophile_fields)))
      end
    end
  end

  def ensure_upload_paths_exist(ectophile_fields) do
    for %{upload_path: upload_path} <- ectophile_fields do
      priv_path = priv_path(upload_path)
      build_priv_path = build_priv_path(upload_path)

      unless File.exists?(priv_path) do
        File.mkdir_p!(priv_path)
      end

      unless File.exists?(build_priv_path) do
        File.mkdir_p!(build_priv_path)
      end
    end
  end
end
