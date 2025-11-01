defmodule CltVsPjTest do
  use ExUnit.Case
  doctest CltVsPj

  test "vacation calculation" do
    assert CltVsPj.calculate_vacation(3000) == 4000.0
    assert CltVsPj.calculate_vacation(1500) == 2000.0

    assert CltVsPj.calculate_vacation(0) == 0.0
    assert CltVsPj.calculate_vacation(-100) == 0.0
  end

  test "calculation of 13th salary" do
    assert CltVsPj.calculate_13th_salary(3000) == 6000.0;

    assert CltVsPj.calculate_13th_salary(0) == 0.0
    assert CltVsPj.calculate_13th_salary(-500) == 0.0
    assert CltVsPj.calculate_13th_salary("text") == 0.0
    assert CltVsPj.calculate_13th_salary(nil) == 0.0
    assert CltVsPj.calculate_13th_salary(2500) == 5000.0
    assert CltVsPj.calculate_13th_salary(:test) == 0.0
  end

  test "calculation of progressive INSS" do
    # Teste na primeira faixa (até R$ 1.412,00)
    assert_in_delta CltVsPj.calculate_inss(1000.00), 75.00, 0.01

    # Teste exatamente no limite da primeira faixa
    assert_in_delta CltVsPj.calculate_inss(1412.00), 105.90, 0.01

    # Teste na segunda faixa (R$ 2.000,00)
    # Primeira faixa: R$ 1.412,00 * 0.075 = R$ 105,90
    # Segunda faixa: (R$ 2.000,00 - R$ 1.412,01) * 0.09 = R$ 587,99 * 0.09 = R$ 52,92
    # Total: R$ 105,90 + R$ 52,92 = R$ 158,82
    assert_in_delta CltVsPj.calculate_inss(2000.00), 158.82, 0.01

    # Teste na terceira faixa (R$ 3.000,00)
    # Primeira faixa: R$ 1.412,00 * 0.075 = R$ 105,90
    # Segunda faixa: (R$ 2.666,68 - R$ 1.412,01) * 0.09 = R$ 1.254,67 * 0.09 = R$ 112,92
    # Terceira faixa: (R$ 3.000,00 - R$ 2.666,69) * 0.12 = R$ 333,31 * 0.12 = R$ 40,00
    # Total: R$ 105,90 + R$ 112,92 + R$ 40,00 = R$ 258,82
    assert_in_delta CltVsPj.calculate_inss(3000.00), 258.82, 0.01

    # Teste acima do teto (R$ 8.000,00 - deve calcular apenas até o teto)
    max_inss = CltVsPj.calculate_inss(7786.02)
    assert_in_delta CltVsPj.calculate_inss(8000.00), max_inss, 0.01

    # Teste com entrada inválida
    assert CltVsPj.calculate_inss(0) == 0.0
    assert CltVsPj.calculate_inss(-100) == 0.0
    assert CltVsPj.calculate_inss("text") == 0.0
  end

  test "tax scenario pattern matching" do
    {category, description, tax} = CltVsPj.tax_scenario(1000.00)
    assert category == :primeira_faixa
    assert is_binary(description)
    assert is_number(tax)

    {category, _, _} = CltVsPj.tax_scenario(2000.00)
    assert category == :segunda_faixa

    {category, _, _} = CltVsPj.tax_scenario(3000.00)
    assert category == :terceira_faixa

    {category, _, _} = CltVsPj.tax_scenario(5000.00)
    assert category == :quarta_faixa

    {category, _, _} = CltVsPj.tax_scenario(10000.00)
    assert category == :teto_inss
  end

  test "calculation of FGTS" do
    assert CltVsPj.calculate_fgts(3000) == 240.0
    assert CltVsPj.calculate_fgts(1500) == 120.0
    assert CltVsPj.calculate_fgts(0) == 0.0
    assert CltVsPj.calculate_fgts(-100) == 0.0
  end

  test "discount calculation" do
    total = CltVsPj.calculate_discount(5000)
    assert total == 918.82
  end
end
