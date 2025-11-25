defmodule IrrfTest do
  use ExUnit.Case
  doctest CltVsPj

  test "IRRF calculation with no dependents - below threshold" do
    # Salary below IRRF threshold (R$ 2,259.20)
    assert CltVsPj.calculate_irrf(2000.00, 0) == 0.0
  end

  test "IRRF calculation with no dependents - first bracket" do
    # Salary R$ 3,000.00
    # INSS: ~R$ 253.41
    # Taxable base: 3000 - 253.41 = 2,746.59
    # IRRF: (2,746.59 * 0.075) - 169.44 = 206.00 - 169.44 = 36.56
    assert_in_delta CltVsPj.calculate_irrf(3000.00, 0), 36.56, 0.50
  end

  test "IRRF calculation with no dependents - second bracket" do
    # Salary R$ 4,000.00
    # INSS: ~R$ 422.95
    # Taxable base: 4000 - 422.95 = 3,577.05
    # IRRF: (3,577.05 * 0.15) - 381.44 = 536.56 - 381.44 = 155.12
    assert_in_delta CltVsPj.calculate_irrf(4000.00, 0), 162.55, 1.00
  end

  test "IRRF calculation with no dependents - third bracket" do
    # Salary R$ 5,000.00
    # INSS: ~R$ 509.60
    # Taxable base: 5000 - 509.60 = 4,490.40
    # IRRF: (4,490.40 * 0.225) - 662.77 = 1,010.34 - 662.77 = 347.57
    assert_in_delta CltVsPj.calculate_irrf(5000.00, 0), 347.57, 1.00
  end

  test "IRRF calculation with no dependents - fourth bracket" do
    # Salary R$ 8,000.00
    # INSS: ~R$ 908.85 (capped)
    # Taxable base: 8000 - 908.85 = 7,091.15
    # IRRF: (7,091.15 * 0.275) - 896.00 = 1,950.07 - 896.00 = 1,054.07
    assert_in_delta CltVsPj.calculate_irrf(8000.00, 0), 1048.36, 2.00
  end

  test "IRRF calculation with 1 dependent" do
    # Salary R$ 5,000.00 with 1 dependent
    # INSS: ~R$ 509.60
    # Deduction per dependent: R$ 189.59
    # Taxable base: 5000 - 509.60 - 189.59 = 4,300.81
    # IRRF: (4,300.81 * 0.225) - 662.77 = 967.68 - 662.77 = 304.91
    assert_in_delta CltVsPj.calculate_irrf(5000.00, 1), 304.91, 1.00
  end

  test "IRRF calculation with 2 dependents" do
    # Salary R$ 5,000.00 with 2 dependents
    # INSS: ~R$ 509.60
    # Deduction per dependent: R$ 189.59 * 2 = R$ 379.18
    # Taxable base: 5000 - 509.60 - 379.18 = 4,111.22
    # IRRF: (4,111.22 * 0.225) - 662.77 = 925.02 - 662.77 = 262.25
    assert_in_delta CltVsPj.calculate_irrf(5000.00, 2), 262.25, 1.00
  end

  test "IRRF calculation with dependents reducing to zero" do
    # Low salary with many dependents should result in 0 IRRF
    assert CltVsPj.calculate_irrf(2500.00, 5) == 0.0
  end

  test "IRRF calculation with invalid inputs" do
    assert CltVsPj.calculate_irrf(0, 0) == 0.0
    assert CltVsPj.calculate_irrf(-1000, 0) == 0.0
    assert CltVsPj.calculate_irrf("invalid", 0) == 0.0
    assert CltVsPj.calculate_irrf(nil, 0) == 0.0
  end
end
