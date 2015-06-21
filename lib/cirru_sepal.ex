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

  defp mapAst(expr) when is_list expr do
    headItem = hd expr
    tailList = tl expr
    cond do
      is_list headItem ->
        headExpr = mapAst headItem
        {headExpr, [], (Enum.map tailList, &mapAst/1)}
      headItem == "[]" -> Enum.map tailList, &mapAst/1
      headItem == "{}" -> {:{}, [], (Enum.map tailList, &mapAst/1)}
      headItem == "%{}" -> createMapFromPairs %{}, tailList
      headItem == "do" -> doSyntax tailList
      headItem == "." ->
        target = mapAst (hd tailList)
        name = String.to_atom (List.last tailList)
        {:., [], [target, name]}
      true -> {(String.to_atom headItem), [], (Enum.map tailList, &mapAst/1)}
    end
  end

  defp mapAst(token) when is_binary token do
    cond do
      String.first(token) == "@" -> String.slice token, 1..-1
      String.first(token) == ":" -> String.to_atom (String.slice token, 1..-1)
      Regex.match? ~r/^[+-]?\d+$/, token -> String.to_integer token
      Regex.match? ~r/^[+-]?\d+\.\d+$/, token -> String.to_float token
      Regex.match? ~r/^\w[\w\d]*$/, token -> {String.to_atom(token), [], Elixir}
      Regex.match? ~r/^~/, token -> Regex.compile! (String.slice token, 1..-1)
      true -> raise ("can not parse: " <> token)
    end
  end

  defp createMapFromPairs(base, pairs) when pairs == [] do base end

  defp createMapFromPairs(base, pairs) do
    cursor = hd pairs
    key = mapAst (hd cursor)
    value = mapAst (List.last cursor)
    newMap = Dict.put_new base, key, value
    createMapFromPairs newMap, (tl pairs)
  end

  defp doSyntax(args) when args == [] do
    [do: nil]
  end

  defp doSyntax(args) when (length args) == 1 do
    arg = hd args
    [do: (mapAst arg)]
  end

  defp doSyntax(args) when (length args) == 1 do
    params = Enum.map args, &mapAst/1
    [do: {:__block__, [], params}]
  end

end
