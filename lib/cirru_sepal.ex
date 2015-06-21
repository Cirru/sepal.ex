defmodule CirruSepal do
  require CirruParser

  def transform(code, filename) do
    ast = CirruParser.pare code, filename
    IO.inspect ast
    args = Enum.map ast, fn(x) -> mapAst x end
    compiledAst = {:__block__, [], args}
    IO.inspect compiledAst
    Macro.to_string compiledAst
  end

  defp context do
    [context: Elixir, import: Kernel]
  end

  defp mapAst(expr) when is_list expr do
    headItem = hd expr
    tailList = Enum.map (tl expr), fn(x) -> mapAst x end
    {(String.to_atom headItem), context, tailList}
  end

  defp mapAst(token) when is_binary token do
    cond do
      String.first(token) == "@" -> String.slice token, 1..-1
      String.first(token) == ":" -> String.to_atom (String.slice token, 1..-1)
      Regex.match? ~r/^\d+$/, token -> String.to_integer token
      Regex.match? ~r/^\d+\.\d+$/, token -> String.to_float token
      Regex.match? ~r/^\w[\w\d]*$/, token -> {String.to_atom(token), [], Elixir}
      true -> raise ("can not parse: " <> token)
    end
  end

end
