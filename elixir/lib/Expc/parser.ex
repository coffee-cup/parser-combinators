defmodule Expc.Parser do
  @moduledoc """
  Parser module...
  """

  @doc """
  Binds to parsers together
  """
  def bind(p1, f) do
    fn inp ->
      case p1.(inp) do
        [{s, rest}] -> [{f.(s), rest}]
        _ -> []
      end
    end
  end

  @doc """
  Parses a single item from the input string

  ## Examples

      iex> Expc.Parser.item().("abc")
      [{"a", "bc"}]

      iex> Expc.Parser.item().("")
      []
  """
  def item() do
    fn inp ->
      case String.slice(inp, 0..0) do
        "" -> []
        s -> [{s, String.slice(inp, 1..-1)}]
      end
    end
  end

  @doc """
  Parses an item from the input if predicate `p` is true
  """
  def satisfy(p) when is_function(p)  do
    fn inp ->
      [{c, rest}] = item().(inp)
      if p.(c) do
        [{c, rest}]
      else
        []
      end
    end
  end

end