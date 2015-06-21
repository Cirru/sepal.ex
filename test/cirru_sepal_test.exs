defmodule CirruSepalTest do
  use ExUnit.Case
  require CirruSepal

  test "the truth" do
    assert 1 + 1 == 2
  end

  test "transform code" do
    sourceFile = "test/examples/demo.cirru"
    targetFile = "test/compiled/demo.ex"
    {_, code} = File.read sourceFile
    compiled = CirruSepal.transform code, sourceFile
    {:ok, file} = File.open targetFile, [:write]
    IO.binwrite file, compiled
    File.close file
  end
end
